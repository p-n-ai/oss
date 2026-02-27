# Technical Plan — Open School Syllabus (OSS)

> **Repository:** `p-n-ai/oss`
> **License:** CC BY-SA 4.0
> **Last updated:** February 2026

---

## 1. Architecture Overview

OSS is a **pure data repository** — it contains no runtime code, no server, and no application logic. It is a collection of structured YAML and Markdown files representing educational curricula, validated by JSON Schemas, and enforced by CI.

The architecture is deliberately simple. Any platform can consume OSS by cloning the repository or adding it as a Git submodule. The technical complexity lives in the schema design, validation pipeline, and content quality framework — not in runtime infrastructure.

```
┌───────────────────────────────────────────────────────────┐
│  Open School Syllabus Repository                          │
│                                                           │
│  ┌─────────────────────────┐  ┌────────────────────────┐  │
│  │  curricula/             │  │  schema/               │  │
│  │  ├── cambridge/igcse/   │  │  ├── syllabus.json     │  │
│  │  ├── malaysia/kssm/     │  │  ├── subject.json      │  │
│  │  ├── india/cbse/        │  │  ├── topic.json        │  │
│  │  └── ...                │  │  ├── examples.json     │  │
│  └─────────────────────────┘  │  └── assessments.json  │  │
│                               └────────────────────────┘  │
│  ┌─────────────────────────┐  ┌────────────────────────┐  │
│  │  concepts/              │  │  taxonomy/             │  │
│  │  └── mathematics/       │  │  └── mathematics/      │  │
│  │      ├── quadratic.yaml │  │      ├── algebra.yaml  │  │
│  │      └── ...            │  │      └── ...           │  │
│  └─────────────────────────┘  └────────────────────────┘  │
│                                                           │
│  ┌────────────────────────────────────────────────────────┐│
│  │  GitHub Actions CI                                    ││
│  │  ├── YAML syntax check                                ││
│  │  ├── JSON Schema validation (ajv)                     ││
│  │  ├── Prerequisite graph cycle detection                ││
│  │  ├── Cross-reference integrity check                  ││
│  │  └── Quality level auto-assessment                    ││
│  └────────────────────────────────────────────────────────┘│
└───────────────────────────────────────────────────────────┘
         │              │               │
         ▼              ▼               ▼
    ┌─────────┐   ┌──────────┐   ┌───────────┐
    │ P&AI Bot│   │ OSS Bot  │   │ Third-    │
    │ (Go)    │   │ (tooling)│   │ party     │
    │ reads   │   │ writes   │   │ platforms │
    └─────────┘   └──────────┘   └───────────┘
```

---

## 2. Tech Stack

OSS itself has no runtime dependencies. The tech stack consists entirely of data formats, validation tools, and CI infrastructure.

### 2.1 Data Formats

| Format | Usage | Rationale |
|--------|-------|-----------|
| **YAML** | All curriculum data (syllabi, subjects, topics, assessments, examples) | Human-readable, comment-friendly, Git-diffable. Teachers can read and edit YAML without tooling. Anchors and aliases reduce duplication. |
| **Markdown** | Teaching notes (`*.teaching.md`) | Natural format for conversational AI teaching instructions. Supports code blocks for math notation, headers for section organization. |
| **JSON Schema** (Draft 2020-12) | Validation rules for all YAML files | Industry-standard schema language. Tooling exists in every language. Enforced in CI — invalid files cannot be merged. |
| **JSON** | Schema files only (`schema/*.schema.json`) | JSON Schema specification requires JSON format. All other content uses YAML. |

### 2.2 Validation Toolchain

| Tool | Version | Purpose |
|------|---------|---------|
| **ajv-cli** | ≥5 | JSON Schema validator. Validates all YAML files against their corresponding schema on every PR. Runs in GitHub Actions CI. |
| **yamllint** | ≥1.35 | YAML syntax and style checker. Enforces consistent formatting (indentation, line length, key ordering). |
| **Node.js** | 20 LTS | Runtime for ajv-cli. Only used in CI, not required for consuming OSS. |
| **Python** (optional) | 3.12 | For custom validation scripts (prerequisite cycle detection, cross-reference integrity). |

### 2.3 CI/CD

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **CI Platform** | GitHub Actions | Free for public repositories. Runs on every push and PR. |
| **Schema Validation** | ajv-cli | Validates every YAML file against its JSON Schema |
| **Lint** | yamllint | Enforces YAML formatting standards |
| **Custom Checks** | Python/Bash scripts | Prerequisite graph cycle detection, cross-reference integrity, quality level auto-assessment |
| **Release** | GitHub Releases | Tagged releases for versioned curriculum snapshots |

---

## 3. Schema Design

OSS uses 7 interconnected schema types. Every file is validated against its JSON Schema on every commit.

### 3.1 Schema Hierarchy

```
Syllabus (top-level qualification)
 └── Subject (topic grouping)
      └── Topic (core teachable unit)
           ├── Teaching Notes (AI instruction guide, Markdown)
           ├── Examples (worked examples with steps)
           └── Assessments (questions, rubrics, hints)

Concept (cross-curriculum bridge)
 └── Links topics from different syllabi covering the same idea

Taxonomy (subject area hierarchy)
 └── Defines the universal classification tree for subjects
```

### 3.2 Schema Files

| Schema | File | Validates |
|--------|------|-----------|
| Syllabus | `schema/syllabus.schema.json` | `curricula/**/syllabus.yaml` |
| Subject | `schema/subject.schema.json` | `curricula/**/subjects/*.yaml` |
| Topic | `schema/topic.schema.json` | `curricula/**/topics/**/*.yaml` |
| Examples | `schema/examples.schema.json` | `curricula/**/topics/**/*.examples.yaml` |
| Assessments | `schema/assessments.schema.json` | `curricula/**/topics/**/*.assessments.yaml` |
| Concept | `schema/concept.schema.json` | `concepts/**/*.yaml` |
| Taxonomy | `schema/taxonomy.schema.json` | `taxonomy/**/*.yaml` |

### 3.3 Topic Schema (Core — Most Complex)

The topic schema is the heart of OSS. Every field exists because an AI tutor or learning platform needs it to teach effectively.

```yaml
# Required fields
id: string                        # Unique within syllabus (e.g., "05-quadratic-equations")
name: string                      # Human-readable name
subject_id: string                # Reference to parent subject
syllabus_id: string               # Reference to parent syllabus
difficulty: enum                  # beginner | intermediate | advanced
learning_objectives: array        # Each with id, text, bloom level

# Pedagogical fields (Level 2+)
prerequisites:
  required: array[string]         # Topic IDs that must be mastered first
  recommended: array[string]      # Topic IDs that help but aren't required
teaching:
  sequence: array[string]         # Recommended teaching order (step by step)
  common_misconceptions: array    # Each with misconception + remediation text
  engagement_hooks: array[string] # Real-world hooks to capture interest
bloom_levels: array[enum]         # remember | understand | apply | analyze | evaluate | create

# Progress tracking fields
mastery:
  minimum_score: number           # 0.0–1.0 threshold for mastery (default: 0.75)
  assessment_count: integer       # Minimum assessments before mastery
  spaced_repetition:
    initial_interval_days: integer
    multiplier: number            # SM-2 ease multiplier (default: 2.5)

# Cross-references
cross_curriculum: array           # Links to same concept in other syllabi
tier: enum                        # core | extended (for tiered curricula like IGCSE)

# File references
ai_teaching_notes: string         # Path to .teaching.md file
examples_file: string             # Path to .examples.yaml file
assessments_file: string          # Path to .assessments.yaml file

# Metadata
quality_level: integer            # 0–5 (see Quality Levels below)
provenance: enum                  # human | ai-assisted | ai-generated | ai-observed
```

### 3.4 Assessment Schema

```yaml
topic_id: string
questions: array
  - id: string                    # Unique within topic (e.g., "Q1")
    text: string                  # Question text (supports LaTeX via $...$)
    difficulty: enum              # easy | medium | hard
    learning_objective: string    # References topic's LO id
    answer:
      type: enum                  # exact | range | multiple_choice | free_text
      value: string               # Correct answer
      working: string             # Step-by-step solution (multiline)
    marks: integer                # Total marks available
    rubric: array                 # Mark allocation breakdown
      - marks: integer
        criteria: string
    hints: array                  # Progressive hints (level 1 = gentle, level 2 = explicit)
      - level: integer
        text: string
    distractors: array            # Common wrong answers with targeted feedback
      - value: string
        feedback: string
```

---

## 4. Repository Structure

```
oss/
├── curricula/                          # All curricula organized by board
│   ├── cambridge/
│   │   └── igcse/
│   │       └── mathematics-0580/
│   │           ├── syllabus.yaml                           # Top-level qualification
│   │           ├── subjects/
│   │           │   ├── algebra.yaml                        # Subject grouping
│   │           │   ├── number.yaml
│   │           │   ├── geometry.yaml
│   │           │   └── statistics.yaml
│   │           ├── topics/
│   │           │   ├── algebra/
│   │           │   │   ├── 01-expressions.yaml             # Topic definition
│   │           │   │   ├── 01-expressions.teaching.md      # AI teaching notes
│   │           │   │   ├── 01-expressions.examples.yaml    # Worked examples
│   │           │   │   ├── 01-expressions.assessments.yaml # Assessment questions
│   │           │   │   ├── 02-linear-equations.yaml
│   │           │   │   └── ...
│   │           │   ├── number/
│   │           │   │   └── ...
│   │           │   └── geometry/
│   │           │       └── ...
│   │           └── locales/                                # Translations
│   │               ├── ms/                                 # Malay
│   │               │   └── topics/algebra/
│   │               │       └── 01-expressions.yaml
│   │               └── ar/                                 # Arabic
│   │                   └── ...
│   └── malaysia/
│       └── kssm/
│           └── mathematics-form3/
│               └── ...                                     # Same structure
│
├── concepts/                           # Universal cross-curriculum concepts
│   └── mathematics/
│       ├── quadratic-equation.yaml     # Bridges IGCSE ↔ KSSM ↔ IB
│       ├── linear-function.yaml
│       ├── pythagorean-theorem.yaml
│       └── ...
│
├── taxonomy/                           # Subject area hierarchies
│   └── mathematics/
│       ├── algebra.yaml                # Classification tree for algebra topics
│       ├── geometry.yaml
│       ├── statistics.yaml
│       └── calculus.yaml
│
├── schema/                             # JSON Schema validation files
│   ├── syllabus.schema.json
│   ├── subject.schema.json
│   ├── topic.schema.json
│   ├── examples.schema.json
│   ├── assessments.schema.json
│   ├── concept.schema.json
│   └── taxonomy.schema.json
│
├── scripts/                            # CI and maintenance scripts
│   ├── validate.sh                     # Run all schema validations
│   ├── check-prerequisites.py          # Detect cycles in prerequisite graph
│   ├── check-references.py             # Verify cross-references are valid
│   ├── assess-quality.py               # Auto-assess quality levels
│   └── export-sqlite.py                # Generate SQLite export (coming soon)
│
├── .github/
│   └── workflows/
│       ├── validate.yml                # Schema validation on every PR
│       ├── quality-report.yml          # Quality assessment on merge to main
│       └── release.yml                 # Tagged release with SQLite export
│
├── .yamllint.yml                       # YAML linting rules
├── CONTRIBUTING.md                     # Contribution guide (3 paths)
├── LICENSE                             # CC BY-SA 4.0
└── README.md
```

### Naming Conventions

| Pattern | Example | Rule |
|---------|---------|------|
| Directories | `curricula/cambridge/igcse/mathematics-0580/` | `board/level/subject-code/` |
| Topics | `05-quadratic-equations.yaml` | `NN-kebab-case.yaml` (NN = sequence number) |
| Teaching notes | `05-quadratic-equations.teaching.md` | Same base name + `.teaching.md` |
| Examples | `05-quadratic-equations.examples.yaml` | Same base name + `.examples.yaml` |
| Assessments | `05-quadratic-equations.assessments.yaml` | Same base name + `.assessments.yaml` |
| Translations | `locales/ms/topics/algebra/01-expressions.yaml` | `locales/{lang-code}/` mirrors source path |
| Concepts | `concepts/mathematics/quadratic-equation.yaml` | `concepts/{domain}/{concept-name}.yaml` |

---

## 5. Quality Level Framework

Every topic carries a `quality_level` field (0–5) that indicates completeness. This is both a content standard and a technical contract — consumers can filter by quality level to ensure they only use content that meets their requirements.

| Level | Name | Required Fields | AI Teaching Capability |
|-------|------|----------------|----------------------|
| **0** | Stub | `id`, `name`, `learning_objectives` | Barely — LLM can attempt teaching from name alone |
| **1** | Basic | + `prerequisites`, `difficulty`, `tier`, `bloom_levels` | Minimally — knows difficulty and ordering |
| **2** | Structured | + `teaching.sequence`, `teaching.common_misconceptions`, `engagement_hooks` | Somewhat — knows what to teach and common pitfalls |
| **3** | Teachable | + `ai_teaching_notes` (.md), `examples_file`, `assessments_file` | **Yes** — has everything needed for an effective session |
| **4** | Complete | + translations (≥1 language), `cross_curriculum` links, peer-reviewed | Well — multilingual, cross-referenced |
| **5** | Gold | + validated by curriculum authority, backed by student interaction data | Excellently — data-proven effectiveness |

**Quality level is auto-assessed by CI.** The `assess-quality.py` script examines each topic file and its companion files to determine the current level. PRs that lower a topic's quality level are flagged for review.

---

## 6. Validation Pipeline (CI)

Every PR triggers the following validation pipeline via GitHub Actions:

```yaml
# .github/workflows/validate.yml
name: Validate Curriculum
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      # 1. YAML syntax and style
      - name: Lint YAML
        run: yamllint -c .yamllint.yml curricula/ concepts/ taxonomy/

      # 2. JSON Schema validation
      - name: Validate schemas
        run: |
          # Validate all syllabus files
          find curricula -name "syllabus.yaml" | xargs -I{} \
            ajv validate -s schema/syllabus.schema.json -d {}

          # Validate all subject files
          find curricula -path "*/subjects/*.yaml" | xargs -I{} \
            ajv validate -s schema/subject.schema.json -d {}

          # Validate all topic files (exclude teaching, examples, assessments)
          find curricula -path "*/topics/*" -name "*.yaml" \
            ! -name "*.examples.yaml" ! -name "*.assessments.yaml" | xargs -I{} \
            ajv validate -s schema/topic.schema.json -d {}

          # Validate examples and assessments
          find curricula -name "*.examples.yaml" | xargs -I{} \
            ajv validate -s schema/examples.schema.json -d {}
          find curricula -name "*.assessments.yaml" | xargs -I{} \
            ajv validate -s schema/assessments.schema.json -d {}

      # 3. Prerequisite graph integrity
      - name: Check prerequisite cycles
        run: python scripts/check-prerequisites.py

      # 4. Cross-reference integrity
      - name: Check references
        run: python scripts/check-references.py

      # 5. Quality level assessment
      - name: Assess quality levels
        run: python scripts/assess-quality.py --report
```

**Validation rules enforced:**

| Check | Tool | Blocks Merge? |
|-------|------|---------------|
| YAML syntax valid | yamllint | Yes |
| Matches JSON Schema | ajv-cli | Yes |
| No prerequisite cycles | custom Python | Yes |
| All topic_id references exist | custom Python | Yes |
| All syllabus_id references exist | custom Python | Yes |
| Bloom's taxonomy levels are valid | JSON Schema enum | Yes |
| Quality level not decreased | custom Python | Warning (reviewer decides) |
| Teaching notes file exists if referenced | custom script | Warning |
| Translation structure matches source | custom script | Warning |

---

## 7. Consumption Methods

OSS is designed to be consumed by any platform in any language. No API server is required.

### 7.1 Git Clone (Simplest)

```bash
git clone https://github.com/p-n-ai/oss.git
```

Read YAML files directly in any language:

```go
// Go (used by P&AI Bot)
data, _ := os.ReadFile("oss/curricula/cambridge/igcse/mathematics-0580/topics/algebra/05-quadratic-equations.yaml")
var topic Topic
yaml.Unmarshal(data, &topic)
```

```python
# Python
import yaml
with open("oss/curricula/cambridge/igcse/mathematics-0580/topics/algebra/05-quadratic-equations.yaml") as f:
    topic = yaml.safe_load(f)
```

### 7.2 Git Submodule (Recommended for Applications)

```bash
git submodule add https://github.com/p-n-ai/oss.git curriculum
```

Pin to a specific release tag for stability:

```bash
cd curriculum && git checkout v1.0.0
```

### 7.3 SQLite Export (Coming Soon)

A pre-built SQLite database containing all curriculum data, generated on every tagged release via GitHub Actions. Useful for offline-capable applications and mobile apps.

```bash
# Download the latest export
curl -LO https://github.com/p-n-ai/oss/releases/latest/download/oss.sqlite
```

### 7.4 Raw GitHub API (No Clone Required)

```bash
# Fetch a single topic via GitHub raw content
curl https://raw.githubusercontent.com/p-n-ai/oss/main/curricula/cambridge/igcse/mathematics-0580/topics/algebra/05-quadratic-equations.yaml
```

---

## 8. Provenance Tracking

Every piece of content tracks its origin via the `provenance` field. This is a technical mechanism for trust — consumers can filter by provenance to enforce their own quality policies.

| Provenance | Meaning | Review Requirement | Automated? |
|-----------|---------|-------------------|------------|
| `human` | Written by a human educator | Standard PR review | No |
| `ai-assisted` | Human authored with AI help | Standard PR review | No |
| `ai-generated` | Fully generated by AI from a prompt | Educator review required | Yes (via OSS Bot) |
| `ai-observed` | Generated from student interaction data | Educator review required | Yes (via P&AI feedback loop) |

GitHub labels mirror provenance: `provenance:human`, `provenance:ai-generated`, etc. Branch protection rules require educator approval for `ai-generated` and `ai-observed` PRs.

---

## 9. Translation Architecture

Translations live in `locales/{lang-code}/` directories that mirror the source structure exactly. This design means translations are additive — they never modify the source files.

```
curricula/cambridge/igcse/mathematics-0580/
├── topics/algebra/
│   └── 01-expressions.yaml              # Source (English)
└── locales/
    ├── ms/                               # Malay
    │   └── topics/algebra/
    │       └── 01-expressions.yaml       # Translated fields only
    ├── ar/                               # Arabic
    │   └── topics/algebra/
    │       └── 01-expressions.yaml
    └── zh/                               # Chinese
        └── ...
```

**Translation file format:** Contains only translatable fields (`name`, `learning_objectives[].text`, `teaching.sequence`, `teaching.common_misconceptions`, `engagement_hooks`). Non-translatable fields (`id`, `difficulty`, `prerequisites`, `mastery`) are inherited from the source.

**Language codes:** ISO 639-1 two-letter codes (e.g., `ms`, `ar`, `zh`, `hi`, `es`, `fr`).

---

## 10. Cross-Curriculum Concepts

The `concepts/` directory bridges the same mathematical (or scientific, literary, etc.) concept across different curricula. This is the mechanism that enables:

- Students transferring between curricula to see what they already know
- AI agents adapting depth based on which syllabus the student follows
- Researchers comparing curriculum alignment across countries

```yaml
# concepts/mathematics/quadratic-equation.yaml
id: quadratic-equation
name: Quadratic Equation
domain: mathematics
subdomain: algebra

definition: "A polynomial equation of degree 2 in the form ax² + bx + c = 0, where a ≠ 0"

curricula:
  - syllabus: cambridge-igcse-mathematics-0580
    topic: 05-quadratic-equations
    scope: "Factorisation and quadratic formula. No completing the square."
  - syllabus: malaysia-kssm-mathematics-form4
    topic: quadratic-equations-and-inequalities
    scope: "Includes completing the square. Quadratic inequalities introduced."
  - syllabus: ib-dp-mathematics-aa-sl
    topic: quadratic-functions
    scope: "Full treatment including discriminant analysis and graphical interpretation."
```

---

## 11. Infrastructure & Cost

OSS has near-zero operating costs because it is a static data repository hosted on GitHub.

| Component | Cost | Notes |
|-----------|------|-------|
| GitHub hosting | Free | Public open-source repository |
| GitHub Actions CI | Free | Free tier for public repos (2,000 minutes/month) |
| Domain (p-n-ai.org) | ~$15/year | For documentation and contribution portal redirect |
| Team maintenance | 5–10 hrs/week | Scales down as community grows |
| **Total** | **~$15/year** | |

---

## 12. Versioning Strategy

OSS uses **Git tags** for versioned releases. Consumers can pin to a specific version for stability or track `main` for the latest content.

| Tag Format | Example | Meaning |
|-----------|---------|---------|
| `v{major}.{minor}.{patch}` | `v1.2.0` | Semantic versioning for schema changes |
| Major | Schema breaking change (field renamed, removed) |
| Minor | New curricula added, new fields added (backward-compatible) |
| Patch | Content corrections, quality improvements, translations |

**Schema stability guarantee:** Once a schema field reaches Level 3 (Teachable) quality across multiple curricula, it will not be removed or renamed without a major version bump and a 6-month deprecation period.

---

## 13. Self-Improving Feedback Loop

When used with [P&AI Bot](https://github.com/p-n-ai/pai-bot), OSS becomes a self-improving system. This is the technical mechanism:

```
1. P&AI Bot teaches students using OSS topic data
2. Agent observes patterns across student interactions:
   - Misconception frequency ("73% of students make sign errors here")
   - Explanation effectiveness ("Explanation A has 20% better comprehension")
   - Content gaps ("Students keep asking about X which isn't in the syllabus")
3. Agent calls OSS Bot API with structured improvement suggestions
4. OSS Bot validates suggestion against schema, opens PR with provenance: ai-observed
5. Educator reviews and merges (or rejects)
6. OSS content improves → P&AI teaches better → more data → better suggestions
```

This loop is the primary long-term growth mechanism for OSS quality beyond Level 3.

---

## 14. Related Repositories

| Repository | Relationship |
|-----------|-------------|
| [p-n-ai/pai-bot](https://github.com/p-n-ai/pai-bot) | Primary consumer. Reads OSS as Git submodule. Feeds back student interaction data. |
| [p-n-ai/oss-bot](https://github.com/p-n-ai/oss-bot) | Primary contributor tooling. CLI validation, AI content generation, web contribution portal. |
