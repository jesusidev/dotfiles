# NextStack Agent Cost Model

_Last updated: November 27, 2025_

## 1. Methodology & Assumptions
- Pricing data comes from the provided pay-as-you-go table (USD per 1M tokens).
- Costs are calculated as `cost = (input_tokens/1,000,000 * price_in) + (output_tokens/1,000,000 * price_out)`.
- Token counts are derived from recent runs and prompt sizes defined in each agent spec (e.g., large context loads for @codebase-agent, multi-file diffs for @homepage-designer). Values represent an average invocation during a standard workflow; actual usage will fluctuate with task size.
- Quality scores (1-5) combine coverage, correctness, and UX polish. Higher scores assume every optional agent (design, accessibility, etc.) completes without issues.
- Cached-read/write discounts are excluded because the current workflows rely on fresh planning contexts.

## 2. Pricing Reference (Agents In Use)
| Model | Price In ($/1M) | Price Out ($/1M) | Notes |
| --- | --- | --- | --- |
| GPT 5.1 Codex | 1.07 | 8.50 | NextStack SaaS orchestrator + reviewer coverages |
| GPT 5.1 | 1.07 | 8.50 | Generic workflow orchestrator |
| Claude Opus 4.5 | 5.00 | 25.00 | Reserved for @homepage-designer where max quality is needed |
| Claude Sonnet 4.5 (≤200k) | 3.00 | 15.00 | Codebase agent, design, copywriting, accessibility subagents |
| Claude Haiku 4.5 | 1.00 | 5.00 | Task planner and build agent |
| Kimi K2 | 0.45 | 2.50 | Feature analyst |
| GLM 4.6 | 0.60 | 2.20 | Documentation subagent |
| Qwen3 Coder 480B | 0.45 | 1.50 | Tester subagent |
| Grok Code Fast 1 | Free | Free | Coding subagent (implementation bursts) |

## 3. Token & Cost Profile per Agent
| Agent | Model | Role | Input Tokens | Output Tokens | Total Tokens | Cost / Run (USD) | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| NextStack SaaS Orchestrator | GPT 5.1 Codex | Primary coordinator for NextStack workflows | 6,000 | 2,500 | 8,500 | **0.028** | Captures request context, routes phases, summarizes progress |
| Workflow Orchestrator | GPT 5.1 | Generic orchestrator used outside NextStack | 5,000 | 2,000 | 7,000 | **0.022** | Included for parity; not part of the NextStack flow by default |
| Codebase Agent (@codebase-agent) | Claude Sonnet 4.5 | Analysis + implementation lead | 12,000 | 6,000 | 18,000 | **0.126** | Loads multi-file context plus diffs; typically invoked twice per feature |
| Task Manager (@task-manager) | Claude Haiku 4.5 | Breaks work into subtasks | 4,000 | 2,000 | 6,000 | **0.014** | Light planning payload; usually one run per feature |
| Feature Analyst (@feature-analyst) | Kimi K2 | Pattern discovery | 10,000 | 5,000 | 15,000 | **0.017** | Scans codebase references and produces docs |
| UX Agent (@ux-agent) | Claude Opus 4.5 | Design system analysis + page design | 12,000 | 6,000 | 18,000 | **0.252** | Analysis mode: design system extraction; Design mode: page specifications |
| Copywriting Agent (@copywriting-agent) | Claude Sonnet 4.5 | Messaging / tone | 5,000 | 3,000 | 8,000 | **0.060** | Only runs when copy changes are requested |
| Coder Agent (@coder-agent) | Grok Code Fast 1 | Writes code per subtask | 6,000 | 4,000 | 10,000 | **0.000** | Free tier; still consumes ~10k tokens per burst |
| Tester (@tester) | Qwen3 Coder 480B | Test author + runner | 5,000 | 4,000 | 9,000 | **0.008** | Often invoked twice (unit + regression) |
| Reviewer (@reviewer) | GPT 5.1 Codex | Code review & security | 6,000 | 4,000 | 10,000 | **0.040** | High scrutiny; one full run per feature |
| Accessibility Agent (@accessibility) | Claude Sonnet 4.5 | WCAG enforcement | 5,000 | 3,000 | 8,000 | **0.060** | Skipped if no web UI touched |
| Build Agent (@build-agent) | Claude Haiku 4.5 | Build, lint, env smoke test | 4,000 | 2,000 | 6,000 | **0.014** | Mirrors CI scripts inside the workflow |
| Documentation Agent (@documentation) | GLM 4.6 | Updates docs/guidelines/README | 5,000 | 3,000 | 8,000 | **0.010** | Triggers on onboarding and Phase 7 |
| Homepage Designer (@homepage-designer) | Claude Opus 4.5 | Marketing page + theme overhaul | 9,000 | 5,000 | 14,000 | **0.170** | Largest single subagent payload in project creation flow |

> _Token counts are averages; when agents ingest large diffs or design references, add 25-40% headroom._

## 4. Workflow Cost Estimates
### 4.1 Project Creation + Homepage Customization
| Step | Agents Invoked | Runs | Est. Cost (USD) | Notes |
| --- | --- | --- | --- | --- |
| Kickoff, documentation, discovery | NextStack SaaS Orchestrator | 4 | 0.11 | Includes naming, documentation brief, roadmap, final summary |
| Template cleanup + README update | Documentation Agent | 1 | 0.01 | Produces docs/guidelines.md + README rewrite |
| Homepage + theme overhaul | Homepage Designer | 1 | 0.17 | Rebuilds marketing page and Mantine tokens |
| **Total** |  |  | **0.29** | ~56k tokens consumed |

### 4.2 Feature Workflow (Lean Backend/API change)
| Phase | Agents | Runs | Est. Cost (USD) | Notes |
| --- | --- | --- | --- | --- |
| Kickoff + wrap-up | NextStack SaaS Orchestrator | 2 | 0.06 | Intake + final summary |
| Analysis | Codebase Agent + Feature Analyst | 2 | 0.14 | Deep code scan, pattern write-up |
| Planning | Task Manager | 1 | 0.01 | Subtask breakdown |
| Implementation | Codebase Agent + Coder Agent + Tester | 2 (codebase), 1 (tester) | 0.26 | Coder agent is free; tester adds ~$0.01 |
| Review | Reviewer | 1 | 0.04 | Security + acceptance |
| Build validation | Build Agent | 1 | 0.01 | Lint/build/test matrix |
| Documentation | Documentation Agent | 1 | 0.01 | Updates guidelines + feature docs |
| **Total** |  |  | **0.53** | Accessibility + design skipped, ~170k tokens |

### 4.3 Feature Workflow (Premium UI/UX change)
| Phase | Agents | Runs | Est. Cost (USD) | Notes |
| --- | --- | --- | --- | --- |
| Kickoff + wrap-up | NextStack SaaS Orchestrator | 2 | 0.06 | Same intake cadence |
| Analysis | Codebase Agent + Feature Analyst + Design + Copywriting | 4 | 0.29 | Adds visual/messaging exploration |
| Planning | Task Manager | 1 | 0.01 | |
| Implementation | Codebase Agent + Coder Agent + Tester (2 runs) | 3 | 0.27 | Tester invoked twice (~$0.02) |
| Review | Reviewer | 1 | 0.04 | |
| Accessibility | Accessibility Agent | 1 | 0.06 | Required for UI modifications |
| Build validation | Build Agent | 1 | 0.01 | |
| Documentation | Documentation Agent | 1 | 0.01 | |
| **Total** |  |  | **0.75** | ~220k tokens per feature |

## 5. Workflow Cost vs Quality Graph
Quality scale: 1 (minimal coverage) to 5 (full fidelity, UX polish, compliance). Points assume workflows above.

| Workflow | Cost (USD) | Quality Score |
| --- | --- | --- |
| Project Creation | 0.29 | 4.3 |
| Lean Feature | 0.53 | 4.1 |
| Premium Feature | 0.75 | 4.9 |

## 6. Observations & Recommendations
- **Largest cost drivers:** The UX agent uses Claude Opus 4.5 and is one of the most expensive steps (~$0.25/run for full design mode). However, analysis mode for pattern extraction is typically shorter and more cost-effective. Sonnet-powered codebase passes now cost ~40% less, so prioritize reuse of their analysis outputs before reinvoking.
- **Low-cost leverage:** Planning, build validation, and documentation agents each cost ~1¢ per run; keep them enabled for safety nets.
- **UX & messaging toggles:** The UX agent (design/analysis) and copywriting agent are valuable for quality but can be selectively applied. Skipping UX analysis mode when patterns are already documented can save costs. Skipping @copywriting-agent and @accessibility on non-user-facing features can save ~$0.12 per feature but may reduce quality.
- **Homepage vs. feature work:** Full page redesigns (UX agent in design mode) are expensive ($0.25). However, the two-phase approach (UX design → codebase implementation) provides better separation of concerns and quality. Cache UX specifications or reuse theme summaries to avoid re-running for minor tweaks.
- **Future optimization ideas:**
  1. Consider keeping a “lite” homepage variant (e.g., Sonnet dry run) when only minor hero/copy tweaks are needed; reserve Opus for full rebrands.
  2. Introduce conversation caching for orchestrator prompts (each 6k-token reload adds ~0.006 USD) when branching between subtasks.
  3. Keep measuring real token usage via `/logs` so this model can be updated with empirical data per repository.

## 7. Temperature Targets
| Agent | Model | Temperature | Rationale |
| --- | --- | --- | --- |
| NextStack SaaS Orchestrator | GPT 5.1 Codex | 0.10 | Deterministic coordination across multi-step flows |
| Workflow Orchestrator | GPT 5.1 | 0.10 | Keeps routing logic predictable |
| Codebase Agent | Claude Sonnet 4.5 | 0.15 | Slight flexibility while implementing complex diffs |
| Task Manager | Claude Haiku 4.5 | 0.15 | Encourages varied task layouts without losing structure |
| Feature Analyst | Kimi K2 | 0.15 | Allows exploratory pattern discovery |
| Coder Agent | Grok Code Fast 1 | 0.10 | Mostly deterministic coding with minor adaptability |
| Tester | Qwen3 Coder 480B | 0.05 | Repeatable test output |
| Reviewer | GPT 5.1 Codex | 0.05 | Strict, deterministic review feedback |
| Build Agent | Claude Haiku 4.5 | 0.05 | Prevents unexpected build scripts |
| Documentation Agent | GLM 4.6 | 0.10 | Consistent technical writing |
| Design Agent | Claude Sonnet 4.5 | 0.65 | High creativity for layout concepts |
| Copywriting Agent | Claude Sonnet 4.5 | 0.70 | Generates varied marketing copy |
| Accessibility Agent | Claude Sonnet 4.5 | 0.20 | Slight variability to suggest alternatives |
| Homepage Designer | Claude Opus 4.5 | 0.45 | Balances creative ideation with reliable delivery |
