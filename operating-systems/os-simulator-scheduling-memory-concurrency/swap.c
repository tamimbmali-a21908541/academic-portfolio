
#include "swap.h"

#include "uthash.h"

typedef struct {
    int page_id;
    int frame_id;
    UT_hash_handle hh;
} page_table_entry_t;
