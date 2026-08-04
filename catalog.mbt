///|
fn acceptance_policy(
  id : String,
  title : String,
  kind : String,
  subject : String,
  field : String,
  predicate : String,
  expected : String,
  severity? : String = "error",
  weight? : Int = 5,
) -> Policy {
  Policy::make(
    id,
    title,
    kind,
    field,
    predicate,
    expected,
    target_subject=subject,
    severity~,
    weight~,
  )
}

///|
pub fn repository_policies() -> Array[Policy] {
  [
    acceptance_policy(
      "repo-public",
      "Repository is public and reachable",
      "repository",
      "",
      "status",
      "eq",
      "pass",
      weight=10,
    ),
    acceptance_policy(
      "git-history",
      "Development history contains at least five commits",
      "git",
      "reachable commits",
      "value",
      "min_int",
      "5",
      weight=5,
    ),
    acceptance_policy(
      "git-clean",
      "Acceptance capture uses a clean working tree",
      "git",
      "working tree",
      "status",
      "eq",
      "pass",
      severity="warn",
      weight=2,
    ),
  ]
}

///|
pub fn build_policies() -> Array[Policy] {
  [
    acceptance_policy(
      "build-check",
      "MoonBit project builds successfully",
      "build",
      "moon check",
      "status",
      "eq",
      "pass",
      weight=10,
    ),
    acceptance_policy(
      "format-check",
      "MoonBit source is formatted",
      "format",
      "moon fmt --check",
      "status",
      "eq",
      "pass",
      weight=4,
    ),
    acceptance_policy(
      "source-scale",
      "Effective MoonBit source reaches the reference scale",
      "source",
      "effective MoonBit lines",
      "value",
      "min_int",
      "4000",
      severity="warn",
      weight=5,
    ),
    acceptance_policy(
      "generated-ratio",
      "Generated source remains a minor part of the review surface",
      "source",
      "generated line ratio",
      "value",
      "max_int",
      "20",
      severity="warn",
      weight=4,
    ),
  ]
}

///|
pub fn test_policies() -> Array[Policy] {
  [
    acceptance_policy(
      "tests-pass",
      "MoonBit test suite passes",
      "test",
      "moon test",
      "status",
      "eq",
      "pass",
      weight=10,
    ),
    acceptance_policy(
      "tests-exist",
      "At least one executable test is present",
      "test",
      "moon test",
      "value",
      "min_int",
      "1",
      weight=6,
    ),
    acceptance_policy(
      "coverage-recorded",
      "A source coverage measurement is recorded",
      "coverage",
      "MoonBit source coverage",
      "status",
      "one_of",
      "present,pass",
      severity="warn",
      weight=3,
    ),
    acceptance_policy(
      "coverage-floor",
      "Recorded source coverage reaches sixty percent",
      "coverage",
      "MoonBit source coverage",
      "value",
      "min_int",
      "60",
      severity="warn",
      weight=4,
    ),
  ]
}

///|
pub fn documentation_policies() -> Array[Policy] {
  [
    acceptance_policy(
      "readme-present",
      "README is included",
      "artifact",
      "README.md",
      "status",
      "eq",
      "present",
      weight=6,
    ),
    acceptance_policy(
      "license-present",
      "License file is included",
      "artifact",
      "LICENSE",
      "status",
      "eq",
      "present",
      weight=5,
    ),
    acceptance_policy(
      "application-present",
      "Project application is included",
      "artifact",
      "PROJECT_APPLICATION.md",
      "status",
      "eq",
      "present",
      weight=3,
    ),
    acceptance_policy(
      "design-present",
      "Technical design is included",
      "artifact",
      "docs/TECHNICAL_DESIGN.md",
      "status",
      "eq",
      "present",
      severity="warn",
      weight=3,
    ),
    acceptance_policy(
      "changelog-present",
      "Change log is included",
      "artifact",
      "CHANGELOG.md",
      "status",
      "eq",
      "present",
      severity="warn",
      weight=2,
    ),
    acceptance_policy(
      "attribution-present",
      "Source attribution inventory is included",
      "artifact",
      "SOURCE_ATTRIBUTION.md",
      "status",
      "eq",
      "present",
      severity="warn",
      weight=3,
    ),
  ]
}

///|
pub fn delivery_policies() -> Array[Policy] {
  [
    acceptance_policy(
      "ci-pass",
      "Continuous integration passes",
      "ci",
      "build-and-test",
      "status",
      "eq",
      "pass",
      weight=9,
    ),
    acceptance_policy(
      "example-runs",
      "Documented command line example runs",
      "example",
      "moon run cmd/main -- sample",
      "status",
      "eq",
      "pass",
      weight=7,
    ),
    acceptance_policy(
      "publication",
      "Package is published to mooncakes.io",
      "publication",
      "",
      "status",
      "eq",
      "pass",
      weight=9,
    ),
  ]
}

///|
pub fn compliance_policies() -> Array[Policy] {
  [
    acceptance_policy(
      "project-license-osi",
      "Project uses an OSI-recognized license",
      "license",
      "project license",
      "status",
      "eq",
      "pass",
      weight=8,
    ),
    acceptance_policy(
      "dependency-licenses",
      "Declared dependencies have acceptable licenses",
      "dependency",
      "declared dependencies",
      "status",
      "eq",
      "pass",
      weight=7,
    ),
    acceptance_policy(
      "source-provenance",
      "Third-party source declarations pass audit",
      "provenance",
      "third-party source declarations",
      "status",
      "eq",
      "pass",
      weight=8,
    ),
    acceptance_policy(
      "originality",
      "Originality or adaptation status is explicitly declared",
      "provenance",
      "original project declaration",
      "value",
      "one_of",
      "original,port-or-reference",
      weight=5,
    ),
  ]
}

///|
pub fn competition_acceptance_policies() -> Array[Policy] {
  merge_policy_groups([
    repository_policies(),
    build_policies(),
    test_policies(),
    documentation_policies(),
    delivery_policies(),
    compliance_policies(),
  ])
}

///|
pub fn minimal_acceptance_policies() -> Array[Policy] {
  let all = competition_acceptance_policies()
  all.filter(policy => {
    policy.id == "repo-public" ||
    policy.id == "build-check" ||
    policy.id == "tests-pass" ||
    policy.id == "readme-present" ||
    policy.id == "project-license-osi"
  })
}

///|
pub fn merge_policy_groups(groups : Array[Array[Policy]]) -> Array[Policy] {
  let result : Array[Policy] = []
  for group in groups {
    for policy in group {
      result.push(policy)
    }
  }
  result
}

///|
pub fn policy_catalog_summary(policies : Array[Policy]) -> String {
  let blocking = policies.filter(policy => policy.is_blocking()).length()
  let advisory = policies.length() - blocking
  "policies=" +
  policies.length().to_string() +
  ",blocking=" +
  blocking.to_string() +
  ",advisory=" +
  advisory.to_string()
}
