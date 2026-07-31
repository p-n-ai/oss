# AGENTS.md — Open School Syllabus (OSS)

## Project Purpose

Open School Syllabus (OSS) is an open, machine-readable curriculum repository.

This repository stores structured curriculum data (YAML + Markdown), validated by JSON Schema and CI. It is infrastructure content, not an app.

- No backend or frontend runtime in this repo.
- No API server in this repo.
- No proprietary exam content.
- License target: CC BY-SA 4.0.

## Current Repository State (as of July 2026)

This is a live curriculum-data repository. The checked-in `curricula/`, `concepts/`, `schema/`, `scripts/`, and validation workflow are implemented and authoritative.

The exact classified inventory is 562 content YAML files:

- 1 syllabus
- 3 subjects
- 15 subject-grades
- 152 canonical topics and 53 locale topic variants
- 115 canonical assessments and 53 locale assessment variants
- 115 canonical examples and 53 locale example variants
- 2 concepts and 0 taxonomy artifacts

Do not recreate the older flat `subjects/*.yaml` or `locales/` scaffolding shown in historical planning material. Follow the current path classifier and schemas instead.

### MANDATORY: Daily Implementation Requires Both Documents

When implementing any day's tasks (Day 0 through Day 30), you **MUST** read and cross-reference **both**:

1. **`docs/development-timeline.md`** — defines **what** to build, task ownership, and sequencing
2. **`docs/implementation-guide.md`** — defines **how** to build it: exact file paths, content templates, schema definitions, validation commands, and exit criteria

**Never implement from one document alone.** The timeline gives scope and order; the guide gives executable instructions. Cross-check both before starting and after completing each day's tasks.

### MANDATORY: ID and Naming Conventions

Before creating **any** curricula content (YAML files, folders, IDs), you **MUST** read and follow **`docs/id-conventions.md`**. This document defines:
- Country, syllabus, grade, subject, and topic ID formats
- Topic prefix table (language-neutral, derived from English subject names)
- Folder and file naming rules (folder name = entity ID)
- `official_ref` field usage
- `name` vs `name_en` bilingual requirements

IDs use the **official MOE language** of the target country (e.g. Malay for Malaysia KSSM, English for India CBSE). Misformatted IDs are caught by the validator and block merges.

**Task Status Tracking:**
Each task row in `docs/development-timeline.md` follows the format:
`| Task ID | Task | Owner | Status | Remark |`
- **⬜** — not started
- **✅** — completed
- Any notes go in the **Remark** column

When completing a day's tasks, update the Status column from ⬜ to ✅ and add any relevant remarks.

## Canonical References

Use these in priority order when instructions conflict:

1. `schema/*.schema.json` and `scripts/lib/oss_validation.rb` — live data contracts, artifact classification, and exact inventory.
2. `scripts/validate.sh` and `scripts/validate-changed.sh` — live validation behavior.
3. `docs/id-conventions.md` — canonical ID, locale identity, and naming conventions.
4. `docs/technical-plan.md` — architecture and validation design.
5. `docs/development-timeline.md` and `docs/implementation-guide.md` — historical sequencing and implementation context.
6. `README.md` — public project narrative and contribution-facing overview.
7. `docs/business-plan.md` — strategy/context, not implementation authority.

**Note:** The development timeline and implementation guide are companion historical documents. Read them together when interpreting a day-specific task, then apply the live contracts above.

## Current Architecture

Current curriculum shape:

- `curricula/{country_id}/{syllabus_id}/syllabus.yaml`
- `curricula/{country_id}/{syllabus_id}/{subject_id}/subject.yaml`
- `curricula/{country_id}/{syllabus_id}/{subject_id}/{subject_grade_id}/subject-grade.yaml`
- `curricula/{country_id}/{syllabus_id}/{subject_id}/{subject_grade_id}/topics/`
- `curricula/**/topics/translations/{locale}/`
- `concepts/{domain}/`
- `taxonomy/{domain}/`
- `schema/*.schema.json` (9 schema files)
- `scripts/` (validation/maintenance)
- `.github/workflows/` (CI)
- `.yamllint.yml`

Canonical topic roots are English when present. Malay locale variants live under `topics/translations/ms/`, reuse the canonical topic ID and filename, and are validated separately.

## Content Model Expectations

Core hierarchy:

- `Syllabus -> Subject -> Subject Grade -> Topic -> {Teaching Notes, Examples, Assessments}`
- `Concept` links equivalent ideas across curricula.
- `Taxonomy` classifies domain trees.

Authoritative schema set:

- `syllabus.schema.json`
- `subject.schema.json`
- `subject-grade.schema.json`
- `topic.schema.json`
- `topic-variant.schema.json`
- `examples.schema.json`
- `assessments.schema.json`
- `concept.schema.json`
- `taxonomy.schema.json`

## Quality and Metadata Rules

When creating curriculum content, follow these requirements:

- When `provenance` is present, keep it non-empty and accurate. Established values include `human`, `ai-assisted`, `ai-generated`, and `ai-observed`.
- Never mislabel AI-written content as `human`.
- Do not claim a higher `quality_level` than content supports.
- Preserve `quality_level: 0` history stubs in the exact inventory. They may have empty `content_standards` and `learning_objectives` and are catalog-only, not teachable content.
- Topics at `quality_level >= 1` require non-empty teaching identity.
- Level 3 (Teachable) is minimum AI-ready threshold.
- Canonical topic IDs are globally unique and match `^[A-Z]{2,3}[0-9]+-[0-9]{2}$`; companion filenames reuse the topic ID.
- Locale variants deliberately reuse their canonical topic ID and are distinguished by their `topics/translations/{locale}/` path.
- Use only consumer-safe canonical fields: root `learning_objectives`, `mastery`, `teaching.sequence`, `teaching.common_misconceptions`, and `answer.options`. Root `engagement_hooks` is the one conflict-normalized exception.
- Locale assessments may translate prose and expected values, but must preserve canonical question IDs, learning-objective references, and answer types.
- Worked examples may omit `learning_objective`; when present, it must exactly match an authored objective ID. Locale example variants may translate prose but preserve canonical worked-example IDs and objective identities.

## Copyright and Safety Rules

- Do not copy from copyrighted exam papers or proprietary materials.
- Create original curriculum-aligned content from public syllabus specifications.
- Flag uncertain pedagogy with AI provenance so educator review can happen.

## Validation Commands

```bash
./scripts/validate.sh
./scripts/validate-changed.sh
```

The full gate parses every content YAML file, validates all 562 artifacts through the deterministic classifier and the correct one of nine schemas with `ajv-formats`, enforces the exact inventory, and checks references, prerequisites, and quality claims.

The changed-files gate owns `yamllint` regressions for touched YAML and blocks newly introduced findings. Historical style findings, including pre-existing findings in a touched file, are intentionally excluded from both gates.

## Working Guidelines for Any Coding Agent

- Keep OSS as a pure-data repo; do not introduce app runtime code unless explicitly requested.
- Prefer additive, schema-first changes: define/adjust schema before bulk content generation.
- Keep `README.md` and docs aligned with actual repo state; avoid claiming files/features that do not exist.
- For major structure changes, update this `AGENTS.md` and the relevant docs in the same change set.
- Preserve human-review checkpoints for pedagogical quality and provenance-sensitive content.

## Related Repositories

- `p-n-ai/pai-bot`: primary consumer of OSS curriculum data.
- `p-n-ai/oss-bot`: contribution/automation tooling for OSS.
