#ifndef VIRTMEM_TYPES_H
#define VIRTMEM_TYPES_H

#include <stdint.h>
#include "uthash.h"

#define INVALID_FRAME -1
typedef enum { VM_RANDOM=0, VM_FIFO, VM_NRU, VM_LRU } vm_policy_t;

typedef struct pte_st {
    int32_t  frame_id;
    uint8_t  present:1;
    uint8_t  referenced:1;
    uint8_t  dirty:1;
    uint32_t last_accessed;
} pte_t;

typedef struct page_table_st {
    uint8_t  nvalid;
    pte_t   *vp;
} page_table_t;

typedef struct frame_desc_st {
    pte_t    *vp;
    int32_t   pid;
    uint32_t  vfn;
} frame_desc_t;

typedef struct free_stack_st {
    uint32_t *ids;
    int       max_size;
    int       top;
} free_stack_t;

typedef struct array_elem_st {
    uint32_t    frame_id;
    int use_bit:1;
    uint32_t last_accessed;
} array_elem_t;

typedef struct array_st {
    array_elem_t *ids;
    int       max_size;
    int       last_index;
    int       top;
} array_t;

typedef struct frame_table_st {
    int           no_frames;
    frame_desc_t *frames;
    free_stack_t  free_stack;

    array_t        eviction_order;
} frame_table_t;

typedef struct swapped_frame_st {
    uint64_t page_id;
    uint8_t  dirty:1;
    uint32_t last_accessed;
    UT_hash_handle hh;
} swapped_frame_t;

typedef struct swap_hash_st {
    int num_swapped;
    uint32_t last_swap_time_ms;
    swapped_frame_t *pages;
} swap_hash_t;

#endif
