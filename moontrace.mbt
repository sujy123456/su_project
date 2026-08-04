///|
/// Public model for one command in a reproducible development workflow.
pub(all) struct TraceStep {
  id : String
  title : String
  command : String
  stage : String
  required : Bool
} derive(Eq, Debug)

///|
/// A normalized event emitted by a workflow runner or imported from CI logs.
pub(all) struct TraceEvent {
  step_id : String
  status : String
  elapsed_ms : Int
  message : String
} derive(Eq, Debug)

///|
/// Rule describing the expected state of a workflow.
pub(all) struct TraceRule {
  id : String
  title : String
  severity : String
  expected_stage : String
  max_elapsed_ms : Int
} derive(Eq, Debug)

///|
/// Finding returned by the audit engine.
pub(all) struct TraceFinding {
  rule_id : String
  step_id : String
  severity : String
  message : String
  passed : Bool
} derive(Eq, Debug)

///|
/// Top-level workflow document used by the library and CLI.
pub(all) struct TraceWorkflow {
  name : String
  summary : String
  steps : Array[TraceStep]
  rules : Array[TraceRule]
} derive(Eq, Debug)

///|
/// Create a workflow step.
pub fn TraceStep::make(
  id : String,
  title : String,
  command : String,
  stage? : String = "build",
  required? : Bool = true,
) -> TraceStep {
  { id, title, command, stage, required }
}

///|
/// Create an event.
pub fn TraceEvent::make(
  step_id : String,
  status : String,
  elapsed_ms : Int,
  message? : String = "",
) -> TraceEvent {
  { step_id, status, elapsed_ms, message }
}

///|
/// Create an audit rule.
pub fn TraceRule::make(
  id : String,
  title : String,
  severity? : String = "error",
  expected_stage? : String = "",
  max_elapsed_ms? : Int = 60000,
) -> TraceRule {
  { id, title, severity, expected_stage, max_elapsed_ms }
}

///|
/// Create a workflow.
pub fn TraceWorkflow::make(
  name : String,
  summary : String,
  steps : Array[TraceStep],
  rules : Array[TraceRule],
) -> TraceWorkflow {
  { name, summary, steps, rules }
}

///|
/// Built-in example used by README, tests, and CLI demo.
pub fn sample_workflow() -> TraceWorkflow {
  let steps = [
    TraceStep::make("plan", "Write design note", "moontrace plan examples/basic.trace", stage="design"),
    TraceStep::make("build", "Build package", "moon check", stage="build"),
    TraceStep::make("test", "Run tests", "moon test", stage="verify"),
    TraceStep::make("report", "Generate report", "moon run cmd/main", stage="report"),
  ]
  let rules = [
    TraceRule::make("required-steps", "Required steps must pass"),
    TraceRule::make("stage-order", "Workflow stages should be traceable", severity="warn"),
    TraceRule::make("fast-tests", "Tests should finish quickly", expected_stage="verify", max_elapsed_ms=120000),
  ]
  TraceWorkflow::make(
    "moontrace-demo",
    "A minimal reproducible project workflow.",
    steps,
    rules,
  )
}

///|
/// Find whether a workflow has a step id.
pub fn TraceWorkflow::has_step(self : TraceWorkflow, step_id : String) -> Bool {
  for step in self.steps {
    if step.id == step_id {
      return true
    }
  }
  false
}

///|
/// Find a status for a step in a list of imported events.
pub fn find_event_status(events : Array[TraceEvent], step_id : String) -> String {
  for event in events {
    if event.step_id == step_id {
      return event.status
    }
  }
  "missing"
}

///|
/// Render a compact one-line summary.
pub fn TraceWorkflow::summary_line(self : TraceWorkflow) -> String {
  "\{self.name}: \{self.steps.length()} steps, \{self.rules.length()} rules"
}
