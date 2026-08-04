///|
/// Build findings for all workflow steps and timing rules.
pub fn audit_workflow(flow : TraceWorkflow, events : Array[TraceEvent]) -> Array[TraceFinding] {
  let findings = []
  for step in flow.steps {
    if step.required {
      let status = find_event_status(events, step.id)
      let passed = status == "pass"
      findings.push({
        rule_id: "required-step",
        step_id: step.id,
        severity: if passed { "info" } else { "error" },
        message: if passed {
          "required step passed"
        } else {
          "required step did not pass"
        },
        passed,
      })
    }
  }
  for rule in flow.rules {
    if rule.expected_stage != "" {
      for step in flow.steps {
        if step.stage == rule.expected_stage {
          let elapsed = find_event_elapsed(events, step.id)
          let passed = elapsed >= 0 && elapsed <= rule.max_elapsed_ms
          findings.push({
            rule_id: rule.id,
            step_id: step.id,
            severity: if passed { "info" } else { rule.severity },
            message: if passed {
              "step is within timing budget"
            } else {
              "step exceeded timing budget or has no event"
            },
            passed,
          })
        }
      }
    }
  }
  findings
}

///|
/// Count failed findings.
pub fn count_failed(findings : Array[TraceFinding]) -> Int {
  let mut total = 0
  for finding in findings {
    if !finding.passed {
      total = total + 1
    }
  }
  total
}

///|
/// Count passed findings.
pub fn count_passed(findings : Array[TraceFinding]) -> Int {
  let mut total = 0
  for finding in findings {
    if finding.passed {
      total = total + 1
    }
  }
  total
}

///|
/// Find elapsed time for a step, or -1 if missing.
pub fn find_event_elapsed(events : Array[TraceEvent], step_id : String) -> Int {
  for event in events {
    if event.step_id == step_id {
      return event.elapsed_ms
    }
  }
  -1
}

///|
/// Decide whether a workflow is accepted.
pub fn is_accepted(findings : Array[TraceFinding]) -> Bool {
  count_failed(findings) == 0
}
