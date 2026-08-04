///|
test "catalog smoke suite is auditable" {
  let suite = catalog_smoke_suite()
  inspect(suite.length(), content="20")
  let flow = suite[0]
  inspect(flow.summary_line(), content="catalog-workflow-001: 1 steps, 1 rules")
  let findings = audit_workflow(flow, passing_events(flow))
  inspect(count_failed(findings), content="0")
}

///|
test "catalog profiles expose stable ids" {
  inspect(catalog_step_010().id, content="catalog-step-010")
  inspect(catalog_rule_010().id, content="catalog-rule-010")
  inspect(catalog_workflow_010().name, content="catalog-workflow-010")
}
