# Technical Plan — Open School Syllabus (OSS)

> **Repository:** `p-n-ai/oss`
> **License:** CC BY-SA 4.0
> **Last updated:** July 2026

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
│  │  └── malaysia/          │  │  ├── syllabus          │  │
│  │      └── malaysia-kssm/ │  │  ├── subject/grade     │  │
│  │                         │  │  ├── topic/variant     │  │
│  │                         │  │  ├── assessment/example│  │
│  └─────────────────────────┘  │  └── concept/taxonomy  │  │
│                               └────────────────────────┘  │
│  ┌─────────────────────────┐  ┌────────────────────────┐  │
│  │  concepts/              │  │  taxonomy/             │  │
│  │  └── mathematics/       │  │  └── mathematics/      │  │
│  │      ├── algebraic...    │  │  0 artifacts today    │  │
│  │      └── linear...       │  │                       │  │
│  └─────────────────────────┘  └────────────────────────┘  │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  GitHub Actions CI                                  │  │
│  │  ├── Parse every content YAML                       │  │
│  │  ├── JSON Schema validation (ajv + formats)         │  │
│  │  ├── Exact artifact inventory                       │  │
│  │  ├── Prerequisite graph cycle detection             │  │
│  │  ├── Cross-reference integrity check                │  │
│  │  └── Quality level auto-assessment                  │  │
│  └─────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────┘
         │               │               │
         ▼               ▼               ▼
    ┌───────────┐   ┌───────────┐   ┌───────────┐
    │ P&AI Bot  │   │ OSS Bot   │   │ Third-    │
    │ (Go)      │   │ (tooling) │   │ party     │
    │ reads     │   │ writes    │   │ platforms │
    └───────────┘   └───────────┘   └───────────┘
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
| **uv** | current | Python tool installer/cache for CI. Installs `yamllint` and persists uv tool directories between runs. |
| **ajv-cli** | ≥5 | JSON Schema validator. Validates changed YAML files on PRs and all content YAML files on the full gate. |
| **ajv-formats** | current | AJV plugin for JSON Schema formats such as `date-time`; installed and load-checked independently from `ajv-cli`. |
| **yamllint** | ≥1.35 | YAML style checker for touched content. Historical repository-wide style debt is not part of the full semantic gate. |
| **Node.js** | 20 LTS | Runtime for ajv-cli. Only used in CI, not required for consuming OSS. |
| **Ruby** | system Ruby or newer | Custom validation scripts for prerequisites, references, and quality assessment. |
| **Python** | 3.12 | Managed by uv for Python-based tooling such as `yamllint`. |

### 2.3 CI/CD

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **CI Platform** | GitHub Actions | Pull requests run changed-file validation. Pushes to `main` and manual runs execute full validation. |
| **Schema Validation** | ajv-cli | Validates changed YAML files on PRs and every YAML file on the full gate. |
| **Lint** | yamllint | Enforces YAML formatting standards on content YAML touched by a pull request. |
| **Custom Checks** | Ruby/Bash scripts | YAML parsing, exact inventory, prerequisite graph, cross-reference integrity, and quality assessment |
| **Release** | GitHub Releases | Tagged releases for versioned curriculum snapshots |

---

## 3. Schema Design

OSS uses nine interconnected schema types. The deterministic artifact classifier selects the schema from a file's role and path; it does not infer a schema from whatever shape happens to validate.

### 3.1 Schema Hierarchy

```
Syllabus (top-level qualification)
 └── Subject (discipline)
      └── Subject-grade (grade-specific grouping)
           └── Canonical Topic (core teachable unit)
                ├── Locale Topic Variant (same canonical ID)
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
| Subject | `schema/subject.schema.json` | `curricula/**/subject.yaml` |
| Subject-grade | `schema/subject-grade.schema.json` | `curricula/**/subject-grade.yaml` |
| Canonical topic | `schema/topic.schema.json` | Canonical topic YAML under `curricula/**/topics/` |
| Locale topic variant | `schema/topic-variant.schema.json` | Topic YAML under `curricula/**/topics/translations/{locale}/` |
| Assessment | `schema/assessments.schema.json` | Canonical and locale `*.assessments.yaml` companions |
| Example | `schema/examples.schema.json` | Canonical and locale `*.examples.yaml` companions |
| Concept | `schema/concept.schema.json` | `concepts/**/*.yaml` |
| Taxonomy | `schema/taxonomy.schema.json` | `taxonomy/**/*.yaml` |

Canonical topic IDs are globally unique across the repository. A locale variant reuses the canonical topic ID by design, but is classified and validated separately for its mirrored path, locale, language, and parent identities.

Canonical topic files live directly under `topics/` and use English when an English representation exists. Malay variants live under `topics/translations/ms/`, reuse the canonical filename and topic ID, and carry `language: ms`.

The current exact inventory is 560 content YAML files:

| Artifact class | Count |
|----------------|------:|
| Syllabus | 1 |
| Subject | 3 |
| Subject-grade | 15 |
| Canonical topic | 152 |
| Locale topic variant | 53 |
| Canonical assessment | 114 |
| Locale assessment | 53 |
| Canonical example | 114 |
| Locale example | 53 |
| Concept | 2 |
| Taxonomy | 0 |
| **Total** | **560** |

### 3.3 Topic Schema (Core — Most Complex)

The topic schema is the heart of OSS. Every field exists because an AI tutor or learning platform needs it to teach effectively.

```yaml
# Required fields
id: string                        # Globally unique canonical topic ID
official_ref: string              # Non-empty source curriculum reference
name or name_en: string           # At least one human-readable name
subject_grade_id: string          # Reference to parent subject-grade
subject_id: string                # Reference to parent subject
syllabus_id: string               # Reference to parent syllabus
content_standards: array          # May be empty for a Level 0 catalog stub

# Level 1 teaching identity
difficulty: enum                  # beginner | intermediate | advanced
learning_objectives: array        # At least one root objective
prerequisites:
  required: array[string]         # Topic IDs that must be mastered first
  recommended: array[string]      # Topic IDs that help but aren't required
bloom_levels: array[enum]         # Or Bloom evidence embedded in objectives

# Pedagogical fields (Level 2+)
teaching:
  sequence: array[string]         # Recommended teaching order (step by step)
  common_misconceptions: array    # Each with misconception + remediation text
  engagement_hooks: array[string] # Real-world hooks to capture interest

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

Runtime-bearing values have one canonical representation: root `learning_objectives`, `mastery`, nested `teaching.sequence` and `teaching.common_misconceptions`, and `answer.options`. Root `engagement_hooks` is the only retained alternate placement because the Go consumer normalizes it with conflict detection. The schemas reject the removed aliases instead of silently dropping authored policy.

Locale assessment variants may localize question prose and expected values, but question IDs, learning-objective references, and answer types remain identical to the canonical assessment. The cross-reference gate enforces that evidence contract.

Worked examples may omit `learning_objective`; when present, it must exactly match an authored objective ID from the canonical topic. Locale example variants may translate prose but preserve canonical worked-example IDs and objective identities.

### 3.4 Assessment Schema

```yaml
topic_id: string
questions: array
  - id: string                    # Unique within topic (e.g., "Q1")
    text: string                  # Question text (supports LaTeX via $...$)
    difficulty: enum              # easy | medium | hard
    learning_objective: string    # References topic's LO id
    answer:
      type: enum                  # exact | range | multiple_choice | true_false |
                                  # matching | free_text | structured |
                                  # structured_response | subjective | opb
      value: string               # Required except for matching
      pairs: array                # Required for matching; value is forbidden
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
│   └── malaysia/
│       └── malaysia-kssm/
│           ├── syllabus.yaml                               # Top-level syllabus
│           └── malaysia-kssm-matematik/
│               ├── subject.yaml                            # Subject
│               └── malaysia-kssm-matematik-tingkatan-1/
│                   ├── subject-grade.yaml                   # Grade-specific subject
│                   └── topics/
│                       ├── MT1-01.yaml                       # Canonical topic
│                       ├── MT1-01.teaching.md                # AI teaching notes
│                       ├── MT1-01.examples.yaml              # Worked examples
│                       ├── MT1-01.assessments.yaml           # Assessments
│                       └── translations/
│                           └── ms/
│                               ├── MT1-01.yaml               # Locale topic variant
│                               ├── MT1-01.examples.yaml
│                               └── MT1-01.assessments.yaml
│
├── concepts/                           # Universal cross-curriculum concepts
│   └── mathematics/
│       ├── algebraic-expression.yaml
│       └── linear-equation.yaml
│
├── taxonomy/                           # Empty today; schema exists for future taxonomies
│
├── schema/                             # JSON Schema validation files
│   ├── syllabus.schema.json
│   ├── subject.schema.json
│   ├── subject-grade.schema.json
│   ├── topic.schema.json
│   ├── topic-variant.schema.json
│   ├── assessments.schema.json
│   ├── examples.schema.json
│   ├── concept.schema.json
│   └── taxonomy.schema.json
│
├── scripts/                            # CI and maintenance scripts
│   ├── validate.sh                     # Run the full semantic gate
│   ├── validate-changed.sh             # Run PR validation for changed files
│   ├── check-inventory.rb              # Enforce the exact artifact inventory
│   ├── check-yaml-syntax.rb             # Parse every content YAML object
│   ├── check-yamllint-regressions.rb    # Block new touched-file style debt
│   ├── check-prerequisites.rb          # Detect cycles in prerequisite graph
│   ├── check-references.rb             # Verify cross-references are valid
│   ├── assess-quality.rb               # Auto-assess quality levels
│   ├── list-schema-targets.rb           # Emit deterministic schema targets
│   └── lib/oss_validation.rb           # Shared classifier + repo helpers
│
├── .github/
│   └── workflows/
│       └── validate.yml                # Changed-file PR validation + full main gate
│
├── .yamllint.yml                       # YAML linting rules
├── CONTRIBUTING.md                     # Contribution guide (3 paths)
├── LICENSE                             # CC BY-SA 4.0
└── README.md
```

### Naming Conventions

| Pattern | Example | Rule |
|---------|---------|------|
| Directories | `curricula/malaysia/malaysia-kssm/malaysia-kssm-matematik/malaysia-kssm-matematik-tingkatan-3/` | `{country_id}/{syllabus_id}/{subject_id}/{subject_grade_id}/` |
| Topics | `MT3-09.yaml` | Canonical topic ID + `.yaml` |
| Teaching notes | `MT3-09.teaching.md` | Same topic ID + `.teaching.md` |
| Examples | `MT3-09.examples.yaml` | Same topic ID + `.examples.yaml` |
| Assessments | `MT3-09.assessments.yaml` | Same topic ID + `.assessments.yaml` |
| Translations | `topics/translations/ms/MT1-01.yaml` | Reuse the canonical filename under `topics/translations/{lang-code}/` |
| Concepts | `concepts/mathematics/linear-equation.yaml` | `concepts/{domain}/{concept-name}.yaml` |

---

## 5. Quality Level Framework

A topic's optional `quality_level` field is a 0–5 completeness claim. When present, the full quality gate rejects claims above the completeness it can verify; consumers can filter for a minimum claimed level when they require it.

| Level | Name | Required Fields | AI Teaching Capability |
|-------|------|----------------|----------------------|
| **0** | Stub | `id`, `name`; `content_standards` and `learning_objectives` may be empty | No — catalog node only |
| **1** | Basic | + at least one learning objective, `prerequisites`, `difficulty`, Bloom evidence | Minimally — knows the teaching target, difficulty, and ordering |
| **2** | Structured | + `teaching.sequence`, `teaching.common_misconceptions`, `engagement_hooks` | Somewhat — knows what to teach and common pitfalls |
| **3** | Teachable | + `ai_teaching_notes` (.md), `examples_file`, `assessments_file` | **Yes** — has everything needed for an effective session |
| **4** | Complete | + translations (≥1 language), `cross_curriculum` links, peer-reviewed | Well — multilingual, cross-referenced |
| **5** | Gold | + validated by curriculum authority, backed by student interaction data | Excellently — data-proven effectiveness |

**Quality level is auto-assessed by CI.** The `assess-quality.rb` script examines each topic file and its companion files to determine the current level. PRs that lower a topic's quality level are flagged for review.

---

## 6. Validation Pipeline (CI)

Pull requests run changed-file validation so scoped fixes are not blocked by existing unrelated full-repo failures. Pushes to `main` and manual workflow runs execute the full validation gate.

```yaml
# .github/workflows/validate.yml
name: Validate Curriculum
on:
  push:
    branches:
      - main
  pull_request:
  workflow_dispatch:

jobs:
  validate:
    runs-on: ubuntu-latest
    env:
      UV_TOOL_DIR: ${{ github.workspace }}/.ci/uv/tools
      UV_TOOL_BIN_DIR: ${{ github.workspace }}/.ci/uv/bin
      NPM_CONFIG_PREFIX: ${{ github.workspace }}/.ci/npm-prefix
    steps:
      - uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"

      - name: Set up uv
        uses: astral-sh/setup-uv@v7
        with:
          python-version: "3.12"
          enable-cache: true
          tool-dir: ${{ env.UV_TOOL_DIR }}
          tool-bin-dir: ${{ env.UV_TOOL_BIN_DIR }}

      - name: Restore validation tools
        uses: actions/cache/restore@v4
        with:
          path: |
            .ci/uv/tools
            .ci/uv/bin
            .ci/npm-prefix
          key: validation-tools-${{ runner.os }}-uv-yamllint-ajv-v2

      - name: Install validators
        run: |
          mkdir -p "$UV_TOOL_DIR" "$UV_TOOL_BIN_DIR" "$NPM_CONFIG_PREFIX"
          echo "$UV_TOOL_BIN_DIR" >> "$GITHUB_PATH"
          echo "$NPM_CONFIG_PREFIX/bin" >> "$GITHUB_PATH"
          export PATH="$UV_TOOL_BIN_DIR:$NPM_CONFIG_PREFIX/bin:$PATH"
          uv python install 3.12

          if ! command -v yamllint >/dev/null; then
            uv tool install yamllint
          fi
          if ! npm list --global --depth=0 ajv-cli >/dev/null 2>&1; then
            npm install --global ajv-cli
          fi
          if ! npm list --global --depth=0 ajv-formats >/dev/null 2>&1; then
            npm install --global ajv-formats
          fi

          export NODE_PATH="$(npm root --global)"
          echo "NODE_PATH=$NODE_PATH" >> "$GITHUB_ENV"
          node -e 'require("ajv-formats")'
          ajv compile --spec=draft2020 -c ajv-formats -s schema/syllabus.schema.json >/dev/null

      - name: Run changed files validation
        if: github.event_name == 'pull_request'
        run: ./scripts/validate-changed.sh

      - name: Run full validation
        if: github.event_name != 'pull_request'
        run: ./scripts/validate.sh
```

**Validation rules enforced:**

| Check | Tool | PR Gate | Full Gate |
|-------|------|---------|-----------|
| Touched content YAML style | yamllint | Yes | No |
| Touched content YAML syntax and schema | YAML parser + AJV | Yes | Included in full checks |
| Every content YAML parses | YAML parser | No | Yes, all 560 |
| Every artifact matches its classified schema | ajv-cli + ajv-formats | No | Yes, all 560 |
| Exact artifact inventory | custom Ruby | No | Yes |
| No prerequisite cycles | custom Ruby | No | Yes |
| All path, topic, syllabus, and companion references agree | custom Ruby | No | Yes |
| Quality level not overclaimed | custom Ruby | No | Yes |
| Workflow YAML parses | Ruby YAML parser | Yes, when workflow changes | Yes, through workflow execution |

The full gate is semantic: syntax, classified schema validity, exact inventory, references, prerequisites, and quality. It intentionally excludes historical repository-wide `yamllint` style debt—currently 2,240 findings across 447 files. The changed-files gate owns `yamllint` for touched content, preventing new style regressions without conflating a legacy formatting cleanup with corpus correctness.

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
data, _ := os.ReadFile("oss/curricula/malaysia/malaysia-kssm/malaysia-kssm-matematik/malaysia-kssm-matematik-tingkatan-3/topics/MT3-09.yaml")
var topic Topic
yaml.Unmarshal(data, &topic)
```

```python
# Python
import yaml
with open("oss/curricula/malaysia/malaysia-kssm/malaysia-kssm-matematik/malaysia-kssm-matematik-tingkatan-3/topics/MT3-09.yaml") as f:
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
curl https://raw.githubusercontent.com/p-n-ai/oss/main/curricula/malaysia/malaysia-kssm/malaysia-kssm-matematik/malaysia-kssm-matematik-tingkatan-3/topics/MT3-09.yaml
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

Translations live under `topics/translations/{lang-code}/` and mirror the canonical topic filenames. This design keeps translations additive: they never modify the canonical files.

```
curricula/malaysia/malaysia-kssm/malaysia-kssm-matematik/malaysia-kssm-matematik-tingkatan-3/topics/
├── MT3-09.yaml                           # English canonical topic
└── translations/
    └── ms/
        └── MT3-09.yaml                   # Malay locale variant
```

**Translation identity:** A locale topic variant reuses the canonical topic ID. The validator checks it through `topic-variant.schema.json` and separately enforces mirrored filename, locale/language agreement, and canonical parent identities. Locale assessment and example companions likewise reuse their canonical `topic_id` and are classified separately from canonical companions.

**Language codes:** ISO 639-1 two-letter codes (e.g., `ms`, `ar`, `zh`, `hi`, `es`, `fr`).

---

## 10. Cross-Curriculum Concepts

The `concepts/` directory bridges the same mathematical (or scientific, literary, etc.) concept across different curricula. This is the mechanism that enables:

- Students transferring between curricula to see what they already know
- AI agents adapting depth based on which syllabus the student follows
- Researchers comparing curriculum alignment across countries

```yaml
# concepts/mathematics/linear-equation.yaml
id: linear-equation
name: "Linear Equation"
domain: mathematics
subdomain: algebra
definition: "An equation of degree 1 in the form ax + b = c, where a is not equal to 0"
curricula:
  - syllabus: malaysia-kssm
    topic: MT1-06
    scope: "Solving linear equations in one variable."
  - syllabus: malaysia-kssm
    topic: MT3-09
    scope: "Straight lines and linear equations in two variables."
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
