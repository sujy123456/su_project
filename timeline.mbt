///|
pub fn timeline_is_monotonic(entries : Array[TimelineEntry]) -> Bool {
  let mut previous = -1
  for entry in entries {
    if entry.sequence <= previous {
      return false
    }
    previous = entry.sequence
  }
  true
}

///|
pub fn timeline_has_duplicate_sequences(entries : Array[TimelineEntry]) -> Bool {
  let seen : Array[Int] = []
  for entry in entries {
    if seen.contains(entry.sequence) {
      return true
    }
    seen.push(entry.sequence)
  }
  false
}

///|
pub fn timeline_sorted(entries : Array[TimelineEntry]) -> Array[TimelineEntry] {
  let result = entries.copy()
  result.sort_by((left, right) => left.sequence.compare(right.sequence))
  result
}

///|
fn transition_is_allowed(previous : String, current : String) -> Bool {
  match (previous, current) {
    ("unknown", "pass") | ("unknown", "fail") | ("unknown", "warn") => true
    ("pass", "pass") | ("pass", "fail") | ("pass", "warn") => true
    ("fail", "pass") | ("fail", "fail") | ("fail", "warn") => true
    ("warn", "pass") | ("warn", "fail") | ("warn", "warn") => true
    ("not_applicable", "not_applicable") => true
    _ => false
  }
}

///|
pub fn timeline_transition_issues(
  entries : Array[TimelineEntry],
) -> Array[SchemaIssue] {
  let issues : Array[SchemaIssue] = []
  if timeline_has_duplicate_sequences(entries) {
    issues.push(
      SchemaIssue::make(
        "timeline.sequence",
        "duplicate",
        "timeline sequence numbers must be unique",
        severity="error",
      ),
    )
  }
  let sorted = timeline_sorted(entries)
  let subjects : Array[String] = []
  for entry in sorted {
    if !subjects.contains(entry.evidence_id) {
      subjects.push(entry.evidence_id)
    }
  }
  for subject in subjects {
    let subject_entries = sorted.filter(entry => entry.evidence_id == subject)
    let mut previous = "unknown"
    for entry in subject_entries {
      if !allowed_evidence_statuses().contains(entry.status) {
        issues.push(
          SchemaIssue::make(
            "timeline[" + entry.sequence.to_string() + "].status",
            "enum",
            "unsupported status: " + entry.status,
            severity="error",
          ),
        )
      } else if !transition_is_allowed(previous, entry.status) {
        issues.push(
          SchemaIssue::make(
            "timeline[" + entry.sequence.to_string() + "]",
            "transition",
            "invalid transition " + previous + " -> " + entry.status,
            severity="error",
          ),
        )
      }
      previous = entry.status
    }
  }
  issues
}

///|
pub fn timeline_latest(entries : Array[TimelineEntry]) -> Array[TimelineEntry] {
  let sorted = timeline_sorted(entries)
  let subjects : Array[String] = []
  for entry in sorted {
    if !subjects.contains(entry.evidence_id) {
      subjects.push(entry.evidence_id)
    }
  }
  subjects.map(subject => {
    let candidates = sorted.filter(entry => entry.evidence_id == subject)
    candidates[candidates.length() - 1]
  })
}

///|
pub fn timeline_to_evidence(
  entries : Array[TimelineEntry],
  observed_at : String,
) -> Array[Evidence] {
  timeline_latest(entries).map(entry => {
    Evidence::make(
      "timeline." + entry.evidence_id,
      "timeline",
      entry.evidence_id,
      entry.status,
      value=entry.value,
      source="moonattest/timeline",
      collected_at=observed_at,
      detail="latest value at sequence " + entry.sequence.to_string(),
    )
  })
}

///|
pub fn timeline_summary(entries : Array[TimelineEntry]) -> String {
  let latest = timeline_latest(entries)
  let passing = latest.filter(entry => entry.status == "pass").length()
  let failing = latest.filter(entry => entry.status == "fail").length()
  "entries=" +
  entries.length().to_string() +
  ",subjects=" +
  latest.length().to_string() +
  ",pass=" +
  passing.to_string() +
  ",fail=" +
  failing.to_string()
}

///|
pub fn timeline_chain(entries : Array[TimelineEntry]) -> Array[String] {
  fingerprint_chain(timeline_sorted(entries))
}

///|
pub fn timeline_chain_is_valid(
  entries : Array[TimelineEntry],
  chain : Array[String],
) -> Bool {
  timeline_chain(entries) == chain
}
