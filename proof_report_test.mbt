///|
test "sample proof is ready" {
  let bundle = sample_proof_bundle()
  inspect(bundle.score.verdict, content="ready")
  inspect(bundle.score.percent, content="100")
  inspect(bundle.score.blocking_failures, content="0")
}

///|
test "sample proof fingerprint verifies" {
  let bundle = sample_proof_bundle()
  inspect(verify_bundle_fingerprint(bundle), content="true")
  inspect(proof_bundle_is_valid(bundle), content="true")
  inspect(proof_bundle_is_acceptable(bundle), content="true")
}

///|
test "fingerprint changes with revision" {
  let first = sample_attestation()
  let second = replace_manifest_revision(first, "different-revision")
  inspect(
    fingerprint_attestation(first) == fingerprint_attestation(second),
    content="false",
  )
}

///|
test "fingerprint is deterministic" {
  let attestation = sample_attestation()
  let first = fingerprint_attestation(attestation)
  let second = fingerprint_attestation(attestation)
  inspect(first == second, content="true")
  inspect(first.has_prefix("ma1-"), content="true")
}

///|
test "evidence identifiers are unique" {
  inspect(unique_evidence_ids(sample_evidence()), content="true")
  inspect(duplicate_evidence_ids(sample_evidence()).length(), content="0")
}

///|
test "duplicate evidence identifiers are reported" {
  let item = Evidence::make("same", "test", "test", "pass")
  inspect(unique_evidence_ids([item, item]), content="false")
  inspect(duplicate_evidence_ids([item, item]).length(), content="1")
}

///|
test "manifest round trip preserves attestation" {
  let original = sample_attestation()
  let parsed = parse_attestation_manifest(render_attestation_manifest(original))
  inspect(parsed == original, content="true")
}

///|
test "manifest line counts match model" {
  let manifest = sample_manifest()
  inspect(manifest_evidence_line_count(manifest), content="22")
  inspect(manifest_policy_line_count(manifest), content="24")
  inspect(manifest_has_header(manifest), content="true")
}

///|
test "manifest revision replacement is isolated" {
  let original = sample_attestation()
  let replaced = replace_manifest_revision(original, "next")
  inspect(replaced.meta.revision, content="next")
  inspect(replaced.evidence.length(), content="22")
}

///|
test "manifest append evidence" {
  let original = sample_attestation()
  let item = Evidence::make("extra", "manual", "review", "pass")
  let updated = append_manifest_evidence(original, item)
  inspect(updated.evidence.length(), content="23")
  inspect(updated.has_evidence("extra"), content="true")
}

///|
test "proof markdown includes review anchors" {
  let report = render_proof_markdown(sample_proof_bundle())
  inspect(report.contains("# MoonAttest Proof: MoonAttest"), content="true")
  inspect(report.contains("## Evidence"), content="true")
  inspect(report.contains("## Policy Findings"), content="true")
  inspect(report.contains("Fingerprint"), content="true")
}

///|
test "proof JSON includes required sections" {
  let report = render_proof_json(sample_proof_bundle())
  inspect(report.has_prefix("{"), content="true")
  inspect(
    report.contains("\"format_version\":\"moonattest-proof/1\""),
    content="true",
  )
  inspect(report.contains("\"evidence\":["), content="true")
  inspect(report.contains("\"findings\":["), content="true")
}

///|
test "console summary is compact" {
  let report = render_console_summary(sample_proof_bundle())
  inspect(report.contains("Verdict: ready"), content="true")
  inspect(report.contains("Score: 100%"), content="true")
  inspect(report.contains("Failures: 0"), content="true")
}

///|
test "failing sample has two regressions" {
  let before = sample_attestation()
  let after = sample_failing_attestation()
  let deltas = attestation_delta(before, after)
  inspect(changed_evidence(deltas).length(), content="2")
  inspect(evidence_regressions(deltas).length(), content="2")
}

///|
test "recovery sample has two improvements" {
  let before = sample_failing_attestation()
  let after = sample_attestation()
  let deltas = attestation_delta(before, after)
  inspect(evidence_improvements(deltas).length(), content="2")
  inspect(attestation_has_regression(before, after), content="false")
}

///|
test "delta markdown names changed evidence" {
  let deltas = attestation_delta(
    sample_failing_attestation(),
    sample_attestation(),
  )
  let report = render_delta_markdown(changed_evidence(deltas))
  inspect(report.contains("moon-test"), content="true")
  inspect(report.contains("mooncakes-publication"), content="true")
}

///|
test "bundle can replace evidence and re-fingerprint" {
  let bundle = sample_proof_bundle()
  let changed = Evidence::make("moon-check", "build", "moon check", "fail")
  let updated = bundle_with_evidence(bundle, changed)
  inspect(updated.fingerprint == bundle.fingerprint, content="false")
  inspect(updated.score.verdict, content="rejected")
}

///|
test "bundle can remove evidence" {
  let bundle = bundle_without_evidence(sample_proof_bundle(), "moon-check")
  inspect(bundle.attestation.has_evidence("moon-check"), content="false")
  inspect(bundle.score.verdict, content="rejected")
}

///|
test "schema accepts complete sample" {
  let issues = validate_attestation(sample_attestation())
  inspect(issues.length(), content="0")
  inspect(schema_is_valid(issues), content="true")
}

///|
test "schema rejects duplicate evidence ids" {
  let original = sample_attestation()
  let evidence = original.evidence.copy()
  evidence.push(evidence[0])
  let issues = validate_attestation(
    Attestation::make(original.meta, evidence, original.policies),
  )
  inspect(schema_error_count(issues) > 0, content="true")
}
