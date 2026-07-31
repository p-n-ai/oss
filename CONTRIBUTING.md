# Contributing to Open School Syllabus (OSS)

Open School Syllabus (OSS) is an open curriculum data repository. Contributions should improve structured curriculum quality while staying schema-valid, pedagogically sound, and legally safe.

## Current State

This is a live curriculum-data repository. The checked-in schemas and validation scripts are authoritative. Read `AGENTS.md` and `docs/id-conventions.md` before changing content.

## Three Ways to Contribute

### 1. Educator Contribution (No YAML Required)

- Open a GitHub issue describing what to add or fix.
- Provide syllabus context, topic scope, and classroom insights.
- Include common misconceptions and remediation ideas when possible.

Suggested issue content:

- Curriculum/board/level (for example: KSSM Form 2 Mathematics)
- Topic name
- What should change
- Why it matters pedagogically
- Optional examples/questions

### 2. Developer Contribution (Direct PR)

- Fork and create a branch.
- Add or edit content files and docs.
- Keep naming and structure conventions exact.
- Open a PR with clear scope and rationale.

### 3. AI-Assisted Contribution

- AI can draft YAML/Markdown content.
- You must set provenance honestly (`ai-assisted` or `ai-generated`).
- Human review is required before merge for pedagogy and factual accuracy.

## Repository Conventions

### Naming

- Syllabus directory: `curricula/{country_id}/{syllabus_id}/`
- Subject directory: `curricula/{country_id}/{syllabus_id}/{subject_id}/`
- Subject-grade directory: `curricula/{country_id}/{syllabus_id}/{subject_id}/{subject_grade_id}/`
- Canonical topic files: `topics/{TOPIC_ID}.yaml` (example: `topics/MT1-01.yaml`)
- Locale variants: `topics/translations/{locale}/{TOPIC_ID}.yaml`
- Teaching notes: same base + `.teaching.md`
- Examples: same base + `.examples.yaml`
- Assessments: same base + `.assessments.yaml`
- Concepts: `concepts/{domain}/{name}.yaml`
- Taxonomy: `taxonomy/{domain}/{area}.yaml`

### Content and Metadata

- Keep OSS as a pure-data repository (no app runtime code unless explicitly requested).
- Do not claim a higher `quality_level` than content actually meets.
- Use valid provenance only: `human`, `ai-assisted`, `ai-generated`, `ai-observed`.
- Never label AI-written content as `human`.

## Copyright and Safety

- Do not copy from copyrighted exam papers or proprietary resources.
- Create original material aligned to public syllabus specifications.
- If uncertain, mark provenance conservatively and request educator review.

## Validation

When scaffolding files/tooling are present, run:

```bash
./scripts/validate.sh
./scripts/validate-changed.sh
```

If commands fail because paths are not created yet, add the missing scaffold first according to `docs/technical-plan.md`.

## Pull Request Checklist

- Contribution is scoped and clearly described.
- Naming conventions are followed.
- Provenance is accurate.
- Claimed quality level matches content completeness.
- No copyrighted or proprietary copied material.
- Relevant docs are updated when structure/rules change.

## Review Expectations

- Content PRs should be reviewed for pedagogical correctness.
- `ai-generated` and `ai-observed` content requires educator review.
- Invalid schema or lint output should block merge until fixed.
