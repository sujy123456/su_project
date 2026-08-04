///|
fn print_help() -> Unit {
  println("MoonAttest - deterministic MoonBit acceptance evidence")
  println(
    "usage: moon run cmd/main -- [sample|json|manifest|diff|timeline|help]",
  )
}

///|
fn main {
  let args = @env.args()
  let command = if args.length() > 1 { args[1] } else { "sample" }
  if command == "sample" {
    println(
      @moonattest.render_console_summary(@moonattest.sample_proof_bundle()),
    )
  } else if command == "json" {
    println(@moonattest.render_proof_json(@moonattest.sample_proof_bundle()))
  } else if command == "manifest" {
    println(@moonattest.sample_manifest())
  } else if command == "diff" {
    let before = @moonattest.sample_failing_attestation()
    let after = @moonattest.sample_attestation()
    println(
      @moonattest.render_delta_markdown(
        @moonattest.attestation_delta(before, after),
      ),
    )
  } else if command == "timeline" {
    println(@moonattest.render_timeline_markdown(@moonattest.sample_timeline()))
  } else {
    print_help()
  }
}
