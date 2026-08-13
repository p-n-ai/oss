# OSS ID Conventions

This document defines the canonical identifier formats for all entities in the Open School Syllabus (OSS) data model. All contributors, tools, and AI-generated content **must** follow these conventions for consistency and cross-referencing.

---

## Language Principle

> **Entity IDs use the official language of the country's Ministry of Education. Canonical topic content uses English when available; locale variants carry the localized teaching content.**

This means:
- A Malaysian KSSM subject ID is `malaysia-kssm-matematik` (Malay — KPM's official language), not `mathematics`
- The YAML file at that path includes `name: "Matematik"` **and** `name_en: "Mathematics"` for tools and integrations that need English
- An English canonical topic can retain the official Malay source label in `name`, while its Malay teaching content lives in the matching `topics/translations/ms/` variant
- An Indian CBSE subject ID is `india-cbse-mathematics-class-10` (English — CBSE's official language)

The bot follows this principle when generating IDs and scaffolding new content.

### Official MOE Languages by Country

| Country | Official MOE Language | Example Subject ID |
|---------|----------------------|-------------------|
| Malaysia | Malay (Bahasa Melayu) | `malaysia-kssm-matematik` |
| Indonesia | Indonesian (Bahasa Indonesia) | `indonesia-k13-matematika-kelas-10` |
| India | English | `india-cbse-mathematics-class-10` |
| Singapore | English | `singapore-o-level-mathematics` |
| UK | English | `uk-cambridge-igcse-mathematics-0580` |
| Australia | English | `australia-ac-mathematics-year-10` |
| Nigeria | English | `nigeria-waec-mathematics` |
| UAE | Arabic | `uae-moe-riyaadiyaat-saff-7` |
| Japan | Japanese | `japan-mext-suugaku-chugaku-1` |

For countries not listed, use the primary language of instruction as declared by the national MOE.

---

## Summary

| Entity | Format | Example |
|--------|--------|---------|
| Country | `{name}` | `malaysia`, `india`, `uk` |
| Syllabus | `{country}-{board}` | `malaysia-kssm`, `india-cbse` |
| Grade | `{grade-name}` in MOE language | `tingkatan-1`, `class-10`, `year-9` |
| Subject | `{syllabus}-{subject}` | `malaysia-kssm-matematik`, `india-cbse-physics` |
| Subject Grade | `{subject_id}-{grade}` | `malaysia-kssm-matematik-tingkatan-1` |
| Topic | `{PREFIX}{grade_num}-{NN}` | `MT1-01`, `SC2-03`, `SJ3-01` |
| Learning Objective | `{official_code}` or `{section.subsection.item}` (SemVer) | `5.1.1`, `9.2.3`, `1.0.0` |
| Assessment Question | `Q{N}` | `Q1`, `Q5` |
| Worked Example | `WE-{NN}` | `WE-01`, `WE-12` |

Country, syllabus, grade, subject, and subject-grade IDs use **lowercase kebab-case**. Topic, learning-objective, question, and worked-example IDs use their dedicated formats above.

---

## Country ID

**Format:** `{common-english-name}` — lowercase, kebab-case

Country IDs are always in English (they identify the country, not a language):

```
malaysia
india
uk
us
singapore
indonesia
australia
nigeria
south-africa
new-zealand
```

Use the common English name, not the ISO code. Multi-word countries use hyphens.

---

## Syllabus ID

**Format:** `{country}-{board}[-{curriculum}][-{version}]`

The board abbreviation uses the MOE's own abbreviation for the curriculum:

```
malaysia-kssm          # Kurikulum Standard Sekolah Menengah
malaysia-kssm-v2       # Illustrative ID for a separately versioned KSSM revision
malaysia-uec           # Unified Examination Certificate
india-cbse             # Central Board of Secondary Education
india-jee              # Joint Entrance Examination
indonesia-k13          # Kurikulum 2013
uk-cambridge-igcse     # Cambridge IGCSE
uk-aqa-gcse            # AQA GCSE
singapore-o-level      # Singapore-Cambridge O-Level
us-common-core         # US Common Core
```

Rules:
- Use the board's own abbreviation in the MOE language where it has one (`kssm` not `ssmk`)
- If the board has multiple curricula, append the curriculum level: `uk-cambridge-igcse` vs `uk-cambridge-alevel`
- If a revision must coexist as a separately addressable syllabus, append a stable version token such as `v2`. The token is part of the syllabus ID and directory name; `syllabus.yaml` has no separate `version` field.
- Never include subject or grade in the syllabus ID

The checked-in corpus currently uses `malaysia-kssm`. The other IDs above are illustrative examples that follow the current naming contract.

---

## Grade ID

**Format:** `{grade-name}` — in the MOE's official language, slugified

```
# Malaysia KSSM (Malay — KPM official)
tingkatan-1
tingkatan-2
tingkatan-3
tingkatan-4
tingkatan-5

# Indonesia Kurikulum 2013 (Indonesian — Kemendikbud official)
kelas-7
kelas-8
kelas-10

# India CBSE (English — CBSE official)
class-9
class-10
class-11
class-12

# UK Cambridge IGCSE (English — no grade, use assessment tier)
core
extended

# UK GCSEs (English)
year-10
year-11

# Japan MEXT (Japanese — MEXT official)
chugaku-1      # 中学1年 = Junior High Year 1
chugaku-2
koko-1         # 高校1年 = Senior High Year 1
```

Rules:
- Always use the MOE's official language term for the grade (e.g. `tingkatan` not `form` for KSSM)
- Slugify: lowercase, spaces and special chars become hyphens
- For exam-based syllabi with no grade structure (e.g. JEE), omit the grade from the subject ID

---

## Subject ID

**Format:** `{syllabus-id}-{subject}`

Subject IDs identify the subject **without** a grade. Subject names use the **official MOE language**:

```
# Malaysia KSSM — Malay subject names (KPM official)
malaysia-kssm-matematik
malaysia-kssm-sains
malaysia-kssm-fizik
malaysia-kssm-kimia
malaysia-kssm-biologi
malaysia-kssm-sejarah
malaysia-kssm-bahasa-melayu

# Indonesia K13 — Indonesian subject names (Kemendikbud official)
indonesia-k13-matematika
indonesia-k13-fisika
indonesia-k13-biologi

# India CBSE — English subject names (CBSE official)
india-cbse-mathematics
india-cbse-physics
india-cbse-chemistry

# UK Cambridge IGCSE — English subject names + code
uk-cambridge-igcse-mathematics-0580
uk-cambridge-igcse-physics-0625
```

Rules:
- Use the official subject name from the MOE curriculum document, slugified
- Keep the syllabus subject code if the board uses one (e.g. `0580` for IGCSE Maths)
- Grade is **not** included in the subject ID (see Subject Grade ID below)

---

## Subject Grade ID

**Format:** `{subject-id}-{grade-id}`

Subject Grade IDs combine the subject with a specific official learning level. The level may be a grade, form, class, or curriculum phase. These IDs are used as folder names and YAML IDs:

```
# Malaysia KSSM
malaysia-kssm-matematik-tingkatan-1
malaysia-kssm-matematik-tingkatan-3
malaysia-kssm-sains-tingkatan-2
malaysia-kssm-fizik-tingkatan-4
malaysia-kssm-kimia-tingkatan-4
malaysia-kssm-biologi-tingkatan-4
malaysia-kssm-sejarah-tingkatan-1
malaysia-kssm-bahasa-melayu-tingkatan-3

# Indonesia K13
indonesia-k13-matematika-kelas-10
indonesia-k13-fisika-kelas-11
indonesia-k13-biologi-kelas-10

# Indonesia Kurikulum Merdeka
indonesia-merdeka-matematika-fase-d

# India CBSE
india-cbse-mathematics-class-10
india-cbse-physics-class-12
india-cbse-chemistry-class-11

# UK Cambridge IGCSE (no grade — subject_grade_id equals subject_id)
uk-cambridge-igcse-mathematics-0580
uk-cambridge-igcse-physics-0625
```

Rules:
- Appends the official learning-level ID to the subject ID
- Stores that level in `grade_id` for schema compatibility, including values such as `fase-d`
- For exam-based syllabi with no grade structure (e.g. IGCSE, JEE), the subject grade ID equals the subject ID

---

## Topic ID

**Grade format:** `{PREFIX}{grade_num}-{NN}`

**Phase format:** `{PREFIX}-{phase_letter}-{NN}`

- **PREFIX** — 2-3 uppercase letters reserved globally for one curriculum-subject identity
- **grade_num** — one or more digits identifying the grade grouping (e.g. `1` for Tingkatan 1, `12` for Class 12)
- **phase_letter** — one uppercase letter identifying the official curriculum phase
- **NN** — 2-digit zero-padded sequence number within the subject+grade, matching chapter/topic order in the official syllabus document

The current schema pattern is `^(?:[A-Z]{2,3}[0-9]+|[A-Z]{2,3}-[A-Z])-[0-9]{2}$`. A grade-less form such as `MT-01` is not valid. Canonical topic IDs must also remain globally unique across OSS.

```
# Malaysia KSSM Matematik Tingkatan 1 → prefix MT, grade 1
MT1-01    # Chapter 1
MT1-02    # Chapter 2
MT1-15    # Chapter 15

# Malaysia KSSM Matematik Tingkatan 3 → prefix MT, grade 3
MT3-01
MT3-09

# Malaysia KSSM Sains Tingkatan 2 → prefix SC, grade 2
SC2-01
SC2-07

# Malaysia KSSM Fizik Tingkatan 4 → prefix PH, grade 4
PH4-01

# India CBSE Physics Class 12 → prefix PH, grade 12
PH12-01

# Indonesia Kurikulum Merdeka Matematika Fase D → prefix IM, phase D
IM-D-01
IM-D-05

```

**Reserved prefix table:**

| Curriculum subject | Prefix |
|--------------------|--------|
| Malaysia KSSM Mathematics | `MT` |
| Malaysia KSSM Science | `SC` |
| Malaysia KSSM History | `SJ` |
| Indonesia Kurikulum Merdeka Mathematics | `IM` |

Existing prefixes remain stable. New curriculum subjects must reserve an unused prefix before adding topics. Start from the English subject name, then qualify it by curriculum or country when the natural prefix is already reserved. Locale variants reuse the canonical topic ID.

---

## Official Reference (`official_ref`)

MOEs and exam boards often assign their own codes, chapter numbers, or reference strings to topics in official curriculum documents. Every canonical topic and locale topic variant requires one non-empty string in `official_ref`.

`official_ref` is **read-only provenance** — it records the board's identifier as printed in the source document. It never replaces the OSS `id` and is never used for cross-referencing between topics (use `id` for that).

### Examples

| Board | Source reference | `official_ref` value |
|-------|-----------------|----------------------|
| Malaysia KSSM | "Bab 9: Garis Lurus" | `"Bab 9"` |
| Malaysia KSSM | Topic code printed on past paper | `"F4-T9"` |
| India CBSE | "Chapter 12: Linear Programming" | `"Chapter 12"` |
| Cambridge IGCSE | Section code in syllabus | `"C2.5"` |
| Singapore O-Level | Syllabus section number | `"2.3"` |
| Japan MEXT | Unit reference in 学習指導要領 | `"第3章第2節"` |
| Nigeria WAEC | WAEC syllabus item code | `"SS2/MAT/03"` |

### Rules

- Store the reference **exactly as it appears** in the official document — do not translate or normalise it.
- If the board uses multiple reference formats (e.g. a chapter number and a paper code), store the single most stable official reference.
- If the source has no formal identifier, resolve the source reference before adding the topic; do not fabricate one.
- `official_ref` is a non-empty string, never a list or structured object.

### Topic YAML with `official_ref`

```yaml
id: MT3-09
official_ref: "Bab 9"              # required; as printed in the KSSM document
name: Garis Lurus
name_en: Straight Lines
subject_grade_id: malaysia-kssm-matematik-tingkatan-3
subject_id: malaysia-kssm-matematik
syllabus_id: malaysia-kssm
country_id: malaysia
language: en                        # canonical topic root
```

---

## Canonical and Locale Content

Entity metadata retains the official MOE label and its English equivalent where available. Topic content has a separate identity rule:

- The topic YAML at the root of `topics/` is canonical. In the current corpus, canonical topic content is English when an English representation exists.
- A localized topic is a full locale variant under `topics/translations/{locale}/`, not a partial overlay.
- A locale variant reuses the canonical topic ID and filename. Its path and `language` distinguish it from the canonical record.
- Canonical topic IDs are globally unique across OSS. Reuse is allowed only by the corresponding locale variant and companion files.

### Subject YAML

```yaml
id: malaysia-kssm-matematik
name: Matematik                    # official MOE language
name_en: Mathematics               # English for interoperability
syllabus_id: malaysia-kssm
country_id: malaysia
language: ms                        # BCP 47 language code
```

### Subject Grade YAML

```yaml
id: malaysia-kssm-matematik-tingkatan-3
name: Matematik Tingkatan 3         # official MOE language
name_en: Mathematics Form 3         # English for interoperability
subject_id: malaysia-kssm-matematik
syllabus_id: malaysia-kssm
grade_id: tingkatan-3
country_id: malaysia
language: ms                        # BCP 47 language code
```

### Topic YAML

```yaml
id: MT3-09
official_ref: "Bab 9"              # required board chapter/topic reference
name: Garis Lurus                   # official source label may be retained
name_en: Straight Lines             # English for interoperability
subject_grade_id: malaysia-kssm-matematik-tingkatan-3
subject_id: malaysia-kssm-matematik
syllabus_id: malaysia-kssm
country_id: malaysia
language: en                        # canonical topic content

content_standards:
  - id: "9.1"
    text_en: Straight Lines
learning_objectives:
  - id: 9.1.1                                          # official DSKP code; use SemVer (e.g. 1.0.0) if absent
    text_en: Determine the gradient of a straight line
    bloom: apply
```

The Malay locale variant is stored at `topics/translations/ms/MT3-09.yaml` and reuses the same identity:

```yaml
id: MT3-09
official_ref: "Bab 9"
name: Garis Lurus
subject_grade_id: malaysia-kssm-matematik-tingkatan-3
subject_id: malaysia-kssm-matematik
syllabus_id: malaysia-kssm
country_id: malaysia
language: ms

content_standards:
  - id: "9.1"
    text: Garis Lurus
learning_objectives:
  - id: 9.1.1
    text: Menentukan kecerunan garis lurus
    bloom: apply
```

### Canonical and Locale Companions

Canonical assessment and example files live beside the canonical topic. Locale companions use the same filename under `topics/translations/{locale}/` and reuse the canonical `topic_id`. Teaching notes can follow the same path convention, but Markdown is outside the content-YAML classifier.

```
topics/
├── MT3-09.yaml                     # canonical topic
├── MT3-09.teaching.md
├── MT3-09.assessments.yaml         # canonical assessment
├── MT3-09.examples.yaml            # canonical examples
└── translations/
    └── ms/
        ├── MT3-09.yaml             # Malay topic variant; id: MT3-09
        ├── MT3-09.teaching.md
        ├── MT3-09.assessments.yaml # Malay assessment variant; topic_id: MT3-09
        └── MT3-09.examples.yaml    # Malay example variant; topic_id: MT3-09
```

---

## Learning Objective ID

**Format:** `{official_code}` — use the official numbering from the syllabus standard document (e.g. DSKP, CBSE syllabus). Fall back to **Semantic Versioning (SemVer)** format `{section.subsection.item}` when no official numbering exists.

```
# Malaysia KSSM (DSKP uses section.subsection.item numbering)
5.1.1
5.1.2
5.2.1

# India CBSE (syllabus uses chapter.item numbering)
12.1
12.2

# Fallback — SemVer (section.subsection.item) format when the syllabus has no official LO codes
1.0.0
1.1.0
2.0.0
```

SemVer fallback semantics:
- **section** — learning objective group or strand (increment for each new group)
- **subsection** — sub-objective within the group (increment for each sub-objective)
- **item** — revision or granular variant (start at `0`, increment for refinements)

Scoped within a single topic. When using the SemVer fallback, reset to `1.0.0` for each topic.

---

## Assessment Question ID

**Format:** `Q{N}` — sequential integer, no padding

```
Q1
Q2
Q10
```

Scoped within a single assessments file.

---

## Worked Example ID

**Format:** `WE-{NN}` — zero-padded 2-digit sequence

```
WE-01
WE-02
WE-12
```

Scoped within a single examples file.

---

## Folder and File Naming

### Rule: folder name = entity ID

Every folder and file in `curricula/` is named after the `id` field of the YAML it contains. This makes any path self-describing and allows tools to resolve entities from paths without opening files.

| Level | Folder/file name | Equals |
|-------|-----------------|--------|
| Country | `malaysia/` | `country_id` |
| Syllabus | `malaysia-kssm/` | `syllabus_id` |
| Subject | `malaysia-kssm-matematik/` | `subject_id` |
| Subject Grade | `malaysia-kssm-matematik-tingkatan-3/` | `subject_grade_id` |
| Subject Grade file | `subject-grade.yaml` | fixed name |
| Topic file | `MT3-09.yaml` | `topic_id` + `.yaml` |
| Teaching notes | `MT3-09.teaching.md` | `topic_id` + `.teaching.md` |
| Assessments | `MT3-09.assessments.yaml` | `topic_id` + `.assessments.yaml` |
| Examples | `MT3-09.examples.yaml` | `topic_id` + `.examples.yaml` |

### Fixed folder names (never change)

| Folder | Purpose |
|--------|---------|
| `curricula/` | Root of all curriculum content |
| `topics/` | Contains all topic files within a subject-grade |
| `translations/` | Contains translated versions of content files |
| `translations/{lang}/` | One folder per BCP 47 language code (`en`, `ms`, `ta`, `zh-hans`) |

### Folder naming rules

1. **Always use the full entity ID** — never abbreviate. Subject folder is `malaysia-kssm-matematik`, not `matematik` or `math`. Subject grade folder is `malaysia-kssm-matematik-tingkatan-3`, not `tingkatan-3` or `t3`.
2. **Lowercase kebab-case** — no uppercase letters, no underscores, no spaces.
3. **Include the full versioned ID when applicable** — a syllabus such as `malaysia-kssm-v2` lives in `malaysia-kssm-v2/`. Its subject and subject-grade IDs use that syllabus ID as their prefix.
4. **Language of folder names** follows the ID convention — MOE language for grades and subjects, English for countries.

---

## Directory Structure

```
curricula/
└── {country_id}/                                # e.g. malaysia/
    └── {syllabus_id}/                           # e.g. malaysia-kssm/
        ├── syllabus.yaml                        # id:  malaysia-kssm
        └── {subject_id}/                        # e.g. malaysia-kssm-matematik/
            ├── subject.yaml                     # id:  malaysia-kssm-matematik
            └── {subject_grade_id}/              # e.g. malaysia-kssm-matematik-tingkatan-3/
                ├── subject-grade.yaml           # id:  malaysia-kssm-matematik-tingkatan-3
                └── topics/
                    ├── {topic_id}.yaml          # e.g. MT3-09.yaml
                    ├── {topic_id}.teaching.md
                    ├── {topic_id}.assessments.yaml
                    ├── {topic_id}.examples.yaml
                    └── translations/
                        └── {lang}/                # e.g. ms/
                            ├── {topic_id}.yaml
                            ├── {topic_id}.teaching.md
                            ├── {topic_id}.assessments.yaml
                            └── {topic_id}.examples.yaml
```

**Full example — Malaysia KSSM Matematik:**

```
curricula/
└── malaysia/
    └── malaysia-kssm/
        ├── syllabus.yaml
        └── malaysia-kssm-matematik/
            ├── subject.yaml
            ├── malaysia-kssm-matematik-tingkatan-1/
            │   ├── subject-grade.yaml
            │   └── topics/
            │       ├── MT1-01.yaml
            │       └── MT1-01.teaching.md
            └── malaysia-kssm-matematik-tingkatan-3/
                ├── subject-grade.yaml
                └── topics/
                    ├── MT3-01.yaml
                    ├── MT3-01.teaching.md
                    ├── MT3-01.assessments.yaml
                    ├── MT3-09.yaml
                    ├── MT3-09.teaching.md
                    ├── MT3-09.assessments.yaml
                    └── translations/
                        └── ms/
                            ├── MT3-09.yaml
                            ├── MT3-09.teaching.md
                            ├── MT3-09.assessments.yaml
                            └── MT3-09.examples.yaml
```

---

## Validation

The path classifier selects the artifact contract before schema validation. It never chooses whichever schema happens to accept a file.

| Artifact class | Path rule | Schema | Current count |
|----------------|-----------|--------|--------------:|
| Syllabus | `curricula/**/syllabus.yaml` | `syllabus.schema.json` | 3 |
| Subject | `curricula/**/subject.yaml` | `subject.schema.json` | 44 |
| Subject-grade | `curricula/**/subject-grade.yaml` | `subject-grade.schema.json` | 16 |
| Canonical topic | canonical YAML directly under `topics/` | `topic.schema.json` | 157 |
| Locale topic variant | topic YAML under `topics/translations/{locale}/` | `topic-variant.schema.json` | 53 |
| Assessment | canonical or locale `*.assessments.yaml` | `assessments.schema.json` | 115 canonical + 53 locale |
| Example | canonical or locale `*.examples.yaml` | `examples.schema.json` | 115 canonical + 53 locale |
| Concept | `concepts/**/*.yaml` | `concept.schema.json` | 2 |
| Taxonomy | `taxonomy/**/*.yaml` | `taxonomy.schema.json` | 0 |
| **Total content YAML** |  | **9 schemas** | **611** |

The schemas enforce these identifier patterns:

```yaml
topic_id:          pattern: "^(?:[A-Z]{2,3}[0-9]+|[A-Z]{2,3}-[A-Z])-[0-9]{2}$"
syllabus_id:       pattern: "^[a-z][a-z0-9-]+$"
subject_id:        pattern: "^[a-z][a-z0-9-]+$"
subject_grade_id:  pattern: "^[a-z][a-z0-9-]+$"
country_id:        pattern: "^[a-z][a-z0-9-]+$"
grade_id:          pattern: "^[a-z][a-z0-9-]+$"
```

`./scripts/validate.sh` parses every content YAML file, validates all 611 classified artifacts with AJV and `ajv-formats`, enforces the exact inventory, and checks references, prerequisites, and quality claims. `./scripts/validate-changed.sh` additionally blocks newly introduced `yamllint` findings in touched YAML; pre-existing style findings, including findings in a touched file, remain outside both gates.

`quality_level: 0` history stubs remain valid inventory members and may have empty `content_standards` and `learning_objectives`. They are catalog-only, not teachable content. Topics at `quality_level >= 1` require non-empty teaching identity.

---

## AI Generation Note

When the OSS Bot generates IDs or scaffolds new content, it follows these conventions:
- IDs use the official MOE language of the target country
- Canonical topic content uses English fields when an English representation exists; localized fields belong in the matching full locale variant
- Locale variants reuse the canonical topic ID, filename, and parent identities
- Topic prefixes use the globally reserved registry and remain stable across locale variants
- Capture the source chapter or section reference in the required `official_ref` field

If you are writing prompt templates or reviewing AI output, refer to this document. Misformatted IDs are caught by the validator and the PR will be blocked.
