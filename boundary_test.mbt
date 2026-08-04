///|
test "file boundary accepts normal source changes" {
  let findings = audit_file_changes(sample_file_changes(), [moontrace_source_policy()])
  inspect(count_failed(findings), content="0")
}

///|
test "file boundary rejects build output changes" {
  let changes = [
    TraceFileChange::make("_build/default/out", "modify", lines_added=1),
  ]
  let findings = audit_file_changes(changes, [moontrace_source_policy()])
  inspect(count_failed(findings), content="1")
}

///|
test "file boundary rejects large delta" {
  let changes = [
    TraceFileChange::make("moontrace.mbt", "modify", lines_added=9000),
  ]
  let findings = audit_file_changes(changes, [moontrace_source_policy()])
  inspect(count_failed(findings), content="1")
}
