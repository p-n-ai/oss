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
    <img src="https://img.shields.io/badge/status-scaffolding-yellow.svg" alt="Status">
    <img src="https://img.shields.io/badge/curricula-0_(building)-blue.svg" alt="Curricula Count">
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

### Planned (Contributions Welcome!)

| Curriculum | Country | Status |
|-----------|---------|--------|
| Cambridge IGCSE 0580 Mathematics | International | 🚧 In progress (seed content) |
| KSSM Matematik Forms 1-3 | Malaysia | 🚧 In progress (seed content) |
| IB Diploma Mathematics AA | International | 📋 Scaffolded |
| SAT Mathematics | USA | 📋 Scaffolded |
| CBSE Class 10 Mathematics | India | 🔲 Not started |
| GCSE Mathematics (Edexcel) | UK | 🔲 Not started |
| SPM Mathematics | Malaysia | 🔲 Not started |
| Kurikulum Merdeka SMA | Indonesia | 🔲 Not started |

Want to see your country's curriculum here? [Start a contribution →](#contribute)

---

## Repository Structure

```
oss/
├── curricula/                        # All curricula organized by board
│   ├── cambridge/
│   │   └── igcse/
│   │       └── mathematics-0580/
│   │           ├── syllabus.yaml                         # Top-level qualification
│   │           ├── subjects/
│   │           │   ├── algebra.yaml                      # Subject grouping
│   │           │   └── number.yaml
│   │           ├── topics/
│   │           │   └── algebra/
│   │           │       ├── 01-expressions.yaml           # Topic definition
│   │           │       ├── 01-expressions.teaching.md    # AI teaching notes
│   │           │       ├── 01-expressions.examples.yaml  # Worked examples
│   │           │       └── 01-expressions.assessments.yaml
│   │           └── locales/                              # Translations
│   │               └── ms/                               # Malay
│   │                   └── topics/algebra/
│   │                       └── 01-expressions.yaml
│   └── malaysia/
│       └── kssm/
│           ├── matematik-tingkatan1/
│           │   └── ...                                     # Same structure
│           ├── matematik-tingkatan2/
│           │   └── ...
│           └── matematik-tingkatan3/
│               └── ...
│
├── concepts/                         # Universal cross-curriculum concepts
│   └── mathematics/
│       ├── quadratic-equation.yaml   # Bridges same concept across curricula
│       ├── linear-function.yaml
│       └── ...
│
├── taxonomy/                         # Subject area hierarchies
│   └── mathematics/
│       ├── algebra.yaml
│       ├── geometry.yaml
│       └── ...
│
├── schema/                           # JSON Schema validation files
│   ├── syllabus.schema.json
│   ├── subject.schema.json
│   ├── topic.schema.json
│   ├── examples.schema.json
│   ├── assessments.schema.json
│   ├── concept.schema.json
│   └── taxonomy.schema.json
│
├── scripts/                          # CI and maintenance scripts
│   ├── validate.sh
│   ├── check-prerequisites.py
│   ├── check-references.py
│   └── assess-quality.py
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

OSS uses 7 core schema types. Every file is validated against its JSON Schema on every commit.

### 1. Syllabus

Top-level qualification (e.g., "Cambridge IGCSE Mathematics 0580").

```yaml
# curricula/cambridge/igcse/mathematics-0580/syllabus.yaml
id: cambridge-igcse-mathematics-0580
name: Cambridge IGCSE Mathematics
board: cambridge
level: igcse
code: "0580"
version: "2025-2027"
subjects:
  - algebra
  - number
  - geometry
  - statistics
assessment:
  components:
    - name: Paper 2 (Extended)
      weight: 35
      duration_minutes: 90
    - name: Paper 4 (Extended)
      weight: 65
      duration_minutes: 150
grading:
  scale: [A*, A, B, C, D, E, F, G, U]
```

### 2. Subject

Groups related topics within a syllabus.

```yaml
# curricula/cambridge/igcse/mathematics-0580/subjects/algebra.yaml
id: algebra
name: Algebra
syllabus_id: cambridge-igcse-mathematics-0580
description: "Algebraic manipulation, equations, inequalities, sequences, and functions"
topics:
  - 01-expressions
  - 02-linear-equations
  - 03-simultaneous-equations
  - 04-inequalities
  - 05-quadratic-equations
```

### 3. Topic (Core Unit)

The heart of OSS. Each topic contains everything an AI agent or learning platform needs.

```yaml
# curricula/cambridge/igcse/mathematics-0580/topics/algebra/05-quadratic-equations.yaml
id: 05-quadratic-equations
name: Quadratic Equations
subject_id: algebra
syllabus_id: cambridge-igcse-mathematics-0580

difficulty: intermediate
tier: extended                       # core | extended

bloom_levels:                        # Bloom's Taxonomy mapping
  - apply
  - analyze

learning_objectives:
  - id: LO1
    text: "Solve quadratic equations by factorisation"
    bloom: apply
  - id: LO2
    text: "Solve quadratic equations using the quadratic formula"
    bloom: apply
  - id: LO3
    text: "Form and solve quadratic equations from context"
    bloom: analyze

prerequisites:
  required:
    - 01-expressions                 # Must master these first
    - 02-linear-equations
  recommended:
    - 04-inequalities

cross_curriculum:                    # Same concept in other curricula
  - syllabus: malaysia-kssm-mathematics-form4
    topic: quadratic-equations-and-inequalities
    scope_difference: "KSSM includes completing the square at Form 4 level"
  - concept: mathematics/quadratic-equation

teaching:
  sequence:                          # Recommended teaching order
    - "Review expanding brackets (prerequisite check)"
    - "Introduce through pattern recognition: find two numbers that add to 5 and multiply to 6"
    - "Connect pattern to factorisation"
    - "Teach the quadratic formula for non-factorisable equations"
    - "Apply to real-world problems"
  common_misconceptions:
    - misconception: "Students write x² + 5x + 6 = 0 as x(x+5) + 6 = 0"
      remediation: "Emphasise that factorisation means TWO brackets: (x+?)(x+?)"
    - misconception: "Students forget ± when using the quadratic formula"
      remediation: "Always write both solutions first, then check if both are valid"
  engagement_hooks:
    - "Projectile problems: 'How long until the ball hits the ground?'"
    - "Area puzzles: 'A rectangular garden has area 24m² and perimeter 20m. Find the dimensions.'"

mastery:
  minimum_score: 0.75
  assessment_count: 3                # Minimum assessments before mastery
  spaced_repetition:
    initial_interval_days: 1
    multiplier: 2.5

ai_teaching_notes: 05-quadratic-equations.teaching.md
examples_file: 05-quadratic-equations.examples.yaml
assessments_file: 05-quadratic-equations.assessments.yaml

quality_level: 3                     # See Quality Levels below
provenance: human                    # human | ai-assisted | ai-generated | ai-observed
```

### 4. Teaching Notes (Markdown)

Written specifically for AI agents — conversational guidance for teaching the topic via chat.

```markdown
<!-- 05-quadratic-equations.teaching.md -->

# Teaching: Quadratic Equations

## Opening (First Message)

Start with a puzzle, not a definition:

"I'm thinking of two numbers. They ADD to 5 and MULTIPLY to 6.
Can you figure out what they are? 🤔"

This is intuitive and avoids the abstract "factorise the trinomial" language
that loses students immediately.

## When the Student is Stuck

If they can't find the two numbers, scaffold:
1. "What pairs of numbers multiply to 6?" → (1,6), (2,3)
2. "Which of those pairs add to 5?" → (2,3) ✓

Then reveal: "You just solved x² + 5x + 6 = 0. The answer is x = -2 or x = -3.
The puzzle IS the method!"

## Common Failure Point: Sign Errors

73% of students make sign errors when factors have negative values.
When this happens, DON'T just correct them. Instead:
"Let's check: if x = 3, does (3)² + 5(3) + 6 = 0? → 9 + 15 + 6 = 30 ≠ 0.
Something's off. Let's try x = -3..."

Always verify by substitution. Build the habit of checking.

## Transitioning to the Quadratic Formula

Only introduce the formula AFTER the student is comfortable with factorisation.
Frame it as: "Some quadratics can't be factorised neatly. That's when we
use the formula — it works for ALL quadratics."

## Session Ending

End with a forward look: "You can now solve quadratic equations two ways.
Next time, we'll use these to solve real problems — like calculating
how high a ball goes when you throw it upward. 🚀"
```

### 5. Assessments

Practice questions with rubrics, hints, and difficulty scaling.

```yaml
# 05-quadratic-equations.assessments.yaml
topic_id: 05-quadratic-equations
questions:
  - id: Q1
    text: "Solve x² + 7x + 12 = 0"
    difficulty: easy
    learning_objective: LO1
    answer:
      type: exact
      value: "x = -3 or x = -4"
      working: |
        x² + 7x + 12 = 0
        Find two numbers that multiply to 12 and add to 7: (3, 4)
        (x + 3)(x + 4) = 0
        x = -3 or x = -4
    marks: 3
    rubric:
      - marks: 1
        criteria: "Correct factorisation"
      - marks: 1
        criteria: "Both solutions found"
      - marks: 1
        criteria: "Correct signs"
    hints:
      - level: 1
        text: "Find two numbers that multiply to 12 and add to 7"
      - level: 2
        text: "The numbers are 3 and 4. Now write it as (x + ?)(x + ?) = 0"
    distractors:                     # Common wrong answers
      - value: "x = 3 or x = 4"
        feedback: "Check the signs! If x = 3, then 9 + 21 + 12 = 42 ≠ 0"

  - id: Q2
    text: "Solve 2x² - 5x - 3 = 0 using the quadratic formula"
    difficulty: medium
    learning_objective: LO2
    answer:
      type: exact
      value: "x = 3 or x = -0.5"
    marks: 4
    # ... rubric, hints, distractors
```

### 6. Concept (Cross-Curriculum Bridge)

Bridges the same concept across different curricula, enabling student transfer and cross-curriculum analysis.

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
```

### 7. Taxonomy (Subject Area Hierarchy)

Defines the universal classification tree for subject areas, enabling consistent categorisation across curricula.

```yaml
# taxonomy/mathematics/algebra.yaml
id: algebra
name: Algebra
domain: mathematics
subtopics:
  - expressions
  - equations
  - inequalities
  - sequences
  - functions
```

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

with open("oss/curricula/cambridge/igcse/mathematics-0580/topics/algebra/05-quadratic-equations.yaml") as f:
    topic = yaml.safe_load(f)

print(topic["learning_objectives"][0]["text"])
# → "Solve quadratic equations by factorisation"
```

```go
// Go
data, _ := os.ReadFile("oss/curricula/cambridge/igcse/mathematics-0580/topics/algebra/05-quadratic-equations.yaml")
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

All YAML files are validated against JSON Schemas in the `schema/` directory.

```bash
# Install the validator
npm install -g ajv-cli ajv-formats

# Validate a single topic (--spec=draft2020 required for Draft 2020-12)
ajv validate --spec=draft2020 -s schema/topic.schema.json -d "curricula/cambridge/igcse/mathematics-0580/topics/algebra/05-quadratic-equations.yaml"

# Validate all topics in a syllabus
find curricula/cambridge -name "*.yaml" -path "*/topics/*" | xargs -I{} ajv validate --spec=draft2020 -s schema/topic.schema.json -d {}
```

The CI pipeline validates every file on every pull request. Invalid files cannot be merged.

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

Every topic in OSS has a quality level that indicates its completeness:

| Level | Name | Contents | AI Can Use? |
|-------|------|----------|-------------|
| ⬜ **0** | Stub | Name + learning objectives only | Barely |
| ⭐ **1** | Basic | + prerequisites, difficulty, tier | Minimally |
| ⭐⭐ **2** | Structured | + teaching sequence, misconceptions | Somewhat |
| ⭐⭐⭐ **3** | Teachable | + teaching notes, examples, assessments | **Yes** |
| ⭐⭐⭐⭐ **4** | Complete | + translations, cross-curriculum links, peer-reviewed | Well |
| ⭐⭐⭐⭐⭐ **5** | Gold | + validated by curriculum authority, data-backed | Excellently |

**Our target: every topic at Level 3 (Teachable) within 6 months of creation.** Level 3 is the threshold where an AI tutor can deliver a genuinely useful teaching session.

---

## Universal Concepts

OSS includes a `concepts/` directory that bridges the same concept across different curricula.

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
  A <a href="https://pandai.app">Pandai</a> initiative. Built by educators and AI, for everyone.
</p>
