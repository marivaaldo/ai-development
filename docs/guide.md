# AI-First Project Evolution Guide

> Goal: build a project ready for sustainable growth, human collaboration, RAG, agents, MCP, generative AI, and automation — without falling into the trap of premature documentation.

---

# Phase 0 — Initial Project

## Minimal structure

```text
project/
├── src/
├── tests/
├── docs/
├── specs/
├── adr/
├── glossary/
└── README.md
```

## Goals

* Organized code
* Minimal documentation
* Important decisions recorded
* Standardized business language

---

# README

## Purpose

Entry point for humans and AI.

## Must contain

* Project overview
* Tech stack
* How to run locally
* How to run tests
* Project structure
* Important links

---

# Glossary

## Purpose

Define business terms.

## Example

```text
Consent
Data Subject
Controller
Processor
Cookie Category
Legal Basis
```

## Benefits

* AI understands the domain better
* Avoids ambiguity
* Facilitates onboarding

---

# ADR (Architecture Decision Records)

## Purpose

Record architectural decisions.

## Structure

```text
adr/
├── architecture/
├── infrastructure/
├── ai/
└── product/
```

## First ADRs

```text
ADR-001 DDD
ADR-002 Hexagonal Architecture
ADR-003 Multi-Tenancy
ADR-004 PostgreSQL
ADR-005 Redis
```

## Don't do

Don't try to reconstruct the entire project history.

---

# Specs

## Purpose

Document features.

## Structure

```text
specs/
└── feature-name/
    ├── requirements.md
    ├── acceptance-criteria.md
    ├── technical-notes.md
    └── tasks.md
```

## Rule

Every relevant new feature must have a spec.

---

# Phase 1 — Consolidated Architecture

## Structure

```text
project/
├── architecture/
├── docs/
├── specs/
├── adr/
└── glossary/
```

---

# Architecture

## Purpose

Explain the system.

## Structure

```text
architecture/
├── bounded-contexts/
├── diagrams/
├── deployment/
├── integrations/
└── data-flow/
```

## Example

```text
architecture/
└── bounded-contexts/
    consent.md
    scanner.md
    billing.md
```

---

# C4 Model

Recommended for architectural documentation.

## Levels

```text
System Context
Container
Component
Code
```

Tools:

* PlantUML
* Mermaid

---

# Domain-Driven Design (DDD)

## Record

* Bounded Contexts
* Aggregates
* Entities
* Value Objects
* Domain Services

## Suggested structure

```text
architecture/
└── domain/
```

---

# Event Storming

## Use

Map complex domains.

## Store results

```text
docs/
└── event-storming/
```

---

# Phase 2 — Operational Standardization

## Structure

```text
project/
├── runbooks/
├── skills/
└── prompts/
```

---

# Runbooks

## Purpose

Document operations.

## Examples

```text
runbooks/
├── deployment.md
├── rollback.md
├── restore-backup.md
├── incident-response.md
└── rotate-secrets.md
```

---

# Skills

## Purpose

Reusable knowledge for AI.

## Structure

```text
skills/
├── adr-writer/
├── code-review/
├── architecture-review/
├── security-review/
└── feature-planning/
```

## Example

```text
skills/
└── code-review/
    skill.md
```

---

# Prompts

## Purpose

Shared prompts.

## Structure

```text
prompts/
├── architecture.md
├── debugging.md
├── review.md
└── planning.md
```

---

# Phase 3 — Knowledge Layer

At this stage the project starts becoming AI-Native.

---

# Embeddings

## What they are

Vector representations of content.

## Applications

* Semantic search
* RAG
* Similarity

---

# Vector Database

## Options

* Qdrant
* pgvector
* Pinecone
* Weaviate

## Recommendation

```text
Small project:
pgvector

Medium/large project:
Qdrant
```

---

# RAG (Retrieval-Augmented Generation)

## Structure

```text
rag/
├── ingestion/
├── chunking/
├── embeddings/
├── indexing/
└── retrieval/
```

## Indexed sources

```text
README
ADRs
Specs
Architecture
Runbooks
Glossary
```

## Flow

```text
Question
↓
Embedding
↓
Vector search
↓
Context
↓
LLM
```

---

# Knowledge Base

## Priority sources

```text
adr/
architecture/
specs/
runbooks/
glossary/
```

---

# Phase 4 — AI Integrated into Development

## Structure

```text
project/
├── workflows/
├── agents/
└── mcp/
```

---

# Workflows

## Purpose

Define processes.

## Example

```text
workflows/
├── new-feature/
├── bug-fix/
├── release/
└── incident-investigation/
```

---

# Workflow Example

```text
Create Spec
↓
Create ADR
↓
Plan
↓
Implement
↓
Test
↓
Open PR
```

---

# Agentic Workflow

## Concept

AI-driven flow.

## Example

```text
Planner
↓
Developer
↓
Reviewer
↓
QA
```

---

# Multi-Agent

## When to use

Large projects.

## Example

```text
agents/
├── architect/
├── backend/
├── frontend/
├── reviewer/
├── qa/
└── product-owner/
```

## When NOT to use

Small projects.

---

# MCP (Model Context Protocol)

## Purpose

Connect AI to systems.

## Structure

```text
mcp/
├── github/
├── postgres/
├── jira/
├── slack/
└── internal-tools/
```

## Use cases

* Query database
* Open PR
* Fetch tickets
* Run scripts

---

# Tool Calling

## Concept

Allow AI to execute actions.

## Examples

```text
getUsers()
listConsents()
openTicket()
```

---

# Function Calling

Structured version of Tool Calling.

---

# Phase 5 — Observability and Governance

Often overlooked.

---

# Observability

## Tools

* OpenTelemetry
* Prometheus
* Grafana

## Documentation

```text
docs/
└── observability/
```

---

# AI Telemetry

Monitor:

* Tokens
* Costs
* Latency
* Accuracy
* Tool usage

---

# Evaluation Framework

Create tests for AI.

## Structure

```text
evaluations/
├── rag/
├── prompts/
└── agents/
```

---

# AI Security

## Document

* Prompt Injection
* Data Leakage
* Context Segregation
* Multi-Tenancy

## Structure

```text
docs/
└── ai-security/
```

---

# Phase 6 — Organizational Scale

---

# Developer Portal

Centralize knowledge.

Examples:

* Backstage
* OpenMetadata

---

# Systems Catalog

```text
systems/
├── consent-service.md
├── scanner-service.md
├── auth-service.md
└── billing-service.md
```

---

# RFCs

Before implementation.

## Structure

```text
rfcs/
```

Flow:

```text
RFC
↓
Discussion
↓
Approval
↓
ADR
↓
Implementation
```

---

# Maturity Roadmap

## Level 1

* README
* Glossary
* ADR
* Specs

## Level 2

* Architecture
* Runbooks
* Skills
* Prompts

## Level 3

* Embeddings
* Vector DB
* RAG

## Level 4

* MCP
* Tool Calling
* Workflows

## Level 5

* Agents
* Multi-Agent
* Evaluation Framework

## Level 6

* Developer Portal
* Systems Catalog
* AI Governance

---

# Golden Rule

Never create documentation because the structure calls for it.

Create it when:

1. It solves a real problem.
2. It will be reused.
3. It can be consumed by humans or AI.
4. It reduces recurring doubts.
5. It reduces rework.

The best documentation for AI is not the largest. It is the most reliable, up-to-date, and closest to the real development flow.
