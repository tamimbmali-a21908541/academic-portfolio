# Algorithms and Data Structures

> **DEISI MDB** — a Java engine that ingests large multi-file movie datasets from CSV and answers analytical queries over them, with the data structures chosen per query to keep lookups off the O(n) path.

**Grade:** 10/20 · **ECTS:** 6 · **Year:** 1 · **Institution:** Universidade Lusófona

---

## Overview

The task: load six related CSV files (movies, actors, directors, genres, genre↔movie relations, votes) totalling thousands of records, tolerate malformed input gracefully, and then answer a set of non-trivial queries fast enough that a naive scan won't do.

The interesting part is not the parsing — it's picking the right structure for each access pattern.

## Data structure choices

The loader builds both list and map views of the same data, because different queries need different access:

| Structure | Purpose | Why |
|---|---|---|
| `ArrayList<Movie>` (pre-sized 5000) | Ordered iteration, range queries | Avoids repeated array growth on load |
| `HashMap<Integer, Movie>` | Lookup by ID | O(1) instead of scanning the list |
| `HashMap<String, Actor>` | Lookup by actor name | Name-keyed queries are common |
| `HashSet<Integer>` | Duplicate movie ID detection | O(1) membership during ingest |
| Relation lists | Genre↔movie, votes | Many-to-many kept out of the entity objects |

Pre-sizing the collections (`new ArrayList<>(15000)` for actors) is a deliberate choice: it trades memory up front to avoid the repeated reallocation-and-copy cost of growing a list across thousands of inserts.

## Error handling

The parser doesn't abort on bad input. For each of the six files it independently tracks:

- count of valid vs invalid rows
- an error code (`PARSE`, `DUPLICATE`, `INVALID`, or none)
- the **first** offending line number

This means a single malformed row in the actors file doesn't cost you the movie data, and the report tells you exactly where to look.

## Queries implemented

Each has a dedicated JUnit test class:

- Count movies / count movies by director
- Actors appearing across two given years
- Movies featuring a given actor in a given year
- Movies with ID below a threshold
- Top month by movie count
- Top movies by gender representation, and by gender bias
- Actors who worked with a given director

## Tech stack

- **Java 17**
- **JUnit 5** — 20+ test classes covering parsing success, parsing failure, and each query
- Custom CSV parsing (no external library)

## Repository contents

```
src/pt/ulusofona/aed/deisimdb/
├── Main.java          # ingest pipeline + query implementations
├── Movie.java         # entities
├── Actor.java
├── Director.java
├── Genre.java
├── DateUtils.java     # date parsing helpers
├── Constants.java
└── Test*.java         # JUnit 5 suites, one per query/concern
```

## Running the tests

The project was developed as a plain source tree without a build tool. Import it into IntelliJ IDEA or Eclipse as a Java 17 project with JUnit 5 on the test classpath, or run from the command line:

```bash
javac -d out -cp junit-platform-console-standalone.jar src/pt/ulusofona/aed/deisimdb/*.java
java -jar junit-platform-console-standalone.jar --class-path out --scan-class-path
```

## Key takeaways

- **The structure choice *is* the algorithm.** Adding a `HashMap` index alongside the list turned repeated linear scans into constant-time lookups; nothing else about the code changed.
- **Pre-sizing collections matters at scale.** Amortised O(1) appends still cost real time when you're doing tens of thousands of them.
- **Partial failure beats total failure** when parsing untrusted input. Per-file error tracking made the loader usable against dirty data.
