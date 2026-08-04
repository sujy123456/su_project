///|
pub fn allowed_evidence_statuses() -> Array[String] {
  [
    "pass", "fail", "warn", "unknown", "not_applicable", "present", "missing", "verified",
    "invalid",
  ]
}

///|
pub fn allowed_policy_predicates() -> Array[String] {
  [
    "eq", "neq", "contains", "not_contains", "prefix", "suffix", "non_empty", "empty",
    "truthy", "falsy", "min_int", "max_int", "between", "one_of",
  ]
}

///|
pub fn allowed_severities() -> Array[String] {
  ["critical", "error", "warn", "warning", "info"]
}

///|
fn schema_issue(
  path : String,
  code : String,
  message : String,
  severity : String,
) -> SchemaIssue {
  SchemaIssue::make(path, code, message, severity~)
}

///|
pub fn validate_project_meta(meta : ProjectMeta) -> Array[SchemaIssue] {
  let issues : Array[SchemaIssue] = []
  if meta.display_name.trim().is_empty() {
    issues.push(
      schema_issue(
        "project.name", "required", "project name is required", "error",
      ),
    )
  }
  if meta.repository.trim().is_empty() {
    issues.push(
      schema_issue(
        "project.repository", "required", "repository URL is required", "error",
      ),
    )
  } else if !meta.repository.contains("github.com/") &&
    !meta.repository.contains("gitlab.com/") &&
    !meta.repository.contains("gitlink.org.cn/") {
    issues.push(
      schema_issue(
        "project.repository", "repository_url", "repository should be a public forge URL",
        "warning",
      ),
    )
  }
  if meta.revision.trim().is_empty() {
    issues.push(
      schema_issue(
        "project.revision", "required", "revision is required", "error",
      ),
    )
  }
  if meta.generated_at.trim().is_empty() {
    issues.push(
      schema_issue(
        "project.generated_at", "required", "generation time is required", "error",
      ),
    )
  }
  if meta.producer.trim().is_empty() {
    issues.push(
      schema_issue(
        "project.producer", "required", "producer is required", "error",
      ),
    )
  }
  issues
}

///|
pub fn validate_evidence_item(
  item : Evidence,
  index : Int,
) -> Array[SchemaIssue] {
  let issues : Array[SchemaIssue] = []
  let root = "evidence[" + index.to_string() + "]"
  if item.id.trim().is_empty() {
    issues.push(
      schema_issue(root + ".id", "required", "evidence id is required", "error"),
    )
  }
  if item.kind.trim().is_empty() {
    issues.push(
      schema_issue(
        root + ".kind",
        "required",
        "evidence kind is required",
        "error",
      ),
    )
  }
  if item.subject.trim().is_empty() {
    issues.push(
      schema_issue(
        root + ".subject",
        "required",
        "evidence subject is required",
        "error",
      ),
    )
  }
  if !allowed_evidence_statuses().contains(item.status) {
    issues.push(
      schema_issue(
        root + ".status",
        "enum",
        "unsupported evidence status: " + item.status,
        "error",
      ),
    )
  }
  if item.value.trim().is_empty() && item.status != "not_applicable" {
    issues.push(
      schema_issue(
        root + ".value",
        "required",
        "evidence value is required",
        "warning",
      ),
    )
  }
  if item.collected_at.trim().is_empty() {
    issues.push(
      schema_issue(
        root + ".collected_at",
        "required",
        "observation time is required",
        "warn",
      ),
    )
  }
  if item.source.trim().is_empty() {
    issues.push(
      schema_issue(
        root + ".source",
        "required",
        "evidence source is required",
        "error",
      ),
    )
  }
  issues
}

///|
pub fn validate_policy_item(item : Policy, index : Int) -> Array[SchemaIssue] {
  let issues : Array[SchemaIssue] = []
  let root = "policies[" + index.to_string() + "]"
  if item.id.trim().is_empty() {
    issues.push(
      schema_issue(root + ".id", "required", "policy id is required", "error"),
    )
  }
  if item.title.trim().is_empty() {
    issues.push(
      schema_issue(
        root + ".title",
        "required",
        "policy title is required",
        "error",
      ),
    )
  }
  if item.target_kind.trim().is_empty() {
    issues.push(
      schema_issue(
        root + ".target_kind",
        "required",
        "target evidence kind is required",
        "error",
      ),
    )
  }
  if !allowed_policy_predicates().contains(item.predicate) {
    issues.push(
      schema_issue(
        root + ".predicate",
        "enum",
        "unsupported predicate: " + item.predicate,
        "error",
      ),
    )
  }
  if !allowed_severities().contains(item.severity) {
    issues.push(
      schema_issue(
        root + ".severity",
        "enum",
        "unsupported severity: " + item.severity,
        "error",
      ),
    )
  }
  if item.weight < 0 || item.weight > 100 {
    issues.push(
      schema_issue(
        root + ".weight",
        "range",
        "policy weight must be between 0 and 100",
        "error",
      ),
    )
  }
  issues
}

///|
fn duplicate_schema_issues(
  values : Array[String],
  path : String,
) -> Array[SchemaIssue] {
  let issues : Array[SchemaIssue] = []
  let seen : Array[String] = []
  let reported : Array[String] = []
  for value in values {
    if seen.contains(value) && !reported.contains(value) {
      reported.push(value)
      issues.push(
        schema_issue(
          path,
          "duplicate",
          "duplicate identifier: " + value,
          "error",
        ),
      )
    } else {
      seen.push(value)
    }
  }
  issues
}

///|
pub fn validate_attestation(attestation : Attestation) -> Array[SchemaIssue] {
  let issues = validate_project_meta(attestation.meta)
  for index, item in attestation.evidence {
    for issue in validate_evidence_item(item, index) {
      issues.push(issue)
    }
  }
  for index, item in attestation.policies {
    for issue in validate_policy_item(item, index) {
      issues.push(issue)
    }
  }
  let evidence_ids = attestation.evidence.map(item => item.id)
  let policy_ids = attestation.policies.map(item => item.id)
  for issue in duplicate_schema_issues(evidence_ids, "evidence") {
    issues.push(issue)
  }
  for issue in duplicate_schema_issues(policy_ids, "policies") {
    issues.push(issue)
  }
  issues
}

///|
pub fn schema_error_count(issues : Array[SchemaIssue]) -> Int {
  issues.filter(issue => issue.severity == "error").length()
}

///|
pub fn schema_warning_count(issues : Array[SchemaIssue]) -> Int {
  issues
  .filter(issue => issue.severity == "warning" || issue.severity == "warn")
  .length()
}

///|
pub fn schema_is_valid(issues : Array[SchemaIssue]) -> Bool {
  schema_error_count(issues) == 0
}

///|
pub fn schema_evidence(
  attestation : Attestation,
  observed_at : String,
) -> Evidence {
  let issues = validate_attestation(attestation)
  let errors = schema_error_count(issues)
  let warnings = schema_warning_count(issues)
  Evidence::make(
    "schema.attestation",
    "schema",
    attestation.meta.display_name,
    if errors == 0 {
      "pass"
    } else {
      "fail"
    },
    value="errors=" + errors.to_string() + ",warnings=" + warnings.to_string(),
    source="moonattest/schema",
    collected_at=observed_at,
    detail="structural validation of the attestation document",
  )
}
