


#include "virtmem_types.h"
#include "virtmem.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

const char* eviction_algo_str[] = { "FIFO", "RANDOM", "CLOCK", "LRU", NULL};

static eviction_algo_en eviction_algo = FIFO;

static int npageacc = 0;
static int npagefaults = 0;
static int nswapin = 0;
static int nswapout = 0;

static int total_page_accesses = 0;
static int total_page_faults = 0;
static int total_swap_ins = 0;
static int total_swap_outs = 0;

static uint32_t last_fault_time_ms = 0;
static uint64_t sum_fault_intervals_ms = 0;
static int fault_interval_count = 0;

static int g_verbose = 0;
static int g_clean = 0;

void set_verbose(int v) { g_verbose = v; }
int  is_verbose(void)   { return g_verbose; }

void set_clean(int c) { g_clean = c; }
int  is_clean(void)   { return g_clean; }

static int swap_contains(swap_hash_t *swap, int32_t pid, int32_t vfn) {
    uint64_t key = (((uint64_t)pid) << 32) | ((uint64_t)vfn);
    swapped_frame_t *p = NULL;
    HASH_FIND(hh, swap->pages, &key, sizeof(uint64_t), p);
    return p != NULL;
}

int set_eviction_algo(const char *ev_str) {
    int i = 0;
    while (eviction_algo_str[i] != NULL) {
        if (strcasecmp(eviction_algo_str[i], ev_str) == 0) {
            eviction_algo = (eviction_algo_en) i;
            return eviction_algo;
        }
        i++;
    }
    return -1;
}

const char *get_eviction_algo_str(void) {
    return eviction_algo_str[eviction_algo];
}




frame_table_t *create_frame_table(int num_frames) {
    if (num_frames <= 0) {
        printf("create_frame_table: invalid num_frames=%d\n", num_frames);
        return NULL;
    }

    frame_table_t *ft = (frame_table_t *)malloc(sizeof(frame_table_t));
    if (!ft) {
        printf("Cannot allocate memory for frame table\n");
        return NULL;
    }

    ft->frames = (frame_desc_t *)calloc((size_t)num_frames, sizeof(frame_desc_t));
    if (!ft->frames) {
        printf("Cannot allocate memory for frame descriptors\n");
        free(ft);
        return NULL;
    }

    ft->no_frames = num_frames;

    if (init_free_stack(&ft->free_stack, num_frames) < 0) {
        free(ft->frames);
        free(ft);
        return NULL;
    }

    if (init_eviction_arr(&ft->eviction_order, num_frames) < 0) {
        printf("Cannot allocate memory for FIFO eviction order\n");
        free(ft->frames);
        free(ft);
        return NULL;
    }
    return ft;
}



int create_page_table(page_table_t *pt, int max_size) {
    if (pt == NULL || max_size <= 0) {
        printf("Invalid page table\n");
        return -1;
    }
    pt->vp = (pte_t *)malloc((size_t)max_size * sizeof(pte_t));
    if (pt->vp == NULL) {
        printf("Cannot allocate memory for page table\n");
        return -1;
    }
    pt->nvalid = max_size;
    for (int i = 0; i < max_size; ++i) {
        pt->vp[i].frame_id = INVALID_FRAME;
        pt->vp[i].present = 0;
        pt->vp[i].referenced = 0;
        pt->vp[i].dirty = 0;
        pt->vp[i].last_accessed = 0;
    }
    return 0;
}


int is_active(pte_t *page) {
    if (page == NULL) return 0;
    return page->present;
}


int is_valid(pte_t *page) {
    if (page == NULL) {
        return 0;
    }
    return page->frame_id != INVALID_FRAME;
}


pte_t *find_page(page_table_t *pt, int32_t vfn) {
    if (pt == NULL || vfn < 1 || vfn > pt->nvalid) {
        return NULL;
    }
    return &pt->vp[vfn-1];
}


int init_free_stack(free_stack_t *stack, int num_frames) {
    if (stack == NULL || num_frames <= 0) {
        printf("Invalid free stack\n");
        return -1;
    }
    stack->ids = (uint32_t *)malloc((size_t)num_frames * sizeof(uint32_t));
    if (stack->ids == NULL) {
        printf("Cannot allocate memory for free stack\n");
        return -1;
    }
    stack->top = num_frames - 1;
    stack->max_size = num_frames;
    for (int i = 0; i < num_frames; ++i) stack->ids[i] = i;
    return 0;
}


int push_free_frame(free_stack_t *stack, int frame_id) {
    if (stack == NULL || frame_id < 0 || stack->top >= (stack->max_size - 1)) {
        return 0;
    }
    stack->ids[++(stack->top)] = (uint32_t)frame_id;
    return 1;
}



int pop_free_frame(free_stack_t *stack) {
    if (stack == NULL || stack->top < 0) return INVALID_FRAME;
    int frame_id = stack->ids[0];
    for (int i = 1; i <= stack->top; ++i) stack->ids[i-1] = stack->ids[i];
    stack->top--;
    return frame_id;
}


int swap_out(swap_hash_t *swap, frame_desc_t *fd) {
    pte_t *vp = fd->vp;
    uint64_t page_key = (((uint64_t)fd->pid) << 32) | ((uint64_t)fd->vfn);
    swapped_frame_t *swapped_page = (swapped_frame_t *)malloc(sizeof(swapped_frame_t));
    if (!swapped_page) {
        printf("Cannot allocate memory for swapped frame\n");
        return -1;
    }
    swapped_page->page_id = page_key;
    swapped_page->dirty = vp->dirty;
    swapped_page->last_accessed = vp->last_accessed;
    HASH_ADD(hh, swap->pages, page_id, sizeof(uint64_t), swapped_page);
    swap->num_swapped += 1;
    nswapout++;
    total_swap_outs++;
    return 0;
}


int swap_in(swap_hash_t *swap, frame_desc_t *fd) {
    pte_t *vp = fd->vp;
    uint64_t page_key = (((uint64_t)fd->pid) << 32) | ((uint64_t)fd->vfn);
    swapped_frame_t *swapped_page = NULL;
    HASH_FIND(hh, swap->pages, &page_key, sizeof(uint64_t), swapped_page);
    if (!swapped_page) {
        printf("Page not found in swap\n");
        return -1;
    }
    vp->dirty = swapped_page->dirty;
    vp->last_accessed = swapped_page->last_accessed;
    HASH_DEL(swap->pages, swapped_page);
    free(swapped_page);
    swap->num_swapped -= 1;
    nswapin++;
    total_swap_ins++;
    return 0;
}


pte_t *page_request(pcb_t *pcb, frame_table_t *frame_table, swap_hash_t *swap, int vfn, uint32_t current_time_ms) {
    npageacc++;
    total_page_accesses++;
    pte_t *vp = find_page(&pcb->page_table, vfn);
    if (!vp) return NULL;

    if (is_active(vp)) {
        vp->last_accessed = current_time_ms;
        update_eviction_array(&frame_table->eviction_order, vp->frame_id, current_time_ms);
        return vp;
    }

    npagefaults++;
    total_page_faults++;

    if (last_fault_time_ms > 0) {
        sum_fault_intervals_ms += (current_time_ms - last_fault_time_ms);
        fault_interval_count++;
    }
    last_fault_time_ms = current_time_ms;

    int in_swap = swap_contains(swap, pcb->pid, vfn);

    int32_t next_frame = pop_free_frame(&frame_table->free_stack);
    if (next_frame == INVALID_FRAME) {
        printf("[t=%ums] ERRO: sem frames livres para a vpn %d (P%d)\n",
               current_time_ms, vfn, pcb->pid);
        return NULL;
    }

    frame_desc_t *fd = &frame_table->frames[next_frame];
    fd->vp  = vp;
    fd->pid = pcb->pid;
    fd->vfn = vfn;
    vp->frame_id = next_frame;
    vp->present  = 1;

    if (in_swap) {
        swap_in(swap, fd);
        if (!is_clean())
            printf("[t=%ums] FALHA #%d: P%d vpn %d -> frame %d (swap-in, já tinha estado em memória)\n",
                   current_time_ms, total_page_faults, pcb->pid, vfn, next_frame);
    } else {
        fd->vp->dirty = 1;
        if (!is_clean())
            printf("[t=%ums] FALHA #%d: P%d vpn %d -> frame %d (nova)\n",
                   current_time_ms, total_page_faults, pcb->pid, vfn, next_frame);
    }

    vp->last_accessed = current_time_ms;
    update_eviction_array(&frame_table->eviction_order, next_frame, current_time_ms);
    return vp;
}


int page_eviction(frame_table_t *frame_table, swap_hash_t *swap, int32_t min_pages_threshold, uint32_t current_time_ms) {
    while (frame_table->free_stack.top + 1 < min_pages_threshold) {
        int free_now = frame_table->free_stack.top + 1;
        printf("[t=%ums] PRESSAO DE MEMORIA: livres=%d < limiar=%d -> substituir (%s)\n",
               current_time_ms, free_now, min_pages_threshold, get_eviction_algo_str());

        int evict_frame = evict(&frame_table->eviction_order);
        if (evict_frame == INVALID_FRAME) {
            printf("  (não há frame para substituir)\n");
            return -1;
        }

        frame_desc_t *fd = &frame_table->frames[evict_frame];
        pte_t *vp = fd->vp;
        if (!vp) {
            push_free_frame(&frame_table->free_stack, evict_frame);
            continue;
        }

        printf("  vitima: frame %d = vpn %d de P%d (ult.acesso=%u ms) -> swap-out\n",
               evict_frame, fd->vfn, fd->pid, vp->last_accessed);

        vp->present = 0;
        if (vp->dirty) {
            if (swap_out(swap, fd) < 0)
                printf("  (falha no swap-out da vpn %d)\n", fd->vfn);
        }
        vp->frame_id = INVALID_FRAME;
        fd->vp  = NULL;
        fd->pid = -1;
        fd->vfn = 0;
        push_free_frame(&frame_table->free_stack, evict_frame);
    }
    return 0;
}

int free_frames_from_memory(frame_table_t *frame_table, int32_t pid) {
    int count = 0;
    for (int i = 0; i < frame_table->no_frames; i++) {
        frame_desc_t *fd = &frame_table->frames[i];
        if (fd->pid == pid) {
            push_free_frame(&frame_table->free_stack, i);
            if (fd->vp) fd->vp->frame_id = INVALID_FRAME;
            fd->vp = NULL;
            fd->pid = -1;
            fd->vfn = 0;
            count++;
        }
    }
    return count;
}

int swap_del(swap_hash_t *swap, int32_t pid, int32_t vfn) {
    uint64_t page_key = (((uint64_t)pid) << 32) | ((uint64_t)vfn);
    swapped_frame_t *swapped_page = NULL;
    HASH_FIND(hh, swap->pages, &page_key, sizeof(uint64_t), swapped_page);
    if (!swapped_page) {
        return 0;
    }
    HASH_DEL(swap->pages, swapped_page);
    free(swapped_page);
    swap->num_swapped -= 1;
    return 1;
}

int free_frames_from_swap(swap_hash_t *swap, int32_t pid, int32_t pages) {
    int count = 0;
    for (int i = 0; i < pages; i++) {
        count += swap_del(swap, pid, i+1);
    }
    return count;
}

void free_pages(frame_table_t *frame_table, swap_hash_t *swap, pcb_t *pcb) {
    printf("Processo %d a terminar: a libertar as suas paginas\n", pcb->pid);
    int freed_frames_from_memory = free_frames_from_memory(frame_table, pcb->pid);
    int freed_frames_from_swap = free_frames_from_swap(swap, pcb->pid, pcb->page_table.nvalid);
    for (int i = 0; i < pcb->page_table.nvalid; i++) {
        pcb->page_table.vp[i].frame_id = INVALID_FRAME;
    }
    printf("Libertou %d frames de memoria e %d de swap (processo %d)\n",
           freed_frames_from_memory, freed_frames_from_swap, pcb->pid);
    printf("%s: page accesses=%d, page faults=%d, swapin=%d, swapout=%d, page fault rate=%f\n",
           eviction_algo_str[eviction_algo], npageacc, npagefaults, nswapin, nswapout,
           npageacc ? ((float)npagefaults/(float)npageacc) : 0.0f);
    npageacc = npagefaults = nswapin = nswapout = 0;
};



int init_eviction_arr(array_t *array, int num_frames) {
    if (array == NULL || num_frames <= 0) {
        return -1;
    }
    array->ids = (array_elem_t *)malloc((size_t)num_frames * sizeof(array_elem_t));
    if (array->ids == NULL) {
        printf("Cannot allocate memory for eviction array\n");
        return -1;
    }
    array->top = -1;
    srand(time(NULL));
    array->max_size = num_frames;
    array->last_index = 0;
    return 0;
}


int32_t fifo_eviction(array_t *fifo) {
    if (fifo == NULL || fifo->top < 0) return INVALID_FRAME;

    int32_t frame_id = fifo->ids[0].frame_id;
    printf("  FIFO: frame %d foi o primeiro a entrar (posicao 0 da fila) -> vitima\n", frame_id);
    if (is_verbose()) {
        printf("    ordem de chegada (frames): ");
        for (int i = 0; i <= fifo->top; ++i)
            printf("%d%s", fifo->ids[i].frame_id, i < fifo->top ? " -> " : "\n");
    }

    for (int i = 1; i <= fifo->top; ++i) {
        fifo->ids[i - 1] = fifo->ids[i];
    }
    fifo->top--;
    return frame_id;
}



int32_t random_eviction(array_t *array) {
    if (array == NULL || array->top < 0) return INVALID_FRAME;

    int evict_idx = rand() % (array->top + 1);
    int32_t frame_id = array->ids[evict_idx].frame_id;
    printf("  RANDOM: frame %d (indice %d sorteado de %d em memoria) -> vitima\n",
           frame_id, evict_idx, array->top + 1);

    for (int i = evict_idx + 1; i <= array->top; i++) {
        array->ids[i - 1] = array->ids[i];
    }
    array->top--;
    return frame_id;
}


int32_t clock_eviction(array_t *array) {
    if (!array || array->top < 0) return INVALID_FRAME;

    int idx = array->last_index;
    if (idx < 0 || idx > array->top) idx = 0;
    int steps = 0;

    while (array->ids[idx].use_bit > 0) {
        if (is_verbose())
            printf("    CLOCK: frame %d tinha use-bit=1 -> 2a chance (reset para 0)\n",
                   array->ids[idx].frame_id);
        array->ids[idx].use_bit = 0;
        idx = (idx + 1) % (array->top + 1);
        steps++;
    }

    int32_t frame_id = array->ids[idx].frame_id;
    printf("  CLOCK: frame %d tem use-bit=0 (ponteiro avancou %d) -> vitima\n", frame_id, steps);

    array->last_index = (idx + 1) % (array->top + 1);

    for (int i = idx + 1; i <= array->top; i++) {
        array->ids[i - 1] = array->ids[i];
    }
    array->top--;
    return frame_id;
}



int32_t lru_eviction(array_t *array) {
    if (!array || array->top < 0) return INVALID_FRAME;

    uint32_t min_time = UINT32_MAX;
    int evict_idx = -1;
    for (int i = 0; i <= array->top; i++) {
        if (array->ids[i].last_accessed < min_time) {
            min_time = array->ids[i].last_accessed;
            evict_idx = i;
        }
    }
    if (evict_idx < 0) return INVALID_FRAME;

    int32_t frame_id = array->ids[evict_idx].frame_id;

    if (is_verbose()) {
        printf("    LRU: tempos de ultimo acesso por frame em memoria:\n");
        for (int i = 0; i <= array->top; i++) {
            printf("      frame %d: %u ms%s\n",
                   array->ids[i].frame_id, array->ids[i].last_accessed,
                   i == evict_idx ? "   <- VITIMA (mais antigo)" : "");
        }
    }
    printf("  LRU: frame %d e o menos recentemente usado (ult.acesso=%u ms) -> vitima\n",
           frame_id, min_time);

    for (int i = evict_idx + 1; i <= array->top; i++) {
        array->ids[i - 1] = array->ids[i];
    }
    array->top--;
    return frame_id;
}




int update_eviction_array(array_t *eviction_arr, int frame_id, uint32_t current_time_ms) {
    if (eviction_arr == NULL || frame_id < 0 || eviction_arr->top >= (eviction_arr->max_size - 1)) {
        return 0;
    }
    for (int i = 0; i <= eviction_arr->top; i++) {
        if (eviction_arr->ids[i].frame_id == frame_id) {
            eviction_arr->ids[i].last_accessed = current_time_ms;
            eviction_arr->ids[i].use_bit = 1;
            return 1;
        }
    }
    eviction_arr->top++;
    eviction_arr->ids[eviction_arr->top].frame_id     = frame_id;
    eviction_arr->ids[eviction_arr->top].last_accessed = current_time_ms;
    eviction_arr->ids[eviction_arr->top].use_bit       = 1;
    return 1;
}

int evict(array_t *eviction_arr) {
    switch (eviction_algo) {
        case FIFO:
            return fifo_eviction(eviction_arr);
        case RANDOM:
            return random_eviction(eviction_arr);
        case CLOCK:
            return clock_eviction(eviction_arr);
        case LRU:
            return lru_eviction(eviction_arr);
        default:
            printf("Not yet implemented\n");
    }
    return INVALID_FRAME;
}

int get_total_page_accesses(void) { return total_page_accesses; }
int get_total_page_faults(void) { return total_page_faults; }
int get_total_swap_ins(void) { return total_swap_ins; }
int get_total_swap_outs(void) { return total_swap_outs; }

double get_avg_page_fault_interval_ms(void) {
    if (fault_interval_count == 0) return 0.0;
    return (double)sum_fault_intervals_ms / fault_interval_count;
}
