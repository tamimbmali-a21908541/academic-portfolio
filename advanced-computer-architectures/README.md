# Advanced Computer Architectures

> Embedded systems work on Arduino — sensor acquisition, actuator control, and timer-driven interrupts — prototyped and simulated in Tinkercad.

**Grade:** 14/20 · **ECTS:** 6 · **Year:** 2 · **Institution:** Universidade Lusófona

---

## Overview

A series of circuit-and-firmware exercises building up from reading a single sensor to a free-form project combining several components under interrupt-driven control.

## What I built

**Sensors**
- Ultrasonic distance sensor
- PIR motion sensor
- Temperature sensor
- Light-dependent resistor (luminosity)

**Actuators and output**
- LCD display
- LEDs
- Motors
- Matrix keypad input

**Techniques**
- Analogue and digital sensor reading
- Actuator control driven by sensor thresholds
- **Timer interrupts** — moving periodic work off the main loop so timing stays accurate regardless of what else is running
- A final open-ended project integrating multiple sensors and actuators

## Tech and tools

- **Arduino** (C/C++)
- **Tinkercad Circuits** — circuit design and simulation

## Key takeaways

- **Interrupts change how you structure firmware.** Polling in `loop()` is simple but its timing drifts with workload; a timer interrupt gives you a guarantee.
- **The circuit is half the bug.** A significant share of problems were wiring and pull-up resistors, not code — hardware debugging is a distinct skill.
- **Constrained resources force explicit decisions** about memory and timing that higher-level environments let you ignore.

---

> This course was assessed through Tinkercad simulations rather than committed source files.
