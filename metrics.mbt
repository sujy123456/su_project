///|
fn count_status(items : Array[Evidence], status : String) -> Int {
  items.filter(item => item.status == status).length()
}

///|
pub fn evidence_metrics(items : Array[Evidence]) -> EvidenceMetrics {
  let total = items.length()
  let passing = items.filter(item => item.is_pass()).length()
  let failing = items.filter(item => item.is_failure()).length()
  let warning = count_status(items, "warn")
  let unknown = count_status(items, "unknown")
  let unique_kinds = evidence_kinds(items).length()
  let unique_sources = evidence_sources(items).length()
  let complete = total - unknown - count_status(items, "missing")
  let completeness_percent = if total == 0 {
    100
  } else {
    complete * 100 / total
  }
  let health_percent = if total == 0 {
    100
  } else {
    (passing * 100 + warning * 50) / total
  }
  {
    total,
    passing,
    failing,
    warning,
    unknown,
    unique_kinds,
    unique_sources,
    completeness_percent,
    health_percent,
  }
}

///|
pub fn policy_metrics(
  policies : Array[Policy],
  findings : Array[Finding],
) -> PolicyMetrics {
  let total = policies.length()
  let passed = count_passed_findings(findings)
  let failed = count_failed_findings(findings)
  let blocking_failed = count_blocking_findings(findings)
  let warning_failed = count_warning_findings(findings)
  let evaluated_percent = policy_coverage(policies, findings)
  let score = score_findings(findings)
  {
    total,
    passed,
    failed,
    blocking_failed,
    warning_failed,
    evaluated_percent,
    weighted_percent: score.percent,
  }
}

///|
pub fn evidence_kind_counts(items : Array[Evidence]) -> Array[(String, Int)] {
  let result : Array[(String, Int)] = []
  for kind in evidence_kinds(items) {
    result.push((kind, evidence_with_kind(items, kind).length()))
  }
  result
}

///|
pub fn evidence_source_counts(items : Array[Evidence]) -> Array[(String, Int)] {
  let result : Array[(String, Int)] = []
  for source in evidence_sources(items) {
    result.push((source, evidence_with_source(items, source).length()))
  }
  result
}

///|
pub fn evidence_status_counts(items : Array[Evidence]) -> Array[(String, Int)] {
  let result : Array[(String, Int)] = []
  for status in evidence_statuses(items) {
    result.push((status, evidence_with_status(items, status).length()))
  }
  result
}

///|
pub fn metric_grade(percent : Int) -> String {
  if percent >= 90 {
    "A"
  } else if percent >= 80 {
    "B"
  } else if percent >= 70 {
    "C"
  } else if percent >= 60 {
    "D"
  } else {
    "F"
  }
}

///|
pub fn render_metrics_markdown(
  evidence : EvidenceMetrics,
  policy : PolicyMetrics,
) -> String {
  let mut output = "## Acceptance Metrics\n\n"
  output = output + "| Metric | Value |\n|---|---:|\n"
  output = output +
    "| Evidence records | " +
    evidence.total.to_string() +
    " |\n"
  output = output +
    "| Passing evidence | " +
    evidence.passing.to_string() +
    " |\n"
  output = output +
    "| Failing evidence | " +
    evidence.failing.to_string() +
    " |\n"
  output = output +
    "| Evidence completeness | " +
    evidence.completeness_percent.to_string() +
    "% |\n"
  output = output +
    "| Evidence health | " +
    evidence.health_percent.to_string() +
    "% |\n"
  output = output + "| Policy pass | " + policy.passed.to_string() + " |\n"
  output = output + "| Policy fail | " + policy.failed.to_string() + " |\n"
  output = output +
    "| Weighted score | " +
    policy.weighted_percent.to_string() +
    "% |\n"
  output
}

///|
pub fn bundle_metrics_markdown(bundle : ProofBundle) -> String {
  render_metrics_markdown(
    evidence_metrics(bundle.attestation.evidence),
    policy_metrics(bundle.attestation.policies, bundle.findings),
  )
}

///|
pub fn metric_evidence(
  items : Array[Evidence],
  collected_at? : String = "",
) -> Array[Evidence] {
  let metrics = evidence_metrics(items)
  [
    Evidence::make(
      "metric-completeness",
      "metric",
      "evidence completeness",
      if metrics.completeness_percent >= 90 {
        "pass"
      } else {
        "warn"
      },
      value=metrics.completeness_percent.to_string(),
      source="moonattest/metrics",
      collected_at~,
    ),
    Evidence::make(
      "metric-health",
      "metric",
      "evidence health",
      if metrics.health_percent >= 80 {
        "pass"
      } else {
        "warn"
      },
      value=metrics.health_percent.to_string(),
      source="moonattest/metrics",
      collected_at~,
    ),
    Evidence::make(
      "metric-source-diversity",
      "metric",
      "unique evidence sources",
      if metrics.unique_sources >= 2 {
        "pass"
      } else {
        "warn"
      },
      value=metrics.unique_sources.to_string(),
      source="moonattest/metrics",
      collected_at~,
    ),
  ]
}
