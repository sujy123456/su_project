///|
/// Canonical line for project metadata.
pub fn canonical_meta(meta : ProjectMeta) -> String {
  "meta|\{meta.project_id}|\{meta.display_name}|\{meta.repository}|\{meta.revision}|\{meta.generated_at}|\{meta.producer}"
}

///|
/// Canonical line for one evidence record.
pub fn canonical_evidence(item : Evidence) -> String {
  "evidence|\{item.id}|\{item.kind}|\{item.subject}|\{item.status}|\{item.value}|\{item.source}|\{item.collected_at}|\{item.detail}"
}

///|
/// Canonical line for one policy declaration.
pub fn canonical_policy(policy : Policy) -> String {
  "policy|\{policy.id}|\{policy.title}|\{policy.target_kind}|\{policy.target_subject}|\{policy.field}|\{policy.predicate}|\{policy.expected}|\{policy.severity}|\{policy.weight}"
}

///|
/// Canonical line for one finding.
pub fn canonical_finding(finding : Finding) -> String {
  "finding|\{finding.policy_id}|\{finding.evidence_id}|\{finding.severity}|\{finding.passed}|\{finding.weight}|\{finding.actual}|\{finding.expected}|\{finding.message}"
}

///|
/// Stable order-preserving serialization used as fingerprint input.
pub fn canonical_attestation(attestation : Attestation) -> String {
  let mut output = canonical_meta(attestation.meta) + "\n"
  for item in attestation.evidence {
    output = output + canonical_evidence(item) + "\n"
  }
  for policy in attestation.policies {
    output = output + canonical_policy(policy) + "\n"
  }
  output
}

///|
pub fn canonical_findings(findings : Array[Finding]) -> String {
  let mut output = ""
  for item in findings {
    output = output + canonical_finding(item) + "\n"
  }
  output
}

///|
/// First bounded rolling checksum. Arithmetic stays within signed Int range.
pub fn checksum_primary(text : String) -> Int {
  let mut acc = 1723
  let mut index = 1
  for ch in text {
    acc = (acc * 31 + ch.to_int() + index) % 10000019
    index = index + 1
  }
  acc
}

///|
/// Independent reverse-weighted checksum used to reduce accidental collisions.
pub fn checksum_secondary(text : String) -> Int {
  let mut acc = 7919
  let mut index = text.length() + 11
  for ch in text {
    acc = (acc * 17 + ch.to_int() * 3 + index) % 9000011
    index = index - 1
  }
  acc
}

///|
/// A compact deterministic fingerprint for review records.
///
/// This is an integrity checksum, not a cryptographic signature.
pub fn fingerprint_text(text : String) -> String {
  "ma1-\{checksum_primary(text)}-\{checksum_secondary(text)}-\{text.length()}"
}

///|
pub fn fingerprint_attestation(attestation : Attestation) -> String {
  fingerprint_text(canonical_attestation(attestation))
}

///|
pub fn fingerprint_bundle_content(
  attestation : Attestation,
  findings : Array[Finding],
  score : AttestationScore,
) -> String {
  let body = canonical_attestation(attestation) + canonical_findings(findings)
  let score_line = "score|\{score.earned}|\{score.possible}|\{score.percent}|\{score.verdict}|\{score.blocking_failures}|\{score.warnings}"
  fingerprint_text(body + score_line)
}

///|
pub fn verify_attestation_fingerprint(
  attestation : Attestation,
  expected : String,
) -> Bool {
  fingerprint_attestation(attestation) == expected
}

///|
pub fn verify_bundle_fingerprint(bundle : ProofBundle) -> Bool {
  fingerprint_bundle_content(bundle.attestation, bundle.findings, bundle.score) ==
  bundle.fingerprint
}

///|
pub fn evidence_fingerprint(item : Evidence) -> String {
  fingerprint_text(canonical_evidence(item))
}

///|
pub fn policy_fingerprint(policy : Policy) -> String {
  fingerprint_text(canonical_policy(policy))
}

///|
pub fn finding_fingerprint(finding : Finding) -> String {
  fingerprint_text(canonical_finding(finding))
}

///|
/// Verify that every evidence identifier is unique.
pub fn unique_evidence_ids(items : Array[Evidence]) -> Bool {
  let mut left = 0
  while left < items.length() {
    let mut right = left + 1
    while right < items.length() {
      if items[left].id == items[right].id {
        return false
      }
      right = right + 1
    }
    left = left + 1
  }
  true
}

///|
/// Verify that every policy identifier is unique.
pub fn unique_policy_ids(items : Array[Policy]) -> Bool {
  let mut left = 0
  while left < items.length() {
    let mut right = left + 1
    while right < items.length() {
      if items[left].id == items[right].id {
        return false
      }
      right = right + 1
    }
    left = left + 1
  }
  true
}

///|
pub fn duplicate_evidence_ids(items : Array[Evidence]) -> Array[String] {
  let duplicates = []
  let mut left = 0
  while left < items.length() {
    let mut right = left + 1
    while right < items.length() {
      if items[left].id == items[right].id &&
        !string_in_list(items[left].id, duplicates) {
        duplicates.push(items[left].id)
      }
      right = right + 1
    }
    left = left + 1
  }
  duplicates
}

///|
pub fn duplicate_policy_ids(items : Array[Policy]) -> Array[String] {
  let duplicates = []
  let mut left = 0
  while left < items.length() {
    let mut right = left + 1
    while right < items.length() {
      if items[left].id == items[right].id &&
        !string_in_list(items[left].id, duplicates) {
        duplicates.push(items[left].id)
      }
      right = right + 1
    }
    left = left + 1
  }
  duplicates
}

///|
pub fn fingerprint_chain(entries : Array[TimelineEntry]) -> Array[String] {
  let result = []
  let mut previous = "ma1-root"
  for entry in entries {
    let body = "\{previous}|\{entry.sequence}|\{entry.evidence_id}|\{entry.status}|\{entry.value}|\{entry.observed_at}|\{entry.note}"
    previous = fingerprint_text(body)
    result.push(previous)
  }
  result
}

///|
pub fn verify_fingerprint_chain(
  entries : Array[TimelineEntry],
  expected : Array[String],
) -> Bool {
  let actual = fingerprint_chain(entries)
  if actual.length() != expected.length() {
    return false
  }
  let mut index = 0
  while index < actual.length() {
    if actual[index] != expected[index] {
      return false
    }
    index = index + 1
  }
  true
}
