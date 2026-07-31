<p align="center">
  <h1 align="center">Open School Syllabus</h1>
  <p align="center">
    <strong>The world's largest open, machine-readable curriculum repository</strong>
  </p>
  <p align="center">
    Wikipedia for curricula — but structured, validated, and AI-ready.
  </p>
  <p align="center">
    <a href="#browse-curricula">Browse Curricula</a> ·
    <a href="#for-developers">For Developers</a> ·
    <a href="#for-educators">For Educators</a> ·
    <a href="#contribute">Contribute</a>
  </p>
  <p align="center">
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-CC%20BY--SA%204.0-orange.svg" alt="License"></a>
    <img src="https://img.shields.io/badge/status-live-green.svg" alt="Status">
    <img src="https://img.shields.io/badge/content_YAML-562-blue.svg" alt="Content YAML Count">
    <img src="https://img.shields.io/badge/format-YAML%20%2B%20Markdown-yellow.svg" alt="Format">
  </p>
</p>

---

## What is Open School Syllabus?

Open School Syllabus (OSS) is a structured, machine-readable repository of educational curricula from around the world. Every topic, learning objective, prerequisite, assessment, and teaching strategy is stored as validated YAML — ready for AI agents, learning platforms, and educational tools to consume.

**Not another content dump.** OSS is specifically designed so that:

- **AI tutors** can read a topic and know exactly what to teach, in what order, at what depth, and what mistakes students commonly make.
- **Learning platforms** can build adaptive learning paths from the prerequisite graph.
- **Teachers** can contribute their real-world teaching insights in natural language.
- **Researchers** can analyze curriculum alignment across countries.
- **Anyone** can host, fork, and adapt it for their needs.

### Why does this exist?

Every AI tutoring platform, every educational app, every school management system independently recreates the same curriculum structures. OSS provides this once, as shared open infrastructure — so builders can focus on what makes their product unique instead of re-typing syllabi from PDFs.

---

## Browse Curricula

### Available curriculum

| Curriculum | Country | Status |
|-----------|---------|--------|
| Malaysia KSSM Mathematics Forms 1-5 | Malaysia | Live structured curriculum |
| Malaysia KSSM Science Forms 1-5 | Malaysia | Live catalog and curriculum content |
| Malaysia KSSM History Forms 1-5 | Malaysia | Live catalog and curriculum content |

Want to see your country's curriculum here? [Start a contribution →](#contribute)

---

## Repository Structure

```
oss/
├── curricula/                        # All curricula organized by board
│   └── malaysia/
│       └── malaysia-kssm/
│           ├── syllabus.yaml                            # Top-level syllabus
│           └── malaysia-kssm-matematik/
│               ├── subject.yaml                         # Subject
│               └── malaysia-kssm-matematik-tingkatan-1/
│                   ├── subject-grade.yaml                # Grade-specific subject
│                   └── topics/
│                       ├── MT1-01.yaml                    # Canonical topic
│                       ├── MT1-01.teaching.md             # AI teaching notes
│                       ├── MT1-01.examples.yaml           # Worked examples
│                       ├── MT1-01.assessments.yaml        # Assessments
│                       └── translations/
│                           └── ms/
│                               ├── MT1-01.yaml            # Locale topic variant
│                               ├── MT1-01.examples.yaml
│                               └── MT1-01.assessments.yaml
│
├── concepts/                         # Universal cross-curriculum concepts
│   └── mathematics/
│       ├── algebraic-expression.yaml
│       └── linear-equation.yaml
│
├── taxonomy/                         # Empty today; schema exists for future taxonomies
│
├── schema/                           # JSON Schema validation files
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
├── scripts/                          # CI and maintenance scripts
│   ├── validate.sh
│   ├── validate-changed.sh
│   ├── check-inventory.rb
│   ├── check-prerequisites.rb
│   ├── check-references.rb
│   ├── assess-quality.rb
│   └── lib/oss_validation.rb
│
├── .github/workflows/                # CI pipelines
│   └── validate.yml
│
├── .yamllint.yml                     # YAML linting rules
├── CONTRIBUTING.md                   # How to contribute
├── LICENSE                           # CC BY-SA 4.0 (planned)
└── README.md
```

---

## Schema Overview

OSS uses nine JSON Schema types. The validator classifies canonical and localized artifacts before selecting a schema, so locale variants cannot accidentally pass as canonical topics.

| Schema type | Current inventory |
|-------------|------------------:|
| Syllabus | 1 |
| Subject | 3 |
| Subject-grade | 15 |
| Canonical topic | 152 |
| Locale topic variant | 53 |
| Assessment | 115 canonical + 53 locale |
| Example | 115 canonical + 53 locale |
| Concept | 2 |
| Taxonomy | 0 |
| **Total content YAML** | **562** |

Canonical topic IDs are globally unique across OSS. A locale topic variant deliberately reuses its canonical topic ID, but is validated separately for its mirrored path, locale, language, and parent identity.

Canonical topic files live directly under `topics/` and use English when an English representation exists. Malay variants live under `topics/translations/ms/`, reuse the canonical filename and topic ID, and carry `language: ms`.

Runtime-bearing values use one canonical shape: root `learning_objectives`, `mastery`, nested `teaching.sequence` and `teaching.common_misconceptions`, and `answer.options`. Root `engagement_hooks` is the sole retained alternate placement because the consumer normalizes it with conflict detection.

Locale assessment variants may localize question prose and expected values, but question IDs, learning-objective references, and answer types must match the canonical assessment so localization cannot change mastery semantics.

Worked examples may omit `learning_objective`; when present, it must exactly match an authored objective ID from the canonical topic. Locale example variants may translate prose but preserve canonical worked-example IDs and objective identities.

The full gate validates all 562 content YAML files. Pull requests use the changed-files gate unless a schema or validation change requires the full corpus to be checked.

### 1. Syllabus

Top-level curriculum family.

```yaml
# curricula/malaysia/malaysia-kssm/syllabus.yaml
id: malaysia-kssm
name: "Kurikulum Standard Sekolah Menengah (KSSM)"
name_en: "Kurikulum Standard Sekolah Menengah (KSSM)"
country_id: malaysia
language: ms
subjects:
  - malaysia-kssm-matematik
  - malaysia-kssm-sains
  - malaysia-kssm-sejarah
provenance: ai-generated
generated_at: "2026-03-30T07:22:36Z"
```

### 2. Subject

Names a discipline within a syllabus. Grade-specific topic inventories live in
the nested `subject-grade.yaml` records.

```yaml
# curricula/malaysia/malaysia-kssm/malaysia-kssm-matematik/subject.yaml
id: malaysia-kssm-matematik
name: "Matematik"
name_en: "Mathematics"
syllabus_id: malaysia-kssm
country_id: malaysia
language: ms
provenance: ai-generated
generated_at: "2026-03-29T23:18:08Z"
```

### 3. Topic (Core Unit)

The heart of OSS. Each topic contains everything an AI agent or learning platform needs.

```yaml
# curricula/malaysia/malaysia-kssm/malaysia-kssm-matematik/
# malaysia-kssm-matematik-tingkatan-3/topics/MT3-09.yaml
id: MT3-09
official_ref: "Bab 9"
name: "Garis Lurus"
name_en: "Straight Lines"
subject_grade_id: malaysia-kssm-matematik-tingkatan-3
subject_id: malaysia-kssm-matematik
syllabus_id: malaysia-kssm
country_id: malaysia
language: en
difficulty: intermediate
tier: core

content_standards:
  - id: "9.1"
    text_en: "Straight Lines"

learning_objectives:
  - id: 9.1.1
    content_standard_id: "9.1"
    text_en: "Connect y = mx + c with gradient and y-intercept."
    bloom: understand

prerequisites:
  required:
    - MT1-06
    - MT2-03
  recommended:
    - MT2-01

teaching:
  sequence:
    - "Connect the equation form to gradient and intercept."
  common_misconceptions:
    - misconception: "Reading the gradient before isolating y."
      remediation: "Rewrite the equation with y alone first."
  engagement_hooks:
    - "Compare the gradients of familiar ramps and staircases."

quality_level: 3
provenance: ai-assisted
ai_teaching_notes: MT3-09.teaching.md
assessments_file: MT3-09.assessments.yaml
examples_file: MT3-09.examples.yaml
```

### 4. Teaching Notes (Markdown)

Written specifically for AI agents — conversational guidance for teaching the topic via chat.

```markdown
<!-- MT3-09.teaching.md -->

# Teaching: Straight Lines

## Opening (First Message)

Ask the student to compare two familiar ramps: which is steeper, and how could
we express that difference with numbers?

## When the Student is Stuck

Have them isolate `y` before identifying `m` and `c`, then verify the gradient
from two points on the line.
```

### 5. Assessments

Practice questions with rubrics, hints, and difficulty scaling.

```yaml
# MT3-09.assessments.yaml
topic_id: MT3-09
provenance: ai-assisted
questions:
  - id: Q1
    text: "For 2y = 6x - 4, identify the gradient and y-intercept."
    difficulty: easy
    learning_objective: 9.1.1
    tp_level: 1
    kbat: false
    answer:
      type: multiple_choice
      value: "Gradient = 3, y-intercept = -2"
      working: |
        Divide the equation by 2:
        y = 3x - 2
      distractors:
        - value: "Gradient = 6, y-intercept = -4"
          feedback: "Divide every term by 2 before reading m and c."
    marks: 2
    rubric:
      - marks: 1
        criteria: "Correctly identifies the gradient."
      - marks: 1
        criteria: "Correctly identifies the y-intercept."
    hints:
      - level: 1
        text: "Isolate y before reading the gradient and intercept."
```

### 6. Concept (Cross-Curriculum Bridge)

Bridges the same concept across different curricula, enabling student transfer and cross-curriculum analysis.

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

### 7. Taxonomy (Subject Area Hierarchy)

The taxonomy schema is ready for subject-area hierarchies, but the exact current
inventory contains no taxonomy artifacts.

---

## For Developers

### Consuming OSS in Your Application

**Option 1: Clone and read YAML directly**

```bash
git clone https://github.com/p-n-ai/oss.git
```

```python
# Python
import yaml

with open("oss/curricula/malaysia/malaysia-kssm/malaysia-kssm-matematik/malaysia-kssm-matematik-tingkatan-3/topics/MT3-09.yaml") as f:
    topic = yaml.safe_load(f)

print(topic["learning_objectives"][0]["text_en"])
# → "Make connection between the equation, y = mx + c, and the gradient..."
```

```go
// Go
data, _ := os.ReadFile("oss/curricula/malaysia/malaysia-kssm/malaysia-kssm-matematik/malaysia-kssm-matematik-tingkatan-3/topics/MT3-09.yaml")
var topic Topic
yaml.Unmarshal(data, &topic)
```

**Option 2: Use as a Git submodule**

```bash
git submodule add https://github.com/p-n-ai/oss.git curriculum
```

**Option 3: SQLite export (coming soon)**

A pre-built SQLite database (50-200MB) containing all curriculum data, for offline-capable applications.

### Validating Content

The repository scripts are the supported validation surface:

```bash
# Install validators
uv tool install yamllint
npm install -g ajv-cli
npm install -g ajv-formats

# Validate a single topic (--spec=draft2020 required for Draft 2020-12)
ajv validate --spec=draft2020 -c ajv-formats -s schema/topic.schema.json -d "curricula/malaysia/malaysia-kssm/malaysia-kssm-matematik/malaysia-kssm-matematik-tingkatan-3/topics/MT3-09.yaml"

# Validate the complete corpus
./scripts/validate.sh

# Validate files changed from the PR base
./scripts/validate-changed.sh
```

The full gate parses every content YAML file, validates it through the correct one of nine schemas with `ajv-formats`, enforces the exact 562-file inventory, and checks references, prerequisite integrity, and quality claims. It intentionally does not make historical repository-wide YAML style debt part of that gate: there are currently 2,240 pre-existing `yamllint` findings across 447 files. The changed-files gate owns `yamllint` for touched YAML and blocks any increase in findings by rule, so new style debt cannot hide inside a semantic change.

Pull request CI runs changed-file validation. Pushes to `main` and manual workflow runs execute the full `./scripts/validate.sh` gate.

---

## For Educators

### How to Contribute (No Coding Required)

You don't need to know YAML or Git. There are 3 ways to contribute:

#### 1. Web Form (Easiest)

Visit [contribute.p-n-ai.org](https://contribute.p-n-ai.org) *(coming soon)* — select a syllabus and topic, type your contribution in plain language, and our bot will structure it and submit it for review.

#### 2. GitHub Issue

[Open an issue](https://github.com/p-n-ai/oss/issues/new) describing what you want to add, change, or fix. Our team or the [OSS Bot](https://github.com/p-n-ai/oss-bot) will implement it.

Examples:
- "The teaching notes for quadratic equations suggest factorisation first, but in Malaysia we teach the formula first"
- "I've been teaching IGCSE Physics for 8 years. Here are the top 5 misconceptions students have about electric circuits..."
- "Please add the Indonesia Kurikulum Merdeka for Mathematics SMA"

#### 3. Direct Pull Request (Most Control)

Fork the repo, add or edit YAML/Markdown files, and open a PR. See [CONTRIBUTING.md](CONTRIBUTING.md) for the full guide.

> **Before writing any YAML:** Read [docs/id-conventions.md](docs/id-conventions.md) for the canonical ID, naming, and locale rules. IDs use the official MOE language of the target country. Syllabus, subject, and subject-grade records require both `name` and `name_en`; canonical topics require at least one, and locale variants carry the localized `name`. The validator enforces the schema-specific requirements.

### What We Need Most

| Contribution Type | Impact | Difficulty |
|------------------|--------|------------|
| 🔴 **New syllabus** — scaffold your country's curriculum | Very High | Medium |
| 🟠 **Teaching notes** — write how you actually teach a topic | High | Easy |
| 🟡 **Assessment questions** — add practice questions with worked solutions | High | Easy |
| 🟢 **Misconceptions** — document common student mistakes and how to fix them | High | Easy |
| 🔵 **Translations** — translate existing topics to your language | Medium | Easy |
| 🟣 **Cross-curriculum links** — map your syllabus to universal concepts | Medium | Medium |

---

## Quality Levels

When present, a topic's quality level is a 0–5 completeness claim. The quality gate rejects claims above the completeness it can verify:

| Level | Name | Contents | AI Can Use? |
|-------|------|----------|-------------|
| ⬜ **0** | Stub | Name; content standards and objectives may be empty | No — catalog only |
| ⭐ **1** | Basic | + at least one objective, prerequisites, difficulty, Bloom evidence | Minimally |
| ⭐⭐ **2** | Structured | + teaching sequence, misconceptions | Somewhat |
| ⭐⭐⭐ **3** | Teachable | + teaching notes, examples, assessments | **Yes** |
| ⭐⭐⭐⭐ **4** | Complete | + translations, cross-curriculum links, peer-reviewed | Well |
| ⭐⭐⭐⭐⭐ **5** | Gold | + validated by curriculum authority, data-backed | Excellently |

**Our target: every topic at Level 3 (Teachable) within 6 months of creation.** Level 3 is the threshold where an AI tutor can deliver a genuinely useful teaching session.

---

## Universal Concepts

OSS includes a `concepts/` directory that bridges the same concept across different curricula.

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

This enables:
- Students transferring between curricula to see what they already know and what's new
- AI agents adapting depth based on which syllabus the student is following
- Researchers comparing curriculum alignment across countries

---

## Self-Improving Feedback Loop

When used with [P&AI Bot](https://github.com/p-n-ai/pai-bot), OSS becomes self-improving:

```
Better curriculum → Better AI teaching → More student data
        ↑                                       │
        │                                       ▼
   Community +          ←          Data-informed
   AI improvements                 improvement suggestions
```

The P&AI agent observes patterns across thousands of students:
- "73% of students make sign errors on this topic" → auto-generates a misconception entry
- "This explanation works 20% better than the existing one" → suggests a teaching note update
- "Students keep asking about a topic not yet in the syllabus" → flags a content gap

These observations are submitted as GitHub issues tagged `ai-observed` for educator review. The curriculum gets better because people use it, which makes more people use it.

---

## Provenance & Trust

Every piece of content tracks its origin:

| Provenance | Meaning | Review Required? |
|-----------|---------|-----------------|
| `human` | Written by a human educator | Standard review |
| `ai-assisted` | Human wrote it with AI help | Standard review |
| `ai-generated` | Fully generated by AI from a prompt | Educator review required |
| `ai-observed` | Generated from student interaction data | Educator review required |

AI-generated and AI-observed content always requires human educator review before merging. We trust AI to scale, but educators are the quality gate.

---

## Related Repositories

| Repository | Description |
|-----------|-------------|
| [p-n-ai/pai-bot](https://github.com/p-n-ai/pai-bot) | AI learning companion that uses OSS as its curriculum source |
| [p-n-ai/oss-bot](https://github.com/p-n-ai/oss-bot) | GitHub bot + CLI tools for contributing to this repository |

---

## License

Open School Syllabus is licensed under [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](LICENSE).

You are free to:
- **Share** — copy and redistribute the material in any medium or format
- **Adapt** — remix, transform, and build upon the material for any purpose, including commercially

Under the following terms:
- **Attribution** — You must give appropriate credit and link to OSS
- **ShareAlike** — If you remix or build upon OSS, you must distribute your contributions under the same license

This means any school, company, or government can use OSS freely — and any improvements they make must be shared back with the community.

---

<p align="center">
  <strong>Every curriculum, structured and open, for every student on Earth.</strong>
  <br>
  A <a href="https://pandai.org">Pandai</a> initiative. Built with ❤️ by educators and AI, for everyone.
</p>
