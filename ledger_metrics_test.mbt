///|
fn ledger_item(
  id : String,
  status : String,
  value : String,
  source : String,
  collected_at : String,
) -> Evidence {
  Evidence::make(
    id,
    "test",
    "moon test",
    status,
    value~,
    source~,
    collected_at~,
  )
}

///|
test "ledger extracts unique dimensions" {
  let items = sample_evidence()
  inspect(evidence_ids(items).length(), content="22")
  inspect(evidence_kinds(items).contains("build"), content="true")
  inspect(evidence_sources(items).contains("moon-cli"), content="true")
  inspect(evidence_statuses(items).contains("pass"), content="true")
}

///|
test "ledger filters by kind" {
  let items = evidence_with_kind(sample_evidence(), "artifact")
  inspect(items.length(), content="6")
}

///|
test "ledger filters by source" {
  let items = evidence_with_source(sample_evidence(), "moon-cli")
  inspect(items.length(), content="3")
}

///|
test "ledger compound query" {
  let items = evidence_matches(
    sample_evidence(),
    kind="artifact",
    subject_contains="README",
    status="present",
  )
  inspect(items.length(), content="1")
  inspect(items[0].id, content="readme")
}

///|
test "identical duplicate observations do not conflict" {
  let item = ledger_item("test", "pass", "10", "ci", "2026-08-04T10:00:00Z")
  inspect(evidence_conflicts([item, item]).length(), content="0")
}

///|
test "different duplicate observations conflict" {
  let first = ledger_item("test", "fail", "9", "local", "2026-08-04T10:00:00Z")
  let second = ledger_item("test", "pass", "10", "ci", "2026-08-04T11:00:00Z")
  let conflicts = evidence_conflicts([first, second])
  inspect(conflicts.length(), content="1")
  inspect(conflicts[0].evidence_id, content="test")
}

///|
test "conflict evidence blocks inconsistent ledger" {
  let first = ledger_item("test", "fail", "9", "local", "2026-08-04T10:00:00Z")
  let second = ledger_item("test", "pass", "10", "ci", "2026-08-04T11:00:00Z")
  let item = conflict_evidence([first, second])
  inspect(item.status, content="fail")
  inspect(item.value, content="1")
}

///|
test "reconcile selects higher-priority source" {
  let local_item = ledger_item(
    "test", "fail", "9", "local", "2026-08-04T12:00:00Z",
  )
  let ci = ledger_item("test", "pass", "10", "ci", "2026-08-04T11:00:00Z")
  let result = reconcile_evidence([local_item, ci], source_priorities=[
    "ci", "local",
  ])
  inspect(result.length(), content="1")
  inspect(result[0].source, content="ci")
  inspect(result[0].status, content="pass")
}

///|
test "reconcile selects newer equal-priority observation" {
  let first = ledger_item("test", "fail", "9", "ci", "2026-08-04T10:00:00Z")
  let second = ledger_item("test", "pass", "10", "ci", "2026-08-04T11:00:00Z")
  let result = reconcile_evidence([first, second])
  inspect(result[0].status, content="pass")
}

///|
test "merge evidence preserves primary source preference" {
  let primary = [
    ledger_item("test", "pass", "10", "ci", "2026-08-04T10:00:00Z"),
  ]
  let secondary = [
    ledger_item("test", "fail", "9", "local", "2026-08-04T11:00:00Z"),
  ]
  let result = merge_evidence(primary, secondary)
  inspect(result.length(), content="1")
  inspect(result[0].source, content="ci")
}

///|
test "ledger summary reports dimensions" {
  let summary = evidence_ledger_summary(sample_evidence())
  inspect(summary.contains("records=22"), content="true")
  inspect(summary.contains("conflicts=0"), content="true")
}

///|
test "conflict markdown renders both sources" {
  let first = ledger_item("test", "fail", "9", "local", "2026-08-04T10:00:00Z")
  let second = ledger_item("test", "pass", "10", "ci", "2026-08-04T11:00:00Z")
  let report = render_conflicts_markdown(evidence_conflicts([first, second]))
  inspect(report.contains("local"), content="true")
  inspect(report.contains("ci"), content="true")
}

///|
test "sample evidence metrics are complete" {
  let metrics = evidence_metrics(sample_evidence())
  inspect(metrics.total, content="22")
  inspect(metrics.completeness_percent, content="100")
  inspect(metrics.failing, content="0")
}

///|
test "empty evidence metrics are healthy by definition" {
  let metrics = evidence_metrics([])
  inspect(metrics.total, content="0")
  inspect(metrics.completeness_percent, content="100")
  inspect(metrics.health_percent, content="100")
}

///|
test "policy metrics match ready sample" {
  let bundle = sample_proof_bundle()
  let metrics = policy_metrics(bundle.attestation.policies, bundle.findings)
  inspect(metrics.total, content="24")
  inspect(metrics.failed, content="0")
  inspect(metrics.weighted_percent, content="100")
}

///|
test "metric grades use conventional thresholds" {
  inspect(metric_grade(95), content="A")
  inspect(metric_grade(85), content="B")
  inspect(metric_grade(75), content="C")
  inspect(metric_grade(65), content="D")
  inspect(metric_grade(55), content="F")
}

///|
test "metrics report contains evidence and policy rows" {
  let bundle = sample_proof_bundle()
  let report = bundle_metrics_markdown(bundle)
  inspect(report.contains("Evidence completeness"), content="true")
  inspect(report.contains("Weighted score"), content="true")
}

///|
test "metric evidence produces three observations" {
  let items = metric_evidence(sample_evidence(), collected_at="now")
  inspect(items.length(), content="3")
  inspect(items[0].collected_at, content="now")
  inspect(items.filter(item => item.status == "pass").length(), content="3")
}

///|
test "sample timeline is monotonic" {
  let entries = sample_timeline()
  inspect(timeline_is_monotonic(entries), content="true")
  inspect(timeline_has_duplicate_sequences(entries), content="false")
}

///|
test "timeline latest keeps one observation per evidence" {
  let latest = timeline_latest(sample_timeline())
  inspect(latest.length(), content="2")
  inspect(latest.filter(item => item.status == "pass").length(), content="2")
}

///|
test "timeline fingerprint chain verifies" {
  let entries = sample_timeline()
  let chain = timeline_chain(entries)
  inspect(chain.length(), content="5")
  inspect(timeline_chain_is_valid(entries, chain), content="true")
}

///|
test "timeline reports duplicate sequence" {
  let entries = sample_timeline()
  let duplicate = entries.copy()
  duplicate.push(entries[0])
  inspect(timeline_has_duplicate_sequences(duplicate), content="true")
  inspect(timeline_transition_issues(duplicate).length() > 0, content="true")
}

///|
test "timeline report includes integrity chain" {
  let report = render_timeline_markdown(sample_timeline())
  inspect(report.contains("Chain"), content="true")
  inspect(report.contains("ma1-"), content="true")
}
