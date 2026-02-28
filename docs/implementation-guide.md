# Implementation Guide — Open School Syllabus (OSS)

> **Companion to:** [development-timeline.md](development-timeline.md)
> **Architecture reference:** [technical-plan.md](technical-plan.md)
> **Duration:** Day 0 → Day 30 (6 weeks)
> **Scope:** KSSM Matematik Forms 1-3, Algebra first

This guide provides step-by-step executable instructions for every day of the development timeline. Each day includes entry criteria, exact file paths, content templates, validation commands, and exit checklists.

## How to Use This Guide

1. Work through days sequentially — each day builds on the previous
2. Check **entry criteria** before starting a day
3. Complete all tasks, run **validation commands**
4. Verify all **exit criteria** checkboxes before moving to the next day
5. Track cumulative progress in the dashboard at the bottom of each day

### Task Owner Legend

| Icon | Owner | Meaning |
|------|-------|---------|
| 🤖 | Developer / AI Agent | Can be executed autonomously |
| 🧑 | Education Lead | Requires human educator expertise |
| 🧑🤖 | Collaborative | AI drafts, educator reviews and edits |

---

## Prerequisites

### Required Tools

```bash
# Node.js 20 LTS (for ajv-cli)
node --version   # Expected: v20.x.x

# Python 3.12 (for custom validation scripts)
python3 --version   # Expected: 3.12.x

# yamllint (YAML linter)
pip install yamllint
yamllint --version   # Expected: ≥1.35

# ajv-cli (JSON Schema validator)
npm install -g ajv-cli ajv-formats
ajv --version   # Expected: ≥5.0.0
```

### Verify Setup

```bash
# All four should succeed without errors
node --version && python3 --version && yamllint --version && ajv help
```

---

## DAY 0 — Repository Setup

**Entry criteria:** Repository exists with documentation only (README.md, CLAUDE.md, AGENTS.md, CONTRIBUTING.md, docs/).

### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 0.1 | Create directory structure | 🤖 | Directories only |
| 0.2 | Create `topic.schema.json` | 🤖 | `schema/topic.schema.json` |
| 0.3 | Create `assessments.schema.json` | 🤖 | `schema/assessments.schema.json` |
| 0.4 | Create `syllabus.schema.json` | 🤖 | `schema/syllabus.schema.json` |
| 0.5 | Create `subject.schema.json` | 🤖 | `schema/subject.schema.json` |
| 0.6 | Create Form 1 `syllabus.yaml` | 🤖 | `curricula/malaysia/kssm/matematik-tingkatan1/syllabus.yaml` |
| 0.7 | Create `.yamllint.yml` | 🤖 | `.yamllint.yml` |
| 0.8 | Choose first 5 Algebra topics | 🧑 | Decision only |

### 0.1 — Create Directory Structure

```bash
mkdir -p schema
mkdir -p curricula/malaysia/kssm/matematik-tingkatan1/subjects
mkdir -p curricula/malaysia/kssm/matematik-tingkatan1/topics/algebra
mkdir -p curricula/malaysia/kssm/matematik-tingkatan2/subjects
mkdir -p curricula/malaysia/kssm/matematik-tingkatan2/topics/algebra
mkdir -p curricula/malaysia/kssm/matematik-tingkatan3/subjects
mkdir -p curricula/malaysia/kssm/matematik-tingkatan3/topics/algebra
mkdir -p concepts/mathematics
mkdir -p taxonomy/mathematics
mkdir -p scripts
mkdir -p .github/workflows
```

### 0.2 — Create `schema/topic.schema.json`

This is the core schema. All topic YAML files validate against it.

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://github.com/p-n-ai/oss/schema/topic.schema.json",
  "title": "Topic",
  "description": "A single teachable unit within a subject",
  "type": "object",
  "required": ["id", "name", "subject_id", "syllabus_id", "difficulty", "learning_objectives", "quality_level", "provenance"],
  "properties": {
    "id": {
      "type": "string",
      "pattern": "^[A-Z][0-9]+-[0-9]{2}$",
      "description": "Unique topic ID within syllabus (e.g., F1-01)"
    },
    "name": {
      "type": "string",
      "minLength": 1
    },
    "subject_id": {
      "type": "string",
      "description": "Reference to parent subject ID"
    },
    "syllabus_id": {
      "type": "string",
      "description": "Reference to parent syllabus ID"
    },
    "difficulty": {
      "type": "string",
      "enum": ["beginner", "intermediate", "advanced"]
    },
    "learning_objectives": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["id", "text", "bloom"],
        "properties": {
          "id": {
            "type": "string",
            "pattern": "^LO[0-9]+$"
          },
          "text": {
            "type": "string",
            "minLength": 1
          },
          "bloom": {
            "type": "string",
            "enum": ["remember", "understand", "apply", "analyze", "evaluate", "create"]
          }
        },
        "additionalProperties": false
      }
    },
    "prerequisites": {
      "type": "object",
      "properties": {
        "required": {
          "type": "array",
          "items": { "type": "string" }
        },
        "recommended": {
          "type": "array",
          "items": { "type": "string" }
        }
      },
      "additionalProperties": false
    },
    "teaching": {
      "type": "object",
      "properties": {
        "sequence": {
          "type": "array",
          "items": { "type": "string" }
        },
        "common_misconceptions": {
          "type": "array",
          "items": {
            "type": "object",
            "required": ["misconception", "remediation"],
            "properties": {
              "misconception": { "type": "string" },
              "remediation": { "type": "string" }
            },
            "additionalProperties": false
          }
        },
        "engagement_hooks": {
          "type": "array",
          "items": { "type": "string" }
        }
      },
      "additionalProperties": false
    },
    "bloom_levels": {
      "type": "array",
      "items": {
        "type": "string",
        "enum": ["remember", "understand", "apply", "analyze", "evaluate", "create"]
      }
    },
    "mastery": {
      "type": "object",
      "properties": {
        "minimum_score": {
          "type": "number",
          "minimum": 0,
          "maximum": 1,
          "default": 0.75
        },
        "assessment_count": {
          "type": "integer",
          "minimum": 1
        },
        "spaced_repetition": {
          "type": "object",
          "properties": {
            "initial_interval_days": {
              "type": "integer",
              "minimum": 1
            },
            "multiplier": {
              "type": "number",
              "minimum": 1,
              "default": 2.5
            }
          },
          "additionalProperties": false
        }
      },
      "additionalProperties": false
    },
    "cross_curriculum": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["concept_id", "syllabus_id", "topic_id"],
        "properties": {
          "concept_id": { "type": "string" },
          "syllabus_id": { "type": "string" },
          "topic_id": { "type": "string" }
        },
        "additionalProperties": false
      }
    },
    "tier": {
      "type": "string",
      "enum": ["core", "extended"]
    },
    "ai_teaching_notes": {
      "type": "string",
      "description": "Relative path to .teaching.md file"
    },
    "examples_file": {
      "type": "string",
      "description": "Relative path to .examples.yaml file"
    },
    "assessments_file": {
      "type": "string",
      "description": "Relative path to .assessments.yaml file"
    },
    "quality_level": {
      "type": "integer",
      "minimum": 0,
      "maximum": 5
    },
    "provenance": {
      "type": "string",
      "enum": ["human", "ai-assisted", "ai-generated", "ai-observed"]
    }
  },
  "additionalProperties": false
}
```

### 0.3 — Create `schema/assessments.schema.json`

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://github.com/p-n-ai/oss/schema/assessments.schema.json",
  "title": "Assessments",
  "description": "Assessment questions for a topic",
  "type": "object",
  "required": ["topic_id", "questions", "provenance"],
  "properties": {
    "topic_id": {
      "type": "string",
      "description": "Reference to the topic these questions assess"
    },
    "questions": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["id", "text", "difficulty", "learning_objective", "answer", "marks"],
        "properties": {
          "id": {
            "type": "string",
            "pattern": "^Q[0-9]+$"
          },
          "text": {
            "type": "string",
            "description": "Question text, supports LaTeX via $...$"
          },
          "difficulty": {
            "type": "string",
            "enum": ["easy", "medium", "hard"]
          },
          "learning_objective": {
            "type": "string",
            "description": "References a learning objective ID from the topic"
          },
          "answer": {
            "type": "object",
            "required": ["type", "value"],
            "properties": {
              "type": {
                "type": "string",
                "enum": ["exact", "range", "multiple_choice", "free_text"]
              },
              "value": {
                "type": "string"
              },
              "working": {
                "type": "string",
                "description": "Step-by-step solution"
              }
            },
            "additionalProperties": false
          },
          "marks": {
            "type": "integer",
            "minimum": 1
          },
          "rubric": {
            "type": "array",
            "items": {
              "type": "object",
              "required": ["marks", "criteria"],
              "properties": {
                "marks": { "type": "integer", "minimum": 1 },
                "criteria": { "type": "string" }
              },
              "additionalProperties": false
            }
          },
          "hints": {
            "type": "array",
            "items": {
              "type": "object",
              "required": ["level", "text"],
              "properties": {
                "level": { "type": "integer", "minimum": 1 },
                "text": { "type": "string" }
              },
              "additionalProperties": false
            }
          },
          "distractors": {
            "type": "array",
            "items": {
              "type": "object",
              "required": ["value", "feedback"],
              "properties": {
                "value": { "type": "string" },
                "feedback": { "type": "string" }
              },
              "additionalProperties": false
            }
          }
        },
        "additionalProperties": false
      }
    },
    "provenance": {
      "type": "string",
      "enum": ["human", "ai-assisted", "ai-generated", "ai-observed"]
    }
  },
  "additionalProperties": false
}
```

### 0.4 — Create `schema/syllabus.schema.json`

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://github.com/p-n-ai/oss/schema/syllabus.schema.json",
  "title": "Syllabus",
  "description": "Top-level qualification or curriculum specification",
  "type": "object",
  "required": ["id", "name", "board", "level", "code", "version", "subjects"],
  "properties": {
    "id": {
      "type": "string",
      "description": "Unique syllabus identifier (e.g., malaysia-kssm-matematik-tingkatan1)"
    },
    "name": { "type": "string" },
    "board": {
      "type": "string",
      "description": "Curriculum board (e.g., malaysia, cambridge)"
    },
    "level": {
      "type": "string",
      "description": "Education level (e.g., kssm, igcse)"
    },
    "code": {
      "type": "string",
      "description": "Subject code or identifier"
    },
    "version": {
      "type": "string",
      "description": "Syllabus version or year range"
    },
    "subjects": {
      "type": "array",
      "items": { "type": "string" },
      "description": "List of subject IDs belonging to this syllabus"
    },
    "assessment": {
      "type": "object",
      "properties": {
        "components": {
          "type": "array",
          "items": {
            "type": "object",
            "required": ["name", "weight"],
            "properties": {
              "name": { "type": "string" },
              "weight": { "type": "number", "minimum": 0, "maximum": 1 },
              "duration_minutes": { "type": "integer", "minimum": 1 }
            },
            "additionalProperties": false
          }
        }
      },
      "additionalProperties": false
    },
    "grading": {
      "type": "object",
      "properties": {
        "scale": {
          "type": "array",
          "items": { "type": "string" }
        }
      },
      "additionalProperties": false
    }
  },
  "additionalProperties": false
}
```

### 0.5 — Create `schema/subject.schema.json`

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://github.com/p-n-ai/oss/schema/subject.schema.json",
  "title": "Subject",
  "description": "A subject grouping within a syllabus",
  "type": "object",
  "required": ["id", "name", "syllabus_id", "topics"],
  "properties": {
    "id": {
      "type": "string",
      "description": "Unique subject identifier"
    },
    "name": { "type": "string" },
    "syllabus_id": {
      "type": "string",
      "description": "Reference to parent syllabus"
    },
    "description": { "type": "string" },
    "topics": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Ordered list of topic IDs"
    }
  },
  "additionalProperties": false
}
```

### 0.6 — Create Form 1 Syllabus

**File:** `curricula/malaysia/kssm/matematik-tingkatan1/syllabus.yaml`

```yaml
id: malaysia-kssm-matematik-tingkatan1
name: "KSSM Matematik Tingkatan 1"
board: malaysia
level: kssm
code: matematik-tingkatan1
version: "2017"
subjects:
  - algebra

assessment:
  components:
    - name: "Pentaksiran Bilik Darjah (PBD)"
      weight: 1.0

grading:
  scale:
    - "Tahap Penguasaan 6 (Cemerlang)"
    - "Tahap Penguasaan 5 (Kepujian)"
    - "Tahap Penguasaan 4 (Baik)"
    - "Tahap Penguasaan 3 (Memuaskan)"
    - "Tahap Penguasaan 2 (Sederhana)"
    - "Tahap Penguasaan 1 (Lemah)"
```

### 0.7 — Create `.yamllint.yml`

**File:** `.yamllint.yml` (project root)

```yaml
extends: default

rules:
  line-length:
    max: 200
    allow-non-breakable-words: true
    allow-non-breakable-inline-mappings: true
  truthy:
    check-keys: false
  document-start: disable
  comments:
    min-spaces-from-content: 1
  indentation:
    spaces: 2
    indent-sequences: true
  empty-lines:
    max: 2
```

### 0.8 — Choose First 5 Topics (🧑 Education Lead)

The timeline specifies Form 1 Algebra (4 topics) + Form 2 topic 1:

| ID | Name (BM) | Name (EN) |
|----|-----------|-----------|
| F1-01 | Pemboleh ubah & Ungkapan Algebra | Variables & Algebraic Expressions |
| F1-02 | Persamaan Linear I | Linear Equations in One Variable |
| F1-03 | Ketaksamaan Linear I | Linear Inequalities (intro) |
| F1-04 | Pola & Jujukan | Patterns & Sequences (algebraic) |
| F2-01 | Ungkapan Algebra II | Expansion & Factorisation |

**Education Lead confirms or adjusts these topics before Day 1.**

### Day 0 Validation

```bash
# Verify directory structure
ls -R curricula/ schema/

# Lint the syllabus file
yamllint -c .yamllint.yml curricula/malaysia/kssm/matematik-tingkatan1/syllabus.yaml

# Validate syllabus against schema
ajv validate -s schema/syllabus.schema.json -d curricula/malaysia/kssm/matematik-tingkatan1/syllabus.yaml
```

### Day 0 Exit Criteria

- [ ] All directories created (`schema/`, `curricula/.../tingkatan1-3/`, `concepts/`, `taxonomy/`, `scripts/`, `.github/workflows/`)
- [ ] 4 schema files created: `topic`, `assessments`, `syllabus`, `subject`
- [ ] `.yamllint.yml` created and working
- [ ] Form 1 `syllabus.yaml` validates against schema
- [ ] First 5 topics confirmed by Education Lead

**Progress:** 0 topics | 0 assessments | 0 teaching notes | 4 schemas | 1 syllabus

---

## WEEK 1 — Form 1 Algebra Content

### Day 1 — Form 1 Topic Stubs + Teaching Notes

**Entry criteria:** Day 0 complete. Directory structure exists. Schemas validate.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 1.1 | Create Form 1 `algebra.yaml` subject | 🤖 | `curricula/.../tingkatan1/subjects/algebra.yaml` |
| 1.2 | Create F1-01 through F1-04 topic stubs | 🤖 | 4 files in `topics/algebra/` |
| 1.3 | Write F1-01 teaching notes | 🧑 | `01-ungkapan-algebra.teaching.md` |
| 1.4 | AI-draft teaching notes for F1-02 to F1-04, Education Lead reviews | 🧑🤖 | 3 `.teaching.md` files |

All paths below are relative to `curricula/malaysia/kssm/matematik-tingkatan1/`.

#### 1.1 — Create Subject File

**File:** `subjects/algebra.yaml`

```yaml
id: algebra
name: "Algebra"
syllabus_id: malaysia-kssm-matematik-tingkatan1
description: "Algebraic concepts for Form 1 KSSM Matematik including expressions, linear equations, inequalities, and patterns"
topics:
  - F1-01
  - F1-02
  - F1-03
  - F1-04
```

#### 1.2 — Create Topic YAML Stubs

Each topic file starts at Quality Level 1 (id, name, learning_objectives, prerequisites, difficulty, bloom_levels).

**File:** `topics/algebra/01-ungkapan-algebra.yaml`

```yaml
id: F1-01
name: "Pemboleh ubah & Ungkapan Algebra (Variables & Algebraic Expressions)"
subject_id: algebra
syllabus_id: malaysia-kssm-matematik-tingkatan1
difficulty: beginner
tier: core

learning_objectives:
  - id: LO1
    text: "Use letters to represent unknown quantities"
    bloom: remember
  - id: LO2
    text: "Recognise and describe algebraic terms, coefficients, and constants"
    bloom: understand
  - id: LO3
    text: "Form algebraic expressions from given situations"
    bloom: apply
  - id: LO4
    text: "Simplify algebraic expressions by collecting like terms"
    bloom: apply
  - id: LO5
    text: "Evaluate algebraic expressions by substituting values"
    bloom: apply

prerequisites:
  required: []
  recommended: []

bloom_levels:
  - remember
  - understand
  - apply

mastery:
  minimum_score: 0.75
  assessment_count: 3
  spaced_repetition:
    initial_interval_days: 3
    multiplier: 2.5

quality_level: 1
provenance: ai-generated
```

**File:** `topics/algebra/02-persamaan-linear-i.yaml`

```yaml
id: F1-02
name: "Persamaan Linear I (Linear Equations in One Variable)"
subject_id: algebra
syllabus_id: malaysia-kssm-matematik-tingkatan1
difficulty: beginner
tier: core

learning_objectives:
  - id: LO1
    text: "Recognise linear equations in one variable"
    bloom: understand
  - id: LO2
    text: "Form linear equations from given situations"
    bloom: apply
  - id: LO3
    text: "Solve linear equations in one variable"
    bloom: apply
  - id: LO4
    text: "Solve problems involving linear equations in one variable"
    bloom: apply

prerequisites:
  required:
    - F1-01
  recommended: []

bloom_levels:
  - understand
  - apply

mastery:
  minimum_score: 0.75
  assessment_count: 3
  spaced_repetition:
    initial_interval_days: 3
    multiplier: 2.5

quality_level: 1
provenance: ai-generated
```

**File:** `topics/algebra/03-ketaksamaan-linear-i.yaml`

```yaml
id: F1-03
name: "Ketaksamaan Linear I (Linear Inequalities — Introduction)"
subject_id: algebra
syllabus_id: malaysia-kssm-matematik-tingkatan1
difficulty: beginner
tier: core

learning_objectives:
  - id: LO1
    text: "Understand and use inequality symbols (>, <, ≥, ≤)"
    bloom: understand
  - id: LO2
    text: "Represent inequalities on a number line"
    bloom: apply
  - id: LO3
    text: "Form linear inequalities from given situations"
    bloom: apply

prerequisites:
  required:
    - F1-01
  recommended:
    - F1-02

bloom_levels:
  - understand
  - apply

mastery:
  minimum_score: 0.75
  assessment_count: 3
  spaced_repetition:
    initial_interval_days: 3
    multiplier: 2.5

quality_level: 1
provenance: ai-generated
```

**File:** `topics/algebra/04-pola-dan-jujukan.yaml`

```yaml
id: F1-04
name: "Pola & Jujukan (Patterns & Sequences — Algebraic Patterns)"
subject_id: algebra
syllabus_id: malaysia-kssm-matematik-tingkatan1
difficulty: beginner
tier: core

learning_objectives:
  - id: LO1
    text: "Recognise and describe patterns using algebraic expressions"
    bloom: understand
  - id: LO2
    text: "Determine specific terms of a sequence"
    bloom: apply
  - id: LO3
    text: "Express patterns as algebraic rules (nth term)"
    bloom: apply

prerequisites:
  required:
    - F1-01
  recommended: []

bloom_levels:
  - understand
  - apply

mastery:
  minimum_score: 0.75
  assessment_count: 3
  spaced_repetition:
    initial_interval_days: 3
    multiplier: 2.5

quality_level: 1
provenance: ai-generated
```

#### 1.3 — Write F1-01 Teaching Notes (🧑 Education Lead)

**File:** `topics/algebra/01-ungkapan-algebra.teaching.md`

The Education Lead writes this file with real teacher quality. Below is the expected structure:

```markdown
# Ungkapan Algebra (Algebraic Expressions) — Teaching Notes

## Overview
[Brief description of what this topic covers and why it matters in the KSSM curriculum]

## Prerequisites Check
- Students should be comfortable with basic arithmetic operations
- Understanding of the concept of "unknown" from primary school word problems

## Teaching Sequence

### 1. Introduction to Variables (15 min)
[How to introduce the concept of using letters for unknowns]
- Start with concrete examples: "Ali has some marbles..."
- Transition from "?" to using letters like x, y

### 2. Algebraic Terms and Coefficients (20 min)
[How to teach the vocabulary: term, coefficient, constant, variable]
- Use visual aids: algebra tiles or coloured cards

### 3. Forming Expressions (20 min)
[Translating word problems into algebraic expressions]
- Key phrases: "more than" → +, "less than" → −, "times" → ×

### 4. Simplifying by Collecting Like Terms (25 min)
[Teaching like terms and simplification]
- Common error: students try to add 3x + 2y = 5xy

### 5. Substitution (15 min)
[Evaluating expressions by replacing variables with numbers]

## Common Misconceptions

| Misconception | Why Students Think This | How to Address |
|---------------|------------------------|----------------|
| 3x + 2y = 5xy | Treating all terms as "combinable" | Use algebra tiles — different shapes can't combine |
| x always equals 1 | Confusion between coefficient and variable | Show x = 5, x = 10 examples |
| 2x means 2 and x (twenty-something) | Reading algebraically as a number | Explicitly show 2 × x notation first |

## Engagement Hooks
- "Secret code" activity: encode messages using algebraic substitution
- Real-world: mobile phone plan pricing (base cost + per-minute rate)

## Assessment Guidance
- Start with substitution (most concrete) before simplification
- Use a mix of numeric and word-problem formats
- Include "spot the error" questions for misconception remediation

## Bahasa Melayu Key Terms
| English | Bahasa Melayu |
|---------|---------------|
| Variable | Pemboleh ubah |
| Algebraic expression | Ungkapan algebra |
| Coefficient | Pekali |
| Constant | Pemalar |
| Like terms | Sebutan serupa |
| Unlike terms | Sebutan tidak serupa |
```

#### 1.4 — AI-Draft Teaching Notes for F1-02 to F1-04 (🧑🤖)

Create three more teaching notes following the same structure as F1-01:

- `topics/algebra/02-persamaan-linear-i.teaching.md`
- `topics/algebra/03-ketaksamaan-linear-i.teaching.md`
- `topics/algebra/04-pola-dan-jujukan.teaching.md`

**Process:**
1. AI generates draft following the template structure above
2. Education Lead reviews for KSSM accuracy, correct BM terminology, pedagogical soundness
3. Education Lead edits and approves

After teaching notes exist, update each topic YAML to add the `ai_teaching_notes` field:

```yaml
# Add to each topic file:
ai_teaching_notes: "01-ungkapan-algebra.teaching.md"  # relative path within topics/algebra/
```

#### Day 1 Validation

```bash
# Lint all YAML
yamllint -c .yamllint.yml curricula/

# Validate subject
ajv validate -s schema/subject.schema.json \
  -d curricula/malaysia/kssm/matematik-tingkatan1/subjects/algebra.yaml

# Validate all topic files
for f in curricula/malaysia/kssm/matematik-tingkatan1/topics/algebra/*.yaml; do
  ajv validate -s schema/topic.schema.json -d "$f"
done
```

#### Day 1 Exit Criteria

- [ ] `subjects/algebra.yaml` validates against subject schema
- [ ] 4 topic YAMLs (F1-01 through F1-04) validate against topic schema
- [ ] F1-01 teaching notes written by Education Lead
- [ ] F1-02, F1-03, F1-04 teaching notes drafted and reviewed
- [ ] All topic files reference their teaching notes via `ai_teaching_notes`

**Progress:** 4 topics | 0 assessments | 4 teaching notes | 4 schemas | 1 syllabus | 1 subject

---

### Day 2 — Form 1 Assessments

**Entry criteria:** Day 1 complete. 4 topic files + 4 teaching notes exist and validate.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 2.1 | Write F1-01 assessments (5 questions) | 🧑 | `01-ungkapan-algebra.assessments.yaml` |
| 2.2 | AI-generate assessments for F1-02 to F1-04 (5 each), Education Lead reviews | 🧑🤖 | 3 `.assessments.yaml` files |

#### 2.1 — F1-01 Assessment File (🧑 Education Lead)

**File:** `curricula/malaysia/kssm/matematik-tingkatan1/topics/algebra/01-ungkapan-algebra.assessments.yaml`

```yaml
topic_id: F1-01
provenance: human

questions:
  - id: Q1
    text: "If $x = 3$, find the value of $2x + 5$."
    difficulty: easy
    learning_objective: LO5
    answer:
      type: exact
      value: "11"
      working: |
        Substitute x = 3 into 2x + 5:
        = 2(3) + 5
        = 6 + 5
        = 11
    marks: 2
    rubric:
      - marks: 1
        criteria: "Correct substitution of x = 3"
      - marks: 1
        criteria: "Correct final answer"
    hints:
      - level: 1
        text: "Replace every x in the expression with the number 3"
      - level: 2
        text: "2x means 2 × x. So 2 × 3 = 6. Now add 5."
    distractors:
      - value: "235"
        feedback: "You wrote the numbers side by side instead of multiplying. Remember, 2x means 2 × x."
      - value: "10"
        feedback: "Check your multiplication: 2 × 3 = 6, not 5."

  - id: Q2
    text: "Simplify the expression: $3a + 2b + 5a - b$"
    difficulty: easy
    learning_objective: LO4
    answer:
      type: exact
      value: "8a + b"
      working: |
        Group like terms:
        3a + 5a = 8a
        2b - b = b
        Answer: 8a + b
    marks: 2
    rubric:
      - marks: 1
        criteria: "Correctly combines the 'a' terms"
      - marks: 1
        criteria: "Correctly combines the 'b' terms"
    hints:
      - level: 1
        text: "Group the terms with the same letter together"
      - level: 2
        text: "Add the a-terms: 3a + 5a = ? Then the b-terms: 2b - b = ?"
    distractors:
      - value: "8ab + b"
        feedback: "3a + 5a = 8a, not 8ab. You don't multiply the variables when adding."
      - value: "8a + 2b"
        feedback: "Check the b-terms again: 2b - b = b, not 2b."

  - id: Q3
    text: "Write an algebraic expression for: 'Aminah is $x$ years old. Her brother is 4 years older than her. What is her brother's age?'"
    difficulty: medium
    learning_objective: LO3
    answer:
      type: exact
      value: "x + 4"
      working: |
        Aminah's age = x
        Brother is 4 years older = x + 4
    marks: 2
    rubric:
      - marks: 1
        criteria: "Uses the variable x correctly"
      - marks: 1
        criteria: "Correct expression x + 4"
    hints:
      - level: 1
        text: "'Older' means we need to add to Aminah's age"
      - level: 2
        text: "Start with x (Aminah's age) and add 4"
    distractors:
      - value: "4x"
        feedback: "'4 years older' means adding 4, not multiplying by 4. The expression should be x + 4."

  - id: Q4
    text: "Identify the coefficient, variable, and constant in the expression: $7y + 3$"
    difficulty: easy
    learning_objective: LO2
    answer:
      type: free_text
      value: "Coefficient: 7, Variable: y, Constant: 3"
      working: |
        In the term 7y:
        - 7 is the coefficient (the number multiplying the variable)
        - y is the variable (the letter representing an unknown)
        In the term 3:
        - 3 is the constant (a number on its own, no variable)
    marks: 3
    rubric:
      - marks: 1
        criteria: "Correctly identifies 7 as the coefficient"
      - marks: 1
        criteria: "Correctly identifies y as the variable"
      - marks: 1
        criteria: "Correctly identifies 3 as the constant"
    hints:
      - level: 1
        text: "A coefficient is the number in front of a letter. A constant is a number with no letter."
      - level: 2
        text: "In 7y, the number 7 is called the coefficient. The letter y is the variable. The number 3 has no letter, so it is the constant."
    distractors: []

  - id: Q5
    text: |
      A rectangle has length $(2x + 3)$ cm and width $x$ cm.
      Write an expression for the perimeter of the rectangle.
      If $x = 5$, find the perimeter.
    difficulty: hard
    learning_objective: LO3
    answer:
      type: exact
      value: "6x + 6; 36 cm"
      working: |
        Perimeter = 2(length + width)
        = 2((2x + 3) + x)
        = 2(3x + 3)
        = 6x + 6

        When x = 5:
        = 6(5) + 6
        = 30 + 6
        = 36 cm
    marks: 4
    rubric:
      - marks: 1
        criteria: "Correct perimeter formula setup"
      - marks: 1
        criteria: "Correct algebraic simplification to 6x + 6"
      - marks: 1
        criteria: "Correct substitution of x = 5"
      - marks: 1
        criteria: "Correct final answer of 36 cm"
    hints:
      - level: 1
        text: "Perimeter of a rectangle = 2 × (length + width)"
      - level: 2
        text: "Length = 2x + 3, Width = x. So perimeter = 2 × ((2x + 3) + x). Simplify what's inside the bracket first."
    distractors:
      - value: "3x + 3"
        feedback: "That's length + width. For perimeter, you need to multiply by 2: perimeter = 2(length + width)."
```

#### 2.2 — AI-Draft Assessments for F1-02 to F1-04 (🧑🤖)

Create three more assessment files following the same structure:

- `topics/algebra/02-persamaan-linear-i.assessments.yaml`
- `topics/algebra/03-ketaksamaan-linear-i.assessments.yaml`
- `topics/algebra/04-pola-dan-jujukan.assessments.yaml`

**Requirements for each file:**
- `topic_id` must match the topic's `id` field
- 5 questions per file
- Difficulty spread: 2 easy, 2 medium, 1 hard
- Each question references a valid `learning_objective` from that topic
- All questions include `answer.working`, `rubric`, and at least 1 `hint`
- `provenance: ai-generated` (since AI drafts, educator reviews)

After creating assessments, update each topic YAML:

```yaml
# Add to each topic file:
assessments_file: "01-ungkapan-algebra.assessments.yaml"  # matching filename
```

#### Day 2 Validation

```bash
# Lint all YAML
yamllint -c .yamllint.yml curricula/

# Validate all assessments
for f in curricula/malaysia/kssm/matematik-tingkatan1/topics/algebra/*.assessments.yaml; do
  ajv validate -s schema/assessments.schema.json -d "$f"
done

# Re-validate topics (now updated with assessments_file references)
for f in curricula/malaysia/kssm/matematik-tingkatan1/topics/algebra/*.yaml; do
  [[ "$f" != *".assessments.yaml" ]] && ajv validate -s schema/topic.schema.json -d "$f"
done
```

#### Day 2 Exit Criteria

- [ ] 4 assessment files created (F1-01 through F1-04)
- [ ] Each file has 5 questions with rubrics and hints
- [ ] All assessment files validate against schema
- [ ] Topic files updated with `assessments_file` references
- [ ] F1-01 assessments written by Education Lead (provenance: human)
- [ ] F1-02 to F1-04 assessments reviewed by Education Lead

**Progress:** 4 topics | 20 questions | 4 teaching notes | 4 assessments | 4 schemas | 1 syllabus | 1 subject

---

### Day 3 — Validation Pipeline

**Entry criteria:** Day 2 complete. All content validates locally.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 3.1 | Create GitHub Actions `validate.yml` | 🤖 | `.github/workflows/validate.yml` |
| 3.2 | Create `scripts/validate.sh` | 🤖 | `scripts/validate.sh` |
| 3.3 | Run full validation, fix any failures | 🤖 | — |

#### 3.1 — GitHub Actions Workflow

**File:** `.github/workflows/validate.yml`

```yaml
name: Validate Curriculum
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install validators
        run: |
          npm install -g ajv-cli ajv-formats
          pip install yamllint

      - name: Lint YAML
        run: yamllint -c .yamllint.yml curricula/ concepts/ taxonomy/

      - name: Validate syllabus files
        run: |
          find curricula -name "syllabus.yaml" -print0 | \
            xargs -0 -I{} ajv validate -s schema/syllabus.schema.json -d {}

      - name: Validate subject files
        run: |
          find curricula -path "*/subjects/*.yaml" -print0 | \
            xargs -0 -I{} ajv validate -s schema/subject.schema.json -d {}

      - name: Validate topic files
        run: |
          find curricula -path "*/topics/*" -name "*.yaml" \
            ! -name "*.examples.yaml" ! -name "*.assessments.yaml" -print0 | \
            xargs -0 -I{} ajv validate -s schema/topic.schema.json -d {}

      - name: Validate assessment files
        run: |
          find curricula -name "*.assessments.yaml" -print0 | \
            xargs -0 -I{} ajv validate -s schema/assessments.schema.json -d {}

      - name: Validate example files
        run: |
          shopt -s nullglob
          files=$(find curricula -name "*.examples.yaml")
          if [ -n "$files" ]; then
            echo "$files" | xargs -I{} ajv validate -s schema/examples.schema.json -d {}
          else
            echo "No example files found (OK at this stage)"
          fi

      - name: Validate concept files
        run: |
          shopt -s nullglob
          files=$(find concepts -name "*.yaml" 2>/dev/null)
          if [ -n "$files" ]; then
            echo "$files" | xargs -I{} ajv validate -s schema/concept.schema.json -d {}
          else
            echo "No concept files found (OK at this stage)"
          fi

      - name: Validate taxonomy files
        run: |
          shopt -s nullglob
          files=$(find taxonomy -name "*.yaml" 2>/dev/null)
          if [ -n "$files" ]; then
            echo "$files" | xargs -I{} ajv validate -s schema/taxonomy.schema.json -d {}
          else
            echo "No taxonomy files found (OK at this stage)"
          fi
```

#### 3.2 — Local Validation Script

**File:** `scripts/validate.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

ERRORS=0

echo "=== OSS Curriculum Validation ==="
echo ""

# 1. YAML Lint
echo "--- YAML Lint ---"
if yamllint -c .yamllint.yml curricula/ concepts/ taxonomy/ 2>/dev/null; then
  echo -e "${GREEN}PASS${NC}: YAML lint"
else
  echo -e "${RED}FAIL${NC}: YAML lint"
  ERRORS=$((ERRORS + 1))
fi

# 2. Schema validation
echo ""
echo "--- Schema Validation ---"

validate_files() {
  local schema="$1"
  local pattern="$2"
  local label="$3"
  local count=0
  local fails=0

  while IFS= read -r -d '' file; do
    count=$((count + 1))
    if ! ajv validate -s "$schema" -d "$file" > /dev/null 2>&1; then
      echo -e "${RED}FAIL${NC}: $file"
      ajv validate -s "$schema" -d "$file" 2>&1 || true
      fails=$((fails + 1))
    fi
  done < <(eval "$pattern")

  if [ $count -eq 0 ]; then
    echo -e "${YELLOW}SKIP${NC}: No $label files found"
  elif [ $fails -eq 0 ]; then
    echo -e "${GREEN}PASS${NC}: $count $label file(s)"
  else
    echo -e "${RED}FAIL${NC}: $fails/$count $label file(s) failed"
    ERRORS=$((ERRORS + fails))
  fi
}

validate_files "schema/syllabus.schema.json" \
  "find curricula -name 'syllabus.yaml' -print0" "syllabus"

validate_files "schema/subject.schema.json" \
  "find curricula -path '*/subjects/*.yaml' -print0" "subject"

validate_files "schema/topic.schema.json" \
  "find curricula -path '*/topics/*' -name '*.yaml' ! -name '*.examples.yaml' ! -name '*.assessments.yaml' -print0" "topic"

validate_files "schema/assessments.schema.json" \
  "find curricula -name '*.assessments.yaml' -print0" "assessment"

validate_files "schema/examples.schema.json" \
  "find curricula -name '*.examples.yaml' -print0" "example"

validate_files "schema/concept.schema.json" \
  "find concepts -name '*.yaml' -print0 2>/dev/null" "concept"

validate_files "schema/taxonomy.schema.json" \
  "find taxonomy -name '*.yaml' -print0 2>/dev/null" "taxonomy"

# Summary
echo ""
echo "=== Summary ==="
if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}All validations passed!${NC}"
  exit 0
else
  echo -e "${RED}$ERRORS validation error(s) found${NC}"
  exit 1
fi
```

```bash
# Make executable
chmod +x scripts/validate.sh
```

#### 3.3 — Run Full Validation

```bash
./scripts/validate.sh
```

Fix any failures before proceeding.

#### Day 3 Exit Criteria

- [ ] `.github/workflows/validate.yml` created
- [ ] `scripts/validate.sh` created and executable
- [ ] Full validation passes locally with zero errors
- [ ] All existing content (1 syllabus, 1 subject, 4 topics, 4 assessments) validates

**Progress:** 4 topics | 20 questions | 4 teaching notes | 4 assessments | 4 schemas | 1 syllabus | 1 subject | 1 CI workflow | 1 validation script

---

### Day 4 — Form 2 Algebra Structure

**Entry criteria:** Day 3 complete. CI pipeline ready. All content validates.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 4.1 | Create Form 2 `syllabus.yaml` | 🤖 | `curricula/.../tingkatan2/syllabus.yaml` |
| 4.2 | Create Form 2 `subjects/algebra.yaml` | 🤖 | `curricula/.../tingkatan2/subjects/algebra.yaml` |
| 4.3 | Create F2-01 through F2-05 topic stubs | 🤖 | 5 files in `topics/algebra/` |
| 4.4 | Write F2-01 teaching notes | 🧑 | `01-ungkapan-algebra-ii.teaching.md` |
| 4.5 | AI-draft teaching notes for F2-02 to F2-03 | 🧑🤖 | 2 `.teaching.md` files |

All paths below are relative to `curricula/malaysia/kssm/matematik-tingkatan2/`.

#### 4.1 — Form 2 Syllabus

**File:** `syllabus.yaml`

Follow the same structure as Form 1 syllabus (see Day 0, task 0.6) with these values:
- `id: malaysia-kssm-matematik-tingkatan2`
- `name: "KSSM Matematik Tingkatan 2"`
- `code: matematik-tingkatan2`

#### 4.2 — Form 2 Subject

**File:** `subjects/algebra.yaml`

Follow the same structure as Form 1 subject (see Day 1, task 1.1) with:
- `syllabus_id: malaysia-kssm-matematik-tingkatan2`
- `topics: [F2-01, F2-02, F2-03, F2-04, F2-05]`

#### 4.3 — Form 2 Topic Stubs

Create 5 topic files at Quality Level 1. Key details:

| File | ID | Name (BM) | Prerequisites |
|------|----|-----------|---------------|
| `01-ungkapan-algebra-ii.yaml` | F2-01 | Ungkapan Algebra II (Expansion & Factorisation) | F1-01 (required) |
| `02-persamaan-linear-ii.yaml` | F2-02 | Persamaan Linear II (with brackets/fractions) | F1-02, F2-01 (required) |
| `03-persamaan-serentak.yaml` | F2-03 | Persamaan Serentak (Simultaneous Linear Equations) | F1-02, F2-02 (required) |
| `04-ketaksamaan-linear-ii.yaml` | F2-04 | Ketaksamaan Linear II (Solving Inequalities) | F1-03, F2-01 (required) |
| `05-pengenalan-pola-algebra.yaml` | F2-05 | Pengenalan Pola Algebra (Algebraic Patterns — Generalisation) | F1-04, F2-01 (required) |

Follow the topic YAML template from Day 1, task 1.2. Set `difficulty: intermediate` for all Form 2 topics. Ensure prerequisite links reference Form 1 topic IDs.

#### 4.4 & 4.5 — Teaching Notes

- 🧑 F2-01 (Expansion & Factorisation) is a key topic with highest misconception rate — Education Lead writes this one personally
- 🧑🤖 F2-02, F2-03 are AI-drafted, educator reviewed

Follow the teaching notes template from Day 1, task 1.3.

#### Day 4 Validation

```bash
# Full validation including Form 2
./scripts/validate.sh
```

#### Day 4 Exit Criteria

- [ ] Form 2 syllabus validates
- [ ] Form 2 subject validates with 5 topic references
- [ ] 5 topic YAMLs (F2-01 through F2-05) validate
- [ ] Prerequisites correctly link to Form 1 topic IDs
- [ ] F2-01 teaching notes written by Education Lead
- [ ] F2-02, F2-03 teaching notes drafted and reviewed

**Progress:** 9 topics | 20 questions | 7 teaching notes | 4 assessments | 4 schemas | 2 syllabi | 2 subjects

---

### Day 5 — Quality Review

**Entry criteria:** Day 4 complete. 9 topics across Forms 1 and 2.

#### Tasks

| # | Task | Owner |
|---|------|-------|
| 5.1 | Review all Week 1 content for KSSM accuracy | 🧑 |
| 5.2 | Fix any schema validation failures | 🤖 |

#### 5.1 — KSSM Accuracy Review (🧑 Education Lead)

**Review checklist:**

- [ ] All topic names use correct BM terminology matching KSSM textbooks
- [ ] Learning objectives align with KSSM Dokumen Standard Kurikulum dan Pentaksiran (DSKP)
- [ ] Prerequisite chains are logically sound (no Form 2 topic requires another Form 2 topic that comes later)
- [ ] Difficulty ratings make sense (Form 1 = beginner, Form 2 = intermediate)
- [ ] Bloom's taxonomy levels accurately reflect the cognitive demand
- [ ] Teaching notes use correct mathematical terminology in both BM and English
- [ ] Assessment questions are at appropriate difficulty for Malaysian secondary school students
- [ ] No copyrighted content from textbooks or past exam papers

#### 5.2 — Fix Validation Failures

```bash
./scripts/validate.sh
# Fix any errors, then re-run until clean
```

#### Day 5 Exit Criteria

- [ ] Education Lead has reviewed all 9 topics and signed off
- [ ] All validation passes with zero errors
- [ ] Any corrections from the review have been applied

**Week 1 Output:** 9 topic YAMLs (F1: 4, F2: 5), 7+ teaching notes, 20+ assessment questions. All pass CI.

**Progress:** 9 topics | 20 questions | 7 teaching notes | 4 assessments | 4 schemas | 2 syllabi | 2 subjects

---

## WEEK 2 — Form 2 & 3 Algebra + Assessments

### Day 6 — Form 2 Assessments + Remaining Notes

**Entry criteria:** Week 1 complete. 9 topics validated, Education Lead review done.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 6.1 | Write assessments for F2-01 through F2-03 (5 questions each) | 🧑 | 3 `.assessments.yaml` files |
| 6.2 | AI-draft teaching notes for F2-04, F2-05 | 🧑🤖 | 2 `.teaching.md` files |
| 6.3 | AI-draft assessments for F2-04, F2-05 | 🧑🤖 | 2 `.assessments.yaml` files |

#### Instructions

- Assessment files go in `curricula/malaysia/kssm/matematik-tingkatan2/topics/algebra/`
- Follow the assessment template from Day 2, task 2.1
- F2-01 assessments must test expansion and factorisation — include questions like "Expand 3(2x + 5)" and "Factorise 6x² + 9x"
- Update each topic YAML with `assessments_file` and `ai_teaching_notes` references
- After adding teaching notes + assessments, update `quality_level` to 2 for topics with both

#### Day 6 Validation

```bash
./scripts/validate.sh
```

#### Day 6 Exit Criteria

- [ ] 5 assessment files for Form 2 (F2-01 through F2-05)
- [ ] 25 new questions (5 per topic)
- [ ] Teaching notes for F2-04, F2-05 drafted and reviewed
- [ ] All topic files updated with file references

**Progress:** 9 topics | 45 questions | 9 teaching notes | 9 assessments | 4 schemas | 2 syllabi | 2 subjects

---

### Day 7 — Form 3 Algebra Structure

**Entry criteria:** Day 6 complete. Form 2 fully populated.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 7.1 | Create Form 3 `syllabus.yaml` + `subjects/algebra.yaml` | 🤖 | 2 files |
| 7.2 | Create F3-01 through F3-05 topic stubs | 🤖 | 5 files |
| 7.3 | Write F3-01 teaching notes | 🧑 | 1 `.teaching.md` |
| 7.4 | AI-draft teaching notes for F3-02 through F3-05 | 🧑🤖 | 4 `.teaching.md` files |

All paths below are relative to `curricula/malaysia/kssm/matematik-tingkatan3/`.

#### Form 3 Topic Details

| File | ID | Name (BM) | Prerequisites |
|------|----|-----------|---------------|
| `01-ungkapan-formula-algebra.yaml` | F3-01 | Ungkapan & Formula Algebra (Subject Change) | F2-01, F2-02 (required) |
| `02-persamaan-linear-dua-pemboleh-ubah.yaml` | F3-02 | Persamaan Linear Dua Pemboleh Ubah (Two Variables) | F2-02, F2-03 (required) |
| `03-persamaan-serentak-ii.yaml` | F3-03 | Persamaan Serentak II (Harder Simultaneous) | F2-03, F3-02 (required) |
| `04-ketaksamaan-linear-iii.yaml` | F3-04 | Ketaksamaan Linear III (Combined Inequalities) | F2-04 (required) |
| `05-indeks-dan-algebra.yaml` | F3-05 | Indeks & Algebra (Indices in Algebraic Expressions) | F2-01 (required) |

Set `difficulty: advanced` for all Form 3 topics.

#### Day 7 Validation

```bash
./scripts/validate.sh
```

#### Day 7 Exit Criteria

- [ ] Form 3 syllabus + subject validates
- [ ] 5 topic YAMLs (F3-01 through F3-05) validate
- [ ] Prerequisites correctly link to Form 2 topic IDs
- [ ] All 5 teaching notes created (F3-01 by Education Lead, others AI-drafted)

**Progress:** 14 topics | 45 questions | 14 teaching notes | 9 assessments | 4 schemas | 3 syllabi | 3 subjects

---

### Day 8 — Form 3 Assessments

**Entry criteria:** Day 7 complete. All 14 algebra topics exist.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 8.1 | Write assessments for F3-01 through F3-03 (5 questions each) | 🧑 | 3 `.assessments.yaml` files |
| 8.2 | AI-draft assessments for F3-04, F3-05 | 🧑🤖 | 2 `.assessments.yaml` files |

#### Instructions

- Assessment files go in `curricula/malaysia/kssm/matematik-tingkatan3/topics/algebra/`
- Form 3 questions should be harder — include multi-step problems
- F3-03 (Simultaneous Equations II) should include questions requiring both substitution and elimination methods
- Update each topic YAML with `assessments_file` reference

#### Day 8 Validation

```bash
./scripts/validate.sh
```

#### Day 8 Exit Criteria

- [ ] 5 assessment files for Form 3 (F3-01 through F3-05)
- [ ] 25 new questions (5 per topic)
- [ ] All assessment files validate

**Progress:** 14 topics | 70 questions | 14 teaching notes | 14 assessments | 4 schemas | 3 syllabi | 3 subjects

---

### Day 9 — Cross-Form Prerequisites + Concepts

**Entry criteria:** Day 8 complete. All 14 algebra topics with assessments.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 9.1 | Create `scripts/check-prerequisites.py` | 🤖 | `scripts/check-prerequisites.py` |
| 9.2 | Create `scripts/check-references.py` | 🤖 | `scripts/check-references.py` |
| 9.3 | Create `schema/concept.schema.json` | 🤖 | `schema/concept.schema.json` |
| 9.4 | Create `linear-equation.yaml` concept | 🤖 | `concepts/mathematics/linear-equation.yaml` |
| 9.5 | Create `algebraic-expression.yaml` concept | 🤖 | `concepts/mathematics/algebraic-expression.yaml` |
| 9.6 | Verify prerequisite chains | 🧑 | — |

#### 9.1 — Prerequisite Cycle Detection Script

**File:** `scripts/check-prerequisites.py`

This script should:
1. Walk all `curricula/**/topics/**/*.yaml` files (excluding `.examples.yaml` and `.assessments.yaml`)
2. Parse `prerequisites.required` from each topic
3. Build a directed graph of topic dependencies
4. Detect cycles using DFS (depth-first search)
5. Exit with code 1 if cycles found, 0 if clean
6. Print the full prerequisite chain for each form

```bash
chmod +x scripts/check-prerequisites.py
python3 scripts/check-prerequisites.py
```

#### 9.2 — Cross-Reference Integrity Script

**File:** `scripts/check-references.py`

This script should:
1. Collect all `id` fields from topic, subject, and syllabus files
2. For each topic, verify that `subject_id` references a valid subject
3. For each topic, verify that `syllabus_id` references a valid syllabus
4. For each subject, verify that all `topics[]` entries exist as topic IDs
5. For each syllabus, verify that all `subjects[]` entries exist as subject IDs
6. Verify that `ai_teaching_notes`, `examples_file`, `assessments_file` paths point to existing files
7. Exit with code 1 if broken references found

```bash
chmod +x scripts/check-references.py
python3 scripts/check-references.py
```

#### 9.3 — Concept Schema

**File:** `schema/concept.schema.json`

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://github.com/p-n-ai/oss/schema/concept.schema.json",
  "title": "Concept",
  "description": "A cross-curriculum concept bridging equivalent topics across different syllabi",
  "type": "object",
  "required": ["id", "name", "domain", "subdomain", "definition", "curricula"],
  "properties": {
    "id": { "type": "string" },
    "name": { "type": "string" },
    "domain": { "type": "string" },
    "subdomain": { "type": "string" },
    "definition": { "type": "string" },
    "curricula": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["syllabus", "topic", "scope"],
        "properties": {
          "syllabus": { "type": "string" },
          "topic": { "type": "string" },
          "scope": { "type": "string" }
        },
        "additionalProperties": false
      }
    }
  },
  "additionalProperties": false
}
```

#### 9.4 — Linear Equation Concept

**File:** `concepts/mathematics/linear-equation.yaml`

```yaml
id: linear-equation
name: "Linear Equation"
domain: mathematics
subdomain: algebra
definition: "An equation of degree 1 in the form ax + b = c, where a ≠ 0"

curricula:
  - syllabus: malaysia-kssm-matematik-tingkatan1
    topic: F1-02
    scope: "Linear equations in one variable, basic solving"
  - syllabus: malaysia-kssm-matematik-tingkatan2
    topic: F2-02
    scope: "Linear equations with brackets and fractions"
  - syllabus: malaysia-kssm-matematik-tingkatan3
    topic: F3-02
    scope: "Linear equations in two variables"
```

#### 9.5 — Algebraic Expression Concept

**File:** `concepts/mathematics/algebraic-expression.yaml`

```yaml
id: algebraic-expression
name: "Algebraic Expression"
domain: mathematics
subdomain: algebra
definition: "A mathematical phrase containing variables, constants, and operations but no equality sign"

curricula:
  - syllabus: malaysia-kssm-matematik-tingkatan1
    topic: F1-01
    scope: "Basic expressions, like terms, simplification"
  - syllabus: malaysia-kssm-matematik-tingkatan2
    topic: F2-01
    scope: "Expansion and factorisation of expressions"
  - syllabus: malaysia-kssm-matematik-tingkatan3
    topic: F3-01
    scope: "Algebraic formulae and changing the subject"
```

#### 9.6 — Prerequisite Chain Verification (🧑 Education Lead)

The Education Lead should verify:
- [ ] A Form 1 student completing F1-01 → F1-02 → F1-03 → F1-04 is a logical sequence
- [ ] Form 2 topics correctly assume Form 1 mastery
- [ ] Form 3 topics correctly assume Form 2 mastery
- [ ] No topic has a prerequisite that is harder than itself
- [ ] The prerequisite graph has no cycles (confirmed by script)

#### Day 9 Validation

```bash
./scripts/validate.sh
python3 scripts/check-prerequisites.py
python3 scripts/check-references.py
```

#### Day 9 Exit Criteria

- [ ] `check-prerequisites.py` runs with no cycles detected
- [ ] `check-references.py` runs with no broken references
- [ ] 2 concept files validate against concept schema
- [ ] Education Lead confirms prerequisite chains are pedagogically sound

**Progress:** 14 topics | 70 questions | 14 teaching notes | 14 assessments | 5 schemas | 3 syllabi | 3 subjects | 2 concepts | 3 scripts

---

### Day 10 — Quality Audit

**Entry criteria:** Day 9 complete. All cross-form validation passes.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 10.1 | Create `scripts/assess-quality.py` | 🤖 | `scripts/assess-quality.py` |
| 10.2 | Add quality report to CI | 🤖 | Update `validate.yml` |
| 10.3 | Full quality audit | 🧑 | — |

#### 10.1 — Quality Assessment Script

**File:** `scripts/assess-quality.py`

This script should:
1. Walk all topic YAML files
2. For each topic, determine quality level based on present fields:
   - Level 0: has `id`, `name`, `learning_objectives`
   - Level 1: + `prerequisites`, `difficulty`, `bloom_levels`
   - Level 2: + `teaching.sequence`, `teaching.common_misconceptions`, `engagement_hooks` (inside teaching notes)
   - Level 3: + `ai_teaching_notes` file exists, `examples_file` exists, `assessments_file` exists
   - Level 4: + translation file exists, `cross_curriculum` has entries, peer-reviewed
   - Level 5: + curriculum authority validation
3. Compare with claimed `quality_level` in the YAML
4. Flag topics claiming higher than actual
5. Print summary report

Usage: `python3 scripts/assess-quality.py --report`

#### 10.2 — Update CI Workflow

Add the prerequisite, reference, and quality checks to `.github/workflows/validate.yml`:

```yaml
      - name: Check prerequisite cycles
        run: python3 scripts/check-prerequisites.py

      - name: Check cross-references
        run: python3 scripts/check-references.py

      - name: Quality level report
        run: python3 scripts/assess-quality.py --report
```

#### 10.3 — Quality Audit (🧑 Education Lead)

Review the quality report output. For each of the 14 algebra topics:
- [ ] Is the topic at Quality Level 2 or higher? (must have teaching notes + assessments by now)
- [ ] Are teaching notes pedagogically sound?
- [ ] Are assessment questions at appropriate difficulty?
- [ ] Fix any topics below Level 2

**Note:** Topics cannot reach Level 3 until examples are added (Week 3).

#### Day 10 Exit Criteria

- [ ] Quality assessment script works and produces accurate report
- [ ] CI workflow updated with all 5 validation steps
- [ ] All 14 algebra topics at Quality Level 2+
- [ ] Education Lead has reviewed quality report and addressed gaps

**Week 2 Output:** All 14 Algebra topics complete (F1:4 + F2:5 + F3:5). 70+ assessment questions. Prerequisite chain validated across 3 forms. Quality Level ≥2 for all topics.

**Progress:** 14 topics | 70 questions | 14 teaching notes | 14 assessments | 5 schemas | 3 syllabi | 3 subjects | 2 concepts | 4 scripts

---

## WEEK 3 — Worked Examples + Malay Translations

### Day 11 — Examples Schema + Form 1 Examples

**Entry criteria:** Week 2 complete. All 14 algebra topics at Quality Level 2+.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 11.1 | Create `schema/examples.schema.json` | 🤖 | `schema/examples.schema.json` |
| 11.2 | Create worked examples for F1-01 through F1-04 (3 examples each) | 🧑🤖 | 4 `.examples.yaml` files |

#### 11.1 — Examples Schema

**File:** `schema/examples.schema.json`

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://github.com/p-n-ai/oss/schema/examples.schema.json",
  "title": "Examples",
  "description": "Worked examples with step-by-step solutions for a topic",
  "type": "object",
  "required": ["topic_id", "examples", "provenance"],
  "properties": {
    "topic_id": { "type": "string" },
    "examples": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["id", "title", "difficulty", "problem", "steps", "final_answer"],
        "properties": {
          "id": {
            "type": "string",
            "pattern": "^E[0-9]+$"
          },
          "title": { "type": "string" },
          "difficulty": {
            "type": "string",
            "enum": ["easy", "medium", "hard"]
          },
          "problem": { "type": "string" },
          "steps": {
            "type": "array",
            "minItems": 1,
            "items": {
              "type": "object",
              "required": ["step", "explanation"],
              "properties": {
                "step": { "type": "string" },
                "explanation": { "type": "string" }
              },
              "additionalProperties": false
            }
          },
          "final_answer": { "type": "string" },
          "learning_objective": {
            "type": "string",
            "description": "References a learning objective ID from the topic"
          },
          "common_error": {
            "type": "string",
            "description": "A common mistake students make on this type of problem"
          }
        },
        "additionalProperties": false
      }
    },
    "provenance": {
      "type": "string",
      "enum": ["human", "ai-assisted", "ai-generated", "ai-observed"]
    }
  },
  "additionalProperties": false
}
```

#### 11.2 — Form 1 Worked Examples

Create example files for each Form 1 topic. 3 examples per file (easy, medium, hard).

**File:** `curricula/malaysia/kssm/matematik-tingkatan1/topics/algebra/01-ungkapan-algebra.examples.yaml`

```yaml
topic_id: F1-01
provenance: ai-assisted

examples:
  - id: E1
    title: "Identifying Algebraic Terms"
    difficulty: easy
    problem: "List the terms, coefficients, and constants in the expression $4x + 7y - 3$"
    learning_objective: LO2
    steps:
      - step: "Identify each term separated by + or −"
        explanation: "The terms are: 4x, 7y, and −3"
      - step: "Find the coefficient of each variable term"
        explanation: "The coefficient of x is 4. The coefficient of y is 7."
      - step: "Identify constants (terms without variables)"
        explanation: "−3 is the constant (it has no variable attached)"
    final_answer: "Terms: 4x, 7y, −3. Coefficients: 4, 7. Constant: −3"

  - id: E2
    title: "Simplifying by Collecting Like Terms"
    difficulty: medium
    problem: "Simplify: $5a + 3b - 2a + 4b - 1$"
    learning_objective: LO4
    steps:
      - step: "Group like terms together"
        explanation: "a-terms: 5a and −2a. b-terms: 3b and 4b. Constants: −1"
      - step: "Combine the a-terms"
        explanation: "5a − 2a = 3a"
      - step: "Combine the b-terms"
        explanation: "3b + 4b = 7b"
      - step: "Write the simplified expression"
        explanation: "3a + 7b − 1"
    final_answer: "3a + 7b − 1"
    common_error: "Students often write 5a + 3b = 8ab, incorrectly combining unlike terms"

  - id: E3
    title: "Forming and Evaluating Expressions"
    difficulty: hard
    problem: |
      A taxi charges RM$(3 + 2d)$ where $d$ is the distance in km.
      (a) Write the expression for the cost of travelling $d$ km.
      (b) Find the cost for a 12 km journey.
    learning_objective: LO3
    steps:
      - step: "Identify the expression"
        explanation: "Cost = 3 + 2d (RM3 base fare plus RM2 per km)"
      - step: "Substitute d = 12"
        explanation: "Cost = 3 + 2(12)"
      - step: "Calculate"
        explanation: "Cost = 3 + 24 = 27"
    final_answer: "(a) Cost = 3 + 2d. (b) RM27"
    common_error: "Students may write 3 + 2(12) = 3 + 212 = 215, forgetting to multiply"
```

After creating examples, update each topic YAML to add `examples_file` and bump `quality_level` to 3 (since they now have teaching notes + examples + assessments):

```yaml
examples_file: "01-ungkapan-algebra.examples.yaml"
quality_level: 3
```

Create similar example files for F1-02, F1-03, F1-04 with 3 examples each.

#### Day 11 Exit Criteria

- [ ] Examples schema created and validates
- [ ] 4 example files for Form 1 (12 worked examples total)
- [ ] All Form 1 topics updated to Quality Level 3
- [ ] All validation passes

**Progress:** 14 topics | 70 questions | 14 teaching notes | 14 assessments | 12 examples | 6 schemas | 3 syllabi | 3 subjects | 2 concepts

---

### Day 12 — Form 2 & 3 Examples

**Entry criteria:** Day 11 complete. Examples schema exists.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 12.1 | Create worked examples for F2-01 through F2-05 (3 each) | 🧑🤖 | 5 `.examples.yaml` files |
| 12.2 | Create worked examples for F3-01 through F3-05 (3 each) | 🧑🤖 | 5 `.examples.yaml` files |

Follow the examples template from Day 11. After creating all examples, update all topic files with `examples_file` and set `quality_level: 3`.

#### Day 12 Exit Criteria

- [ ] 10 example files created (30 worked examples)
- [ ] All 14 algebra topics now at Quality Level 3 (Teachable)
- [ ] All validation passes

**Progress:** 14 topics (all Level 3) | 70 questions | 14 teaching notes | 14 assessments | 42 examples | 6 schemas

---

### Day 13 — Malay Translation Structure

**Entry criteria:** Day 12 complete. All 14 topics at Quality Level 3.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 13.1 | Create `locales/ms/` directory structure for all 3 forms | 🤖 | Directories |
| 13.2 | Translate Form 1 topic names, LOs, misconceptions to BM | 🧑🤖 | 4 translation files |
| 13.3 | Translate Form 1 teaching notes to BM | 🧑🤖 | 4 `.teaching.md` files |

#### 13.1 — Directory Structure

```bash
# Form 1 translations
mkdir -p curricula/malaysia/kssm/matematik-tingkatan1/locales/ms/topics/algebra
# Form 2 translations
mkdir -p curricula/malaysia/kssm/matematik-tingkatan2/locales/ms/topics/algebra
# Form 3 translations
mkdir -p curricula/malaysia/kssm/matematik-tingkatan3/locales/ms/topics/algebra
```

#### 13.2 — Translation File Format

Translation files contain ONLY translatable fields. Non-translatable fields inherit from source.

**File:** `curricula/malaysia/kssm/matematik-tingkatan1/locales/ms/topics/algebra/01-ungkapan-algebra.yaml`

```yaml
# Translation of F1-01 to Bahasa Melayu
# Non-translatable fields (id, difficulty, prerequisites, mastery) inherit from source

name: "Pemboleh ubah & Ungkapan Algebra"

learning_objectives:
  - id: LO1
    text: "Menggunakan huruf untuk mewakili kuantiti yang tidak diketahui"
  - id: LO2
    text: "Mengenal pasti dan menerangkan sebutan algebra, pekali, dan pemalar"
  - id: LO3
    text: "Membentuk ungkapan algebra daripada situasi yang diberikan"
  - id: LO4
    text: "Memudahkan ungkapan algebra dengan mengumpul sebutan serupa"
  - id: LO5
    text: "Menilai ungkapan algebra dengan menggantikan nilai"
```

#### Day 13 Exit Criteria

- [ ] `locales/ms/` directories created for all 3 forms
- [ ] 4 Form 1 translation files created
- [ ] 4 Form 1 teaching notes translated to BM

**Progress:** 14 topics | 70 questions | 14 teaching notes | 14 assessments | 42 examples | 4 translations | 6 schemas

---

### Day 14 — Form 2 & 3 Translations

**Entry criteria:** Day 13 complete. Form 1 translations done.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 14.1 | Translate Form 2 topics + teaching notes to BM | 🧑🤖 | 5 translation files + 5 teaching notes |
| 14.2 | Translate Form 3 topics + teaching notes to BM | 🧑🤖 | 5 translation files + 5 teaching notes |
| 14.3 | Native speaker review of all BM translations | 🧑 | — |

#### 14.3 — BM Translation Review (🧑 Education Lead)

Review checklist:
- [ ] Mathematical terminology matches KSSM textbook terminology
- [ ] Bahasa Melayu is natural, not machine-translation quality
- [ ] Key terms: pemboleh ubah (variable), pekali (coefficient), pemalar (constant), sebutan (term), ungkapan (expression), persamaan (equation), ketaksamaan (inequality)
- [ ] Teaching notes read naturally in BM

#### Day 14 Exit Criteria

- [ ] All 14 translation files created
- [ ] All 14 teaching notes translated
- [ ] Native speaker review complete

**Progress:** 14 topics | 70 questions | 14 teaching notes | 14 assessments | 42 examples | 14 translations | 6 schemas

---

### Day 15 — Taxonomy + Documentation

**Entry criteria:** Day 14 complete. All translations reviewed.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 15.1 | Create `schema/taxonomy.schema.json` | 🤖 | `schema/taxonomy.schema.json` |
| 15.2 | Create `taxonomy/mathematics/algebra.yaml` | 🤖 | 1 file |
| 15.3 | Update CONTRIBUTING.md and README.md | 🤖 | Updates |

#### 15.1 — Taxonomy Schema

**File:** `schema/taxonomy.schema.json`

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://github.com/p-n-ai/oss/schema/taxonomy.schema.json",
  "title": "Taxonomy",
  "description": "Subject area classification hierarchy",
  "type": "object",
  "required": ["id", "name", "domain", "subtopics"],
  "properties": {
    "id": { "type": "string" },
    "name": { "type": "string" },
    "domain": { "type": "string" },
    "subtopics": {
      "type": "array",
      "items": { "type": "string" }
    }
  },
  "additionalProperties": false
}
```

#### 15.2 — Algebra Taxonomy

**File:** `taxonomy/mathematics/algebra.yaml`

```yaml
id: algebra
name: "Algebra"
domain: mathematics
subtopics:
  - "Algebraic Expressions"
  - "Linear Equations"
  - "Simultaneous Equations"
  - "Linear Inequalities"
  - "Algebraic Formulae"
  - "Algebraic Patterns & Sequences"
  - "Indices in Algebra"
  - "Expansion & Factorisation"
```

#### Day 15 Exit Criteria

- [ ] Taxonomy schema created
- [ ] Algebra taxonomy file validates
- [ ] All 7 schemas now exist
- [ ] CONTRIBUTING.md updated to reflect current state
- [ ] README.md updated to reflect current state

**Week 3 Output:** 42 worked examples. Malay translations for all 14 topics. Taxonomy defined. All 7 schemas complete.

**Progress:** 14 topics | 70 questions | 14 teaching notes | 14 assessments | 42 examples | 14 translations | 7 schemas | 1 taxonomy | 3 syllabi | 3 subjects | 2 concepts

---

## WEEK 4 — Non-Algebra Topic Stubs + Quality

### Days 16-17 — Form 1 Non-Algebra Topics

**Entry criteria:** Week 3 complete. All 7 schemas exist.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 16.1 | Create non-algebra subjects for Form 1: `numbers.yaml`, `measurement.yaml`, `statistics.yaml` | 🤖 | 3 subject files |
| 16.2 | Create Level 0-1 topic stubs for Form 1 non-algebra (8-10 topics) | 🤖 | 8-10 topic files |
| 16.3 | Elevate 3 high-priority topics to Level 2 | 🧑🤖 | Updates + 3 teaching notes |

#### Form 1 Non-Algebra Topics (Suggested)

| Subject | Topic | Difficulty |
|---------|-------|------------|
| numbers | Rational Numbers | beginner |
| numbers | Integers | beginner |
| numbers | Fractions, Decimals & Percentages | beginner |
| numbers | Squares, Cubes & Roots | beginner |
| measurement | Perimeter & Area | beginner |
| measurement | Ratio, Rate & Proportion | beginner |
| statistics | Data Handling & Representation | beginner |
| statistics | Basic Probability | beginner |

Create topic files at Quality Level 0-1. Follow the topic YAML template from Day 1 but with minimal fields (id, name, subject_id, syllabus_id, difficulty, learning_objectives, quality_level, provenance).

Update the Form 1 `syllabus.yaml` to add new subjects and `subjects/algebra.yaml` is unchanged.

#### Days 16-17 Exit Criteria

- [ ] 3 new subject files for Form 1
- [ ] 8-10 non-algebra topic stubs created
- [ ] 3 topics elevated to Level 2 with teaching notes
- [ ] Form 1 syllabus updated with new subjects
- [ ] All validation passes

**Progress:** 22-24 topics | 70 questions | 17 teaching notes | 14 assessments | 42 examples | 14 translations | 7 schemas

---

### Day 18 — Form 2 & 3 Non-Algebra Topics

**Entry criteria:** Days 16-17 complete. Form 1 non-algebra stubs exist.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 18.1 | Create Level 0-1 stubs for Form 2 non-algebra (8-10 topics) | 🤖 | 8-10 topic files |
| 18.2 | Create Level 0-1 stubs for Form 3 non-algebra (8-10 topics) | 🤖 | 8-10 topic files |
| 18.3 | Verify all prerequisite links across algebra and non-algebra | 🧑 | — |

Create appropriate subjects (numbers, geometry, statistics, measurement) for Forms 2 and 3. Update syllabi to include new subjects.

#### Day 18 Exit Criteria

- [ ] 16-20 more non-algebra topic stubs (Forms 2 + 3)
- [ ] Syllabi updated for all 3 forms
- [ ] Prerequisite links verified by Education Lead
- [ ] All validation passes

**Progress:** ~40 topics | 70 questions | 17 teaching notes | 14 assessments | 42 examples | 14 translations | 7 schemas

---

### Days 19-20 — More Assessments + Quality

**Entry criteria:** Day 18 complete. ~40 topics across 3 forms.

#### Tasks

| # | Task | Owner |
|---|------|-------|
| 19.1 | Add 5 MORE assessment questions per Algebra topic (total: 10/topic) | 🧑 |
| 19.2 | Add harder "exam-style" questions for Form 3 (PT3 format) | 🧑 |
| 20.1 | Run full quality report | 🤖 |
| 20.2 | Ensure ALL 14 Algebra topics at Quality Level 3+ | 🧑 |

#### Quality Report Output

```bash
python3 scripts/assess-quality.py --report
```

Expected output:
```
=== Quality Level Report ===
Level 5 (Gold):      0 topics
Level 4 (Complete):  0 topics
Level 3 (Teachable): 14 topics (all Algebra)
Level 2 (Structured): 3 topics
Level 1 (Basic):     5-7 topics
Level 0 (Stub):      ~15 topics
Total: ~40 topics
```

#### Days 19-20 Exit Criteria

- [ ] 140+ assessment questions (10 per algebra topic)
- [ ] PT3-style questions for Form 3
- [ ] Quality report generated
- [ ] All 14 algebra topics confirmed at Level 3+

**Week 4 Output:** ~25 non-algebra topic stubs. 140+ algebra assessment questions. Full quality report.

**Progress:** ~40 topics | 140 questions | 17 teaching notes | 14 assessments | 42 examples | 14 translations | 7 schemas

---

## WEEK 5 — Open Source Prep

### Days 21-22 — Documentation + Tooling

**Entry criteria:** Week 4 complete. 140+ assessment questions. Quality report clean.

#### Tasks

| # | Task | Owner | Files Created |
|---|------|-------|---------------|
| 21.1 | Create 10+ "good first issues" on GitHub | 🤖 | GitHub issues |
| 21.2 | Create CODEOWNERS file | 🤖 | `.github/CODEOWNERS` |
| 21.3 | Create issue templates | 🤖 | `.github/ISSUE_TEMPLATE/*.md` |
| 22.1 | Create `scripts/export-sqlite.py` | 🤖 | `scripts/export-sqlite.py` |
| 22.2 | Add SQLite export to release workflow | 🤖 | `.github/workflows/release.yml` |

#### 21.2 — CODEOWNERS

**File:** `.github/CODEOWNERS`

```
# Education Lead auto-assigned on all content PRs
curricula/ @education-lead
concepts/ @education-lead
taxonomy/ @education-lead

# Schema changes require dev review
schema/ @dev-lead

# Script changes require dev review
scripts/ @dev-lead
```

#### 21.3 — Issue Templates

Create 4 templates in `.github/ISSUE_TEMPLATE/`:

1. `new-topic.md` — Request to add a new topic
2. `improve-content.md` — Improve existing teaching notes, assessments, or examples
3. `translation.md` — Add or improve a translation
4. `bug-report.md` — Report a schema validation error or content issue

Each template should use GitHub's issue template format with appropriate labels.

#### 21.1 — Good First Issues

Create issues for community contributors:

1. "Add teaching notes for [stub topic]" (5-6 issues)
2. "Translate Form 1 topics to Chinese (zh)" (1 issue)
3. "Translate Form 1 topics to Tamil (ta)" (1 issue)
4. "Add 2 more worked examples for F1-03" (1 issue)
5. "Improve assessment hints for F2-01" (1 issue)
6. "Add BM-only assessment questions for F1-01" (1 issue)

Label all with `good first issue` and `help wanted`.

#### Days 21-22 Exit Criteria

- [ ] 10+ GitHub issues created with `good first issue` label
- [ ] CODEOWNERS file created
- [ ] 4 issue templates created
- [ ] SQLite export script works
- [ ] Release workflow created

**Progress:** All content unchanged. Infrastructure additions: CODEOWNERS, issue templates, export script, release workflow.

---

### Day 23 — Final Validation

**Entry criteria:** Days 21-22 complete. All tooling in place.

#### Tasks

| # | Task | Owner |
|---|------|-------|
| 23.1 | Run FULL CI pipeline locally: yamllint + ajv + prerequisites + references + quality | 🤖 |
| 23.2 | Final read-through of every teaching note and assessment | 🧑 |

```bash
# Full validation suite
./scripts/validate.sh
python3 scripts/check-prerequisites.py
python3 scripts/check-references.py
python3 scripts/assess-quality.py --report
```

All must pass with zero errors.

#### Day 23 Exit Criteria

- [ ] Full CI passes locally
- [ ] Education Lead has read every teaching note
- [ ] Education Lead has reviewed every assessment question
- [ ] No content corrections needed (or all corrections applied)

---

### Days 24-25 — Pre-Launch

**Entry criteria:** Day 23 complete. All validation green.

#### Tasks

| # | Task | Owner |
|---|------|-------|
| 24.1 | Tag v0.1.0 release | 🤖 |
| 25.1 | Prepare curriculum section of launch blog | 🧑 |

#### 24.1 — Tag Release

```bash
git tag -a v0.1.0 -m "First public release: KSSM Matematik F1-F3 Algebra (14 topics at Level 3+)"
git push origin v0.1.0
```

This triggers the release workflow which generates the SQLite export as a downloadable asset.

#### Days 24-25 Exit Criteria

- [ ] v0.1.0 tagged and pushed
- [ ] Release appears on GitHub with SQLite download
- [ ] Launch blog draft ready

**Week 5 Output:** Repo public-ready. v0.1.0 tagged. 10+ good first issues. SQLite export available.

---

## WEEK 6 — Launch + Community

### Day 26 — Launch Day

| # | Task | Owner |
|---|------|-------|
| 26.1 | Publish repo publicly | 🧑 |
| 26.2 | Announce in Malaysian teacher communities | 🧑 |

### Days 27-28 — Community Response

| # | Task | Owner |
|---|------|-------|
| 27.1 | Respond to every issue and PR within 24 hours | 🧑 |
| 28.1 | Identify most-requested additional content | 🧑 |

### Days 29-30 — First Community Contributions

| # | Task | Owner |
|---|------|-------|
| 29.1 | Review and merge first community PRs | 🧑 |
| 30.1 | Write curriculum section of 6-week report | 🧑 |

**Week 6 is primarily community engagement (🧑 Human tasks).**

---

## Appendix A — Complete Schema Reference

All 7 schemas are defined inline in the guide at the point of first creation:

| Schema | Created On | Section |
|--------|-----------|---------|
| `topic.schema.json` | Day 0 | Task 0.2 |
| `assessments.schema.json` | Day 0 | Task 0.3 |
| `syllabus.schema.json` | Day 0 | Task 0.4 |
| `subject.schema.json` | Day 0 | Task 0.5 |
| `concept.schema.json` | Day 9 | Task 9.3 |
| `examples.schema.json` | Day 11 | Task 11.1 |
| `taxonomy.schema.json` | Day 15 | Task 15.1 |

---

## Appendix B — Content Templates

### Topic Template (Quality Level 1)

```yaml
id: "XX-NN"              # e.g., F1-01, F2-03
name: "Name (BM) (English Description)"
subject_id: algebra       # or numbers, measurement, statistics, geometry
syllabus_id: malaysia-kssm-matematik-tingkatanN
difficulty: beginner      # beginner | intermediate | advanced
tier: core                # core | extended

learning_objectives:
  - id: LO1
    text: "First learning objective"
    bloom: understand     # remember | understand | apply | analyze | evaluate | create

prerequisites:
  required: []            # Topic IDs that must be mastered
  recommended: []         # Topic IDs that help but aren't required

bloom_levels:
  - understand
  - apply

mastery:
  minimum_score: 0.75
  assessment_count: 3
  spaced_repetition:
    initial_interval_days: 3
    multiplier: 2.5

quality_level: 1
provenance: ai-generated  # human | ai-assisted | ai-generated | ai-observed
```

### Assessment Template

```yaml
topic_id: "XX-NN"
provenance: ai-generated

questions:
  - id: Q1
    text: "Question text here. Supports $LaTeX$ notation."
    difficulty: easy       # easy | medium | hard
    learning_objective: LO1
    answer:
      type: exact          # exact | range | multiple_choice | free_text
      value: "correct answer"
      working: |
        Step-by-step solution
        Line 2
    marks: 2
    rubric:
      - marks: 1
        criteria: "First mark criterion"
      - marks: 1
        criteria: "Second mark criterion"
    hints:
      - level: 1
        text: "Gentle nudge"
      - level: 2
        text: "More explicit help"
    distractors:
      - value: "common wrong answer"
        feedback: "Targeted feedback explaining the error"
```

### Teaching Notes Template

```markdown
# Topic Name — Teaching Notes

## Overview
[Brief description]

## Prerequisites Check
[What students should know before starting]

## Teaching Sequence

### 1. Section Title (XX min)
[Teaching instructions]

### 2. Section Title (XX min)
[Teaching instructions]

## Common Misconceptions

| Misconception | Why Students Think This | How to Address |
|---------------|------------------------|----------------|
| ... | ... | ... |

## Engagement Hooks
- [Real-world connection 1]
- [Real-world connection 2]

## Assessment Guidance
[Tips for assessing understanding]

## Bahasa Melayu Key Terms
| English | Bahasa Melayu |
|---------|---------------|
| ... | ... |
```

### Examples Template

```yaml
topic_id: "XX-NN"
provenance: ai-assisted

examples:
  - id: E1
    title: "Example title"
    difficulty: easy
    problem: "Problem statement"
    learning_objective: LO1
    steps:
      - step: "Mathematical step"
        explanation: "Why we do this"
    final_answer: "The answer"
    common_error: "What students often get wrong"
```

### Translation Template

```yaml
# Translation of XX-NN to [Language]
# Non-translatable fields inherit from source

name: "Translated name"

learning_objectives:
  - id: LO1
    text: "Translated learning objective"
```

### Concept Template

```yaml
id: concept-name
name: "Concept Name"
domain: mathematics
subdomain: algebra
definition: "Clear mathematical definition"

curricula:
  - syllabus: syllabus-id
    topic: topic-id
    scope: "What this curriculum covers for this concept"
```

---

## Appendix C — Progress Tracking Dashboard

| Day | Topics | Questions | Teaching Notes | Assessments | Examples | Translations | Schemas | Scripts |
|-----|--------|-----------|----------------|-------------|----------|--------------|---------|---------|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 4 | 0 |
| 1 | 4 | 0 | 4 | 0 | 0 | 0 | 4 | 0 |
| 2 | 4 | 20 | 4 | 4 | 0 | 0 | 4 | 0 |
| 3 | 4 | 20 | 4 | 4 | 0 | 0 | 4 | 1 |
| 4 | 9 | 20 | 7 | 4 | 0 | 0 | 4 | 1 |
| 5 | 9 | 20 | 7 | 4 | 0 | 0 | 4 | 1 |
| 6 | 9 | 45 | 9 | 9 | 0 | 0 | 4 | 1 |
| 7 | 14 | 45 | 14 | 9 | 0 | 0 | 4 | 1 |
| 8 | 14 | 70 | 14 | 14 | 0 | 0 | 4 | 1 |
| 9 | 14 | 70 | 14 | 14 | 0 | 0 | 5 | 3 |
| 10 | 14 | 70 | 14 | 14 | 0 | 0 | 5 | 4 |
| 11 | 14 | 70 | 14 | 14 | 12 | 0 | 6 | 4 |
| 12 | 14 | 70 | 14 | 14 | 42 | 0 | 6 | 4 |
| 13 | 14 | 70 | 14 | 14 | 42 | 4 | 6 | 4 |
| 14 | 14 | 70 | 14 | 14 | 42 | 14 | 6 | 4 |
| 15 | 14 | 70 | 14 | 14 | 42 | 14 | 7 | 4 |
| 16-17 | ~24 | 70 | 17 | 14 | 42 | 14 | 7 | 4 |
| 18 | ~40 | 70 | 17 | 14 | 42 | 14 | 7 | 4 |
| 19-20 | ~40 | 140 | 17 | 14 | 42 | 14 | 7 | 4 |
| 21-25 | ~40 | 140 | 17 | 14 | 42 | 14 | 7 | 5 |
| 26-30 | ~40+ | 140+ | 17+ | 14+ | 42+ | 14+ | 7 | 5 |
