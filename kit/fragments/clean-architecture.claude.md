## Clean Architecture

This project follows patterns from "Clean Architecture" (Robert C. Martin).

Dependencies must point inward: Frameworks → Adapters → Use Cases → Entities.
No inner layer may import from an outer layer.

Use the Clean Architecture skills to guide implementation and review:

- `/ca-guide` — unsure which pattern to use? Start here
- `/ca-solid` — reviewing class and interface design (SRP, OCP, LSP, ISP, DIP)
- `/ca-component-cohesion` — what belongs in a package or library (REP, CCP, CRP)
- `/ca-component-coupling` — dependency directions between packages (ADP, SDP, SAP)
- `/ca-dependency-rule` — verifying correct layer boundaries
- `/ca-screaming-architecture` — folder structure that reveals domain intent
- `/ca-use-case` — implementing a business operation as an Interactor
- `/ca-humble-object` — separating testable logic from framework-coupled code
- `/ca-ports-adapters` — pluggable infrastructure via Ports & Adapters
- `/ca-boundary-objects` — Request/Response models, Presenters, Controllers
- `/ca-details` — keeping business rules independent of frameworks and databases
- `/ca-testing-strategy` — layered tests aligned with architecture boundaries
