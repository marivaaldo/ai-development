---
name: ca-component-cohesion
description: Apply REP, CCP, and CRP to design cohesive components and packages
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Component Cohesion Principles

Three principles (Robert C. Martin) that guide what belongs inside a component (library, package, module, or deployable unit). They answer: "which classes belong together?"

## When to invoke

- Deciding whether to split or merge packages/libraries
- Reviewing why a change to one feature forces unrelated packages to release new versions
- Designing the structure of a new library or module

## The three principles

### REP — Release/Reuse Equivalency Principle
**The granule of reuse is the granule of release.** Classes that are released together should be reusable together; if you need only one class from a package, you should not be forced to take the rest.
- Violation signal: users of your library must upgrade to get a fix in a class they never use
- Implication: a component must be coherent enough to be released and versioned as a single unit

### CCP — Common Closure Principle
**Classes that change for the same reasons and at the same times belong together.** This is the SRP applied to components.
- Violation signal: a single business requirement change forces you to modify five separate packages
- Fix: co-locate classes that respond to the same change driver (same actor, same policy)
- Priority for applications (change management matters more than reuse)

### CRP — Common Reuse Principle
**Do not force users of a component to depend on things they do not need.** This is the ISP applied to components.
- Violation signal: depending on a component forces you to recompile/redeploy when an unrelated class in it changes
- Fix: split the component so that clients only depend on what they actually use
- Priority for libraries (reuse granularity matters more than change management)

## The tension triangle

REP, CCP, and CRP pull in different directions — you cannot fully satisfy all three simultaneously:
- **CCP + REP** → easy to change but large components (pulls classes together)
- **CRP** → small, fine-grained components (pulls classes apart)
- Balance depends on whether you're building a library (favor CRP) or an application (favor CCP)

## Review checklist

- [ ] **REP**: everything in the component is released and versioned together; nothing is there "just in case"
- [ ] **CCP**: a single feature change touches only one or two components, not many
- [ ] **CRP**: depending on this component does not drag in unrelated classes or transitive dependencies
- [ ] The balance between CCP and CRP reflects the component's purpose (app vs library)

## Common mistakes

- Grouping classes by technical role (`utils/`, `models/`) instead of by change driver (violates CCP)
- Packaging every class separately to maximize CRP, making dependency management unmanageable
- Ignoring REP by releasing components that contain half-finished or unrelated classes
