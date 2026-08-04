///|
test "parse trace spec" {
  let text = "workflow demo\nsummary Demo flow\nstep build|build|moon check|true\nrule fast|Fast verify|warn|build|2000\n"
  let flow = parse_trace_spec(text)
  inspect(flow.summary_line(), content="demo: 1 steps, 1 rules")
  inspect(flow.steps[0].command, content="moon check")
}

///|
test "audit passing flow" {
  let flow = sample_workflow()
  let findings = audit_workflow(flow, passing_events(flow))
  inspect(count_failed(findings), content="0")
  inspect(is_accepted(findings), content="true")
}

///|
test "audit failure flow" {
  let flow = sample_workflow()
  let findings = audit_workflow(flow, events_with_failure(flow, "test"))
  inspect(count_failed(findings), content="1")
  inspect(is_accepted(findings), content="false")
}

///|
test "audit slow verify flow" {
  let flow = sample_workflow()
  let findings = audit_workflow(flow, events_with_slow_verify(flow))
  inspect(count_failed(findings), content="1")
}

///|
test "render reports" {
  let flow = sample_workflow()
  let findings = audit_workflow(flow, passing_events(flow))
  inspect(render_jsonish_report(flow, findings), content="{ \"workflow\": \"moontrace-demo\", \"steps\": 4, \"rules\": 3, \"passed\": 5, \"failed\": 0 }")
}
