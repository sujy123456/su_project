///|
/// Render a Markdown audit report.
pub fn render_markdown_report(flow : TraceWorkflow, findings : Array[TraceFinding]) -> String {
  let mut output = "# MoonTrace Audit Report\n\n"
  output = output + "- Workflow: \{flow.name}\n"
  output = output + "- Summary: \{flow.summary}\n"
  output = output + "- Steps: \{flow.steps.length()}\n"
  output = output + "- Rules: \{flow.rules.length()}\n"
  output = output + "- Passed: \{count_passed(findings)}\n"
  output = output + "- Failed: \{count_failed(findings)}\n\n"
  output = output + "## Findings\n\n"
  for finding in findings {
    output = output + "- [\{if finding.passed { "x" } else { " " }}] "
    output = output + "\{finding.rule_id} / \{finding.step_id}: \{finding.message}\n"
  }
  output
}

///|
/// Render a compact machine-readable report.
pub fn render_jsonish_report(flow : TraceWorkflow, findings : Array[TraceFinding]) -> String {
  "{ \"workflow\": \"\{flow.name}\", \"steps\": \{flow.steps.length()}, \"rules\": \{flow.rules.length()}, \"passed\": \{count_passed(findings)}, \"failed\": \{count_failed(findings)} }"
}

///|
/// Render a table of workflow steps.
pub fn render_step_table(flow : TraceWorkflow) -> String {
  let mut output = "| id | stage | required | command |\n|---|---|---|---|\n"
  for step in flow.steps {
    output = output + "| \{step.id} | \{step.stage} | \{step.required} | \{step.command} |\n"
  }
  output
}
