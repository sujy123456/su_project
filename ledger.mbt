///|
pub fn evidence_ids(items : Array[Evidence]) -> Array[String] {
  unique_strings(items.map(item => item.id))
}

///|
pub fn evidence_kinds(items : Array[Evidence]) -> Array[String] {
  unique_strings(items.map(item => item.kind))
}

///|
pub fn evidence_sources(items : Array[Evidence]) -> Array[String] {
  unique_strings(items.map(item => item.source))
}

///|
pub fn evidence_statuses(items : Array[Evidence]) -> Array[String] {
  unique_strings(items.map(item => item.status))
}

///|
pub fn evidence_with_id(
  items : Array[Evidence],
  id : String,
) -> Array[Evidence] {
  items.filter(item => item.id == id)
}

///|
pub fn evidence_with_kind(
  items : Array[Evidence],
  kind : String,
) -> Array[Evidence] {
  items.filter(item => item.kind == kind)
}

///|
pub fn evidence_with_source(
  items : Array[Evidence],
  source : String,
) -> Array[Evidence] {
  items.filter(item => item.source == source)
}

///|
pub fn evidence_with_status(
  items : Array[Evidence],
  status : String,
) -> Array[Evidence] {
  items.filter(item => item.status == status)
}

///|
pub fn evidence_matches(
  items : Array[Evidence],
  kind? : String = "",
  subject_contains? : String = "",
  status? : String = "",
  source? : String = "",
) -> Array[Evidence] {
  items.filter(item => {
    (kind == "" || item.kind == kind) &&
    (subject_contains == "" || item.subject.contains(subject_contains)) &&
    (status == "" || item.status == status) &&
    (source == "" || item.source == source)
  })
}

///|
fn observations_disagree(first : Evidence, second : Evidence) -> Bool {
  first.status != second.status || first.value != second.value
}

///|
pub fn evidence_conflicts(items : Array[Evidence]) -> Array[EvidenceConflict] {
  let conflicts : Array[EvidenceConflict] = []
  let mut left = 0
  while left < items.length() {
    let mut right = left + 1
    while right < items.length() {
      let first = items[left]
      let second = items[right]
      if first.id == second.id && observations_disagree(first, second) {
        conflicts.push(
          EvidenceConflict::make(
            first.id,
            first.source,
            second.source,
            first.status,
            second.status,
            first.value,
            second.value,
          ),
        )
      }
      right = right + 1
    }
    left = left + 1
  }
  conflicts
}

///|
pub fn conflict_evidence(items : Array[Evidence]) -> Evidence {
  let conflicts = evidence_conflicts(items)
  Evidence::make(
    "evidence-conflicts",
    "integrity",
    "duplicate evidence observations",
    if conflicts.length() == 0 {
      "pass"
    } else {
      "fail"
    },
    value=conflicts.length().to_string(),
    source="moonattest/ledger",
    detail=if conflicts.length() == 0 {
      "no conflicting duplicate observations"
    } else {
      "conflicting identifiers: " +
      join_non_empty(
        unique_strings(conflicts.map(item => item.evidence_id)),
        ",",
      )
    },
  )
}

///|
fn source_priority(source : String, priorities : Array[String]) -> Int {
  let mut index = 0
  while index < priorities.length() {
    if priorities[index] == source {
      return priorities.length() - index
    }
    index = index + 1
  }
  0
}

///|
fn observation_is_newer(first : Evidence, second : Evidence) -> Bool {
  first.collected_at > second.collected_at
}

///|
fn preferred_observation(
  first : Evidence,
  second : Evidence,
  source_priorities : Array[String],
) -> Evidence {
  let first_priority = source_priority(first.source, source_priorities)
  let second_priority = source_priority(second.source, source_priorities)
  if first_priority > second_priority {
    first
  } else if second_priority > first_priority {
    second
  } else if observation_is_newer(second, first) {
    second
  } else {
    first
  }
}

///|
pub fn reconcile_evidence(
  items : Array[Evidence],
  source_priorities? : Array[String] = [],
) -> Array[Evidence] {
  let result : Array[Evidence] = []
  for item in items {
    let mut found = false
    let mut index = 0
    while index < result.length() {
      if result[index].id == item.id {
        result[index] = preferred_observation(
          result[index],
          item,
          source_priorities,
        )
        found = true
      }
      index = index + 1
    }
    if !found {
      result.push(item)
    }
  }
  result
}

///|
pub fn merge_evidence(
  primary : Array[Evidence],
  secondary : Array[Evidence],
) -> Array[Evidence] {
  let all = primary.copy()
  for item in secondary {
    all.push(item)
  }
  let priorities = unique_strings(primary.map(item => item.source))
  reconcile_evidence(all, source_priorities=priorities)
}

///|
pub fn evidence_ledger_summary(items : Array[Evidence]) -> String {
  let conflicts = evidence_conflicts(items)
  "records=" +
  items.length().to_string() +
  ",ids=" +
  evidence_ids(items).length().to_string() +
  ",kinds=" +
  evidence_kinds(items).length().to_string() +
  ",sources=" +
  evidence_sources(items).length().to_string() +
  ",conflicts=" +
  conflicts.length().to_string()
}

///|
pub fn render_conflicts_markdown(conflicts : Array[EvidenceConflict]) -> String {
  if conflicts.length() == 0 {
    return "No evidence conflicts.\n"
  }
  let mut output = "| Evidence | First source | Second source | First | Second |\n"
  output = output + "|---|---|---|---|---|\n"
  for conflict in conflicts {
    output = output + "| `" + conflict.evidence_id + "` | "
    output = output + escape_markdown_cell(conflict.first_source) + " | "
    output = output + escape_markdown_cell(conflict.second_source) + " | "
    output = output +
      conflict.first_status +
      ": " +
      escape_markdown_cell(conflict.first_value) +
      " | "
    output = output +
      conflict.second_status +
      ": " +
      escape_markdown_cell(conflict.second_value) +
      " |\n"
  }
  output
}
