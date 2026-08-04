# MoonTrace

MoonTrace is a MoonBit library and CLI demo for reproducible task workflows and audit reports. It helps a project describe what should happen during a development task, import the observed events, check rules, and render a compact report that can be kept with CI logs or hackathon acceptance records.

## Why

Many hackathon projects can build and test, but the development process is hard to review after the fact. MoonTrace gives MoonBit projects a small, auditable layer:

- describe steps with a tiny line-based DSL;
- record whether each step passed, failed, or timed out;
- check required steps and timing budgets;
- render Markdown and JSON-like summaries;
- reuse a generated catalog of workflow profiles for design, build, verify, docs, release, license, publish, and review stages.

## Install Toolchain

Install MoonBit first. On Windows PowerShell:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser; irm https://cli.moonbitlang.cn/install/powershell.ps1 | iex
```

Then reopen the terminal, or prepend the local binary directory for the current session:

```powershell
$env:PATH = "$env:USERPROFILE\.moon\bin;$env:PATH"
```

## Build And Test

```powershell
moon check
moon test
moon run cmd/main
```

Expected CLI output:

```text
moontrace-demo: 4 steps, 3 rules
audit: 5 passed, 0 failed
release: nearly-ready (85/100)
{ "workflow": "moontrace-demo", "steps": 4, "rules": 3, "passed": 5, "failed": 0 }
```

## DSL Example

```text
workflow demo
summary Demo flow
step build|build|moon check|true
step test|verify|moon test|true
rule required|Required steps must pass|error||60000
rule fast-test|Verify stage should be fast|warn|verify|120000
```

## MoonBit API Example

```mbt
test "audit example" {
  let flow = sample_workflow()
  let events = passing_events(flow)
  let findings = audit_workflow(flow, events)
  inspect(is_accepted(findings), content="true")
}
```

## Project Layout

- `moontrace.mbt`: public workflow, step, event, rule, and finding models.
- `parser.mbt`: line-based DSL parser.
- `audit.mbt`: audit engine and finding counters.
- `events.mbt`: event fixture builders for examples and tests.
- `report.mbt`: Markdown and compact machine-readable report renderers.
- `boundary.mbt`: file boundary checks for changed paths and line deltas.
- `release.mbt`: release readiness scoring for hackathon acceptance.
- `catalog.generated.mbt`: generated built-in workflow catalog.
- `cmd/main`: runnable CLI demo.
- `examples/basic.trace`: runnable input example.
- `examples/expected_report.md`: expected Markdown audit report shape.
- `docs/PROJECT_APPLICATION.md`: one-page hackathon application draft.

## Publication Plan

The package is prepared for mooncakes.io publication through MoonBit's package flow:

```powershell
moon login
moon publish
```

The final GitHub repository should be public before submission. Update `moon.mod` if the GitHub username differs from the placeholder repository URL.

## License

MIT License. MoonTrace is an original project and does not copy third-party source code.
