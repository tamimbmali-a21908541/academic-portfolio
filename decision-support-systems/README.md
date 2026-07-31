# Decision Support Systems

> Business intelligence end to end — dimensional modelling, ETL pipelines in Pentaho, and reporting in Power BI, on top of an Oracle relational base.

**Grade:** 10/20 · **ECTS:** 6 · **Year:** 2 · **Institution:** Universidade Lusófona

---

## Overview

Where the Databases course optimised schemas for transactional correctness, this one optimised them for analysis — which turns out to mean the opposite decisions.

## What I did

**Modelling**
- Relational modelling with **Oracle SQL Data Modeler**
- **Dimensional modelling** — fact and dimension tables, star schemas

**ETL**
- **Pentaho Data Integration** — extracting from operational sources, transforming, and loading into the analytical model

**Reporting**
- **Power BI** — dashboards and reports over the dimensional model

## Key takeaways

- **Normalised and dimensional models optimise for opposite things.** 3NF minimises redundancy for safe writes; a star schema deliberately denormalises to minimise joins for fast reads. Neither is "more correct" — they serve different workloads.
- **ETL is where data quality is decided.** Everything downstream inherits whatever the transformation step let through.
- **A report is only as good as its grain.** Getting the fact table's granularity right determines which questions the model can answer at all.

---

> Coursework consisted of data models, Pentaho transformations, and Power BI reports rather than committed source code.
