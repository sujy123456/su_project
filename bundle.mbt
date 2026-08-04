///|
fn finding_from_schema_issue(issue : SchemaIssue, index : Int) -> Finding {
  Finding::make(
    "schema-" + issue.code + "-" + index.to_string(),
    issue.path,
    issue.severity,
    false,
    if issue.severity == "error" {
      1
    } else {
      0
    },
    "invalid",
    "valid",
    issue.message,
  )
}

///|
pub fn schema_findings(issues : Array[SchemaIssue]) -> Array[Finding] {
  let findings : Array[Finding] = []
  for index, issue in issues {
    findings.push(finding_from_schema_issue(issue, index))
  }
  findings
}

///|
pub fn build_proof_bundle(attestation : Attestation) -> ProofBundle {
  let findings = evaluate_policies(attestation.policies, attestation.evidence)
  for finding in schema_findings(validate_attestation(attestation)) {
    findings.push(finding)
  }
  let score = score_findings(findings)
  let fingerprint = fingerprint_bundle_content(attestation, findings, score)
  {
    attestation,
    findings,
    score,
    fingerprint,
    format_version: "moonattest-proof/1",
  }
}

///|
pub fn verify_proof_bundle(bundle : ProofBundle) -> Array[SchemaIssue] {
  let issues : Array[SchemaIssue] = []
  if bundle.format_version != "moonattest-proof/1" {
    issues.push(
      SchemaIssue::make(
        "bundle.format_version", "format", "unsupported proof bundle format",
      ),
    )
  }
  if !verify_bundle_fingerprint(bundle) {
    issues.push(
      SchemaIssue::make(
        "bundle.fingerprint", "fingerprint", "proof bundle fingerprint does not match its content",
      ),
    )
  }
  if !unique_evidence_ids(bundle.attestation.evidence) {
    issues.push(
      SchemaIssue::make(
        "bundle.attestation.evidence", "duplicate", "proof bundle contains duplicate evidence identifiers",
      ),
    )
  }
  if !unique_policy_ids(bundle.attestation.policies) {
    issues.push(
      SchemaIssue::make(
        "bundle.attestation.policies", "duplicate", "proof bundle contains duplicate policy identifiers",
      ),
    )
  }
  let expected = evaluate_policies(
    bundle.attestation.policies,
    bundle.attestation.evidence,
  )
  if bundle.findings.length() < expected.length() {
    issues.push(
      SchemaIssue::make(
        "bundle.findings", "incomplete", "proof bundle is missing evaluated policy findings",
      ),
    )
  }
  issues
}

///|
pub fn proof_bundle_is_valid(bundle : ProofBundle) -> Bool {
  verify_proof_bundle(bundle).length() == 0
}

///|
pub fn proof_bundle_is_acceptable(bundle : ProofBundle) -> Bool {
  proof_bundle_is_valid(bundle) && bundle.score.blocking_failures == 0
}

///|
pub fn proof_bundle_summary(bundle : ProofBundle) -> String {
  "verdict=" +
  bundle.score.verdict +
  ",score=" +
  bundle.score.percent.to_string() +
  ",evidence=" +
  bundle.attestation.evidence.length().to_string() +
  ",policies=" +
  bundle.attestation.policies.length().to_string() +
  ",fingerprint=" +
  bundle.fingerprint
}

///|
pub fn rebuild_proof_bundle(bundle : ProofBundle) -> ProofBundle {
  build_proof_bundle(bundle.attestation)
}

///|
pub fn bundle_with_evidence(
  bundle : ProofBundle,
  item : Evidence,
) -> ProofBundle {
  let evidence = bundle.attestation.evidence.copy()
  let mut replaced = false
  let mut index = 0
  while index < evidence.length() {
    if evidence[index].id == item.id {
      evidence[index] = item
      replaced = true
    }
    index = index + 1
  }
  if !replaced {
    evidence.push(item)
  }
  build_proof_bundle({ ..bundle.attestation, evidence, })
}

///|
pub fn bundle_without_evidence(
  bundle : ProofBundle,
  evidence_id : String,
) -> ProofBundle {
  let evidence = bundle.attestation.evidence.filter(item => {
    item.id != evidence_id
  })
  build_proof_bundle({ ..bundle.attestation, evidence, })
}
