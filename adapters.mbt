///|
/// Normalize `moon check` output into acceptance evidence.
pub fn evidence_from_moon_check(
  output : String,
  collected_at? : String = "",
) -> Evidence {
  let passed = (output.contains("Finished") || output.contains("no work to do")) &&
    !output.contains("error:") &&
    !output.contains("failed")
  Evidence::make(
    "moon-check",
    "build",
    "moon check",
    if passed {
      "pass"
    } else {
      "fail"
    },
    value=if passed { "0" } else { "1" },
    source="moon-cli",
    collected_at~,
    detail=output,
  )
}

///|
/// Normalize `moon test` output and retain the passed test count.
pub fn evidence_from_moon_test(
  output : String,
  collected_at? : String = "",
) -> Evidence {
  let passed = output.contains("failed: 0") || output.contains("0 failed")
  let numbers = numbers_in_text(output)
  let passed_count = if numbers.length() >= 2 { numbers[1] } else { 0 }
  Evidence::make(
    "moon-test",
    "test",
    "moon test",
    if passed {
      "pass"
    } else {
      "fail"
    },
    value="\{passed_count}",
    source="moon-cli",
    collected_at~,
    detail=output,
  )
}

///|
/// Normalize a coverage summary. The caller provides the measured percentage
/// because coverage output formats vary across toolchain versions.
pub fn evidence_from_coverage(
  percent : Int,
  detail? : String = "",
  collected_at? : String = "",
) -> Evidence {
  Evidence::make(
    "moon-coverage",
    "coverage",
    "MoonBit source coverage",
    if percent >= 0 {
      "present"
    } else {
      "missing"
    },
    value="\{percent}",
    source="moon-coverage",
    collected_at~,
    detail~,
  )
}

///|
pub fn evidence_from_format_check(
  passed : Bool,
  detail? : String = "",
) -> Evidence {
  Evidence::make(
    "moon-fmt",
    "format",
    "moon fmt --check",
    if passed {
      "pass"
    } else {
      "fail"
    },
    value=if passed { "clean" } else { "changes-required" },
    source="moon-cli",
    detail~,
  )
}

///|
pub fn evidence_from_commit_count(
  count : Int,
  revision? : String = "",
) -> Evidence {
  Evidence::make(
    "git-commits",
    "git",
    "reachable commits",
    if count > 0 {
      "present"
    } else {
      "missing"
    },
    value="\{count}",
    source="git",
    detail=revision,
  )
}

///|
pub fn evidence_from_clean_tree(
  clean : Bool,
  detail? : String = "",
) -> Evidence {
  Evidence::make(
    "git-clean-tree",
    "git",
    "working tree",
    if clean {
      "pass"
    } else {
      "fail"
    },
    value=if clean { "clean" } else { "dirty" },
    source="git",
    detail~,
  )
}

///|
pub fn evidence_from_public_repository(
  repository : String,
  reachable : Bool,
  is_public : Bool,
) -> Evidence {
  let passed = reachable && is_public
  Evidence::make(
    "repository-public",
    "repository",
    repository,
    if passed {
      "pass"
    } else {
      "fail"
    },
    value=if is_public { "public" } else { "private" },
    source="repository-probe",
    detail=if reachable { "reachable" } else { "unreachable" },
  )
}

///|
pub fn evidence_from_file_presence(
  id : String,
  path : String,
  present : Bool,
  source? : String = "workspace",
) -> Evidence {
  Evidence::make(
    id,
    "artifact",
    path,
    if present {
      "present"
    } else {
      "missing"
    },
    value=if present { "1" } else { "0" },
    source~,
  )
}

///|
pub fn evidence_from_line_count(
  effective_lines : Int,
  generated_lines? : Int = 0,
) -> Evidence {
  Evidence::make(
    "moonbit-lines",
    "source",
    "effective MoonBit lines",
    if effective_lines > 0 {
      "present"
    } else {
      "missing"
    },
    value="\{effective_lines}",
    source="workspace-counter",
    detail="generated=\{generated_lines}",
  )
}

///|
pub fn evidence_from_license(license : String, file_present : Bool) -> Evidence {
  let accepted = file_present && is_osi_license(license)
  Evidence::make(
    "project-license",
    "license",
    "project license",
    if accepted {
      "pass"
    } else {
      "fail"
    },
    value=license,
    source="moon.mod+LICENSE",
    detail=if file_present {
      "license file present"
    } else {
      "license file missing"
    },
  )
}

///|
pub fn evidence_from_mooncakes(
  package_name : String,
  version : String,
  published : Bool,
) -> Evidence {
  Evidence::make(
    "mooncakes-publication",
    "publication",
    package_name,
    if published {
      "pass"
    } else {
      "missing"
    },
    value=version,
    source="mooncakes.io",
  )
}

///|
pub fn evidence_from_ci(
  provider : String,
  workflow : String,
  passed : Bool,
  run_id? : String = "",
) -> Evidence {
  Evidence::make(
    "ci-\{workflow}",
    "ci",
    workflow,
    if passed {
      "pass"
    } else {
      "fail"
    },
    value=run_id,
    source=provider,
  )
}

///|
pub fn evidence_from_example(
  name : String,
  command : String,
  passed : Bool,
  output? : String = "",
) -> Evidence {
  Evidence::make(
    "example-\{name}",
    "example",
    command,
    if passed {
      "pass"
    } else {
      "fail"
    },
    value=name,
    source="example-runner",
    detail=output,
  )
}

///|
pub fn evidence_from_dependency_count(
  total : Int,
  unlicensed : Int,
) -> Evidence {
  Evidence::make(
    "dependency-license-scan",
    "dependency",
    "declared dependencies",
    if unlicensed == 0 {
      "pass"
    } else {
      "fail"
    },
    value="\{total}",
    source="moon.mod",
    detail="unlicensed=\{unlicensed}",
  )
}

///|
pub fn merge_evidence_groups(
  groups : Array[Array[Evidence]],
) -> Array[Evidence] {
  let result = []
  for group in groups {
    for item in group {
      result.push(item)
    }
  }
  result
}
