///|
/// Build a passing event list for examples and smoke tests.
pub fn passing_events(flow : TraceWorkflow) -> Array[TraceEvent] {
  let events = []
  let mut elapsed = 1000
  for step in flow.steps {
    events.push(TraceEvent::make(step.id, "pass", elapsed))
    elapsed = elapsed + 1000
  }
  events
}

///|
/// Build an event list with one failed step.
pub fn events_with_failure(flow : TraceWorkflow, failed_step_id : String) -> Array[TraceEvent] {
  let events = []
  let mut elapsed = 1000
  for step in flow.steps {
    events.push(
      TraceEvent::make(
        step.id,
        if step.id == failed_step_id { "fail" } else { "pass" },
        elapsed,
      ),
    )
    elapsed = elapsed + 1000
  }
  events
}

///|
/// Build an event list where the verification stage times out.
pub fn events_with_slow_verify(flow : TraceWorkflow) -> Array[TraceEvent] {
  let events = []
  for step in flow.steps {
    events.push(
      TraceEvent::make(
        step.id,
        "pass",
        if step.stage == "verify" { 999999 } else { 1000 },
      ),
    )
  }
  events
}
