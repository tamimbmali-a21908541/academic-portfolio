
#ifndef VIRTMEM_H
#define VIRTMEM_H

#include "virtmem_types.h"
#include "pcb.h"

typedef enum {
    FIFO = 0,
    RANDOM,
    CLOCK,
    LRU
} eviction_algo_en;

extern const char* eviction_algo_str[];

int set_eviction_algo(const char *ev_str);
const char *get_eviction_algo_str(void);

void set_verbose(int v);
int  is_verbose(void);

void set_clean(int c);
int  is_clean(void);

int create_page_table(page_table_t *pt, int max_size);
frame_table_t *create_frame_table(int num_frames);

pte_t *find_page(page_table_t *pt, int32_t vfn);
int is_active(pte_t *page);
int is_valid(pte_t *page);

int init_free_stack(free_stack_t *stack, int num_frames);
int push_free_frame(free_stack_t *stack, int frame_id);
int pop_free_frame(free_stack_t *stack);

int init_eviction_arr(array_t *array, int num_frames);
int update_eviction_array(array_t *eviction_arr, int frame_id, uint32_t current_time_ms);
int evict(array_t *eviction_arr);

int swap_out(swap_hash_t *swap, frame_desc_t *fd);
int swap_in(swap_hash_t *swap, frame_desc_t *fd);

int page_eviction(frame_table_t *frame_table, swap_hash_t *swap, int32_t min_pages_threshold, uint32_t current_time_ms);
pte_t *page_request(pcb_t *pcb, frame_table_t *frame_table, swap_hash_t *swap, int vfn, uint32_t current_time_ms);
void free_pages(frame_table_t *frame_table, swap_hash_t *swap, pcb_t *pcb);
int free_frames_from_memory(frame_table_t *frame_table, int32_t pid);
int free_frames_from_swap(swap_hash_t *swap, int32_t pid, int32_t pages);

int get_total_page_accesses(void);
int get_total_page_faults(void);
int get_total_swap_ins(void);
int get_total_swap_outs(void);
double get_avg_page_fault_interval_ms(void);

#endif
