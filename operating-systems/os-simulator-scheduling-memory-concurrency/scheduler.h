#ifndef SCHEDULER_H
#define SCHEDULER_H

#include "queue.h"

#define TIME_SLICE_MS 400
#define NUM_MLFQ_QUEUES 3
#define MAX_CPUS 4

typedef enum {
    ALGO_RR = 0,
    ALGO_MLFQ,
    ALGO_FIFO
} sched_algo_t;


int set_sched_algo(const char *algo_str);

const char* get_sched_algo_str(void);

sched_algo_t get_sched_algo(void);


int scheduler(uint32_t current_time_ms, queue_t *rq, queue_t *cq, pcb_t **cpu_task);

int scheduler_mlfq(uint32_t current_time_ms, queue_t mlfq[], queue_t *cq, pcb_t **cpu_task);

int scheduler_fifo(uint32_t current_time_ms, queue_t *rq, queue_t *cq, pcb_t **cpu_task);


void enqueue_mlfq(queue_t mlfq[], pcb_t *task);

pcb_t* dequeue_mlfq(queue_t mlfq[]);

void drain_ready_into_mlfq(queue_t *rq, queue_t mlfq[]);

int get_rr_decision_count(void);
int get_mlfq_decision_count(void);
int get_processes_completed(void);
void increment_processes_completed(void);

void   add_completed_metrics(uint32_t turnaround_ms, uint32_t response_ms);
double get_avg_turnaround_ms(void);
double get_avg_response_ms(void);

#endif
