
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>
#include <sys/errno.h>
#include <stdlib.h>
#include <pthread.h>

#include "scheduler.h"
#include "virtmem.h"
#include "msg.h"
#include "queue.h"

static volatile sig_atomic_t keep_running = 1;

static volatile int had_connections = 0;
static volatile int idle_check_counter = 0;

static uint32_t current_time_ms = 0;
static pthread_mutex_t time_mutex = PTHREAD_MUTEX_INITIALIZER;

static queue_t command_queue = QUEUE_INIT;
static queue_t ready_queue = QUEUE_INIT;
static queue_t blocked_queue = QUEUE_INIT;
static queue_t mlfq_queues[NUM_MLFQ_QUEUES];

static pcb_t *CPUs[MAX_CPUS];
static pthread_mutex_t cpu_mutexes[MAX_CPUS];

static frame_table_t *frame_table;
static swap_hash_t swap;
static int num_pages = 20;
static int num_frames = 30;
static int min_pages_threshold = 4;
static int num_cpus = 1;
static pthread_mutex_t memory_mutex = PTHREAD_MUTEX_INITIALIZER;

static pthread_t command_thread;
static pthread_t blocked_thread;
static pthread_t timer_thread;
static pthread_t cpu_threads[MAX_CPUS];
static int cpu_ids[MAX_CPUS];

static int server_fd = -1;

void handle_signal(int sig) {
    printf("\n[Signal] Caught signal %d — stopping scheduler...\n", sig);
    keep_running = 0;

    queue_broadcast(&ready_queue);
    queue_broadcast(&command_queue);
    queue_broadcast(&blocked_queue);
    for (int i = 0; i < NUM_MLFQ_QUEUES; i++) {
        queue_broadcast(&mlfq_queues[i]);
    }
}

void trigger_shutdown(const char* reason) {
    printf("\n[Auto-Shutdown] %s\n", reason);
    keep_running = 0;

    queue_broadcast(&ready_queue);
    queue_broadcast(&command_queue);
    queue_broadcast(&blocked_queue);
    for (int i = 0; i < NUM_MLFQ_QUEUES; i++) {
        queue_broadcast(&mlfq_queues[i]);
    }
}


uint32_t get_current_time(void) {
    pthread_mutex_lock(&time_mutex);
    uint32_t t = current_time_ms;
    pthread_mutex_unlock(&time_mutex);
    return t;
}

void advance_time(uint32_t ms) {
    pthread_mutex_lock(&time_mutex);
    current_time_ms += ms;
    pthread_mutex_unlock(&time_mutex);
}

void* timer_worker(void* arg) {
    (void)arg;

    printf("[Timer Worker] Started\n");

    while (keep_running) {
        usleep(TICKS_MS * 1000);
        advance_time(TICKS_MS);

        uint32_t t = get_current_time();
        if (t % 1000 == 0 && !is_clean()) {
            printf("[Timer] Simulation time: %u ms (%u s)\n", t, t/1000);
        }
    }

    printf("[Timer Worker] Stopped\n");
    return NULL;
}

void* command_worker(void* arg) {
    (void)arg;

    printf("[Command Worker] Started\n");

    while (keep_running) {
        uint32_t t = get_current_time();

        pthread_mutex_lock(&memory_mutex);
        pthread_mutex_lock(&command_queue.mutex);
        pthread_mutex_lock(&blocked_queue.mutex);
        pthread_mutex_lock(&ready_queue.mutex);

        int had_processes_before = get_processes_completed();

        check_new_commands(&command_queue, &blocked_queue, &ready_queue,
                          server_fd, t, frame_table, &swap);

        if (get_processes_completed() > had_processes_before || command_queue.head != NULL ||
            ready_queue.head != NULL || blocked_queue.head != NULL) {
            had_connections = 1;
        }

        if (ready_queue.head != NULL) {
            pthread_cond_broadcast(&ready_queue.not_empty);
        }

        int all_queues_empty = (command_queue.head == NULL &&
                                ready_queue.head == NULL &&
                                blocked_queue.head == NULL);

        pthread_mutex_unlock(&ready_queue.mutex);
        pthread_mutex_unlock(&blocked_queue.mutex);
        pthread_mutex_unlock(&command_queue.mutex);
        pthread_mutex_unlock(&memory_mutex);

        int mlfq_empty = 1;
        for (int i = 0; i < NUM_MLFQ_QUEUES && mlfq_empty; i++) {
            pthread_mutex_lock(&mlfq_queues[i].mutex);
            if (mlfq_queues[i].head != NULL) mlfq_empty = 0;
            pthread_mutex_unlock(&mlfq_queues[i].mutex);
        }

        int cpus_idle = 1;
        for (int i = 0; i < num_cpus && cpus_idle; i++) {
            pthread_mutex_lock(&cpu_mutexes[i]);
            if (CPUs[i] != NULL) cpus_idle = 0;
            pthread_mutex_unlock(&cpu_mutexes[i]);
        }

        if (had_connections && all_queues_empty && mlfq_empty && cpus_idle &&
            get_processes_completed() > 0) {
            idle_check_counter++;
            if (idle_check_counter >= 10) {
                trigger_shutdown("All applications have finished - simulation complete!");
                break;
            }
        } else {
            idle_check_counter = 0;
        }

        usleep(TICKS_MS * 500);
    }

    printf("[Command Worker] Stopped\n");
    return NULL;
}

void* blocked_worker(void* arg) {
    (void)arg;

    printf("[Blocked Worker] Started\n");

    while (keep_running) {
        uint32_t t = get_current_time();

        pthread_mutex_lock(&command_queue.mutex);
        pthread_mutex_lock(&blocked_queue.mutex);

        check_blocked_queue(&blocked_queue, &command_queue, t);

        pthread_mutex_unlock(&blocked_queue.mutex);
        pthread_mutex_unlock(&command_queue.mutex);

        usleep(TICKS_MS * 500);
    }

    printf("[Blocked Worker] Stopped\n");
    return NULL;
}

void* cpu_worker(void* arg) {
    int cpu_id = *(int*)arg;

    printf("[CPU %d] worker iniciado\n", cpu_id);

    pcb_t *prev_task = NULL;

    while (keep_running) {
        uint32_t t = get_current_time();
        pcb_t *task = NULL;

        pthread_mutex_lock(&cpu_mutexes[cpu_id]);
        task = CPUs[cpu_id];
        if (task != NULL) {
            goto execute_task;
        }
        pthread_mutex_unlock(&cpu_mutexes[cpu_id]);

        if (get_sched_algo() == ALGO_MLFQ) {
            pthread_mutex_lock(&ready_queue.mutex);
            for (int i = 0; i < NUM_MLFQ_QUEUES; i++) {
                pthread_mutex_lock(&mlfq_queues[i].mutex);
            }

            task = NULL;
            while (task == NULL && keep_running) {
                drain_ready_into_mlfq(&ready_queue, mlfq_queues);
                task = dequeue_mlfq(mlfq_queues);

                if (task == NULL && keep_running) {
                    for (int i = NUM_MLFQ_QUEUES - 1; i >= 0; i--) {
                        pthread_mutex_unlock(&mlfq_queues[i].mutex);
                    }
                    pthread_cond_wait(&ready_queue.not_empty, &ready_queue.mutex);
                    for (int i = 0; i < NUM_MLFQ_QUEUES; i++) {
                        pthread_mutex_lock(&mlfq_queues[i].mutex);
                    }
                }
            }

            for (int i = NUM_MLFQ_QUEUES - 1; i >= 0; i--) {
                pthread_mutex_unlock(&mlfq_queues[i].mutex);
            }
            pthread_mutex_unlock(&ready_queue.mutex);
        } else {
            pthread_mutex_lock(&ready_queue.mutex);

            while (ready_queue.head == NULL && keep_running) {
                pthread_cond_wait(&ready_queue.not_empty, &ready_queue.mutex);
            }

            if (!keep_running) {
                pthread_mutex_unlock(&ready_queue.mutex);
                break;
            }

            task = dequeue_pcb(&ready_queue);
            pthread_mutex_unlock(&ready_queue.mutex);
        }

        if (!task) continue;

        pthread_mutex_lock(&cpu_mutexes[cpu_id]);
        CPUs[cpu_id] = task;
        task->slice_start_ms = t;
        task->slice_used_ms = 0;

execute_task:
        {
            pcb_t *cur = CPUs[cpu_id];
            if (cur) {
                uint32_t tnow = get_current_time();

                if (cur != prev_task) {
                    prev_task = cur;
                    if (!is_clean()) {
                        printf("[t=%ums] CPU%d <- P%d (burst %u ms, prioridade %u)\n",
                               tnow, cpu_id, cur->pid, cur->time_ms, cur->priority);
                    } else {
                        if (cur->time_ms > 300) {
                            printf("[t=%ums] CPU%d <- P%d (%u ms)\n", tnow, cpu_id, cur->pid, cur->time_ms);
                        }
                    }
                }

                if (!cur->ran_once) {
                    cur->ran_once = 1;
                    cur->first_run_time_ms = tnow;
                    cur->response_time_ms = (tnow >= cur->arrival_time_ms)
                                            ? (tnow - cur->arrival_time_ms) : 0;
                }

                pthread_mutex_lock(&memory_mutex);
                for (uint32_t i = 0; i < cur->requested_pages.count; i++) {
                    int vfn = cur->requested_pages.ids[i];
                    int is_dirty = 0;
                    if (vfn < 0) { is_dirty = 1; vfn = -vfn; }

                    page_eviction(frame_table, &swap, min_pages_threshold, tnow);
                    pte_t *vp = page_request(cur, frame_table, &swap, vfn, tnow);
                    if (vp) {
                        vp->referenced = 1;
                        vp->present = 1;
                        vp->last_accessed = tnow;
                        if (is_dirty) vp->dirty = 1;
                    }
                }
                pthread_mutex_unlock(&memory_mutex);
            }
        }

        usleep(TICKS_MS * 1000);

        t = get_current_time();

        pthread_mutex_lock(&command_queue.mutex);
        pthread_mutex_lock(&ready_queue.mutex);

        if (get_sched_algo() == ALGO_MLFQ) {
            for (int i = 0; i < NUM_MLFQ_QUEUES; i++) {
                pthread_mutex_lock(&mlfq_queues[i].mutex);
            }

            drain_ready_into_mlfq(&ready_queue, mlfq_queues);
            scheduler_mlfq(t, mlfq_queues, &command_queue, &CPUs[cpu_id]);

            for (int i = NUM_MLFQ_QUEUES - 1; i >= 0; i--) {
                pthread_mutex_unlock(&mlfq_queues[i].mutex);
            }
        } else if (get_sched_algo() == ALGO_FIFO) {
            scheduler_fifo(t, &ready_queue, &command_queue, &CPUs[cpu_id]);
        } else {
            scheduler(t, &ready_queue, &command_queue, &CPUs[cpu_id]);
        }

        int has_tasks = (ready_queue.head != NULL);
        if (get_sched_algo() == ALGO_MLFQ) {
            for (int i = 0; i < NUM_MLFQ_QUEUES && !has_tasks; i++) {
                pthread_mutex_lock(&mlfq_queues[i].mutex);
                has_tasks = (mlfq_queues[i].head != NULL);
                pthread_mutex_unlock(&mlfq_queues[i].mutex);
            }
        }
        if (has_tasks) {
            pthread_cond_broadcast(&ready_queue.not_empty);
        }

        pthread_mutex_unlock(&ready_queue.mutex);
        pthread_mutex_unlock(&command_queue.mutex);
        pthread_mutex_unlock(&cpu_mutexes[cpu_id]);
    }

    printf("[CPU %d Worker] Stopped\n", cpu_id);
    return NULL;
}

int parse_args(int argc, char *argv[], int *pages, int *frames, int *threshold, int *cpus) {
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--pages") == 0) {
            if (i + 1 < argc) {
                char *endptr;
                errno = 0;
                long val = strtol(argv[++i], &endptr, 10);
                if (errno != 0 || *endptr != '\0' || val <= 0) {
                    fprintf(stderr, "Error: invalid number for --pages: %s\n", argv[i]);
                    return -1;
                }
                *pages = (int) val;
            } else {
                fprintf(stderr, "Error: --pages requires a number\n");
                return -1;
            }
        } else if (strcmp(argv[i], "--frames") == 0) {
            if (i + 1 < argc) {
                char *endptr;
                errno = 0;
                long val = strtol(argv[++i], &endptr, 10);
                if (errno != 0 || *endptr != '\0' || val <= 0) {
                    fprintf(stderr, "Error: invalid number for --frames: %s\n", argv[i]);
                    return -1;
                }
                *frames = (int) val;
            } else {
                fprintf(stderr, "Error: --frames requires a number\n");
                return -1;
            }
        } else if (strcmp(argv[i], "--algo") == 0) {
            if (i + 1 < argc) {
                if (set_eviction_algo(argv[++i]) < 0) {
                    fprintf(stderr, "Error: invalid eviction algo: %s\n", argv[i]);
                    fprintf(stderr, "Valid options: FIFO, RANDOM, LRU, CLOCK\n");
                    return -1;
                }
            } else {
                fprintf(stderr, "Error: --algo requires a type [FIFO, CLOCK, LRU, RANDOM]\n");
                return -1;
            }
        } else if (strcmp(argv[i], "--sched") == 0) {
            if (i + 1 < argc) {
                if (set_sched_algo(argv[++i]) < 0) {
                    fprintf(stderr, "Error: invalid scheduling algo: %s\n", argv[i]);
                    fprintf(stderr, "Valid options: RR, MLFQ\n");
                    return -1;
                }
            } else {
                fprintf(stderr, "Error: --sched requires a type [RR, MLFQ]\n");
                return -1;
            }
        } else if (strcmp(argv[i], "--threshold") == 0) {
            if (i + 1 < argc) {
                char *endptr;
                errno = 0;
                long val = strtol(argv[++i], &endptr, 10);
                if (errno != 0 || *endptr != '\0' || val < 0) {
                    fprintf(stderr, "Error: invalid number for --threshold: %s\n", argv[i]);
                    return -1;
                }
                *threshold = (int) val;
            } else {
                fprintf(stderr, "Error: --threshold requires a number\n");
                return -1;
            }
        } else if (strcmp(argv[i], "--cpus") == 0) {
            if (i + 1 < argc) {
                char *endptr;
                errno = 0;
                long val = strtol(argv[++i], &endptr, 10);
                if (errno != 0 || *endptr != '\0' || val < 1 || val > MAX_CPUS) {
                    fprintf(stderr, "Error: invalid number for --cpus: %s (1-%d)\n", argv[i], MAX_CPUS);
                    return -1;
                }
                *cpus = (int) val;
            } else {
                fprintf(stderr, "Error: --cpus requires a number (1-%d)\n", MAX_CPUS);
                return -1;
            }
        } else if (strcmp(argv[i], "--verbose") == 0 || strcmp(argv[i], "-v") == 0) {
            set_verbose(1);
        } else if (strcmp(argv[i], "--clean") == 0) {
            set_verbose(0);
            set_clean(1);
        } else if (strcmp(argv[i], "--help") == 0) {
            printf("Uso: %s [opcoes]\n", argv[0]);
            printf("\nOpcoes:\n");
            printf("  --pages <num>      Numero de paginas virtuais (default: 20)\n");
            printf("  --frames <num>     Numero de frames fisicos (default: 30)\n");
            printf("  --threshold <num>  Minimo de frames livres antes de substituir (default: 4)\n");
            printf("  --algo <nome>      Substituicao de paginas: FIFO, RANDOM, LRU, CLOCK\n");
            printf("  --sched <nome>     Escalonamento: RR, MLFQ\n");
            printf("  --cpus <num>       Numero de CPUs (1-%d, default: 1)\n", MAX_CPUS);
            printf("  --verbose, -v      Output detalhado (tabelas de paginas, filas, acertos)\n");
            printf("  --clean            Output mais limpo (bom para defesa/apresentacao)\n");
            printf("  --help             Mostra esta ajuda\n");
            return 1;
        } else {
            fprintf(stderr, "Unknown option: %s\n", argv[i]);
            fprintf(stderr, "Try --help\n");
            return -1;
        }
    }

    return 0;
}

int main(int argc, char *argv[]) {

    int res = parse_args(argc, argv, &num_pages, &num_frames, &min_pages_threshold, &num_cpus);
    if (res > 0) {
        return EXIT_SUCCESS;
    } else if (res < 0) {
        return EXIT_FAILURE;
    }

    if (is_clean()) {
        printf("\n[OSSIM] %s + %s | %d CPU(s) | Slice %d ms | Clean mode\n\n",
               get_sched_algo_str(), get_eviction_algo_str(), num_cpus, TIME_SLICE_MS);
    } else {
        printf("\n");
        printf("╔═══════════════════════════════════════════════════════════╗\n");
        printf("║       OSSIM - Concurrent Operating System Simulator       ║\n");
        printf("╠═══════════════════════════════════════════════════════════╣\n");
        printf("║  CPUs: %-4d │ Scheduling: %-6s │ Time Slice: %d ms     ║\n",
               num_cpus, get_sched_algo_str(), TIME_SLICE_MS);
        printf("║  Pages: %-3d │ Frames: %-4d │ Page Replacement: %-6s  ║\n",
               num_pages, num_frames, get_eviction_algo_str());
        printf("╚═══════════════════════════════════════════════════════════╝\n");
        printf("\n");
    }

    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);

    frame_table = create_frame_table(num_frames);
    if (!frame_table) {
        fprintf(stderr, "Failed to create frame table\n");
        return EXIT_FAILURE;
    }

    swap.last_swap_time_ms = 0;
    swap.num_swapped = 0;
    swap.pages = NULL;

    printf("[Main] Initializing %d MLFQ priority queues...\n", NUM_MLFQ_QUEUES);
    for (int i = 0; i < NUM_MLFQ_QUEUES; i++) {
        queue_init(&mlfq_queues[i]);
    }

    printf("[Main] Initializing %d CPUs...\n", num_cpus);
    for (int i = 0; i < num_cpus; i++) {
        CPUs[i] = NULL;
        cpu_ids[i] = i;
        pthread_mutex_init(&cpu_mutexes[i], NULL);
    }

    server_fd = setup_server_socket(SOCKET_PATH);
    if (server_fd < 0) {
        fprintf(stderr, "Failed to set up server socket\n");
        return EXIT_FAILURE;
    }
    printf("[Main] Server listening on %s\n", SOCKET_PATH);

    printf("[Main] Creating worker threads...\n");

    if (pthread_create(&timer_thread, NULL, timer_worker, NULL) != 0) {
        perror("pthread_create timer");
        return EXIT_FAILURE;
    }

    if (pthread_create(&command_thread, NULL, command_worker, NULL) != 0) {
        perror("pthread_create command");
        return EXIT_FAILURE;
    }

    if (pthread_create(&blocked_thread, NULL, blocked_worker, NULL) != 0) {
        perror("pthread_create blocked");
        return EXIT_FAILURE;
    }

    for (int i = 0; i < num_cpus; i++) {
        if (pthread_create(&cpu_threads[i], NULL, cpu_worker, &cpu_ids[i]) != 0) {
            perror("pthread_create cpu");
            return EXIT_FAILURE;
        }
    }

    if (!is_clean()) {
        printf("[Main] All %d threads started successfully!\n", 3 + num_cpus);
        printf("[Main] Press Ctrl+C to stop the simulator.\n\n");
    } else {
        printf("[Main] Running in clean mode (defense-friendly output)\n\n");
    }

    pthread_join(timer_thread, NULL);
    pthread_join(command_thread, NULL);
    pthread_join(blocked_thread, NULL);
    for (int i = 0; i < num_cpus; i++) {
        pthread_join(cpu_threads[i], NULL);
    }

    printf("\n");
    if (is_clean()) {
        printf("╔════════════════════════════════════════════════════════════════════════════╗\n");
        printf("║                        RESUMO FINAL - MODO DEFESA / CLEAN                   ║\n");
        printf("╠════════════════════════════════════════════════════════════════════════════╣\n");
        printf("║  Escalonamento: %-6s   |  Page Replacement: %-6s   |  CPUs: %d            ║\n",
               get_sched_algo_str(), get_eviction_algo_str(), num_cpus);
        printf("║  Time Slice: %3d ms      |  Pages: %3d   Frames: %3d   Threshold: %d     ║\n",
               TIME_SLICE_MS, num_pages, num_frames, min_pages_threshold);
        printf("╠════════════════════════════════════════════════════════════════════════════╣\n");
        printf("║  ESCALONAMENTO (6a)                                                        ║\n");
        printf("║    Tempo de Execução Médio .... %.0f ms                                   ║\n", get_avg_turnaround_ms());
        printf("║    Tempo de Resposta Médio .... %.0f ms                                   ║\n", get_avg_response_ms());
        printf("║    Processos terminados ....... %d                                        ║\n", get_processes_completed());
        if (get_sched_algo() == ALGO_MLFQ)
            printf("║    Decisões MLFQ ............... %d                                     ║\n", get_mlfq_decision_count());
        else
            printf("║    Decisões %-4s .............. %d                                     ║\n", get_sched_algo_str(), get_rr_decision_count());
        printf("╠════════════════════════════════════════════════════════════════════════════╣\n");
        printf("║  MEMÓRIA (6b)                                                              ║\n");
        printf("║    Page Accesses .............. %d                                        ║\n", get_total_page_accesses());
        printf("║    Page Faults ................ %d                                        ║\n", get_total_page_faults());
        printf("║    Tempo Médio Page Faults .... %.0f ms                                  ║\n", get_avg_page_fault_interval_ms());
        printf("║    Swap-ins ................... %d                                        ║\n", get_total_swap_ins());
        printf("║    Swap-outs .................. %d                                        ║\n", get_total_swap_outs());
        printf("║    Page Fault Rate ............ %.2f%%                                    ║\n",
               get_total_page_accesses() > 0 ?
               (100.0 * get_total_page_faults() / get_total_page_accesses()) : 0.0);
        printf("╚════════════════════════════════════════════════════════════════════════════╝\n");
    } else {
        printf("==================================================================\n");
        printf("                       RESUMO DA SIMULACAO\n");
        printf("==================================================================\n");
        printf("  CONFIGURACAO\n");
        printf("    Escalonamento ........... %s\n", get_sched_algo_str());
        printf("    Substituicao de paginas . %s\n", get_eviction_algo_str());
        printf("    CPUs .................... %d\n", num_cpus);
        printf("    Fatia de tempo .......... %d ms\n", TIME_SLICE_MS);
        printf("    Paginas virtuais ........ %d\n", num_pages);
        printf("    Frames fisicos .......... %d\n", num_frames);
        printf("------------------------------------------------------------------\n");
        printf("  ESCALONAMENTO (ponto 6a)\n");
        printf("    Tempo total de simulacao  %u ms (%u s)\n", current_time_ms, current_time_ms/1000);
        printf("    Processos terminados .... %d\n", get_processes_completed());
        printf("    Tempo Medio de Execucao . %.0f ms   (turnaround medio)\n", get_avg_turnaround_ms());
        printf("    Tempo Medio de Resposta . %.0f ms\n", get_avg_response_ms());
        if (get_sched_algo() == ALGO_MLFQ)
            printf("    Decisoes de MLFQ ........ %d\n", get_mlfq_decision_count());
        else if (get_sched_algo() == ALGO_FIFO)
            printf("    Preempcoes .............. 0  (FIFO e nao-preemptivo)\n");
        else
            printf("    Decisoes de RR .......... %d\n", get_rr_decision_count());
        printf("------------------------------------------------------------------\n");
        printf("  MEMORIA (ponto 6b)\n");
        printf("    Acessos a paginas ....... %d\n", get_total_page_accesses());
        printf("    Page faults ............. %d\n", get_total_page_faults());
        printf("    Tempo Medio de Page Faults .. %.0f ms\n", get_avg_page_fault_interval_ms());
        printf("    Taxa de page faults ..... %.2f%%\n",
               get_total_page_accesses() > 0 ?
               (100.0 * get_total_page_faults() / get_total_page_accesses()) : 0.0);
        printf("    Swap-outs ............... %d\n", get_total_swap_outs());
        printf("    Swap-ins ................ %d\n", get_total_swap_ins());
        printf("==================================================================\n");
    }
    printf("\n");

    printf("[Main] Cleaning up resources...\n");

    close(server_fd);
    unlink(SOCKET_PATH);

    for (int i = 0; i < NUM_MLFQ_QUEUES; i++) {
        queue_destroy(&mlfq_queues[i]);
    }

    for (int i = 0; i < num_cpus; i++) {
        pthread_mutex_destroy(&cpu_mutexes[i]);
    }

    pthread_mutex_destroy(&time_mutex);
    pthread_mutex_destroy(&memory_mutex);

    printf("[Main] Shutdown complete. Final simulation time: %u ms\n", current_time_ms);
    return EXIT_SUCCESS;
}
