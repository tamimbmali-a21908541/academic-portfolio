# Final Course Work

> A multi-role school management platform built in Flutter and Supabase, serving administrators, teachers, students, and parents from a single cross-platform codebase, with access control enforced at the database level through Row-Level Security.

**Grade:** 17/20 · **ECTS:** 20 · **Year:** 3 · **Institution:** Universidade Lusófona

*The highest-weighted project of the programme (20 ECTS).*

---

## Overview

A school runs on information that different people are allowed to see different slices of. A parent may see their own child's grades; a teacher sees their own classes; an administrator sees everything. Getting that wrong is the whole problem — so the authorisation model, not the feature list, drove the design.

## Architecture

```
┌─────────────────────────────────────────────┐
│  Flutter app  (Android · iOS · Web)         │
│  Four role-specific interfaces              │
│  Admin · Teacher · Student · Parent         │
└──────────────────┬──────────────────────────┘
                   │ Supabase client
┌──────────────────▼──────────────────────────┐
│  Supabase                                   │
│  ├── Auth          (identity, sessions)     │
│  ├── PostgreSQL    (relational core)        │
│  ├── Row-Level Security  ◄── authorisation  │
│  └── Notifications                          │
└─────────────────────────────────────────────┘
```

### Security model

Authorisation is enforced by **PostgreSQL Row-Level Security policies**, not by the client. A role's permissions are a property of the database row, so a compromised or modified client still cannot read another family's data. The Flutter app's role-specific UIs are a usability layer on top of that, not the security boundary.

This is the design decision the project turns on: putting the policy where the data lives means there is exactly one place to get it right, rather than one place per screen.

## Roles and capabilities

| Role | Sees |
|---|---|
| Administrator | Full school: users, classes, enrolment, configuration |
| Teacher | Own classes — attendance, grades, communication |
| Student | Own record — schedule, grades, notifications |
| Parent | Their own children's records only |

## Tech stack

- **Flutter / Dart** — single codebase targeting Android, iOS, and Web
- **Supabase** — managed Postgres, authentication, and realtime
- **PostgreSQL** — relational schema with RLS policies
- **Push notifications** — event-driven updates to the relevant role

## Key takeaways

- **Authorisation belongs in the database.** Enforcing it in the UI means re-implementing it on every screen and trusting the client; RLS makes it structural.
- **Multi-tenancy is a modelling problem before it is a code problem.** The schema had to express "who may see this row" before any feature could be built safely.
- **Cross-platform paid off** — one Flutter codebase covering mobile and web was the difference between shipping the full scope and shipping a third of it.
- **Four user types is four products.** Each role needed its own information architecture; sharing one generic interface would have served none of them well.

---

## About the source code

**The source is not publicly available.** This is the university's final course work and the code remains coursework owned by the institution, so it isn't published here or anywhere else.

That constraint is why this write-up goes into more architectural detail than the other project READMEs — the design decisions are the substance, and they're described here in full. I'm happy to walk through the codebase, the schema, and the RLS policies directly in an interview.

The projects in this repository with **fully published source** are:

- [`distributed-computing`](../distributed-computing) — four Spring Boot microservices, Kafka, database-per-service
- [`web-programming`](../web-programming) — a Django 5.2 platform with a typed django-ninja REST API
- [`image-processing`](../image-processing) — C#/EmguCV traffic sign recognition
- [`algorithms-and-data-structures`](../algorithms-and-data-structures) and [`programming-languages-ii`](../programming-languages-ii) — Java, with JUnit 5 suites
