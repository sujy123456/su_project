///|
fn evidence_by_id(items : Array[Evidence], id : String) -> Evidence? {
  for item in items {
    if item.id == id {
      return Some(item)
    }
  }
  None
}

///|
fn status_quality(status : String) -> Int {
  match status {
    "pass" => 4
    "not_applicable" => 3
    "warn" => 2
    "unknown" => 1
    "fail" => 0
    _ => 1
  }
}

///|
fn evidence_change(old_item : Evidence, new_item : Evidence) -> String {
  if canonical_evidence(old_item) == canonical_evidence(new_item) {
    "unchanged"
  } else if status_quality(new_item.status) > status_quality(old_item.status) {
    "improved"
  } else if status_quality(new_item.status) < status_quality(old_item.status) {
    "regressed"
  } else {
    "changed"
  }
}

///|
pub fn compare_evidence(
  previous : Array[Evidence],
  current : Array[Evidence],
) -> Array[EvidenceDelta] {
  let deltas : Array[EvidenceDelta] = []
  for old_item in previous {
    match evidence_by_id(current, old_item.id) {
      Some(new_item) =>
        deltas.push(
          EvidenceDelta::make(
            old_item.id,
            evidence_change(old_item, new_item),
            old_item.status,
            new_item.status,
            old_item.value,
            new_item.value,
          ),
        )
      None =>
        deltas.push(
          EvidenceDelta::make(
            old_item.id,
            "removed",
            old_item.status,
            "missing",
            old_item.value,
            "",
          ),
        )
    }
  }
  for new_item in current {
    if evidence_by_id(previous, new_item.id) is None {
      deltas.push(
        EvidenceDelta::make(
          new_item.id,
          "added",
          "missing",
          new_item.status,
          "",
          new_item.value,
        ),
      )
    }
  }
  deltas
}

///|
pub fn changed_evidence(deltas : Array[EvidenceDelta]) -> Array[EvidenceDelta] {
  deltas.filter(delta => delta.change != "unchanged")
}

///|
pub fn evidence_regressions(
  deltas : Array[EvidenceDelta],
) -> Array[EvidenceDelta] {
  deltas.filter(delta => {
    delta.change == "regressed" || delta.change == "removed"
  })
}

///|
pub fn evidence_improvements(
  deltas : Array[EvidenceDelta],
) -> Array[EvidenceDelta] {
  deltas.filter(delta => delta.change == "improved" || delta.change == "added")
}

///|
pub fn evidence_delta_summary(deltas : Array[EvidenceDelta]) -> String {
  let added = deltas.filter(delta => delta.change == "added").length()
  let removed = deltas.filter(delta => delta.change == "removed").length()
  let changed = deltas.filter(delta => delta.change == "changed").length()
  let improved = deltas.filter(delta => delta.change == "improved").length()
  let regressed = deltas.filter(delta => delta.change == "regressed").length()
  "added=" +
  added.to_string() +
  ",removed=" +
  removed.to_string() +
  ",changed=" +
  changed.to_string() +
  ",improved=" +
  improved.to_string() +
  ",regressed=" +
  regressed.to_string()
}

///|
pub fn attestation_delta(
  previous : Attestation,
  current : Attestation,
) -> Array[EvidenceDelta] {
  compare_evidence(previous.evidence, current.evidence)
}

///|
pub fn attestation_has_regression(
  previous : Attestation,
  current : Attestation,
) -> Bool {
  evidence_regressions(attestation_delta(previous, current)).length() > 0
}
