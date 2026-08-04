# MoonAttest Technical Design

## Scope

MoonAttest converts heterogeneous project checks into deterministic acceptance evidence. It does not execute shell commands, schedule jobs, retry tasks, manage secrets, or replace CI providers. Collection can be performed by scripts or CI; this package owns normalization, validation, policy evaluation, reconciliation, comparison, and reporting.

## Data Flow

1. Adapters convert tool output and repository observations into `Evidence`.
2. The schema validator checks required fields, identifiers, statuses, predicates, and weights.
3. The ledger detects conflicting observations and reconciles them using declared source priority and collection time.
4. Provenance and boundary modules audit licenses, notices, tracked files, generated code, and line deltas.
5. The policy engine selects evidence by kind and subject, evaluates predicates, and computes a weighted verdict.
6. Reporters render Markdown, JSON, metrics, timelines, and revision differences.
7. Canonical serialization produces a deterministic proof fingerprint that can be recomputed during review.

## Core Invariants

- Evidence and policy identifiers are unique inside an attestation.
- A policy evaluates exactly one selected evidence record or emits a missing-evidence finding.
- Blocking failures always produce a rejected verdict, independent of numeric score.
- Canonical serialization preserves declaration order and includes all review-relevant fields.
- Generated line counts are recorded separately from effective authored MoonBit source.
- Fingerprints provide deterministic integrity checks, not cryptographic authenticity.

## Manifest Format

The line protocol uses `project`, `name`, `repository`, `revision`, `generated`, `producer`, `evidence`, and `policy` records. Evidence and policy payloads use a fixed pipe-delimited field order. The format deliberately avoids runtime JSON dependencies while JSON remains available as an output report.

## Extension Points

- Add adapters without changing the evidence model.
- Add policy profiles by composing arrays of `Policy` values.
- Add new report formats from `ProofBundle` without changing evaluation.
- Replace the checksum implementation with a cryptographic backend while retaining canonical serialization.

## Verification

`moon check`, `moon test`, and the CLI sample run in GitHub Actions. Tests cover parsers, predicates, scoring, schema validation, source licenses, file boundaries, conflict reconciliation, metrics, fingerprints, timelines, diffs, and report anchors.
