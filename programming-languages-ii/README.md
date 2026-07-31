# Programming Languages II

> **The Great Programming Journey** — a Java board game where players advance across tiles, fall into programming-themed "abysses", and use "tools" to escape. Built as an exercise in applying inheritance, polymorphism, and the factory pattern to a domain with many variants.

**Grade:** 10/20 · **ECTS:** 6 · **Year:** 2 · **Institution:** Universidade Lusófona

---

## Overview

The game's premise is a joke about a developer's life — the hazards are `StackOverflowAbyss`, `InfiniteLoopAbyss`, `SegFaultAbyss`, `BlueScreenAbyss`, `DuplicateCodeAbyss` — but the design problem underneath is real: you have a dozen hazard types and a handful of remedy types, each with different behaviour, and you need to add new ones without rewriting the game loop.

## Design

### Polymorphism over conditionals

Every hazard extends an abstract `Abyss`; every remedy implements `Tool`. `GameManager` never asks *what kind* of abyss a player landed on — it calls the abstract method and the subclass decides.

```
Abyss (abstract)                    Tool (interface)
├── StackOverflowAbyss              ├── IDETool
├── InfiniteLoopAbyss               ├── InheritanceTool
├── SegFaultAbyss                   ├── ExceptionHandlingTool
├── BlueScreenAbyss                 ├── FunctionalProgrammingTool
├── CrashAbyss                      ├── UnitTestsTool
├── DuplicateCodeAbyss              └── ProfessorHelpTool
├── ExceptionAbyss
├── FileNotFoundAbyss
├── LogicErrorAbyss
├── SideEffectsAbyss
├── SyntaxErrorAbyss
└── LLMAbyss
```

Adding a thirteenth hazard means adding one class. No `switch` statement anywhere has to change.

### Factories

`AbyssFactory` and `ToolFactory` centralise construction, so the board can be built from a config file without the loader knowing every concrete type.

### Encapsulation

`Player`, `Board`, and `Tile` expose behaviour, not fields. `Board` owns tile placement; `Player` owns position and inventory. `GameManager` coordinates them without reaching into either.

### Error handling

`InvalidFileException` is a custom checked exception for malformed game files — the loader distinguishes "this file is broken" from every other `IOException`.

## Tech stack

- **Java 17**
- **JUnit 5** — 6 test classes including edge cases and a comprehensive integration suite
- UML class diagrams produced before implementation

## Repository contents

```
src/pt/ulusofona/lp2/greatprogrammingjourney/
├── GameManager.java       # game loop and coordination
├── Board.java, Tile.java  # board model
├── Player.java
├── Abyss.java + 12 subclasses
├── Tool.java + 6 implementations
├── AbyssFactory.java, ToolFactory.java
├── InvalidFileException.java
└── Test*.java             # JUnit 5 suites
```

## Running

Import as a Java 17 project in IntelliJ IDEA or Eclipse with JUnit 5 on the test classpath. `Main.java` is the entry point.

## Key takeaways

- **Inheritance earns its keep when variants share a contract but differ in behaviour** — twelve abyss types, one call site.
- **The factory pattern decouples "what exists" from "who builds it"**, which is what made loading boards from files clean.
- **Designing the UML first paid off.** The class hierarchy was settled before any code existed, and it didn't need restructuring later.
- **Custom exceptions carry intent.** `InvalidFileException` says something `IOException` cannot.
