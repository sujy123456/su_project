///|
/// Parse the MoonAttest line protocol.
///
/// The format is intentionally dependency-free and deterministic:
/// project, name, repository, revision, generated, producer, evidence, policy.
pub fn parse_attestation_manifest(text : String) -> Attestation {
  let mut project_id = "unnamed"
  let mut display_name = "Unnamed project"
  let mut repository = ""
  let mut revision = ""
  let mut generated_at = ""
  let mut producer = "moonattest"
  let evidence = []
  let policies = []
  for raw in text.split("\n") {
    let line = raw.to_owned()
    if line == "" || line.has_prefix("#") {
      continue
    }
    if line.has_prefix("project ") {
      project_id = line.after("project ").unwrap_or("unnamed").to_owned()
    } else if line.has_prefix("name ") {
      display_name = line.after("name ").unwrap_or("Unnamed project").to_owned()
    } else if line.has_prefix("repository ") {
      repository = line.after("repository ").unwrap_or("").to_owned()
    } else if line.has_prefix("revision ") {
      revision = line.after("revision ").unwrap_or("").to_owned()
    } else if line.has_prefix("generated ") {
      generated_at = line.after("generated ").unwrap_or("").to_owned()
    } else if line.has_prefix("producer ") {
      producer = line.after("producer ").unwrap_or("moonattest").to_owned()
    } else if line.has_prefix("evidence ") {
      evidence.push(
        parse_evidence_line(line.after("evidence ").unwrap_or("").to_owned()),
      )
    } else if line.has_prefix("policy ") {
      policies.push(
        parse_policy_line(line.after("policy ").unwrap_or("").to_owned()),
      )
    }
  }
  Attestation::make(
    ProjectMeta::make(
      project_id,
      display_name,
      repository,
      revision,
      generated_at~,
      producer~,
    ),
    evidence,
    policies,
  )
}

///|
pub fn parse_evidence_line(line : String) -> Evidence {
  let parts = line.split("|").map(value => value.to_owned()).collect()
  Evidence::make(
    text_part(parts, 0, "missing-id"),
    text_part(parts, 1, "unknown"),
    text_part(parts, 2, "project"),
    normalized_status(text_part(parts, 3, "unknown")),
    value=text_part(parts, 4, ""),
    source=text_part(parts, 5, "manual"),
    collected_at=text_part(parts, 6, ""),
    detail=text_part(parts, 7, ""),
  )
}

///|
pub fn parse_policy_line(line : String) -> Policy {
  let parts = line.split("|").map(value => value.to_owned()).collect()
  Policy::make(
    text_part(parts, 0, "missing-policy-id"),
    text_part(parts, 1, "Untitled policy"),
    text_part(parts, 2, "unknown"),
    text_part(parts, 4, "status"),
    text_part(parts, 5, "eq"),
    text_part(parts, 6, "pass"),
    target_subject=text_part(parts, 3, ""),
    severity=text_part(parts, 7, "error"),
    weight=parse_non_negative_int(text_part(parts, 8, "1"), 1),
  )
}

///|
pub fn render_evidence_line(item : Evidence) -> String {
  "evidence \{item.id}|\{item.kind}|\{item.subject}|\{item.status}|\{item.value}|\{item.source}|\{item.collected_at}|\{item.detail}"
}

///|
pub fn render_policy_line(policy : Policy) -> String {
  "policy \{policy.id}|\{policy.title}|\{policy.target_kind}|\{policy.target_subject}|\{policy.field}|\{policy.predicate}|\{policy.expected}|\{policy.severity}|\{policy.weight}"
}

///|
pub fn render_attestation_manifest(attestation : Attestation) -> String {
  let meta = attestation.meta
  let mut output = "project \{meta.project_id}\n"
  output = output + "name \{meta.display_name}\n"
  output = output + "repository \{meta.repository}\n"
  output = output + "revision \{meta.revision}\n"
  output = output + "generated \{meta.generated_at}\n"
  output = output + "producer \{meta.producer}\n"
  for item in attestation.evidence {
    output = output + render_evidence_line(item) + "\n"
  }
  for policy in attestation.policies {
    output = output + render_policy_line(policy) + "\n"
  }
  output
}

///|
pub fn manifest_summary(attestation : Attestation) -> String {
  "\{attestation.meta.project_id}: \{attestation.evidence.length()} evidence records, \{attestation.policies.length()} policies"
}

///|
pub fn manifest_has_header(text : String) -> Bool {
  text.contains("project ") && text.contains("revision ")
}

///|
pub fn manifest_evidence_line_count(text : String) -> Int {
  let mut count = 0
  for line in text.split("\n") {
    if line.has_prefix("evidence ") {
      count = count + 1
    }
  }
  count
}

///|
pub fn manifest_policy_line_count(text : String) -> Int {
  let mut count = 0
  for line in text.split("\n") {
    if line.has_prefix("policy ") {
      count = count + 1
    }
  }
  count
}

///|
pub fn replace_manifest_revision(
  attestation : Attestation,
  revision : String,
) -> Attestation {
  let old = attestation.meta
  Attestation::make(
    ProjectMeta::make(
      old.project_id,
      old.display_name,
      old.repository,
      revision,
      generated_at=old.generated_at,
      producer=old.producer,
    ),
    attestation.evidence,
    attestation.policies,
  )
}

///|
pub fn append_manifest_evidence(
  attestation : Attestation,
  item : Evidence,
) -> Attestation {
  let evidence = attestation.evidence.copy()
  evidence.push(item)
  Attestation::make(attestation.meta, evidence, attestation.policies)
}

///|
pub fn append_manifest_policy(
  attestation : Attestation,
  policy : Policy,
) -> Attestation {
  let policies = attestation.policies.copy()
  policies.push(policy)
  Attestation::make(attestation.meta, attestation.evidence, policies)
}
