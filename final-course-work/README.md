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
- **Riverpod** — state management across the four role interfaces
- **Supabase** — managed Postgres, authentication, and realtime
- **PostgreSQL** — relational schema with RLS policies
- **Firebase Cloud Messaging** — event-driven push notifications to the relevant role
- **GDPR-aware design** — data protection, security, usability and scalability treated as requirements, not afterthoughts

### Architectural decisions, recorded

Technology choices were not left implicit. The project keeps **Architecture Decision Records (ADRs)** documenting each significant change and why it was made — including the migrations from Firebase to Supabase and from Provider to Riverpod, both of which were deliberate reversals of earlier decisions rather than defaults carried forward.

### Testing

Testing was layered rather than treated as one activity: **unit, interface, integration, end-to-end and security tests**, plus validation of each user profile against its own permission boundary — the layer that matters most when authorisation is the point of the system.

## Scope

The platform grew from **12 modules at the interim milestone to 39 by the final delivery**. The problem it addresses is a documented structural one: the fragmentation of digital platforms in Portuguese schools, framed against current research and TALIS 2024 data rather than assumed.

## Key takeaways

- **Authorisation belongs in the database.** Enforcing it in the UI means re-implementing it on every screen and trusting the client; RLS makes it structural.
- **Multi-tenancy is a modelling problem before it is a code problem.** The schema had to express "who may see this row" before any feature could be built safely.
- **Cross-platform paid off** — one Flutter codebase covering mobile and web was the difference between shipping the full scope and shipping a third of it.
- **Four user types is four products.** Each role needed its own information architecture; sharing one generic interface would have served none of them well.

---

## Evaluator feedback

Selected comments from the examining panel across the interim and final report evaluations and the oral defence. *Translated from the original Portuguese.*

> "The report presents work of a **high technical and conceptual level**, clearly aligned with a structural problem of the Portuguese education system: the fragmentation of school digital platforms. The theoretical framing is solid, well supported by current scientific literature and relevant empirical data (TALIS 2024), showing academic maturity."

> "The definition of objectives is ambitious, clear and coherent, reflected in a rigorous and well-structured requirements specification, with strong attention to critical aspects such as GDPR, security, usability and scalability. The proposed solution demonstrates **a very advanced state of development for an interim phase**, with a well-founded architecture and technology choices appropriate to the context."

> "The report presents significant technical work with **a structure above the average of the reports presented in previous years**. The group understands the chosen technologies in detail, and even intends to use specific versions — which demonstrates care and knowledge."

> "Solid, technically mature work […] The architectural evolution is well documented, with justified technical decisions and the use of ADRs. **The testing component is very positive**, including unit, interface, integration, end-to-end and security tests, and validation by user profile. Overall, an excellent piece of work that raises high expectations for the final result."

> "The methodological approach, the detailed planning and the division of responsibilities between the group members stand out positively."

On the oral defence:

> "Both Boshra and Tamim show great courage and learning in having presented and written a report in a non-native language, and are to be congratulated for it. Their commitment to the project is commendable, given that they were **highly autonomous** and still managed to put the MVP of their application into a usable environment. In the presentation they were able to **debate the supervisors' questions**, justify their choices and explore the subject behind them."

### Feedback taken forward

The panel's recommendations for the final phase, recorded here because they are the honest measure of what the project still needed:

- **Formal validation with real users.** The strongest criticism, and a fair one: the results presented were largely internal. Confirming usefulness and usability with teachers, parents, students and administrators in a pilot — distributed through Google Play testing and TestFlight — was the clear next priority.
- **Depth over module count.** Growing from 12 to 39 modules raises the risk of breadth without depth; the final delivery needed to show that the main flows are complete, coherent and integrated, not merely present.
- **Demonstrating pertinence.** Establishing real institutional interest through surveys or direct engagement with a school, rather than inferring demand from public data alone.
- **Justifying the two-tier choice.** A reasonable architectural challenge: why client-to-Supabase rather than a three-tier design with a REST server mediating database access. RLS answers part of it, but the trade-off deserves to be argued explicitly.
- **Report legibility.** Figures too small and set on dark backgrounds; density of quantitative metrics at the expense of a clear narrative thread.

---

## About the source code

**The source is not publicly available.** This is the university's final course work and the code remains coursework owned by the institution, so it isn't published here or anywhere else.

That constraint is why this write-up goes into more architectural detail than the other project READMEs — the design decisions are the substance, and they're described here in full. I'm happy to walk through the codebase, the schema, and the RLS policies directly in an interview.

The projects in this repository with **fully published source** are:

- [`distributed-computing`](../distributed-computing) — four Spring Boot microservices, Kafka, database-per-service
- [`web-programming`](../web-programming) — a Django 5.2 platform with a typed django-ninja REST API
- [`image-processing`](../image-processing) — C#/EmguCV traffic sign recognition
- [`algorithms-and-data-structures`](../algorithms-and-data-structures) and [`programming-languages-ii`](../programming-languages-ii) — Java, with JUnit 5 suites
