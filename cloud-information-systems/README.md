# Cloud Information Systems

> Cloud architecture models and AWS services in practice — containerising applications with Docker and deploying them into networked cloud environments.

**Grade:** 13/20 · **ECTS:** 5 · **Year:** 3 · **Institution:** Universidade Lusófona

---

## Overview

The course worked through the cloud service models conceptually and then made them concrete by deploying real applications onto AWS.

## Topics and practical work

**Service models**
- **IaaS** — raw compute and network, maximum control
- **PaaS** — managed runtime, application-level concerns only
- **SaaS** — consumption without operation

**AWS services used**
- **EC2** — virtual machine provisioning
- **VPC** — network isolation, subnets, and routing
- **Elastic Beanstalk** — managed application deployment (PaaS)

**Containerisation**
- **Docker** — packaging applications with their dependencies so the deployment target stops mattering

## Key takeaways

- **The service models are a trade of control for operational burden.** EC2 gives you everything and makes everything your problem; Elastic Beanstalk takes both away. Choosing correctly means being honest about which you actually need.
- **VPC is where cloud security starts.** Network isolation is the boundary everything else is built on top of.
- **Containers decouple the application from the host**, which is what makes the same artefact runnable locally, on EC2, and in a managed platform.

---

> Practical work was performed in AWS and Docker environments rather than committed as source files.
