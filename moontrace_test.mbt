///|
test "sample workflow summary" {
  let flow = sample_workflow()
  inspect(flow.summary_line(), content="moontrace-demo: 4 steps, 3 rules")
}

///|
test "workflow step lookup" {
  let flow = sample_workflow()
  inspect(flow.has_step("test"), content="true")
  inspect(flow.has_step("deploy"), content="false")
}

///|
test "event lookup" {
  let events = [
    TraceEvent::make("build", "pass", 1200),
    TraceEvent::make("test", "pass", 3000),
  ]
  inspect(find_event_status(events, "test"), content="pass")
  inspect(find_event_status(events, "lint"), content="missing")
}
