# Operating Systems

> **OSSIM** — a multi-CPU operating system simulator written in C, implementing three CPU schedulers and four page-replacement policies, with simulated processes running as separate programs that talk to the kernel over sockets.

### 🔗 [**Try the live web platform → ossim-platform.vercel.app**](https://ossim-platform.vercel.app/)

**Grade:** 12/20 · **ECTS:** 6 · **Year:** 2 · **Institution:** Universidade Lusófona

---

## Overview

Scheduling and paging algorithms are easy to state and hard to intuit. This simulator makes them observable: you feed it a workload, pick an algorithm, and watch the scheduling decisions and page faults play out with comparative metrics at the end.

The design choice that makes it interesting is that **simulated processes are real separate programs**. They connect to the simulator over a socket and request CPU time and memory pages, rather than being loop iterations inside one process. The kernel side is threaded (`pthread`) and coordinates them.

## CPU scheduling

Three interchangeable algorithms, selected at runtime (`scheduler.h`):

| Algorithm | Notes |
|---|---|
| **FIFO** | Run to completion, no preemption — the baseline |
| **Round Robin** | 400 ms time slice, preemptive |
| **MLFQ** | **3-level Multi-Level Feedback Queue** with demotion between levels |

Runs on up to **4 CPUs** (`MAX_CPUS`), so the scheduler assigns tasks across cores rather than to a single run queue.

Reported metrics: average turnaround time, average response time, scheduling decision counts per algorithm, processes completed.

## Virtual memory

Four page-replacement policies (`virtmem.h`):

| Policy | Notes |
|---|---|
| **FIFO** | Evict oldest resident page |
| **RANDOM** | Uniform random victim — the control case |
| **CLOCK** | Second-chance approximation of LRU |
| **LRU** | True least-recently-used via an eviction array timestamped on access |

Backed by a real memory hierarchy:
- **Page tables** per process and a global **frame table**
- A **free-frame stack** for O(1) allocation
- **Swap in / swap out** to a hash-indexed swap store (`uthash`) when frames run out
- A configurable **minimum free-frame threshold** that triggers proactive eviction

Reported metrics: total page accesses, page faults, swap-ins, swap-outs, and average interval between faults.

## Concurrency

The kernel is multithreaded — ~95 `pthread` call sites coordinate CPU threads, the process-request handler, and the timer. Socket I/O (`app-io.c`) carries typed request/response messages between each simulated process and the simulator, with a shared simulation clock passed in the message envelope so all parties agree on time.

## Repository contents

```
os-simulator-scheduling-memory-concurrency/
├── ossim.c            # simulator core, threads, main loop  (26 KB)
├── scheduler.c/.h     # FIFO, Round Robin, MLFQ
├── virtmem.c/.h       # page tables, frames, eviction, swap  (16 KB)
├── virtmem_types.h    # pte_t, frame_desc_t, free_stack_t
├── queue.c/.h         # generic process queue
├── burst_queue.c/.h   # CPU/IO burst sequences
├── app-io.c           # socket IPC for simulated processes
├── pcb.h              # process control block
├── msg.h              # IPC message envelope
└── uthash.h           # third-party hash macros (swap index)
```

## Building

```bash
cd os-simulator-scheduling-memory-concurrency
gcc -o ossim ossim.c scheduler.c virtmem.c queue.c burst_queue.c -lpthread
gcc -o app  app-io.c
```

Run the simulator, then launch one or more `app` processes to connect to it. Workloads are defined as CPU/IO burst sequences (`cpu_ms, io_ms, nice, [pages]`).

## Key takeaways

- **No scheduler wins on every metric.** FIFO has the best throughput on uniform workloads and the worst response time on mixed ones; MLFQ trades a little throughput for responsiveness. Running all three over the same workload is what makes the trade-off legible.
- **Page replacement performance is workload-dependent** — which is exactly why real kernels ship CLOCK-style approximations rather than true LRU. Having RANDOM as a control makes it obvious when a policy is genuinely doing better than chance.
- **Separate processes over sockets forced the design to be honest.** Once the "processes" are real programs the simulator can't inspect, every interaction has to go through an explicit protocol — which is what a syscall boundary actually is.
- **Concurrency bugs are not ordinary bugs.** They fail intermittently and depend on interleaving, so they have to be designed out rather than tested out.
