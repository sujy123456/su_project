///|
test "moon check adapter accepts successful output" {
  let item = evidence_from_moon_check("Finished. moon: ran 4 tasks")
  inspect(item.status, content="pass")
  inspect(item.value, content="0")
}

///|
test "moon check adapter rejects compiler error" {
  let item = evidence_from_moon_check("error: unresolved identifier\nfailed")
  inspect(item.status, content="fail")
  inspect(item.value, content="1")
}

///|
test "moon test adapter reads passed count" {
  let item = evidence_from_moon_test("Total tests: 43, passed: 43, failed: 0")
  inspect(item.status, content="pass")
  inspect(item.value, content="43")
}

///|
test "moon test adapter detects failure" {
  let item = evidence_from_moon_test("Total tests: 43, passed: 42, failed: 1")
  inspect(item.status, content="fail")
}

///|
test "coverage adapter retains percentage" {
  let item = evidence_from_coverage(78, detail="line coverage")
  inspect(item.status, content="present")
  inspect(item.value, content="78")
}

///|
test "repository adapter combines reachability and visibility" {
  inspect(
    evidence_from_public_repository("url", true, true).status,
    content="pass",
  )
  inspect(
    evidence_from_public_repository("url", false, true).status,
    content="fail",
  )
  inspect(
    evidence_from_public_repository("url", true, false).status,
    content="fail",
  )
}

///|
test "file presence adapter reports missing artifact" {
  let item = evidence_from_file_presence("readme", "README.md", false)
  inspect(item.status, content="missing")
  inspect(item.subject, content="README.md")
}

///|
test "line count adapter separates generated source" {
  let item = evidence_from_line_count(4100, generated_lines=200)
  inspect(item.value, content="4100")
  inspect(item.detail, content="generated=200")
}

///|
test "license adapter accepts OSI license" {
  inspect(evidence_from_license("Apache-2.0", true).status, content="pass")
  inspect(evidence_from_license("Proprietary", true).status, content="fail")
  inspect(evidence_from_license("MIT", false).status, content="fail")
}

///|
test "dependency adapter reports unlicensed entries" {
  inspect(evidence_from_dependency_count(4, 0).status, content="pass")
  inspect(evidence_from_dependency_count(4, 1).status, content="fail")
}

///|
test "OSI catalog includes common licenses" {
  inspect(is_osi_license("MIT"), content="true")
  inspect(is_osi_license("Apache-2.0"), content="true")
  inspect(is_osi_license("EPL-2.0"), content="true")
  inspect(is_osi_license("Custom"), content="false")
}

///|
test "notice requirement is license specific" {
  inspect(license_requires_notice("Apache-2.0"), content="true")
  inspect(license_requires_notice("EPL-2.0"), content="true")
  inspect(license_requires_notice("MIT"), content="false")
}

///|
test "approved source record passes audit" {
  let findings = source_record_issues(sample_source_records()[0])
  inspect(source_findings_pass(findings), content="true")
  inspect(count_source_failures(findings), content="0")
}

///|
test "missing source origin fails audit" {
  let record = SourceRecord::make("x", "Unknown", "", "MIT", "snippet")
  let findings = source_record_issues(record)
  inspect(source_findings_pass(findings), content="false")
  inspect(count_source_failures(findings), content="1")
}

///|
test "Apache source requires notice" {
  let record = SourceRecord::make(
    "x", "Library", "https://example.com", "Apache-2.0", "API",
  )
  let findings = source_record_issues(record)
  inspect(source_findings_pass(findings), content="false")
}

///|
test "source inventory renders attribution columns" {
  let report = render_source_inventory(sample_source_records())
  inspect(report.contains("origin"), content="true")
  inspect(report.contains("Apache-2.0"), content="true")
}

///|
test "file observation delta includes additions and removals" {
  let item = FileObservation::make(
    "model.mbt",
    "modified",
    lines_added=12,
    lines_removed=3,
  )
  inspect(item.delta(), content="15")
}

///|
test "default boundary rejects generated output" {
  let item = FileObservation::make(
    "catalog.generated.mbt",
    "added",
    lines_added=500,
    generated=true,
  )
  let rule = BoundaryRule::make("source", max_delta=1000)
  inspect(observation_matches_boundary(item, rule), content="false")
  inspect(
    observation_boundary_reason(item, rule),
    content="generated output is not accepted as review evidence",
  )
}

///|
test "boundary enforces allowed prefix" {
  let item = FileObservation::make("src/core.mbt", "added", lines_added=30)
  let rule = BoundaryRule::make("docs", allowed_prefix="docs/")
  inspect(observation_matches_boundary(item, rule), content="false")
  inspect(
    observation_boundary_reason(item, rule),
    content="path is outside allowed prefix",
  )
}

///|
test "boundary enforces maximum delta" {
  let item = FileObservation::make("large.mbt", "added", lines_added=1001)
  let rule = BoundaryRule::make("source", max_delta=1000)
  inspect(observation_matches_boundary(item, rule), content="false")
  inspect(
    observation_boundary_reason(item, rule),
    content="line delta exceeds declared boundary",
  )
}

///|
test "boundary rejects untracked observation" {
  let item = FileObservation::make(
    "new.mbt",
    "added",
    lines_added=10,
    tracked=false,
  )
  let rule = BoundaryRule::make("tracked")
  inspect(observation_matches_boundary(item, rule), content="false")
  inspect(
    observation_boundary_reason(item, rule),
    content="file is not tracked by the repository",
  )
}

///|
test "boundary audit emits one result per observation" {
  let observations = sample_file_observations()
  let results = audit_file_boundaries(
    observations,
    moonattest_default_boundaries(),
  )
  inspect(results.length() >= observations.length(), content="true")
  inspect(
    results.filter(item => item.status == "fail").length() > 0,
    content="true",
  )
}

///|
test "generated ratio excludes authored source" {
  let observations = sample_file_observations()
  inspect(total_changed_lines(observations), content="1724")
  inspect(generated_changed_lines(observations), content="900")
  inspect(effective_changed_lines(observations), content="824")
  inspect(generated_ratio_percent(observations), content="52")
}
