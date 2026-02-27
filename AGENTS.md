# AGENTS.md — Open School Syllabus (OSS)

## Project Purpose

Open School Syllabus (OSS) is an open, machine-readable curriculum repository.

This repository stores structured curriculum data (YAML + Markdown), validated by JSON Schema and CI. It is infrastructure content, not an app.

- No backend or frontend runtime in this repo.
- No API server in this repo.
- No proprietary exam content.
- License target: CC BY-SA 4.0.

## Current Repository State (as of February 2026)

This repository is still in scaffolding/documentation phase.

### Files that currently exist

- `README.md`
- `CLAUDE.md`
- `AGENTS.md`
- `docs/technical-plan.md`
- `docs/development-timeline.md`
- `docs/business-plan.md`

### Important implication for coding agents

Most implementation paths described in docs are planned, not yet present (for example: `curricula/`, `schema/`, `scripts/`, `.github/workflows/`).

When asked to implement features, create those directories/files according to `docs/technical-plan.md` and `docs/development-timeline.md`, then keep docs consistent.

## Canonical References

Use these in priority order when instructions conflict:

1. `docs/technical-plan.md` — architecture, schema system, validation design.
2. `docs/development-timeline.md` — execution sequencing and initial curriculum scope.
3. `README.md` — public project narrative and contribution-facing overview.
4. `docs/business-plan.md` — strategy/context, not implementation authority.

## Target Architecture (Planned)

Planned repository shape:

- `curricula/{board}/{level}/{subject-code}/`
- `concepts/{domain}/`
- `taxonomy/{domain}/`
- `schema/*.schema.json` (7 schema files)
- `scripts/` (validation/maintenance)
- `.github/workflows/` (CI)
- `.yamllint.yml`

Treat this as the intended design when generating new files.

## Content Model Expectations

Core hierarchy:

- `Syllabus -> Subject -> Topic -> {Teaching Notes, Examples, Assessments}`
- `Concept` links equivalent ideas across curricula.
- `Taxonomy` classifies domain trees.

Schema set expected by design:

- `syllabus.schema.json`
- `subject.schema.json`
- `topic.schema.json`
- `examples.schema.json`
- `assessments.schema.json`
- `concept.schema.json`
- `taxonomy.schema.json`

## Quality and Metadata Rules

When creating curriculum content, follow these requirements:

- Use accurate provenance values: `human`, `ai-assisted`, `ai-generated`, `ai-observed`.
- Never mislabel AI-written content as `human`.
- Do not claim a higher `quality_level` than content supports.
- Level 3 (Teachable) is minimum AI-ready threshold.
- Follow strict naming conventions (`NN-kebab-case` for topic files).

## Copyright and Safety Rules

- Do not copy from copyrighted exam papers or proprietary materials.
- Create original curriculum-aligned content from public syllabus specifications.
- Flag uncertain pedagogy with AI provenance so educator review can happen.

## Validation Commands (Planned Tooling)

These commands are expected once scaffolding files are created:

```bash
yamllint -c .yamllint.yml curricula/ concepts/ taxonomy/
ajv validate -s schema/topic.schema.json -d "path/to/topic.yaml"
python scripts/check-prerequisites.py
python scripts/check-references.py
python scripts/assess-quality.py --report
```

If these paths/tools do not exist yet, create the missing scaffolding first.

## Working Guidelines for Any Coding Agent

- Keep OSS as a pure-data repo; do not introduce app runtime code unless explicitly requested.
- Prefer additive, schema-first changes: define/adjust schema before bulk content generation.
- Keep `README.md` and docs aligned with actual repo state; avoid claiming files/features that do not exist.
- For major structure changes, update this `AGENTS.md` and the relevant docs in the same change set.
- Preserve human-review checkpoints for pedagogical quality and provenance-sensitive content.

## Related Repositories

- `p-n-ai/pai-bot`: primary consumer of OSS curriculum data.
- `p-n-ai/oss-bot`: contribution/automation tooling for OSS.
