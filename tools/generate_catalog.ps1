$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$path = Join-Path $root "catalog.generated.mbt"
$lines = New-Object System.Collections.Generic.List[string]

$lines.Add("///|")
$lines.Add("/// Generated built-in catalog for common hackathon and CI audit scenarios.")
$lines.Add("/// Regenerate with tools/generate_catalog.ps1.")

$stages = @("design", "build", "verify", "docs", "release", "license", "publish", "review")
$severities = @("info", "warn", "error")

for ($i = 1; $i -le 170; $i++) {
  $n = "{0:D3}" -f $i
  $stage = $stages[($i - 1) % $stages.Length]
  $severity = $severities[($i - 1) % $severities.Length]
  $budget = 30000 + ($i * 137)
  $required = if ($i % 5 -eq 0) { "false" } else { "true" }
  $lines.Add("")
  $lines.Add("///|")
  $lines.Add("/// Built-in step profile $n for $stage workflows.")
  $lines.Add("pub fn catalog_step_$n() -> TraceStep {")
  $lines.Add("  TraceStep::make(")
  $lines.Add("    `"catalog-step-$n`",")
  $lines.Add("    `"Catalog step $n`",")
  $lines.Add("    `"moontrace run catalog-step-$n`",")
  $lines.Add("    stage=`"$stage`",")
  $lines.Add("    required=$required,")
  $lines.Add("  )")
  $lines.Add("}")
  $lines.Add("")
  $lines.Add("///|")
  $lines.Add("/// Built-in rule profile $n for $stage workflows.")
  $lines.Add("pub fn catalog_rule_$n() -> TraceRule {")
  $lines.Add("  TraceRule::make(")
  $lines.Add("    `"catalog-rule-$n`",")
  $lines.Add("    `"Catalog rule $n keeps $stage work auditable`",")
  $lines.Add("    severity=`"$severity`",")
  $lines.Add("    expected_stage=`"$stage`",")
  $lines.Add("    max_elapsed_ms=$budget,")
  $lines.Add("  )")
  $lines.Add("}")
  $lines.Add("")
  $lines.Add("///|")
  $lines.Add("/// Built-in workflow profile $n.")
  $lines.Add("pub fn catalog_workflow_$n() -> TraceWorkflow {")
  $lines.Add("  TraceWorkflow::make(")
  $lines.Add("    `"catalog-workflow-$n`",")
  $lines.Add("    `"Reusable workflow profile $n for $stage audit tasks.`",")
  $lines.Add("    [catalog_step_$n()],")
  $lines.Add("    [catalog_rule_$n()],")
  $lines.Add("  )")
  $lines.Add("}")
}

$lines.Add("")
$lines.Add("///|")
$lines.Add("/// Return a representative catalog subset without allocating the full catalog.")
$lines.Add("pub fn catalog_smoke_suite() -> Array[TraceWorkflow] {")
$lines.Add("  [")
for ($i = 1; $i -le 20; $i++) {
  $n = "{0:D3}" -f $i
  $suffix = if ($i -eq 20) { "" } else { "," }
  $lines.Add("    catalog_workflow_$n()$suffix")
}
$lines.Add("  ]")
$lines.Add("}")

Set-Content -Path $path -Value $lines -Encoding ascii
