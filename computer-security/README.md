# Computer Security

> **Status: in progress** — not yet started.

**ECTS:** 5 · **Year:** 3 · **Institution:** Universidade Lusófona

---

## Course scope

Information security fundamentals — cryptography, authentication and authorisation, network security, common vulnerability classes, and secure development practice.

## Related work already completed

Security-relevant decisions appear across several completed projects:

- **[Final Course Work](../final-course-work)** — authorisation enforced through **PostgreSQL Row-Level Security** at the data layer rather than in the client, so a modified client cannot read another user's records.
- **[Web Programming](../web-programming)** — a **safe expression evaluator** that parses user input to an AST and walks it with an operator whitelist instead of calling `eval()`; environment-based secret configuration with no hardcoded credentials; OAuth via django-allauth and JWT.
- **[Cloud Information Systems](../cloud-information-systems)** — network isolation with AWS **VPC** as the foundational security boundary.
- **[Distributed Computing](../distributed-computing)** — per-service credential isolation, with `.env` templates kept out of version control.

---

> This course is one of two remaining for degree completion. It will be updated here once finished.
