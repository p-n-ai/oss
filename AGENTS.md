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

### MANDATORY: Daily Implementation Requires Both Documents

When implementing any day's tasks (Day 0 through Day 30), you **MUST** read and cross-reference **both**:

1. **`docs/development-timeline.md`** — defines **what** to build, task ownership, and sequencing
2. **`docs/implementation-guide.md`** — defines **how** to build it: exact file paths, content templates, schema definitions, validation commands, and exit criteria

**Never implement from one document alone.** The timeline gives scope and order; the guide gives executable instructions. Cross-check both before starting and after completing each day's tasks.

**Task Status Tracking:**
Each task row in `docs/development-timeline.md` follows the format:
`| Task ID | Task | Owner | Status | Remark |`
- **⬜** — not started
- **✅** — completed
- Any notes go in the **Remark** column

When completing a day's tasks, update the Status column from ⬜ to ✅ and add any relevant remarks.

## Canonical References

Use these in priority order when instructions conflict:

1. `docs/technical-plan.md` — architecture, schema system, validation design.
2. `docs/development-timeline.md` — execution sequencing and initial curriculum scope (**what** to build).
3. `docs/implementation-guide.md` — step-by-step build instructions, templates, exit criteria (**how** to build).
4. `README.md` — public project narrative and contribution-facing overview.
5. `docs/business-plan.md` — strategy/context, not implementation authority.

**Note:** Documents 2 and 3 are companion documents. Always use both together when implementing daily tasks.

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
ajv validate --spec=draft2020 -s schema/topic.schema.json -d "path/to/topic.yaml"
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
