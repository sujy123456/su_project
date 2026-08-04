///|
/// Evidence collected before a hackathon acceptance review.
pub(all) struct ReleaseEvidence {
  has_readme : Bool
  has_ci : Bool
  has_tests : Bool
  has_examples : Bool
  has_license : Bool
  moonbit_lines : Int
  commit_count : Int
  published_to_mooncakes : Bool
} derive(Eq, Debug)

///|
/// Human-readable readiness score.
pub(all) struct ReleaseReadiness {
  score : Int
  max_score : Int
  status : String
  message : String
} derive(Eq, Debug)

///|
/// Build release evidence.
pub fn ReleaseEvidence::make(
  has_readme? : Bool = false,
  has_ci? : Bool = false,
  has_tests? : Bool = false,
  has_examples? : Bool = false,
  has_license? : Bool = false,
  moonbit_lines? : Int = 0,
  commit_count? : Int = 0,
  published_to_mooncakes? : Bool = false,
) -> ReleaseEvidence {
  {
    has_readme,
    has_ci,
    has_tests,
    has_examples,
    has_license,
    moonbit_lines,
    commit_count,
    published_to_mooncakes,
  }
}

///|
/// Score evidence against the acceptance checklist.
pub fn score_release_readiness(evidence : ReleaseEvidence) -> ReleaseReadiness {
  let mut score = 0
  if evidence.has_readme { score = score + 10 }
  if evidence.has_ci { score = score + 10 }
  if evidence.has_tests { score = score + 10 }
  if evidence.has_examples { score = score + 10 }
  if evidence.has_license { score = score + 10 }
  if evidence.moonbit_lines >= 4000 { score = score + 20 }
  if evidence.commit_count >= 5 { score = score + 15 }
  if evidence.published_to_mooncakes { score = score + 15 }
  let status = if score >= 90 {
    "ready"
  } else if score >= 70 {
    "nearly-ready"
  } else {
    "in-progress"
  }
  {
    score,
    max_score: 100,
    status,
    message: release_message(status),
  }
}

///|
/// Explain readiness status.
pub fn release_message(status : String) -> String {
  if status == "ready" {
    "project is ready for public acceptance"
  } else if status == "nearly-ready" {
    "project needs final publication or repository work"
  } else {
    "project still needs core acceptance materials"
  }
}

///|
/// Local evidence for the current repository before remote publication.
pub fn local_release_evidence() -> ReleaseEvidence {
  ReleaseEvidence::make(
    has_readme=true,
    has_ci=true,
    has_tests=true,
    has_examples=true,
    has_license=true,
    moonbit_lines=5908,
    commit_count=5,
    published_to_mooncakes=false,
  )
}
