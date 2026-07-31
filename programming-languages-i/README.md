# Programming Languages I

> Systems programming in C — pointers, manual memory management, dynamic data structures, and file I/O.

**Grade:** 10/20 · **ECTS:** 5 · **Year:** 1 · **Institution:** Universidade Lusófona

---

## Topics studied

**Memory**
- Pointers and pointer arithmetic
- Dynamic allocation with `malloc` / `free`
- The stack/heap distinction, and what leaks and dangling pointers actually are

**Data structures, built by hand**
- Linked lists
- Dynamic arrays
- Queues (FIFO) and stacks

**Systems**
- File I/O and serialisation
- Structs and modular program organisation

## Project — Trotify

A scooter-sharing management application written in C, applying dynamic memory and linked structures to model vehicles, users, and trips with persistence to file.

## Why it matters for software

C removes the safety net, which is precisely its pedagogical value: implementing a linked list with explicit `malloc`/`free` makes ownership, lifetime, and aliasing concrete in a way a garbage-collected language never does. Every data structure re-encountered later in [Algorithms and Data Structures](../algorithms-and-data-structures) had already been built here from nothing.

---

> Assessed by project and examination; source not committed to this repository.
