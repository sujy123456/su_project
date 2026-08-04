///|
pub fn sample_project_meta() -> ProjectMeta {
  ProjectMeta::make(
    "moonattest",
    "MoonAttest",
    "https://github.com/sujy123456/su_project",
    "sample-revision",
    generated_at="2026-08-04T18:00:00+08:00",
    producer="moonattest/0.2.0",
  )
}

///|
pub fn sample_source_records() -> Array[SourceRecord] {
  [
    SourceRecord::make(
      "moonbit-core",
      "MoonBit core library",
      "https://github.com/moonbitlang/core",
      "Apache-2.0",
      "standard library APIs",
      notice_present=true,
    ),
  ]
}

///|
pub fn sample_file_observations() -> Array[FileObservation] {
  [
    FileObservation::make("model.mbt", "modified", lines_added=210),
    FileObservation::make("policy.mbt", "added", lines_added=240),
    FileObservation::make("report.mbt", "added", lines_added=260),
    FileObservation::make(
      "docs/TECHNICAL_DESIGN.md",
      "modified",
      lines_added=90,
    ),
    FileObservation::make("examples/basic.attest", "added", lines_added=24),
    FileObservation::make(
      "_build/cache.bin",
      "ignored",
      lines_added=900,
      generated=true,
      tracked=false,
    ),
  ]
}

///|
pub fn sample_evidence() -> Array[Evidence] {
  let collected = "2026-08-04T18:00:00+08:00"
  let items = [
    evidence_from_public_repository(
      "https://github.com/sujy123456/su_project", true, true,
    ),
    evidence_from_commit_count(8, revision="sample-revision"),
    evidence_from_clean_tree(true),
    evidence_from_moon_check(
      "Finished. moon check completed",
      collected_at=collected,
    ),
    evidence_from_format_check(true, detail="moon fmt --check completed"),
    evidence_from_line_count(4280, generated_lines=0),
    Evidence::make(
      "generated-source-ratio",
      "source",
      "generated line ratio",
      "present",
      value="0",
      source="workspace-counter",
      collected_at=collected,
      detail="generated files are excluded from effective line count",
    ),
    evidence_from_moon_test(
      "Total tests: 64, passed: 64, failed: 0",
      collected_at=collected,
    ),
    evidence_from_coverage(78, detail="line coverage", collected_at=collected),
    evidence_from_file_presence("readme", "README.md", true),
    evidence_from_file_presence("license-file", "LICENSE", true),
    evidence_from_file_presence("application", "PROJECT_APPLICATION.md", true),
    evidence_from_file_presence(
      "technical-design", "docs/TECHNICAL_DESIGN.md", true,
    ),
    evidence_from_file_presence("changelog", "CHANGELOG.md", true),
    evidence_from_file_presence(
      "source-attribution", "SOURCE_ATTRIBUTION.md", true,
    ),
    evidence_from_ci(
      "GitHub Actions",
      "build-and-test",
      true,
      run_id="sample-ci",
    ),
    evidence_from_example(
      "sample",
      "moon run cmd/main -- sample",
      true,
      output="proof bundle rendered",
    ),
    evidence_from_mooncakes("sujy123456/moonattest", "0.2.0", true),
    evidence_from_license("MIT", true),
    evidence_from_dependency_count(1, 0),
    source_audit_evidence(sample_source_records()),
    original_project_evidence(true, 0),
  ]
  items.map(item => {
    if item.collected_at == "" {
      { ..item, collected_at: collected }
    } else {
      item
    }
  })
}

///|
pub fn sample_attestation() -> Attestation {
  Attestation::make(
    sample_project_meta(),
    sample_evidence(),
    competition_acceptance_policies(),
  )
}

///|
pub fn sample_proof_bundle() -> ProofBundle {
  build_proof_bundle(sample_attestation())
}

///|
pub fn sample_failing_attestation() -> Attestation {
  let base = sample_attestation()
  let evidence = base.evidence.map(item => {
    if item.id == "moon-test" {
      Evidence::make(
        item.id,
        item.kind,
        item.subject,
        "fail",
        value="61",
        source=item.source,
        collected_at=item.collected_at,
        detail="3 failed",
      )
    } else if item.id == "mooncakes-publication" {
      Evidence::make(
        item.id,
        item.kind,
        item.subject,
        "missing",
        value="0.2.0",
        source=item.source,
        collected_at=item.collected_at,
        detail="publication pending",
      )
    } else {
      item
    }
  })
  Attestation::make(base.meta, evidence, base.policies)
}

///|
pub fn sample_timeline() -> Array[TimelineEntry] {
  [
    TimelineEntry::make(
      1,
      "moon-check",
      "fail",
      value="1",
      observed_at="2026-08-04T10:00:00+08:00",
      note="initial build",
    ),
    TimelineEntry::make(
      2,
      "moon-test",
      "fail",
      value="12",
      observed_at="2026-08-04T10:05:00+08:00",
      note="initial tests",
    ),
    TimelineEntry::make(
      3,
      "moon-check",
      "pass",
      value="0",
      observed_at="2026-08-04T11:00:00+08:00",
      note="type errors fixed",
    ),
    TimelineEntry::make(
      4,
      "moon-test",
      "warn",
      value="58",
      observed_at="2026-08-04T11:30:00+08:00",
      note="two tests remain",
    ),
    TimelineEntry::make(
      5,
      "moon-test",
      "pass",
      value="64",
      observed_at="2026-08-04T12:00:00+08:00",
      note="regression suite complete",
    ),
  ]
}

///|
pub fn sample_manifest() -> String {
  render_attestation_manifest(sample_attestation())
}
