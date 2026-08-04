///|
/// Return an array element or a caller-provided fallback.
pub fn text_part(
  parts : Array[String],
  index : Int,
  fallback : String,
) -> String {
  if index >= 0 && index < parts.length() {
    parts[index]
  } else {
    fallback
  }
}

///|
/// Parse an unsigned decimal integer and return a fallback on malformed input.
pub fn parse_non_negative_int(text : String, fallback : Int) -> Int {
  let mut value = 0
  let mut seen = false
  for ch in text {
    if ch >= '0' && ch <= '9' {
      value = value * 10 + (ch.to_int() - '0'.to_int())
      seen = true
    } else {
      return fallback
    }
  }
  if seen {
    value
  } else {
    fallback
  }
}

///|
/// Parse a signed decimal integer and return a fallback on malformed input.
pub fn parse_signed_int(text : String, fallback : Int) -> Int {
  if text.has_prefix("-") {
    let rest = text.after("-").unwrap_or("").to_owned()
    let parsed = parse_non_negative_int(rest, fallback)
    if parsed == fallback && rest != "\{fallback}" {
      fallback
    } else {
      0 - parsed
    }
  } else {
    parse_non_negative_int(text, fallback)
  }
}

///|
pub fn parse_bool_text(text : String, fallback : Bool) -> Bool {
  if text == "true" || text == "yes" || text == "1" || text == "on" {
    true
  } else if text == "false" || text == "no" || text == "0" || text == "off" {
    false
  } else {
    fallback
  }
}

///|
/// Collect all decimal number runs found in arbitrary tool output.
pub fn numbers_in_text(text : String) -> Array[Int] {
  let numbers = []
  let mut value = 0
  let mut active = false
  for ch in text {
    if ch >= '0' && ch <= '9' {
      value = value * 10 + (ch.to_int() - '0'.to_int())
      active = true
    } else if active {
      numbers.push(value)
      value = 0
      active = false
    }
  }
  if active {
    numbers.push(value)
  }
  numbers
}

///|
pub fn first_number_or(text : String, fallback : Int) -> Int {
  let numbers = numbers_in_text(text)
  if numbers.length() > 0 {
    numbers[0]
  } else {
    fallback
  }
}

///|
pub fn last_number_or(text : String, fallback : Int) -> Int {
  let numbers = numbers_in_text(text)
  if numbers.length() > 0 {
    numbers[numbers.length() - 1]
  } else {
    fallback
  }
}

///|
/// Escape a string for compact JSON output.
pub fn escape_json(text : String) -> String {
  let mut output = ""
  for ch in text {
    if ch == '"' {
      output = output + "\\\""
    } else if ch == '\\' {
      output = output + "\\\\"
    } else if ch == '\n' {
      output = output + "\\n"
    } else if ch == '\r' {
      output = output + "\\r"
    } else if ch == '\t' {
      output = output + "\\t"
    } else {
      output = output + "\{ch}"
    }
  }
  output
}

///|
/// Escape Markdown table delimiters and line breaks.
pub fn escape_markdown_cell(text : String) -> String {
  let mut output = ""
  for ch in text {
    if ch == '|' {
      output = output + "\\|"
    } else if ch == '\n' || ch == '\r' {
      output = output + " "
    } else {
      output = output + "\{ch}"
    }
  }
  output
}

///|
pub fn join_non_empty(parts : Array[String], separator : String) -> String {
  let mut output = ""
  let mut first = true
  for part in parts {
    if part != "" {
      if !first {
        output = output + separator
      }
      output = output + part
      first = false
    }
  }
  output
}

///|
pub fn string_in_list(value : String, options : Array[String]) -> Bool {
  for option in options {
    if value == option {
      return true
    }
  }
  false
}

///|
pub fn unique_strings(values : Array[String]) -> Array[String] {
  let result = []
  for value in values {
    if !string_in_list(value, result) {
      result.push(value)
    }
  }
  result
}

///|
pub fn count_occurrences(text : String, needle : String) -> Int {
  if needle == "" {
    return 0
  }
  text.split(needle).length() - 1
}

///|
pub fn normalized_status(status : String) -> String {
  if status == "ok" ||
    status == "success" ||
    status == "passed" ||
    status == "true" {
    "pass"
  } else if status == "error" || status == "failed" || status == "false" {
    "fail"
  } else if status == "available" || status == "exists" {
    "present"
  } else {
    status
  }
}

///|
pub fn severity_rank(severity : String) -> Int {
  if severity == "critical" {
    4
  } else if severity == "error" {
    3
  } else if severity == "warn" {
    2
  } else if severity == "info" {
    1
  } else {
    0
  }
}

///|
pub fn clamp_int(value : Int, minimum : Int, maximum : Int) -> Int {
  if value < minimum {
    minimum
  } else if value > maximum {
    maximum
  } else {
    value
  }
}

///|
pub fn repeat_text(text : String, count : Int) -> String {
  let mut output = ""
  let mut index = 0
  while index < count {
    output = output + text
    index = index + 1
  }
  output
}
