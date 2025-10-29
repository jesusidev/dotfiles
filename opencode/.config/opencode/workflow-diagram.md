# Agent Workflow Diagram

## Complete Feature Development Flow

```mermaid
flowchart TD
    Start([User Request]) --> Orchestrator[Workflow Orchestrator]
    
    Orchestrator --> Decision{Request Type?}
    
    Decision -->|Simple Task| SimpleRoute[Route to Subagent]
    SimpleRoute --> Review[Reviewer Subagent]
    SimpleRoute --> Build[Build Agent Subagent]
    SimpleRoute --> Coder[Coder Agent Subagent]
    SimpleRoute --> Docs[Documentation Subagent]
    
    Decision -->|Complex Feature| Phase1[Phase 1: Analysis]
    
    Phase1 --> CodebaseAnalysis[Codebase Agent<br/>Analysis Mode]
    CodebaseAnalysis --> FeatureAnalyst[Feature Analyst Subagent]
    FeatureAnalyst --> PatternDoc[Create Pattern Doc<br/>docs/patterns/feature-patterns.md]
    
    PatternDoc --> Phase2[Phase 2: Planning]
    Phase2 --> TaskManager[Task Manager]
    TaskManager --> TaskPlan[Create Task Plan<br/>tasks/subtasks/feature/]
    TaskPlan --> Approval{User Approval?}
    
    Approval -->|No| TaskManager
    Approval -->|Yes| Phase3[Phase 3: Implementation]
    
    Phase3 --> CodebaseImpl[Codebase Agent<br/>Implementation Mode]
    
    CodebaseImpl --> SubtaskLoop{More Subtasks?}
    
    SubtaskLoop -->|Yes| ReadSubtask[Read Subtask<br/>seq-task.md]
    ReadSubtask --> CoderAgent[Coder Agent Subagent<br/>Implement Code]
    CoderAgent --> TesterAgent[Tester Subagent<br/>Write Tests]
    TesterAgent --> Validate[Validate<br/>Type Check, Lint, Tests]
    Validate --> UpdateStatus[Update Task Status<br/>Mark Complete in Index]
    UpdateStatus --> SubtaskLoop
    
    SubtaskLoop -->|No| Phase4[Phase 4: Quality Assurance]
    
    Phase4 --> ReviewerAgent[Reviewer Subagent<br/>Code Review]
    ReviewerAgent --> Phase5[Phase 5: Build Validation]
    
    Phase5 --> BuildAgent[Build Agent Subagent<br/>Build Check]
    BuildAgent --> Phase6[Phase 6: Documentation]
    
    Phase6 --> DocsAgent[Documentation Subagent<br/>Update Docs & Patterns]
    DocsAgent --> UpdatePatterns[Update Pattern Doc<br/>docs/patterns/feature-patterns.md]
    UpdatePatterns --> Complete([Feature Complete])
    
    Review --> SimpleComplete([Task Complete])
    Build --> SimpleComplete
    Coder --> SimpleComplete
    Docs --> SimpleComplete
    
    style Orchestrator fill:#e1f5ff
    style CodebaseAnalysis fill:#fff4e1
    style TaskManager fill:#ffe1f5
    style CodebaseImpl fill:#fff4e1
    style FeatureAnalyst fill:#f0f0f0
    style CoderAgent fill:#f0f0f0
    style TesterAgent fill:#f0f0f0
    style ReviewerAgent fill:#f0f0f0
    style BuildAgent fill:#f0f0f0
    style DocsAgent fill:#f0f0f0
    style PatternDoc fill:#e8f5e9
    style TaskPlan fill:#e8f5e9
    style UpdatePatterns fill:#e8f5e9
```

## Agent Hierarchy

```mermaid
graph TD
    WO[Workflow Orchestrator<br/>Primary Agent]
    
    WO --> CA[Codebase Agent<br/>Primary Agent]
    WO --> TM[Task Manager<br/>Primary Agent]
    
    CA --> FA[Feature Analyst<br/>Subagent]
    CA --> COD[Coder Agent<br/>Subagent]
    CA --> TST[Tester<br/>Subagent]
    
    WO --> REV[Reviewer<br/>Subagent]
    WO --> BLD[Build Agent<br/>Subagent]
    WO --> DOC[Documentation<br/>Subagent]
    
    style WO fill:#e1f5ff
    style CA fill:#fff4e1
    style TM fill:#ffe1f5
    style FA fill:#f0f0f0
    style COD fill:#f0f0f0
    style TST fill:#f0f0f0
    style REV fill:#f0f0f0
    style BLD fill:#f0f0f0
    style DOC fill:#f0f0f0
```

## Artifacts Created During Flow

```mermaid
flowchart LR
    Start([Feature Request]) --> P1[Phase 1: Analysis]
    P1 --> A1[Pattern Documentation]
    
    A1 --> P2[Phase 2: Planning]
    P2 --> A2[Task Index README]
    P2 --> A3[Task Files]
    
    A3 --> P3[Phase 3: Implementation]
    P3 --> A4[Source Code Files]
    P3 --> A5[Test Files]
    P3 --> A6[Updated Task Status]
    
    A6 --> P4[Phase 4-6: QA and Docs]
    P4 --> A7[Review Feedback]
    P4 --> A8[Build Validation]
    P4 --> A9[Updated Documentation]
    P4 --> A10[Updated Pattern Doc]
    
    style A1 fill:#e8f5e9
    style A2 fill:#e8f5e9
    style A3 fill:#e8f5e9
    style A4 fill:#fff9c4
    style A5 fill:#fff9c4
    style A6 fill:#e8f5e9
    style A7 fill:#ffe0b2
    style A8 fill:#ffe0b2
    style A9 fill:#e8f5e9
    style A10 fill:#e8f5e9
```

## Phase Details

### Phase 1: Analysis
- **Agent:** @codebase-agent (analysis mode)
- **Subagent:** @feature-analyst
- **Output:** `docs/patterns/{feature}-patterns.md`
- **Purpose:** Understand existing codebase patterns relevant to the feature request

### Phase 2: Planning
- **Agent:** @task-manager
- **Input:** Pattern analysis from Phase 1
- **Output:** Task plan in `tasks/subtasks/{feature}/`
- **Purpose:** Break down feature into atomic subtasks

### Phase 3: Implementation
- **Agent:** @codebase-agent (implementation mode)
- **Subagents:** @coder-agent, @tester
- **Output:** Source code + tests + updated task status
- **Purpose:** Implement each subtask sequentially

### Phase 4: Quality Assurance
- **Subagent:** @reviewer
- **Output:** Code review feedback
- **Purpose:** Validate code quality and security

### Phase 5: Build Validation
- **Subagent:** @build-agent
- **Output:** Build validation results
- **Purpose:** Ensure project compiles successfully

### Phase 6: Documentation
- **Subagent:** @documentation
- **Output:** Updated documentation (README, API docs, pattern docs)
- **Purpose:** Keep docs current with changes and update pattern documentation with new patterns discovered during implementation
- **Pattern Update:** Reviews implementation and updates `docs/patterns/{feature}-patterns.md` to prevent drift
