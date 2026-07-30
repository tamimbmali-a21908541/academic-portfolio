# Operating Systems

> Core OS theory — processes, memory, concurrency, and synchronisation — applied by building an interactive simulator for CPU scheduling and page replacement with live metrics.

**Grade:** 12/20 · **ECTS:** 6 · **Year:** 2 · **Institution:** Universidade Lusófona

---

## Overview

Scheduling and paging algorithms are easy to state and hard to intuit. Building a simulator that visualises them step by step, and reports the metrics side by side, makes the trade-offs between them concrete.

## Topics studied

**Processes**
- Process lifecycle, states, and context switching
- CPU scheduling algorithms and their fairness/throughput trade-offs

**Memory**
- Virtual memory and paging
- Page replacement algorithms

**Concurrency**
- Race conditions and critical sections
- Synchronisation primitives
- Deadlock — conditions, prevention, and avoidance

## What I built

An interactive simulator that:
- Visualises **CPU scheduling** algorithm execution over a workload
- Visualises **page replacement** behaviour against a reference string
- Reports comparative **metrics** — waiting time, turnaround, fault counts

## Key takeaways

- **Scheduling algorithms trade fairness against throughput,** and no single algorithm wins on every metric. Seeing the numbers move as the workload changes is what makes that stick.
- **Page replacement performance is workload-dependent.** An algorithm that looks optimal on one reference string is beaten on another — which is exactly why real systems approximate rather than optimise.
- **Concurrency bugs are not ordinary bugs.** They fail intermittently and depend on interleaving, so they must be designed out rather than tested out.

---

> The simulator was built as a course deliverable; its source is not committed to this repository.
