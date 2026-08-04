///|
pub fn observation_matches_boundary(
  item : FileObservation,
  rule : BoundaryRule,
) -> Bool {
  let prefix_ok = rule.allowed_prefix == "" ||
    item.path.has_prefix(rule.allowed_prefix)
  let denied_ok = rule.denied_fragment == "" ||
    !item.path.contains(rule.denied_fragment)
  let delta_ok = item.delta() <= rule.max_delta
  let generated_ok = rule.allow_generated || !item.generated
  let tracked_ok = !rule.require_tracked || item.tracked
  prefix_ok && denied_ok && delta_ok && generated_ok && tracked_ok
}

///|
pub fn observation_boundary_reason(
  item : FileObservation,
  rule : BoundaryRule,
) -> String {
  if rule.allowed_prefix != "" && !item.path.has_prefix(rule.allowed_prefix) {
    "path is outside allowed prefix"
  } else if rule.denied_fragment != "" &&
    item.path.contains(rule.denied_fragment) {
    "path contains denied fragment"
  } else if item.delta() > rule.max_delta {
    "line delta exceeds declared boundary"
  } else if item.generated && !rule.allow_generated {
    "generated output is not accepted as review evidence"
  } else if rule.require_tracked && !item.tracked {
    "file is not tracked by the repository"
  } else {
    "file observation satisfies boundary"
  }
}

///|
pub fn boundary_evidence_for(
  item : FileObservation,
  rule : BoundaryRule,
) -> Evidence {
  let passed = observation_matches_boundary(item, rule)
  Evidence::make(
    "boundary-\{rule.id}-\{fingerprint_text(item.path)}",
    "file-boundary",
    item.path,
    if passed {
      "pass"
    } else {
      "fail"
    },
    value="\{item.delta()}",
    source="git-diff",
    detail=observation_boundary_reason(item, rule),
  )
}

///|
pub fn audit_file_boundaries(
  observations : Array[FileObservation],
  rules : Array[BoundaryRule],
) -> Array[Evidence] {
  let result = []
  for item in observations {
    let mut matched = false
    for rule in rules {
      if observation_matches_boundary(item, rule) {
        result.push(boundary_evidence_for(item, rule))
        matched = true
      }
    }
    if !matched {
      result.push(
        Evidence::make(
          "boundary-unmatched-\{fingerprint_text(item.path)}",
          "file-boundary",
          item.path,
          "fail",
          value="\{item.delta()}",
          source="git-diff",
          detail="no declared boundary accepts this observation",
        ),
      )
    }
  }
  result
}

///|
pub fn total_changed_lines(observations : Array[FileObservation]) -> Int {
  let mut total = 0
  for item in observations {
    total = total + item.delta()
  }
  total
}

///|
pub fn generated_changed_lines(observations : Array[FileObservation]) -> Int {
  let mut total = 0
  for item in observations {
    if item.generated {
      total = total + item.delta()
    }
  }
  total
}

///|
pub fn effective_changed_lines(observations : Array[FileObservation]) -> Int {
  total_changed_lines(observations) - generated_changed_lines(observations)
}

///|
pub fn generated_ratio_percent(observations : Array[FileObservation]) -> Int {
  let total = total_changed_lines(observations)
  if total == 0 {
    0
  } else {
    generated_changed_lines(observations) * 100 / total
  }
}

///|
pub fn generated_ratio_evidence(
  observations : Array[FileObservation],
) -> Evidence {
  let percent = generated_ratio_percent(observations)
  Evidence::make(
    "generated-source-ratio",
    "source",
    "generated line ratio",
    "present",
    value="\{percent}",
    source="git-diff",
    detail="effective=\{effective_changed_lines(observations)};total=\{total_changed_lines(observations)}",
  )
}

///|
pub fn moonattest_default_boundaries() -> Array[BoundaryRule] {
  [
    BoundaryRule::make("source", denied_fragment="_build", max_delta=12000),
    BoundaryRule::make("docs", allowed_prefix="docs/", max_delta=4000),
    BoundaryRule::make("examples", allowed_prefix="examples/", max_delta=2000),
    BoundaryRule::make("ci", allowed_prefix=".github/", max_delta=1000),
  ]
}
