# Contributing to Open School Syllabus (OSS)

Open School Syllabus (OSS) is an open curriculum data repository. Contributions should improve structured curriculum quality while staying schema-valid, pedagogically sound, and legally safe.

## Current State

This repository is currently in scaffolding/documentation phase. Some paths described in docs are planned and may not exist yet.

If your contribution introduces new structure (for example `curricula/`, `schema/`, `scripts/`, `.github/workflows/`), follow:

1. `docs/technical-plan.md`
2. `docs/development-timeline.md`
3. `AGENTS.md`

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

- Curriculum directory: `curricula/{board}/{level}/{subject-code}/`
- Topic files: `NN-kebab-case.yaml` (example: `05-quadratic-equations.yaml`)
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
yamllint -c .yamllint.yml curricula/ concepts/ taxonomy/
ajv validate --spec=draft2020 -s schema/topic.schema.json -d "path/to/topic.yaml"
python scripts/check-prerequisites.py
python scripts/check-references.py
python scripts/assess-quality.py --report
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

