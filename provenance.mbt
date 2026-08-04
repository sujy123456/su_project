///|
/// OSI-recognized licenses commonly used by MoonBit packages.
pub fn osi_license_ids() -> Array[String] {
  [
    "0BSD", "Apache-2.0", "BSD-2-Clause", "BSD-3-Clause", "BSL-1.0", "EPL-2.0", "GPL-2.0-only",
    "GPL-2.0-or-later", "GPL-3.0-only", "GPL-3.0-or-later", "ISC", "LGPL-2.1-only",
    "LGPL-2.1-or-later", "LGPL-3.0-only", "LGPL-3.0-or-later", "MIT", "MPL-2.0",
    "Unlicense", "Zlib",
  ]
}

///|
pub fn is_osi_license(license : String) -> Bool {
  string_in_list(license, osi_license_ids())
}

///|
pub fn license_requires_notice(license : String) -> Bool {
  license == "Apache-2.0" ||
  license == "EPL-2.0" ||
  license == "MPL-2.0" ||
  license.has_prefix("GPL-") ||
  license.has_prefix("LGPL-")
}

///|
pub fn source_record_issues(record : SourceRecord) -> Array[SourceFinding] {
  let findings = []
  if !record.approved {
    findings.push({
      source_id: record.id,
      passed: false,
      severity: "error",
      code: "source-not-approved",
      message: "source was not approved for inclusion",
    })
  } else {
    findings.push({
      source_id: record.id,
      passed: true,
      severity: "info",
      code: "source-approved",
      message: "source was approved for inclusion",
    })
  }
  if record.origin == "" {
    findings.push({
      source_id: record.id,
      passed: false,
      severity: "error",
      code: "origin-missing",
      message: "source origin is missing",
    })
  } else {
    findings.push({
      source_id: record.id,
      passed: true,
      severity: "info",
      code: "origin-present",
      message: "source origin is declared",
    })
  }
  if !is_osi_license(record.license) {
    findings.push({
      source_id: record.id,
      passed: false,
      severity: "error",
      code: "license-not-osi",
      message: "source license is not in the recognized OSI set",
    })
  } else {
    findings.push({
      source_id: record.id,
      passed: true,
      severity: "info",
      code: "license-osi",
      message: "source license is recognized",
    })
  }
  let notice_ok = !license_requires_notice(record.license) ||
    record.notice_present
  findings.push({
    source_id: record.id,
    passed: notice_ok,
    severity: if notice_ok {
      "info"
    } else {
      "error"
    },
    code: if notice_ok {
      "notice-ok"
    } else {
      "notice-missing"
    },
    message: if notice_ok {
      "license notice obligation is satisfied"
    } else {
      "license requires a notice that was not declared"
    },
  })
  findings
}

///|
pub fn audit_sources(records : Array[SourceRecord]) -> Array[SourceFinding] {
  let findings = []
  for record in records {
    for finding in source_record_issues(record) {
      findings.push(finding)
    }
  }
  findings
}

///|
pub fn source_findings_pass(findings : Array[SourceFinding]) -> Bool {
  for finding in findings {
    if !finding.passed && finding.severity == "error" {
      return false
    }
  }
  true
}

///|
pub fn count_source_failures(findings : Array[SourceFinding]) -> Int {
  let mut count = 0
  for finding in findings {
    if !finding.passed {
      count = count + 1
    }
  }
  count
}

///|
pub fn source_audit_evidence(records : Array[SourceRecord]) -> Evidence {
  let findings = audit_sources(records)
  let failures = count_source_failures(findings)
  Evidence::make(
    "source-provenance",
    "provenance",
    "third-party source declarations",
    if failures == 0 {
      "pass"
    } else {
      "fail"
    },
    value="\{records.length()}",
    source="SOURCE_ATTRIBUTION",
    detail="failures=\{failures}",
  )
}

///|
pub fn original_project_evidence(
  declared_original : Bool,
  copied_sources : Int,
) -> Evidence {
  let passed = declared_original && copied_sources == 0
  Evidence::make(
    "originality-declaration",
    "provenance",
    "original project declaration",
    if passed {
      "pass"
    } else {
      "fail"
    },
    value=if declared_original { "original" } else { "port-or-reference" },
    source="project-application",
    detail="copied_sources=\{copied_sources}",
  )
}

///|
pub fn render_source_inventory(records : Array[SourceRecord]) -> String {
  let mut output = "| id | name | origin | license | usage | modified | notice |\n"
  output = output + "|---|---|---|---|---|---|---|\n"
  for record in records {
    output = output +
      "| \{escape_markdown_cell(record.id)} | \{escape_markdown_cell(record.name)} | "
    output = output +
      "\{escape_markdown_cell(record.origin)} | \{record.license} | "
    output = output +
      "\{escape_markdown_cell(record.usage)} | \{record.modified} | \{record.notice_present} |\n"
  }
  output
}
