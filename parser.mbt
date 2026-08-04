///|
/// Lightweight DSL parser.
///
/// Format:
/// ```text
/// workflow moontrace-demo
/// summary Minimal reproducible workflow
/// step plan|design|moontrace plan|true
/// rule required-steps|Required steps must pass|error||60000
/// ```
pub fn parse_trace_spec(text : String) -> TraceWorkflow {
  let mut name = "unnamed"
  let mut summary = ""
  let steps = []
  let rules = []
  for raw in text.split("\n") {
    let line = raw.to_owned()
    if line == "" || (line.contains("#") && line.has_prefix("#")) {
      continue
    }
    if line.has_prefix("workflow ") {
      name = line.after("workflow ").unwrap_or("unnamed").to_owned()
    } else if line.has_prefix("summary ") {
      summary = line.after("summary ").unwrap_or("").to_owned()
    } else if line.has_prefix("step ") {
      steps.push(parse_step_line(line.after("step ").unwrap_or("").to_owned()))
    } else if line.has_prefix("rule ") {
      rules.push(parse_rule_line(line.after("rule ").unwrap_or("").to_owned()))
    }
  }
  TraceWorkflow::make(name, summary, steps, rules)
}

///|
/// Parse one step line.
pub fn parse_step_line(line : String) -> TraceStep {
  let parts = line.split("|").map(x => x.to_owned()).collect()
  let id = part_at(parts, 0, "step")
  let stage = part_at(parts, 1, "build")
  let command = part_at(parts, 2, "")
  let required = part_at(parts, 3, "true") != "false"
  TraceStep::make(id, id, command, stage~, required~)
}

///|
/// Parse one rule line.
pub fn parse_rule_line(line : String) -> TraceRule {
  let parts = line.split("|").map(x => x.to_owned()).collect()
  TraceRule::make(
    part_at(parts, 0, "rule"),
    part_at(parts, 1, "Untitled rule"),
    severity=part_at(parts, 2, "error"),
    expected_stage=part_at(parts, 3, ""),
    max_elapsed_ms=parse_int_or(part_at(parts, 4, "60000"), 60000),
  )
}

///|
/// Safe array lookup with default.
pub fn part_at(parts : Array[String], index : Int, default : String) -> String {
  if index >= 0 && index < parts.length() {
    parts[index]
  } else {
    default
  }
}

///|
/// Simple positive integer parser used by the DSL.
pub fn parse_int_or(text : String, default : Int) -> Int {
  let mut value = 0
  let mut seen = false
  for char in text {
    if char >= '0' && char <= '9' {
      value = value * 10 + (char.to_int() - '0'.to_int())
      seen = true
    } else {
      return default
    }
  }
  if seen { value } else { default }
}
