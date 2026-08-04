///|
/// A normalized file change recorded during a task.
pub(all) struct TraceFileChange {
  path : String
  action : String
  lines_added : Int
  lines_removed : Int
} derive(Eq, Debug)

///|
/// Path policy for a workflow.
pub(all) struct TracePathPolicy {
  id : String
  allowed_prefix : String
  denied_fragment : String
  max_total_delta : Int
} derive(Eq, Debug)

///|
/// Create a file change.
pub fn TraceFileChange::make(
  path : String,
  action : String,
  lines_added? : Int = 0,
  lines_removed? : Int = 0,
) -> TraceFileChange {
  { path, action, lines_added, lines_removed }
}

///|
/// Create a path policy.
pub fn TracePathPolicy::make(
  id : String,
  allowed_prefix : String,
  denied_fragment? : String = "",
  max_total_delta? : Int = 1000,
) -> TracePathPolicy {
  { id, allowed_prefix, denied_fragment, max_total_delta }
}

///|
/// Check whether one change satisfies one policy.
pub fn change_matches_policy(change : TraceFileChange, policy : TracePathPolicy) -> Bool {
  let in_allowed = policy.allowed_prefix == "" || change.path.has_prefix(policy.allowed_prefix)
  let not_denied = policy.denied_fragment == "" || !change.path.contains(policy.denied_fragment)
  let delta = change.lines_added + change.lines_removed
  in_allowed && not_denied && delta <= policy.max_total_delta
}

///|
/// Audit a batch of file changes.
pub fn audit_file_changes(
  changes : Array[TraceFileChange],
  policies : Array[TracePathPolicy],
) -> Array[TraceFinding] {
  let findings = []
  for change in changes {
    let mut passed_any = false
    for policy in policies {
      if change_matches_policy(change, policy) {
        passed_any = true
      }
    }
    findings.push({
      rule_id: "path-boundary",
      step_id: change.path,
      severity: if passed_any { "info" } else { "error" },
      message: if passed_any {
        "file change is inside declared boundary"
      } else {
        "file change is outside declared boundary"
      },
      passed: passed_any,
    })
  }
  findings
}

///|
/// Common policy for this repository.
pub fn moontrace_source_policy() -> TracePathPolicy {
  TracePathPolicy::make("moontrace-source", "", denied_fragment="_build", max_total_delta=5000)
}

///|
/// Fixture for README examples.
pub fn sample_file_changes() -> Array[TraceFileChange] {
  [
    TraceFileChange::make("moontrace.mbt", "modify", lines_added=20),
    TraceFileChange::make("docs/TECHNICAL_DESIGN.md", "modify", lines_added=12),
  ]
}
