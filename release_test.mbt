///|
test "release readiness before mooncakes publication" {
  let readiness = score_release_readiness(local_release_evidence())
  inspect(readiness.score, content="85")
  inspect(readiness.status, content="nearly-ready")
}

///|
test "release readiness after publication" {
  let evidence = ReleaseEvidence::make(
    has_readme=true,
    has_ci=true,
    has_tests=true,
    has_examples=true,
    has_license=true,
    moonbit_lines=5908,
    commit_count=5,
    published_to_mooncakes=true,
  )
  let readiness = score_release_readiness(evidence)
  inspect(readiness.score, content="100")
  inspect(readiness.status, content="ready")
}

///|
test "release readiness line threshold" {
  let evidence = ReleaseEvidence::make(
    has_readme=true,
    has_ci=true,
    has_tests=true,
    has_examples=true,
    has_license=true,
    moonbit_lines=3999,
    commit_count=5,
  )
  let readiness = score_release_readiness(evidence)
  inspect(readiness.score, content="65")
  inspect(readiness.status, content="in-progress")
}
