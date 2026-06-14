---
name: ca-solid
description: Review and apply SOLID principles to classes and modules
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# SOLID Principles

Five design principles (Robert C. Martin) that make software systems easier to maintain, extend, and understand. Violations are early indicators of designs that will become painful to change.

## When to invoke

- Reviewing a class, module, or interface for design quality
- Diagnosing why a change in one place breaks unrelated parts
- Deciding how to structure a new class or interface

## The five principles

### S — Single Responsibility Principle
A class should have **one reason to change** — meaning one actor (team, user type, or policy) that can cause it to change.
- Violation signal: the class has methods used by different actors (e.g., a `Report` class used by HR and by Finance)
- Fix: separate into two classes, each serving one actor

### O — Open/Closed Principle
A class should be **open for extension, closed for modification**.
- New behavior should be addable without changing existing code — achieved via abstraction (interfaces, polymorphism)
- Violation signal: adding a new feature requires `if/else` or `switch` in existing classes
- Fix: introduce an abstraction; new behavior is a new implementation

### L — Liskov Substitution Principle
**Subtypes must be substitutable** for their base types without altering correctness.
- Violation signal: a subclass overrides a method to throw, return nothing, or do less than the base
- Fix: favor composition over inheritance; design contracts carefully

### I — Interface Segregation Principle
**No client should depend on methods it does not use**.
- Violation signal: an interface has 10 methods but each implementer only needs 2–3
- Fix: split the interface into smaller, focused interfaces per client need

### D — Dependency Inversion Principle
**High-level modules must not depend on low-level modules**; both must depend on abstractions.
- Violation signal: a business rule class directly imports a database driver or HTTP client
- Fix: introduce an interface in the high-level layer; the low-level detail implements it

## Review checklist

- [ ] **SRP**: each class has one clear reason to change; its public methods serve one actor
- [ ] **OCP**: new behavior is added by extending, not by modifying existing classes
- [ ] **LSP**: subclasses honor the full contract of the base type
- [ ] **ISP**: interfaces are small and client-focused; no implementer is forced to stub methods
- [ ] **DIP**: domain/business classes depend only on abstractions, never on concrete infrastructure

## Common mistakes

- Treating SRP as "one method per class" (too extreme) — it is about one actor, not one method
- Adding `extends` for code reuse without checking behavioral substitutability (LSP violation)
- Creating one giant interface for a whole subsystem (ISP violation)
- Injecting concrete implementations instead of interfaces into high-level classes (DIP violation)
