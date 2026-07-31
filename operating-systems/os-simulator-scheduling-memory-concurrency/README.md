# OSSIM — source

Implementation of the OS simulator. For the full write-up — architecture, algorithms, and design rationale — see the [course README](../README.md).

**Live web platform:** [ossim-platform.vercel.app](https://ossim-platform.vercel.app/)

---

## Layout

| File | Purpose |
|---|---|
| `ossim.c` | Simulator core — threads, main loop, CPU assignment |
| `scheduler.c/.h` | FIFO, Round Robin (400 ms slice), 3-level MLFQ |
| `virtmem.c/.h` | Page tables, frame table, eviction (FIFO/RANDOM/CLOCK/LRU), swap |
| `virtmem_types.h` | `pte_t`, `frame_desc_t`, `free_stack_t`, `swap_hash_t` |
| `queue.c/.h` | Generic process queue |
| `burst_queue.c/.h` | CPU/IO burst sequences per process |
| `app-io.c` | Socket client — simulated processes request CPU and pages |
| `pcb.h` | Process control block |
| `msg.h` | IPC message envelope (carries the shared simulation clock) |
| `debug.h` | Verbose logging macros |
| `uthash.h` | Third-party hash macros ([uthash](https://troydhanson.github.io/uthash/)), used to index swap |

> `swap.c` / `swap.h` are vestigial — the swap implementation lives in `virtmem.c` (`swap_in`, `swap_out`).

## Build

```bash
gcc -o ossim ossim.c scheduler.c virtmem.c queue.c burst_queue.c -lpthread
gcc -o app app-io.c
```

## Run

Start the simulator, then connect one or more `app` processes to it:

```bash
./ossim &
./app <workload.csv>
```

Workload lines are burst sequences: `cpu_ms, io_ms, nice, [pages]`.

### Runtime options

- **Scheduler** — `RR` (default), `MLFQ`, or `FIFO` via `set_sched_algo()`
- **Eviction policy** — `FIFO`, `RANDOM`, `CLOCK`, or `LRU` via `set_eviction_algo()`
- **Verbose logging** — `set_verbose()`
- Compile-time limits in `scheduler.h`: `TIME_SLICE_MS` (400), `NUM_MLFQ_QUEUES` (3), `MAX_CPUS` (4)

## Metrics reported

**Scheduling** — average turnaround, average response time, decision counts, processes completed
**Memory** — page accesses, page faults, swap-ins, swap-outs, average interval between faults
