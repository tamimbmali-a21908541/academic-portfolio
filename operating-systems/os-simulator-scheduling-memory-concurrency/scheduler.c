#include "scheduler.h"
#include "virtmem.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "msg.h"

static const char* sched_algo_str[] = { "RR", "MLFQ", "FIFO", NULL };
static sched_algo_t current_sched_algo = ALGO_RR;
static int processes_completed = 0;

static uint64_t sum_turnaround_ms = 0;
static uint64_t sum_response_ms   = 0;

int set_sched_algo(const char *algo_str) {
    for (int i = 0; sched_algo_str[i] != NULL; i++) {
        if (strcasecmp(sched_algo_str[i], algo_str) == 0) {
            current_sched_algo = (sched_algo_t)i;
            return 0;
        }
    }
    return -1;
}

const char* get_sched_algo_str(void) { return sched_algo_str[current_sched_algo]; }
sched_algo_t get_sched_algo(void)    { return current_sched_algo; }

static int rr_decision_count = 0;
static int mlfq_decision_count = 0;

static void show_ready_queue(queue_t *rq, const char* contexto) {
    if (!is_verbose()) return;
    printf("    [ready queue %s]:", contexto);
    if (rq->head == NULL) { printf(" (vazia)\n"); return; }
    for (queue_elem_t *e = rq->head; e != NULL; e = e->next)
        printf(" P%d", e->pcb->pid);
    printf("\n");
}

static void show_mlfq_queues(queue_t mlfq[], const char* contexto) {
    if (!is_verbose()) return;
    printf("    [filas MLFQ %s]:", contexto);
    for (int q = 0; q < NUM_MLFQ_QUEUES; q++) {
        printf(" fila%d=", q);
        if (mlfq[q].head == NULL) { printf("()"); continue; }
        for (queue_elem_t *e = mlfq[q].head; e != NULL; e = e->next)
            printf("%sP%d", (e == mlfq[q].head) ? "(" : ",", e->pcb->pid);
        printf(")");
    }
    printf("\n");
}

int scheduler(uint32_t current_time_ms, queue_t *rq, queue_t *cq, pcb_t **cpu_task) {

    if (*cpu_task) {
        (*cpu_task)->ellapsed_time_ms += TICKS_MS;
        (*cpu_task)->slice_used_ms    += TICKS_MS;

        if ((*cpu_task)->ellapsed_time_ms >= (*cpu_task)->time_ms) {
            if (!is_clean())
                printf("[t=%ums] P%d terminou o burst de CPU (%u ms) -> vai bloquear/pedir novo\n",
                       current_time_ms, (*cpu_task)->pid, (*cpu_task)->time_ms);

            msg_t msg = { .pid = (*cpu_task)->pid, .request = PROCESS_REQUEST_DONE, .time_ms = current_time_ms };
            if (write((*cpu_task)->sockfd, &msg, sizeof(msg_t)) != sizeof(msg_t)) perror("write");

            enqueue_pcb(cq, *cpu_task);
            *cpu_task = NULL;
        }
        else if ((*cpu_task)->slice_used_ms >= TIME_SLICE_MS) {
            ++rr_decision_count;
            printf("[t=%ums] P%d preemptado: usou a fatia de %d ms (burst %u/%u ms) -> fim da fila (RR)\n",
                   current_time_ms, (*cpu_task)->pid, TIME_SLICE_MS,
                   (*cpu_task)->ellapsed_time_ms, (*cpu_task)->time_ms);

            enqueue_pcb(rq, *cpu_task);
            *cpu_task = NULL;
            show_ready_queue(rq, "apos preempcao");
        }
    }

    if (*cpu_task == NULL) {
        show_ready_queue(rq, "antes de escalonar");
        *cpu_task = dequeue_pcb(rq);
        if (*cpu_task) {
            (*cpu_task)->slice_start_ms = current_time_ms;
            (*cpu_task)->slice_used_ms  = 0;
            ++rr_decision_count;
            return 1;
        }
    }
    return 0;
}

int scheduler_fifo(uint32_t current_time_ms, queue_t *rq, queue_t *cq, pcb_t **cpu_task) {

    if (*cpu_task) {
        (*cpu_task)->ellapsed_time_ms += TICKS_MS;
        (*cpu_task)->slice_used_ms    += TICKS_MS;

        if ((*cpu_task)->ellapsed_time_ms >= (*cpu_task)->time_ms) {
            if (!is_clean())
                printf("[t=%ums] P%d terminou o burst de CPU (%u ms) -> vai bloquear/pedir novo\n",
                       current_time_ms, (*cpu_task)->pid, (*cpu_task)->time_ms);

            msg_t msg = { .pid = (*cpu_task)->pid, .request = PROCESS_REQUEST_DONE, .time_ms = current_time_ms };
            if (write((*cpu_task)->sockfd, &msg, sizeof(msg_t)) != sizeof(msg_t)) perror("write");

            enqueue_pcb(cq, *cpu_task);
            *cpu_task = NULL;
        }
    }

    if (*cpu_task == NULL) {
        show_ready_queue(rq, "antes de escalonar");
        *cpu_task = dequeue_pcb(rq);
        if (*cpu_task) {
            (*cpu_task)->slice_start_ms = current_time_ms;
            (*cpu_task)->slice_used_ms  = 0;
            ++rr_decision_count;
            return 1;
        }
    }
    return 0;
}


void enqueue_mlfq(queue_t mlfq[], pcb_t *task) {
    if (!task) return;
    if (task->priority >= NUM_MLFQ_QUEUES) task->priority = NUM_MLFQ_QUEUES - 1;
    enqueue_pcb(&mlfq[task->priority], task);
}

pcb_t* dequeue_mlfq(queue_t mlfq[]) {
    for (int i = 0; i < NUM_MLFQ_QUEUES; i++) {
        pcb_t *task = dequeue_pcb(&mlfq[i]);
        if (task) return task;
    }
    return NULL;
}

void drain_ready_into_mlfq(queue_t *rq, queue_t mlfq[]) {
    pcb_t *t;
    while ((t = dequeue_pcb(rq)) != NULL) {
        enqueue_mlfq(mlfq, t);
    }
}

int scheduler_mlfq(uint32_t current_time_ms, queue_t mlfq[], queue_t *cq, pcb_t **cpu_task) {

    if (*cpu_task) {
        (*cpu_task)->ellapsed_time_ms += TICKS_MS;
        (*cpu_task)->slice_used_ms    += TICKS_MS;

        if ((*cpu_task)->ellapsed_time_ms >= (*cpu_task)->time_ms) {
            uint32_t old = (*cpu_task)->priority;

            msg_t msg = { .pid = (*cpu_task)->pid, .request = PROCESS_REQUEST_DONE, .time_ms = current_time_ms };
            if (write((*cpu_task)->sockfd, &msg, sizeof(msg_t)) != sizeof(msg_t)) perror("write");

            if ((*cpu_task)->priority > 0) {
                (*cpu_task)->priority--;
                if (!is_clean())
                    printf("[t=%ums] P%d terminou burst (%u ms) cedo (I/O-bound) -> SOBE prioridade %u->%u\n",
                           current_time_ms, (*cpu_task)->pid, (*cpu_task)->time_ms, old, (*cpu_task)->priority);
                else
                    printf("[t=%ums] P%d terminou burst cedo -> SOBE %u->%u\n",
                           current_time_ms, (*cpu_task)->pid, old, (*cpu_task)->priority);
            } else {
                printf("[t=%ums] P%d terminou burst (%u ms) cedo (I/O-bound) -> mantem fila 0 (alta)\n",
                       current_time_ms, (*cpu_task)->pid, (*cpu_task)->time_ms);
            }
            enqueue_pcb(cq, *cpu_task);
            *cpu_task = NULL;
        }
        else if ((*cpu_task)->slice_used_ms >= TIME_SLICE_MS) {
            ++mlfq_decision_count;
            uint32_t old = (*cpu_task)->priority;
            if ((*cpu_task)->priority < NUM_MLFQ_QUEUES - 1) {
                (*cpu_task)->priority++;
                if (!is_clean())
                    printf("[t=%ums] P%d gastou a fatia (%d ms) (CPU-bound) -> DESCE prioridade %u->%u\n",
                           current_time_ms, (*cpu_task)->pid, TIME_SLICE_MS, old, (*cpu_task)->priority);
                else
                    printf("[t=%ums] P%d -> DESCE prioridade %u->%u\n",
                           current_time_ms, (*cpu_task)->pid, old, (*cpu_task)->priority);
            } else {
                printf("[t=%ums] P%d gastou a fatia (%d ms) (CPU-bound) -> ja na fila mais baixa (%d)\n",
                       current_time_ms, (*cpu_task)->pid, TIME_SLICE_MS, NUM_MLFQ_QUEUES - 1);
            }
            (*cpu_task)->slice_used_ms = 0;
            enqueue_mlfq(mlfq, *cpu_task);
            *cpu_task = NULL;
            show_mlfq_queues(mlfq, "apos descida");
        }
    }

    if (*cpu_task == NULL) {
        show_mlfq_queues(mlfq, "antes de escalonar");

        int from_queue = -1;
        for (int i = 0; i < NUM_MLFQ_QUEUES; i++) {
            if (mlfq[i].head != NULL) { from_queue = i; break; }
        }

        *cpu_task = dequeue_mlfq(mlfq);
        if (*cpu_task) {
            (*cpu_task)->slice_start_ms = current_time_ms;
            (*cpu_task)->slice_used_ms  = 0;
            ++mlfq_decision_count;
            if (is_verbose() && from_queue >= 0)
                printf("    MLFQ: escolhido P%d da fila %d (maior prioridade nao-vazia)\n",
                       (*cpu_task)->pid, from_queue);
            return 1;
        }
    }
    return 0;
}

int  get_rr_decision_count(void)   { return rr_decision_count; }
int  get_mlfq_decision_count(void) { return mlfq_decision_count; }
int  get_processes_completed(void) { return processes_completed; }
void increment_processes_completed(void) { processes_completed++; }

void add_completed_metrics(uint32_t turnaround_ms, uint32_t response_ms) {
    sum_turnaround_ms += turnaround_ms;
    sum_response_ms   += response_ms;
}
double get_avg_turnaround_ms(void) {
    return processes_completed ? (double)sum_turnaround_ms / processes_completed : 0.0;
}
double get_avg_response_ms(void) {
    return processes_completed ? (double)sum_response_ms / processes_completed : 0.0;
}
