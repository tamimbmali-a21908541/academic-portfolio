# Databases

> Relational database design from conceptual model to working schema — Entity-Relationship modelling, normalisation to third normal form, SQL, and ETL.

**Grade:** 12/20 · **ECTS:** 6 · **Year:** 2 · **Institution:** Universidade Lusófona

---

## Overview

The course ran the full modelling pipeline: model the domain conceptually, translate it into relations, normalise it, then implement and query it.

## What I did

**Conceptual modelling**
- Entity-Relationship diagrams — entities, attributes, relationships, and cardinality
- Identifying keys and participation constraints

**Logical modelling**
- Translating ER diagrams into the relational model
- **Normalisation through to 3NF** — eliminating repeating groups, partial dependencies, and transitive dependencies

**Implementation**
- SQL — DDL for schema creation with constraints, DML for querying
- Stored procedures and triggers
- ETL processes for loading and transforming data

A restaurant management schema served as the running case study.

## Key takeaways

- **Normalisation is a correctness tool, not a style preference.** Each normal form removes a specific class of update anomaly; knowing which anomaly is what makes the rule memorable.
- **Constraints in the schema beat validation in the application.** The database is the one place every writer must pass through.
- **The ER diagram is where design errors are cheap to fix.** A modelling mistake caught on paper costs minutes; the same mistake caught after the application is built costs a migration.

---

> Coursework consisted of diagrams and SQL scripts rather than an application codebase. Related applied work appears in [`decision-support-systems`](../decision-support-systems) and the Django applications in [`web-programming`](../web-programming).
