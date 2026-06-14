---
name: ca-component-coupling
description: Apply ADP, SDP, and SAP to manage dependencies between components
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Component Coupling Principles

Three principles (Robert C. Martin) that govern the relationships between components. They answer: "in which direction should dependencies flow, and how stable should each component be?"

## When to invoke

- Diagnosing why a change in one package forces changes in many others
- Reviewing the dependency graph of a system
- Deciding the direction of a new dependency between two modules

## The three principles

### ADP — Acyclic Dependencies Principle
**There must be no cycles in the component dependency graph.**
- Violation signal: `ComponentA` depends on `ComponentB`, which depends back on `ComponentA` (directly or transitively)
- Consequence: you cannot release, build, or test any component in the cycle independently
- Fix: break the cycle by introducing an interface/abstraction, or by moving the shared concept into a new component both depend on

### SDP — Stable Dependencies Principle
**Depend in the direction of stability.** A component should only depend on components that are more stable than itself.
- **Stability** = hard to change = many other components depend on it (it has many inward dependencies)
- Violation signal: a stable component depends on a volatile (frequently changing) component
- Fix: introduce an abstraction that the stable component depends on; let the volatile component implement it

### SAP — Stable Abstractions Principle
**Stable components should be abstract; unstable components can be concrete.**
- Stable = depended on by many → must be abstract so it can be extended without being modified
- Violation signal: a highly stable component (many dependents) is almost entirely concrete classes
- Fix: extract interfaces/abstract classes that capture the stable behavior; let implementations vary

## Stability metric

`I = (outgoing dependencies) / (incoming + outgoing dependencies)`
- `I = 0` → maximally stable (nothing depends on it outside the component, many depend on it)
- `I = 1` → maximally unstable (depends on many things, nothing depends on it)

Dependencies should flow from `I = 1` toward `I = 0`.

## Review checklist

- [ ] **ADP**: the dependency graph has no cycles (can be verified with static analysis tools)
- [ ] **SDP**: volatile components are not depended upon by stable components
- [ ] **SAP**: components with many inward dependencies expose abstract types, not concrete classes
- [ ] New dependencies are added in the direction of stability

## Common mistakes

- Creating a `common` or `shared` package that everything depends on, including volatile code (violates SDP)
- Ignoring cycle detection until the codebase becomes impossible to build incrementally
- Highly stable components that are 100% concrete (violates SAP, makes them rigid)
- Not using abstraction to break a cycle, choosing instead to restructure the whole dependency graph
