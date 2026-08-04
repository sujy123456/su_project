///|
pub fn render_evidence_markdown(items : Array[Evidence]) -> String {
  let mut output = "| Evidence | Kind | Subject | Status | Value | Source |\n"
  output = output + "|---|---|---|---|---:|---|\n"
  for item in items {
    output = output + "| `" + escape_markdown_cell(item.id) + "` | "
    output = output + escape_markdown_cell(item.kind) + " | "
    output = output + escape_markdown_cell(item.subject) + " | "
    output = output + item.status + " | "
    output = output + escape_markdown_cell(item.value) + " | "
    output = output + escape_markdown_cell(item.source) + " |\n"
  }
  output
}

///|
pub fn render_findings_markdown(items : Array[Finding]) -> String {
  let mut output = "| Policy | Result | Severity | Actual | Expected | Message |\n"
  output = output + "|---|---|---|---|---|---|\n"
  for item in items {
    output = output + "| `" + escape_markdown_cell(item.policy_id) + "` | "
    output = output + (if item.passed { "PASS" } else { "FAIL" }) + " | "
    output = output + item.severity + " | "
    output = output + escape_markdown_cell(item.actual) + " | "
    output = output + escape_markdown_cell(item.expected) + " | "
    output = output + escape_markdown_cell(item.message) + " |\n"
  }
  output
}

///|
pub fn render_schema_issues_markdown(items : Array[SchemaIssue]) -> String {
  if items.length() == 0 {
    return "No schema issues.\n"
  }
  let mut output = "| Path | Code | Severity | Message |\n"
  output = output + "|---|---|---|---|\n"
  for item in items {
    output = output + "| `" + escape_markdown_cell(item.path) + "` | "
    output = output + item.code + " | " + item.severity + " | "
    output = output + escape_markdown_cell(item.message) + " |\n"
  }
  output
}

///|
pub fn render_proof_markdown(bundle : ProofBundle) -> String {
  let meta = bundle.attestation.meta
  let score = bundle.score
  let mut output = "# MoonAttest Proof: " + meta.display_name + "\n\n"
  output = output + "- Project ID: `" + meta.project_id + "`\n"
  output = output + "- Repository: " + meta.repository + "\n"
  output = output + "- Revision: `" + meta.revision + "`\n"
  output = output + "- Generated: " + meta.generated_at + "\n"
  output = output + "- Verdict: **" + score.verdict + "**\n"
  output = output + "- Score: **" + score.percent.to_string() + "%** ("
  output = output +
    score.earned.to_string() +
    "/" +
    score.possible.to_string() +
    ")\n"
  output = output + "- Fingerprint: `" + bundle.fingerprint + "`\n\n"
  output = output +
    "## Evidence\n\n" +
    render_evidence_markdown(bundle.attestation.evidence)
  output = output +
    "\n## Policy Findings\n\n" +
    render_findings_markdown(bundle.findings)
  output
}

///|
fn json_property(name : String, value : String) -> String {
  "\"" + escape_json(name) + "\":\"" + escape_json(value) + "\""
}

///|
fn json_evidence(item : Evidence) -> String {
  "{" +
  json_property("id", item.id) +
  "," +
  json_property("kind", item.kind) +
  "," +
  json_property("subject", item.subject) +
  "," +
  json_property("status", item.status) +
  "," +
  json_property("value", item.value) +
  "," +
  json_property("source", item.source) +
  "," +
  json_property("collected_at", item.collected_at) +
  "," +
  json_property("detail", item.detail) +
  "}"
}

///|
fn json_finding(item : Finding) -> String {
  "{" +
  json_property("policy_id", item.policy_id) +
  "," +
  json_property("evidence_id", item.evidence_id) +
  "," +
  json_property("severity", item.severity) +
  "," +
  "\"passed\":" +
  item.passed.to_string() +
  "," +
  "\"weight\":" +
  item.weight.to_string() +
  "," +
  json_property("actual", item.actual) +
  "," +
  json_property("expected", item.expected) +
  "," +
  json_property("message", item.message) +
  "}"
}

///|
fn json_evidence_array(items : Array[Evidence]) -> String {
  let mut output = "["
  let mut index = 0
  while index < items.length() {
    if index > 0 {
      output = output + ","
    }
    output = output + json_evidence(items[index])
    index = index + 1
  }
  output + "]"
}

///|
fn json_findings_array(items : Array[Finding]) -> String {
  let mut output = "["
  let mut index = 0
  while index < items.length() {
    if index > 0 {
      output = output + ","
    }
    output = output + json_finding(items[index])
    index = index + 1
  }
  output + "]"
}

///|
pub fn render_proof_json(bundle : ProofBundle) -> String {
  let meta = bundle.attestation.meta
  let score = bundle.score
  "{" +
  json_property("format_version", bundle.format_version) +
  "," +
  json_property("project_id", meta.project_id) +
  "," +
  json_property("display_name", meta.display_name) +
  "," +
  json_property("repository", meta.repository) +
  "," +
  json_property("revision", meta.revision) +
  "," +
  json_property("generated_at", meta.generated_at) +
  "," +
  "\"score\":{" +
  "\"earned\":" +
  score.earned.to_string() +
  "," +
  "\"possible\":" +
  score.possible.to_string() +
  "," +
  "\"percent\":" +
  score.percent.to_string() +
  "," +
  json_property("verdict", score.verdict) +
  "," +
  "\"blocking_failures\":" +
  score.blocking_failures.to_string() +
  "}," +
  "\"evidence\":" +
  json_evidence_array(bundle.attestation.evidence) +
  "," +
  "\"findings\":" +
  json_findings_array(bundle.findings) +
  "," +
  json_property("fingerprint", bundle.fingerprint) +
  "}"
}

///|
pub fn render_delta_markdown(deltas : Array[EvidenceDelta]) -> String {
  let mut output = "# Attestation Difference\n\n"
  output = output + evidence_delta_summary(deltas) + "\n\n"
  output = output +
    "| Evidence | Change | Old status | New status | Old value | New value |\n"
  output = output + "|---|---|---|---|---|---|\n"
  for delta in deltas {
    output = output + "| `" + escape_markdown_cell(delta.evidence_id) + "` | "
    output = output +
      delta.change +
      " | " +
      delta.old_status +
      " | " +
      delta.new_status +
      " | "
    output = output + escape_markdown_cell(delta.old_value) + " | "
    output = output + escape_markdown_cell(delta.new_value) + " |\n"
  }
  output
}

///|
pub fn render_timeline_markdown(entries : Array[TimelineEntry]) -> String {
  let mut output = "| Sequence | Evidence | Status | Value | Observed | Note | Chain |\n"
  output = output + "|---:|---|---|---:|---|---|---|\n"
  let sorted = timeline_sorted(entries)
  let chain = timeline_chain(entries)
  let mut index = 0
  while index < sorted.length() {
    let entry = sorted[index]
    output = output +
      "| " +
      entry.sequence.to_string() +
      " | `" +
      entry.evidence_id +
      "` | "
    output = output +
      entry.status +
      " | " +
      escape_markdown_cell(entry.value) +
      " | "
    output = output + escape_markdown_cell(entry.observed_at) + " | "
    output = output +
      escape_markdown_cell(entry.note) +
      " | `" +
      chain[index] +
      "` |\n"
    index = index + 1
  }
  output
}

///|
pub fn render_console_summary(bundle : ProofBundle) -> String {
  let failed = failed_findings(bundle.findings)
  let mut output = "MoonAttest " + bundle.format_version + "\n"
  output = output + "Project: " + bundle.attestation.meta.display_name + "\n"
  output = output + "Revision: " + bundle.attestation.meta.revision + "\n"
  output = output +
    "Evidence: " +
    bundle.attestation.evidence.length().to_string() +
    "\n"
  output = output +
    "Policies: " +
    bundle.attestation.policies.length().to_string() +
    "\n"
  output = output + "Verdict: " + bundle.score.verdict + "\n"
  output = output + "Score: " + bundle.score.percent.to_string() + "%\n"
  output = output + "Failures: " + failed.length().to_string() + "\n"
  output = output + "Fingerprint: " + bundle.fingerprint
  output
}
