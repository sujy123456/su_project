///|
/// Identity and revision metadata for one project acceptance run.
pub(all) struct ProjectMeta {
  project_id : String
  display_name : String
  repository : String
  revision : String
  generated_at : String
  producer : String
} derive(Eq, Debug)

///|
/// One normalized, independently inspectable acceptance fact.
pub(all) struct Evidence {
  id : String
  kind : String
  subject : String
  status : String
  value : String
  source : String
  collected_at : String
  detail : String
} derive(Eq, Debug)

///|
/// A policy declaration evaluated against normalized evidence.
pub(all) struct Policy {
  id : String
  title : String
  target_kind : String
  target_subject : String
  field : String
  predicate : String
  expected : String
  severity : String
  weight : Int
} derive(Eq, Debug)

///|
/// Result of evaluating one policy.
pub(all) struct Finding {
  policy_id : String
  evidence_id : String
  severity : String
  passed : Bool
  weight : Int
  actual : String
  expected : String
  message : String
} derive(Eq, Debug)

///|
/// Input document from which a proof bundle is derived.
pub(all) struct Attestation {
  meta : ProjectMeta
  evidence : Array[Evidence]
  policies : Array[Policy]
} derive(Eq, Debug)

///|
/// Weighted score and final decision for an attestation.
pub(all) struct AttestationScore {
  earned : Int
  possible : Int
  percent : Int
  verdict : String
  blocking_failures : Int
  warnings : Int
} derive(Eq, Debug)

///|
/// Deterministic proof bundle suitable for CI artifacts and review records.
pub(all) struct ProofBundle {
  attestation : Attestation
  findings : Array[Finding]
  score : AttestationScore
  fingerprint : String
  format_version : String
} derive(Eq, Debug)

///|
/// Difference for one evidence identifier across two attestations.
pub(all) struct EvidenceDelta {
  evidence_id : String
  change : String
  old_status : String
  new_status : String
  old_value : String
  new_value : String
} derive(Eq, Debug)

///|
/// Provenance declaration for copied, adapted, or generated material.
pub(all) struct SourceRecord {
  id : String
  name : String
  origin : String
  license : String
  usage : String
  modified : Bool
  notice_present : Bool
  approved : Bool
} derive(Eq, Debug)

///|
/// Compliance result for one provenance declaration.
pub(all) struct SourceFinding {
  source_id : String
  passed : Bool
  severity : String
  code : String
  message : String
} derive(Eq, Debug)

///|
/// File-level observation imported from a change summary.
pub(all) struct FileObservation {
  path : String
  action : String
  lines_added : Int
  lines_removed : Int
  generated : Bool
  tracked : Bool
} derive(Eq, Debug)

///|
/// Boundary policy for repository changes.
pub(all) struct BoundaryRule {
  id : String
  allowed_prefix : String
  denied_fragment : String
  max_delta : Int
  allow_generated : Bool
  require_tracked : Bool
} derive(Eq, Debug)

///|
/// Ordered evidence history entry used to explain how a result changed.
pub(all) struct TimelineEntry {
  sequence : Int
  evidence_id : String
  status : String
  value : String
  observed_at : String
  note : String
} derive(Eq, Debug)

///|
/// Structural validation issue for an attestation document.
pub(all) struct SchemaIssue {
  path : String
  code : String
  severity : String
  message : String
} derive(Eq, Debug)

///|
/// Conflicting observations that use the same stable evidence identifier.
pub(all) struct EvidenceConflict {
  evidence_id : String
  first_source : String
  second_source : String
  first_status : String
  second_status : String
  first_value : String
  second_value : String
} derive(Eq, Debug)

///|
/// Aggregate measurements for one evidence collection.
pub(all) struct EvidenceMetrics {
  total : Int
  passing : Int
  failing : Int
  warning : Int
  unknown : Int
  unique_kinds : Int
  unique_sources : Int
  completeness_percent : Int
  health_percent : Int
} derive(Eq, Debug)

///|
/// Aggregate measurements for one policy evaluation.
pub(all) struct PolicyMetrics {
  total : Int
  passed : Int
  failed : Int
  blocking_failed : Int
  warning_failed : Int
  evaluated_percent : Int
  weighted_percent : Int
} derive(Eq, Debug)

///|
pub fn ProjectMeta::make(
  project_id : String,
  display_name : String,
  repository : String,
  revision : String,
  generated_at? : String = "",
  producer? : String = "moonattest",
) -> ProjectMeta {
  { project_id, display_name, repository, revision, generated_at, producer }
}

///|
pub fn Evidence::make(
  id : String,
  kind : String,
  subject : String,
  status : String,
  value? : String = "",
  source? : String = "manual",
  collected_at? : String = "",
  detail? : String = "",
) -> Evidence {
  { id, kind, subject, status, value, source, collected_at, detail }
}

///|
pub fn Policy::make(
  id : String,
  title : String,
  target_kind : String,
  field : String,
  predicate : String,
  expected : String,
  target_subject? : String = "",
  severity? : String = "error",
  weight? : Int = 1,
) -> Policy {
  {
    id,
    title,
    target_kind,
    target_subject,
    field,
    predicate,
    expected,
    severity,
    weight,
  }
}

///|
pub fn Finding::make(
  policy_id : String,
  evidence_id : String,
  severity : String,
  passed : Bool,
  weight : Int,
  actual : String,
  expected : String,
  message : String,
) -> Finding {
  {
    policy_id,
    evidence_id,
    severity,
    passed,
    weight,
    actual,
    expected,
    message,
  }
}

///|
pub fn Attestation::make(
  meta : ProjectMeta,
  evidence : Array[Evidence],
  policies : Array[Policy],
) -> Attestation {
  { meta, evidence, policies }
}

///|
pub fn SourceRecord::make(
  id : String,
  name : String,
  origin : String,
  license : String,
  usage : String,
  modified? : Bool = false,
  notice_present? : Bool = false,
  approved? : Bool = true,
) -> SourceRecord {
  { id, name, origin, license, usage, modified, notice_present, approved }
}

///|
pub fn FileObservation::make(
  path : String,
  action : String,
  lines_added? : Int = 0,
  lines_removed? : Int = 0,
  generated? : Bool = false,
  tracked? : Bool = true,
) -> FileObservation {
  { path, action, lines_added, lines_removed, generated, tracked }
}

///|
pub fn BoundaryRule::make(
  id : String,
  allowed_prefix? : String = "",
  denied_fragment? : String = "",
  max_delta? : Int = 10000,
  allow_generated? : Bool = false,
  require_tracked? : Bool = true,
) -> BoundaryRule {
  {
    id,
    allowed_prefix,
    denied_fragment,
    max_delta,
    allow_generated,
    require_tracked,
  }
}

///|
pub fn TimelineEntry::make(
  sequence : Int,
  evidence_id : String,
  status : String,
  value? : String = "",
  observed_at? : String = "",
  note? : String = "",
) -> TimelineEntry {
  { sequence, evidence_id, status, value, observed_at, note }
}

///|
pub fn EvidenceDelta::make(
  evidence_id : String,
  change : String,
  old_status : String,
  new_status : String,
  old_value : String,
  new_value : String,
) -> EvidenceDelta {
  { evidence_id, change, old_status, new_status, old_value, new_value }
}

///|
pub fn EvidenceConflict::make(
  evidence_id : String,
  first_source : String,
  second_source : String,
  first_status : String,
  second_status : String,
  first_value : String,
  second_value : String,
) -> EvidenceConflict {
  {
    evidence_id,
    first_source,
    second_source,
    first_status,
    second_status,
    first_value,
    second_value,
  }
}

///|
pub fn SchemaIssue::make(
  path : String,
  code : String,
  message : String,
  severity? : String = "error",
) -> SchemaIssue {
  { path, code, severity, message }
}

///|
pub fn Evidence::is_pass(self : Evidence) -> Bool {
  self.status == "pass" || self.status == "present" || self.status == "verified"
}

///|
pub fn Evidence::is_failure(self : Evidence) -> Bool {
  self.status == "fail" || self.status == "missing" || self.status == "invalid"
}

///|
pub fn Evidence::identity(self : Evidence) -> String {
  "\{self.kind}:\{self.subject}:\{self.id}"
}

///|
pub fn Policy::is_blocking(self : Policy) -> Bool {
  self.severity == "error" || self.severity == "critical"
}

///|
pub fn FileObservation::delta(self : FileObservation) -> Int {
  self.lines_added + self.lines_removed
}

///|
pub fn Attestation::evidence_count(self : Attestation) -> Int {
  self.evidence.length()
}

///|
pub fn Attestation::policy_count(self : Attestation) -> Int {
  self.policies.length()
}

///|
pub fn Attestation::find_evidence(self : Attestation, id : String) -> Evidence? {
  for item in self.evidence {
    if item.id == id {
      return Some(item)
    }
  }
  None
}

///|
pub fn Attestation::has_evidence(self : Attestation, id : String) -> Bool {
  self.find_evidence(id) is Some(_)
}

///|
pub fn Attestation::evidence_of_kind(
  self : Attestation,
  kind : String,
) -> Array[Evidence] {
  let result = []
  for item in self.evidence {
    if item.kind == kind {
      result.push(item)
    }
  }
  result
}

///|
pub fn count_passed_findings(findings : Array[Finding]) -> Int {
  let mut count = 0
  for item in findings {
    if item.passed {
      count = count + 1
    }
  }
  count
}

///|
pub fn count_failed_findings(findings : Array[Finding]) -> Int {
  findings.length() - count_passed_findings(findings)
}

///|
pub fn count_blocking_findings(findings : Array[Finding]) -> Int {
  let mut count = 0
  for item in findings {
    if !item.passed && (item.severity == "error" || item.severity == "critical") {
      count = count + 1
    }
  }
  count
}

///|
pub fn count_warning_findings(findings : Array[Finding]) -> Int {
  let mut count = 0
  for item in findings {
    if !item.passed && item.severity == "warn" {
      count = count + 1
    }
  }
  count
}
