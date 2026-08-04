fn main {
  let flow = @moontrace.sample_workflow()
  println(flow.summary_line())
  let findings = @moontrace.audit_workflow(flow, @moontrace.passing_events(flow))
  let readiness = @moontrace.score_release_readiness(@moontrace.local_release_evidence())
  println("audit: \{ @moontrace.count_passed(findings) } passed, \{ @moontrace.count_failed(findings) } failed")
  println("release: \{readiness.status} (\{readiness.score}/\{readiness.max_score})")
  println(@moontrace.render_jsonish_report(flow, findings))
}
