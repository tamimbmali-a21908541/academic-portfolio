
#ifndef PCB_H
#define PCB_H
#include <stdint.h>

#include "msg.h"
#include "virtmem_types.h"

typedef enum  {
    TASK_COMMAND = 0,
    TASK_BLOCKED,
    TASK_RUNNING,
    TASK_STOPPED,
    TASK_TERMINATED,
} task_status_en;

typedef struct pcb_st{
    int32_t pid;
    task_status_en status;
    uint32_t sockfd;

    uint32_t time_ms;
    uint32_t ellapsed_time_ms;
    uint32_t slice_used_ms;
    uint32_t slice_start_ms;
    uint32_t last_update_time_ms;

    uint32_t arrival_time_ms;
    uint32_t first_run_time_ms;
    uint32_t response_time_ms;
    uint8_t  arrived;
    uint8_t  ran_once;

    uint32_t priority;

    page_info_t requested_pages;
    page_table_t page_table;
} pcb_t;

#endif
