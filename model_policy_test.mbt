///|
fn test_evidence(
  id : String,
  kind : String,
  subject : String,
  status : String,
  value? : String = "",
) -> Evidence {
  Evidence::make(
    id,
    kind,
    subject,
    status,
    value~,
    source="test",
    collected_at="2026-08-04T00:00:00Z",
  )
}

///|
test "evidence pass statuses" {
  inspect(
    test_evidence("a", "build", "check", "pass").is_pass(),
    content="true",
  )
  inspect(
    test_evidence("b", "artifact", "README", "present").is_pass(),
    content="true",
  )
  inspect(
    test_evidence("c", "proof", "bundle", "verified").is_pass(),
    content="true",
  )
}

///|
test "evidence failure statuses" {
  inspect(
    test_evidence("a", "build", "check", "fail").is_failure(),
    content="true",
  )
  inspect(
    test_evidence("b", "artifact", "README", "missing").is_failure(),
    content="true",
  )
  inspect(
    test_evidence("c", "proof", "bundle", "invalid").is_failure(),
    content="true",
  )
}

///|
test "evidence identity is stable" {
  let item = test_evidence("moon-check", "build", "moon check", "pass")
  inspect(item.identity(), content="build:moon check:moon-check")
}

///|
test "attestation lookup finds evidence" {
  let attestation = sample_attestation()
  inspect(attestation.has_evidence("moon-test"), content="true")
  inspect(attestation.has_evidence("not-there"), content="false")
}

///|
test "attestation filters evidence kind" {
  let artifacts = sample_attestation().evidence_of_kind("artifact")
  inspect(artifacts.length(), content="6")
}

///|
test "text predicate equality" {
  inspect(evaluate_text_predicate("pass", "eq", "pass"), content="true")
  inspect(evaluate_text_predicate("fail", "neq", "pass"), content="true")
}

///|
test "text predicate containment" {
  inspect(
    evaluate_text_predicate("moon check complete", "contains", "check"),
    content="true",
  )
  inspect(
    evaluate_text_predicate("moon check complete", "not_contains", "error"),
    content="true",
  )
}

///|
test "text predicate prefix and suffix" {
  inspect(
    evaluate_text_predicate("docs/design.md", "prefix", "docs/"),
    content="true",
  )
  inspect(
    evaluate_text_predicate("docs/design.md", "suffix", ".md"),
    content="true",
  )
}

///|
test "text predicate empty values" {
  inspect(evaluate_text_predicate("value", "non_empty", ""), content="true")
  inspect(evaluate_text_predicate("", "empty", ""), content="true")
}

///|
test "text predicate booleans" {
  inspect(evaluate_text_predicate("yes", "truthy", ""), content="true")
  inspect(evaluate_text_predicate("off", "falsy", ""), content="true")
}

///|
test "text predicate integer minimum" {
  inspect(evaluate_text_predicate("4000", "min_int", "4000"), content="true")
  inspect(evaluate_text_predicate("3999", "min_int", "4000"), content="false")
}

///|
test "text predicate integer maximum" {
  inspect(evaluate_text_predicate("20", "max_int", "20"), content="true")
  inspect(evaluate_text_predicate("21", "max_int", "20"), content="false")
}

///|
test "text predicate integer range" {
  inspect(evaluate_text_predicate("75", "between", "60..90"), content="true")
  inspect(evaluate_text_predicate("95", "between", "60..90"), content="false")
}

///|
test "text predicate option list" {
  inspect(
    evaluate_text_predicate("Apache-2.0", "one_of", "MIT,Apache-2.0"),
    content="true",
  )
  inspect(
    evaluate_text_predicate("private", "one_of", "public,internal"),
    content="false",
  )
}

///|
test "policy selects exact subject" {
  let policy = Policy::make(
    "p",
    "build",
    "build",
    "status",
    "eq",
    "pass",
    target_subject="moon check",
  )
  inspect(
    select_policy_evidence(policy, sample_evidence()) is Some(_),
    content="true",
  )
}

///|
test "passing policy finding" {
  let policy = Policy::make("p", "build", "build", "status", "eq", "pass")
  let finding = evaluate_policy(policy, [
    test_evidence("e", "build", "check", "pass"),
  ])
  inspect(finding.passed, content="true")
  inspect(finding.actual, content="pass")
}

///|
test "failing policy finding" {
  let policy = Policy::make(
    "p",
    "build",
    "build",
    "status",
    "eq",
    "pass",
    weight=7,
  )
  let finding = evaluate_policy(policy, [
    test_evidence("e", "build", "check", "fail"),
  ])
  inspect(finding.passed, content="false")
  inspect(finding.weight, content="7")
}

///|
test "missing evidence fails required policy" {
  let policy = Policy::make("p", "required", "build", "status", "eq", "pass")
  let finding = evaluate_policy(policy, [])
  inspect(finding.passed, content="false")
  inspect(finding.actual, content="missing")
}

///|
test "score rejects blocking failure" {
  let findings = [
    Finding::make("p", "e", "error", false, 10, "fail", "pass", "failed"),
  ]
  let score = score_findings(findings)
  inspect(score.verdict, content="rejected")
  inspect(score.blocking_failures, content="1")
}

///|
test "score is ready above ninety" {
  let findings = [
    Finding::make("a", "e", "info", true, 9, "pass", "pass", "ok"),
    Finding::make("b", "e", "warn", true, 1, "pass", "pass", "ok"),
  ]
  let score = score_findings(findings)
  inspect(score.percent, content="100")
  inspect(score.verdict, content="ready")
}

///|
test "policy catalog identifiers are unique" {
  let policies = competition_acceptance_policies()
  inspect(unique_policy_ids(policies), content="true")
  inspect(policies.length(), content="24")
}

///|
test "minimal catalog contains five gates" {
  let policies = minimal_acceptance_policies()
  inspect(policies.length(), content="5")
  inspect(
    policy_catalog_summary(policies),
    content="policies=5,blocking=5,advisory=0",
  )
}

///|
test "competition sample satisfies every policy" {
  let attestation = sample_attestation()
  let findings = evaluate_policies(attestation.policies, attestation.evidence)
  inspect(count_failed_findings(findings), content="0")
  inspect(policy_coverage(attestation.policies, findings), content="100")
}
