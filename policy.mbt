///|
/// Return the first evidence record selected by a policy.
pub fn select_policy_evidence(
  policy : Policy,
  evidence : Array[Evidence],
) -> Evidence? {
  for item in evidence {
    let kind_matches = policy.target_kind == "*" ||
      item.kind == policy.target_kind
    let subject_matches = policy.target_subject == "" ||
      item.subject == policy.target_subject
    if kind_matches && subject_matches {
      return Some(item)
    }
  }
  None
}

///|
/// Read a policy-addressable evidence field.
pub fn evidence_field(item : Evidence, field : String) -> String {
  if field == "id" {
    item.id
  } else if field == "kind" {
    item.kind
  } else if field == "subject" {
    item.subject
  } else if field == "status" {
    item.status
  } else if field == "value" {
    item.value
  } else if field == "source" {
    item.source
  } else if field == "collected_at" {
    item.collected_at
  } else if field == "detail" {
    item.detail
  } else if field == "present" {
    "true"
  } else {
    ""
  }
}

///|
pub fn evaluate_text_predicate(
  actual : String,
  predicate : String,
  expected : String,
) -> Bool {
  if predicate == "eq" {
    actual == expected
  } else if predicate == "neq" {
    actual != expected
  } else if predicate == "contains" {
    actual.contains(expected)
  } else if predicate == "not_contains" {
    !actual.contains(expected)
  } else if predicate == "prefix" {
    actual.has_prefix(expected)
  } else if predicate == "suffix" {
    actual.has_suffix(expected)
  } else if predicate == "non_empty" {
    actual != ""
  } else if predicate == "empty" {
    actual == ""
  } else if predicate == "truthy" {
    parse_bool_text(actual, false)
  } else if predicate == "falsy" {
    !parse_bool_text(actual, true)
  } else if predicate == "min_int" {
    parse_signed_int(actual, -2147483647) >= parse_signed_int(expected, 0)
  } else if predicate == "max_int" {
    parse_signed_int(actual, 2147483647) <= parse_signed_int(expected, 0)
  } else if predicate == "between" {
    let limits = expected.split("..").map(value => value.to_owned()).collect()
    let value = parse_signed_int(actual, -2147483647)
    let minimum = parse_signed_int(text_part(limits, 0, "0"), 0)
    let maximum = parse_signed_int(text_part(limits, 1, "0"), 0)
    value >= minimum && value <= maximum
  } else if predicate == "one_of" {
    let options = expected.split(",").map(value => value.to_owned()).collect()
    string_in_list(actual, options)
  } else {
    false
  }
}

///|
pub fn policy_message(
  policy : Policy,
  passed : Bool,
  actual : String,
) -> String {
  if passed {
    "\{policy.title}: observed value satisfies \{policy.predicate} \{policy.expected}"
  } else {
    "\{policy.title}: observed '\{actual}' does not satisfy \{policy.predicate} '\{policy.expected}'"
  }
}

///|
pub fn evaluate_policy(policy : Policy, evidence : Array[Evidence]) -> Finding {
  match select_policy_evidence(policy, evidence) {
    Some(item) => {
      let actual = evidence_field(item, policy.field)
      let passed = if policy.predicate == "present" {
        true
      } else if policy.predicate == "absent" {
        false
      } else {
        evaluate_text_predicate(actual, policy.predicate, policy.expected)
      }
      Finding::make(
        policy.id,
        item.id,
        if passed {
          "info"
        } else {
          policy.severity
        },
        passed,
        policy.weight,
        actual,
        policy.expected,
        policy_message(policy, passed, actual),
      )
    }
    None => {
      let passed = policy.predicate == "absent"
      Finding::make(
        policy.id,
        "",
        if passed {
          "info"
        } else {
          policy.severity
        },
        passed,
        policy.weight,
        "missing",
        policy.expected,
        if passed {
          "\{policy.title}: evidence is correctly absent"
        } else {
          "\{policy.title}: required evidence is missing"
        },
      )
    }
  }
}

///|
pub fn evaluate_policies(
  policies : Array[Policy],
  evidence : Array[Evidence],
) -> Array[Finding] {
  let findings = []
  for policy in policies {
    findings.push(evaluate_policy(policy, evidence))
  }
  findings
}

///|
pub fn finding_possible_weight(findings : Array[Finding]) -> Int {
  let mut total = 0
  for finding in findings {
    if finding.weight > 0 {
      total = total + finding.weight
    }
  }
  total
}

///|
pub fn finding_earned_weight(findings : Array[Finding]) -> Int {
  let mut total = 0
  for finding in findings {
    if finding.passed && finding.weight > 0 {
      total = total + finding.weight
    }
  }
  total
}

///|
pub fn score_findings(findings : Array[Finding]) -> AttestationScore {
  let possible = finding_possible_weight(findings)
  let earned = finding_earned_weight(findings)
  let percent = if possible == 0 { 0 } else { earned * 100 / possible }
  let blocking_failures = count_blocking_findings(findings)
  let warnings = count_warning_findings(findings)
  let verdict = if blocking_failures > 0 {
    "rejected"
  } else if percent >= 90 {
    "ready"
  } else if percent >= 70 {
    "conditional"
  } else {
    "insufficient"
  }
  { earned, possible, percent, verdict, blocking_failures, warnings }
}

///|
pub fn failed_findings(findings : Array[Finding]) -> Array[Finding] {
  let result = []
  for finding in findings {
    if !finding.passed {
      result.push(finding)
    }
  }
  result
}

///|
pub fn passed_findings(findings : Array[Finding]) -> Array[Finding] {
  let result = []
  for finding in findings {
    if finding.passed {
      result.push(finding)
    }
  }
  result
}

///|
pub fn findings_at_least(
  findings : Array[Finding],
  minimum_severity : String,
) -> Array[Finding] {
  let result = []
  let minimum = severity_rank(minimum_severity)
  for finding in findings {
    if severity_rank(finding.severity) >= minimum {
      result.push(finding)
    }
  }
  result
}

///|
pub fn all_blocking_passed(findings : Array[Finding]) -> Bool {
  count_blocking_findings(findings) == 0
}

///|
pub fn policy_ids(policies : Array[Policy]) -> Array[String] {
  policies.map(policy => policy.id)
}

///|
pub fn finding_for_policy(
  findings : Array[Finding],
  policy_id : String,
) -> Finding? {
  for finding in findings {
    if finding.policy_id == policy_id {
      return Some(finding)
    }
  }
  None
}

///|
pub fn policy_by_id(policies : Array[Policy], policy_id : String) -> Policy? {
  for policy in policies {
    if policy.id == policy_id {
      return Some(policy)
    }
  }
  None
}

///|
pub fn policy_coverage(
  policies : Array[Policy],
  findings : Array[Finding],
) -> Int {
  if policies.length() == 0 {
    return 100
  }
  let mut evaluated = 0
  for policy in policies {
    if finding_for_policy(findings, policy.id) is Some(_) {
      evaluated = evaluated + 1
    }
  }
  evaluated * 100 / policies.length()
}
