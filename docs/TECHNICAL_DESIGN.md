# Technical Design

MoonTrace is intentionally small. The first release focuses on reproducible task audit, not general CI orchestration.

## Boundary

MoonTrace owns workflow descriptions, event normalization, rule checks, and report rendering. It does not execute shell commands, upload artifacts, manage secrets, or replace GitHub Actions.

## Data Flow

1. A user writes a trace spec or builds `TraceWorkflow` directly.
2. CI or test fixtures produce `TraceEvent` records.
3. `audit_workflow` compares required steps and stage-specific timing rules.
4. Report functions render Markdown or compact machine-readable output.

## Package Structure

- Model layer: `moontrace.mbt`
- Parser layer: `parser.mbt`
- Audit layer: `audit.mbt`
- Event fixtures: `events.mbt`
- Report layer: `report.mbt`
- Catalog: `catalog.generated.mbt`

## Roadmap

- Parse event logs from JSON once the package depends on a stable MoonBit JSON library.
- Add file-boundary checks for allowed path changes.
- Add GitHub Actions examples that persist MoonTrace reports as artifacts.
- Publish the package to mooncakes.io after repository creation.
