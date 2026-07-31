# Computer Networks

> Design and configuration of a multi-site corporate network in Cisco Packet Tracer — VLAN segmentation, inter-site links, IP addressing, core servers, and wireless access.

**Grade:** 11/20 · **ECTS:** 6 · **Year:** 2 · **Institution:** Universidade Lusófona

---

## Overview

The brief was to build the network infrastructure for a company operating across several sites: segment the internal network by department, connect the branches, provide shared services, and document the result as a technical report.

## What the topology covers

- **VLAN segmentation** — departments isolated into separate broadcast domains, with inter-VLAN routing where the business requires it
- **IP addressing plan** — subnets allocated per site and per VLAN, sized to the host count rather than uniformly
- **Inter-site connectivity** — routed links between the head office and branch offices
- **Server infrastructure** — core network services placed in the topology
- **Wireless access** — access points integrated into the wired VLAN structure

## Tech and tools

- **Cisco Packet Tracer** — topology design, device configuration, and simulation
- Cisco IOS configuration — switching, VLANs, routing, addressing

## Repository contents

```
FinalProject.pkt    # Cisco Packet Tracer topology (open in Packet Tracer 8+)
```

## Key takeaways

- **VLANs are an organisational tool as much as a technical one** — the segmentation maps to how the company is actually structured, not to an arbitrary technical split.
- **Addressing plans have to be designed before configuration.** Retrofitting a subnet scheme onto a built topology is far more work than planning it up front.
- **Simulation makes failure cheap.** Packet Tracer's ability to trace a packet hop by hop turned "it doesn't work" into a specific misconfigured interface.
