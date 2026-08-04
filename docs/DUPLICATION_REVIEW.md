# Public Duplication Review

Review date: 2026-08-04

This review covers publicly searchable MoonBit repositories and package pages. It cannot prove uniqueness against private applications or entries visible only inside the organizer's Feishu form, so the project scope should be checked again when the official candidate list is published.

| Public project | Publicly described focus | Overlap avoided by MoonAttest |
|---|---|---|
| [MoonFlow](https://www.gitlink.org.cn/zswissac/moonbit) | Workflow DSL, event logs, retries, deterministic replay and audit | No task execution, retries, scheduling or replay |
| [moonbit-workflow-engine](https://www.gitlink.org.cn/ylyl/moonbit-workflow-engine) | Hierarchical state machines, workflow scheduling and retries | No state-machine or workflow runtime |
| [brickfrog/moontrace](https://mooncakes.io/docs/brickfrog/moontrace) | OpenTelemetry tracing package | Renamed from MoonTrace; no telemetry API |
| MoonBench and moon_mutest | Benchmarking and mutation testing | Imports their possible results only as generic evidence; does not implement either engine |
| MoonNinja | Build orchestration | Does not invoke compilers or own a build graph |
| moonguard | Project policy and guard checks | Focuses on normalized proof bundles, provenance, evidence reconciliation and revision differences |

## Differentiating Boundary

MoonAttest begins after tools have produced observations. Its primary abstraction is a sourced `Evidence` record, not a job, task, span, test mutation, or build edge. The main outputs are deterministic proof bundles, evidence conflict reports, provenance findings, integrity timelines, and cross-revision acceptance differences.

The following features are deliberately out of scope because they create direct overlap with existing projects:

- DAG execution and dependency scheduling;
- retries, backoff, timeouts and worker queues;
- hierarchical state machines and workflow DSL runtimes;
- OpenTelemetry spans, exporters and trace propagation;
- benchmark execution, mutation generation and build orchestration.

## Ongoing Check

Before final submission, search the official list for `attestation`, `evidence`, `proof`, `acceptance`, `compliance`, `quality gate`, `验收`, `证据`, `证明` and `合规`. If a highly similar entry appears, preserve the evidence model but narrow the product further toward MoonBit package-release proof bundles and license provenance.
