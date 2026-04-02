# oss — Daily Development Timeline

> **Repository:** `p-n-ai/oss`
> **Focus:** KSSM Matematik (Form 1–5) — Algebra first (F1-F3), then full DSKP (F4-F5)
> **Duration:** 6 weeks (Day 0 → Day 30)

---

## Scope for oss

oss owns the **curriculum data**: YAML topic files, Markdown teaching notes, assessment questions, JSON Schemas, and validation CI. No runtime code — purely content + structure.

**First 6 months curriculum scope (aligned to official DSKP):**

| Form | Topics | DSKP Chapters | Status |
|------|--------|---------------|--------|
| **Form 1** | Ungkapan Algebra, Persamaan Linear, Ketaksamaan Linear | Bab 5, 6, 7 | ✅ Algebra complete |
| **Form 2** | Pola dan Jujukan, Pemfaktoran dan Pecahan Algebra, Rumus Algebra | Bab 1, 2, 3 | ✅ Algebra complete |
| **Form 3** | Indeks, Garis Lurus | Bab 1, 9 | ✅ Algebra complete |
| **Form 4** | All 10 DSKP chapters (Fungsi & Persamaan Kuadratik → Pengurusan Kewangan) | Bab 1–10 | ✅ Full DSKP via OSS Bot |
| **Form 5** | All 8 DSKP chapters (Ubahan → Pemodelan Matematik) | Bab 1–8 | ✅ Full DSKP via OSS Bot |

**Note:** Topic IDs follow the OSS convention `MT{grade}-{NN}` (prefix `MT` from English "Mathematics", grade number, 2-digit DSKP chapter number — e.g., `MT1-05` = Tingkatan 1 Bab 5). Algebra topics were built first (Weeks 1-3), Form 4-5 full DSKP added via OSS Bot. See [docs/id-conventions.md](id-conventions.md) for the full prefix table and ID rules.

**Folder structure note (Mar 2026):** Curricula restructured to **Country > Syllabus > Subject > Subject Grade > Topics** hierarchy:
```
curricula/malaysia/malaysia-kssm/                        # syllabus level
├── syllabus.yaml
└── malaysia-kssm-matematik/                             # subject level
    ├── subject.yaml
    ├── malaysia-kssm-matematik-tingkatan-1/             # subject-grade level
    │   ├── subject-grade.yaml
    │   └── topics/
    ├── ...tingkatan-2/
    ├── ...tingkatan-3/
    ├── ...tingkatan-4/
    └── ...tingkatan-5/
```

---

## KSSM Matematik Topic Map (DSKP-Aligned)

Topic IDs follow OSS conventions: `{PREFIX}{grade_num}-{NN}` where prefix is derived from the English subject name. For Matematik (Mathematics) the prefix is `MT`.

```
Form 1 Algebra (3 topics — DSKP Bab 5, 6, 7)
├── MT1-05 Ungkapan Algebra (Algebraic Expressions)
├── MT1-06 Persamaan Linear (Linear Equations)
└── MT1-07 Ketaksamaan Linear (Linear Inequalities)

Form 2 Algebra (3 topics — DSKP Bab 1, 2, 3)
├── MT2-01 Pola dan Jujukan (Patterns & Sequences)
├── MT2-02 Pemfaktoran dan Pecahan Algebra (Factorisation & Algebraic Fractions)
└── MT2-03 Rumus Algebra (Algebraic Formulae)

Form 3 Algebra (2 topics — DSKP Bab 1, 9)
├── MT3-01 Indeks (Indices)
└── MT3-09 Garis Lurus (Straight Lines)

Form 4 Full DSKP (10 topics — Bab 1–10) [Added via OSS Bot]
├── MT4-01 Fungsi dan Persamaan Kuadratik
├── MT4-02 Asas Nombor
├── MT4-03 Penaakulan Logik
├── MT4-04 Operasi Set
├── MT4-05 Rangkaian Dalam Teori Graf
├── MT4-06 Ketaksamaan Linear dalam Dua Pemboleh Ubah
├── MT4-07 Graf Gerakan
├── MT4-08 Sukatan Serakan Data Tak Terkumpul
├── MT4-09 Kebarangkalian Peristiwa Bergabung
└── MT4-10 Matematik Pengguna: Pengurusan Kewangan

Form 5 Full DSKP (8 topics — Bab 1–8) [Added via OSS Bot]
├── MT5-01 Ubahan
├── MT5-02 Matriks
├── MT5-03 Matematik Pengguna: Insurans
├── MT5-04 Matematik Pengguna: Percukaian
├── MT5-05 Kekongruenan, Pembesaran dan Gabungan Transformasi
├── MT5-06 Nisbah dan Graf Fungsi Trigonometri
├── MT5-07 Sukatan Serakan Data Terkumpul
└── MT5-08 Pemodelan Matematik
```

**Total topics: 26** (F1: 3, F2: 3, F3: 2, F4: 10, F5: 8)

---

## DAY 0 — SETUP ✅

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-D0-1` | Initialize repo: `curricula/`, `schema/`, `concepts/`, `taxonomy/`, `scripts/`, `.github/workflows/` | 🤖 Claude Code | ✅ | |
| `O-D0-2` | Create 4 schemas: `topic`, `assessments`, `syllabus`, `subject` (JSON Schema Draft 2020-12). Remaining schemas (`examples`, `concept`, `taxonomy`) are created as their content types are first introduced. | 🤖 Claude Code | ✅ | |
| `O-D0-3` | Create syllabus.yaml with board metadata (now at `curricula/malaysia/malaysia-kssm/syllabus.yaml` after restructure) | 🤖 Claude Code | ✅ | Path updated after folder restructure |
| `O-D0-4` | 🧑 Choose first 5 Algebra topics against official DSKP (Form 1: 3 topics + Form 2: 2 topics) | 🧑 Education Lead | ✅ | |

**Exit:** Repo exists with schema files and syllabus structure for KSSM Matematik Form 1. ✅ **Completed**

> **Structural update (Mar 2026):** Curricula folder restructured from flat `curricula/malaysia/malaysia-kssm/malaysia-kssm-matematik-tingkatan-{N}/` to nested `curricula/malaysia/malaysia-kssm/malaysia-kssm-matematik/malaysia-kssm-matematik-tingkatan-{N}/` hierarchy. `subject.yaml` renamed to `subject-grade.yaml` at each tingkatan level; new `subject.yaml` added at the subject level; `syllabus.yaml` moved to syllabus level.

---

## WEEK 1 — FORM 1 ALGEBRA CONTENT

### Day 1 (Mon) — Form 1 Algebra Topics (3 topics)

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W1D1-1` | Create `curricula/malaysia/malaysia-kssm/malaysia-kssm-matematik-tingkatan-1/subject.yaml` — subject metadata | 🤖 | ✅ | |
| `O-W1D1-2` | Create topic YAML stubs for MT1-05, MT1-06, MT1-07: id, name, prerequisites, learning_objectives, difficulty, bloom_levels | 🤖 | ✅ | |
| `O-W1D1-3` | 🧑 Write MT1-05 teaching notes (`MT1-05.teaching.md`) — real teacher quality, conversational, KSSM-aligned | 🧑 Education Lead | ✅ | |
| `O-W1D1-4` | 🧑🤖 AI-draft teaching notes for MT1-06 and MT1-07, Education Lead reviews and edits | Collaborative | ✅ | |

### Day 2 (Tue) — Assessments for Form 1 Algebra

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W1D2-1` | 🧑 Write 10 assessment questions for MT1-05 (Ungkapan Algebra): answers, rubrics, hints, difficulty spread | 🧑 Education Lead | ✅ | |
| `O-W1D2-2` | 🤖 AI-generate assessments for MT1-06 (15 questions), Education Lead reviews and expands | Collaborative | ✅ | |
| `O-W1D2-3` | 🤖 AI-generate assessments for MT1-07 (10 questions), Education Lead reviews | Collaborative | ✅ | |
| `O-W1D2-4` | Create `.yamllint.yml` with formatting rules | 🤖 | ✅ | |

### Day 3 (Wed) — Validation Pipeline

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W1D3-1` | GitHub Actions workflow `validate.yml`: yamllint + ajv-cli validation of all YAML against schemas | 🤖 | ✅ | |
| `O-W1D3-2` | `scripts/validate.sh` — run all schema validations locally | 🤖 | ✅ | |
| `O-W1D3-3` | Validate all existing content passes CI | 🤖 | ✅ | |

### Day 4 (Thu) — Form 2 Algebra Begins (3 topics)

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W1D4-1` | Create Form 2 syllabus + subject-grade metadata (now at `malaysia-kssm-matematik/malaysia-kssm-matematik-tingkatan-2/subject-grade.yaml`) | 🤖 | ✅ | Path updated after restructure |
| `O-W1D4-2` | Create topic YAML stubs for MT2-01, MT2-02, MT2-03 with prerequisites linking to Form 1 | 🤖 | ✅ | |
| `O-W1D4-3` | 🧑 Write MT2-02 teaching notes (Pemfaktoran dan Pecahan Algebra) — key topic, highest misconception rate | 🧑 Education Lead | ✅ | Prepared by Thoriq, reviewed by Faiz |
| `O-W1D4-4` | 🧑🤖 AI-draft teaching notes for MT2-01 and MT2-03 | Collaborative | ✅ | 1st review by Thoriq, 2nd review by Faiz |

### Day 5 (Fri) — Quality Check

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W1D5-1` | 🧑 Review all Week 1 content for KSSM accuracy: correct terminology (BM & English), correct scope per form | 🧑 Education Lead | ✅ | QA report completed; issues #1-#4 resolved |
| `O-W1D5-2` | Fix any schema validation failures | 🤖 | ✅ | fixed encoding corruption in MT2-02 assessments; all validations pass |

**Week 1 Output:** 6 topic YAMLs (F1: 3, F2: 3), 6 teaching notes, 15+ assessment questions. All pass CI.

---

## WEEK 2 — FORM 2 & 3 ALGEBRA + ASSESSMENTS

### Day 6 (Mon) — Form 2 Assessments

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W2D6-1` | 🧑 Write assessments for MT2-01 (15 questions) (Algebra focus) | 🧑 Education Lead | ✅ | Prepared by Thoriq, reviewed by Faiz |
| `O-W2D6-2` | 🧑🤖 AI-draft assessments for MT2-02 (15 questions) and MT2-03 (5 questions) (Algebra focus) | Collaborative | ✅ | Prepared by Thoriq, reviewed by Faiz |

**Implementation note (Mar 2026):** Form 2 learning objective IDs were aligned from `LOx` style to DSKP code format (for example `1.1.1`, `2.2.3`, `3.1.4`) to match PR #1 convention updates.

### Day 7 (Tue) — Form 3 Algebra Structure

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W2D7-1` | Create Form 3 syllabus + subject-grade metadata (now at `malaysia-kssm-matematik/malaysia-kssm-matematik-tingkatan-3/subject-grade.yaml`) | 🤖 | ✅ | Path updated after restructure |
| `O-W2D7-2` | Create topic YAML stubs for MT3-01 and MT3-09 with prerequisites linking to Form 2 | 🤖 | ✅ | |
| `O-W2D7-3` | 🧑 Write MT3-01 teaching notes (Indeks — Indices) | 🧑 Education Lead | ✅ | Prepared by Thoriq, reviewed by Faiz |
| `O-W2D7-4` | 🧑🤖 AI-draft teaching notes for MT3-09 (Garis Lurus) | Collaborative | ✅ | Prepared by Thoriq, reviewed by Faiz |

### Day 8 (Wed) — Form 3 Assessments

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W2D8-1` | 🧑 Write assessments for MT3-01 and MT3-09 (5 questions each) | 🧑 Education Lead | ✅ | Prepared by Thoriq, reviewed by Faiz |
| `O-W2D8-2` | 🧑🤖 AI-draft additional assessment questions for F3 topics | Collaborative | ✅ | Included in O-W2D8-1 drafts |

### Day 9 (Thu) — Cross-Form Prerequisites + Concepts

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W2D9-1` | `scripts/check-prerequisites.rb` — detect cycles in prerequisite graph across all 3 forms | 🤖 | ✅ | |
| `O-W2D9-2` | `scripts/check-references.rb` — verify all topic_id and syllabus_id references are valid | 🤖 | ✅ | |
| `O-W2D9-3` | Create `concepts/mathematics/linear-equation.yaml` bridging F1→F2→F3 linear equations | 🤖 | ✅ | |
| `O-W2D9-4` | Create `concepts/mathematics/algebraic-expression.yaml` bridging expansion/factorisation across forms | 🤖 | ✅ | |
| `O-W2D9-5` | 🧑 Verify prerequisite chain: can a Form 1 student's mastery correctly unlock Form 2 topics? | 🧑 Education Lead | ✅ | Full F1-F3 audit + fixes |

### Day 10 (Fri) — Quality Audit

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W2D10-1` | `scripts/assess-quality.rb` — auto-assess quality levels for all topics | 🤖 | ✅ | |
| `O-W2D10-2` | Add quality report to CI (runs on merge to main) | 🤖 | ✅ | |
| `O-W2D10-3` | 🧑 Full quality audit: are all 8 Algebra topics at Level 3 (Teachable)? Fix any that aren't. | 🧑 Education Lead | ✅ | 8 topics validated via Telegram simulation |

**Week 2 Output:** All 8 Algebra topics complete (F1:3 + F2:3 + F3:2). 40+ assessment questions. Prerequisite chain validated across 3 forms. Quality Level ≥2 for all topics.

---

## WEEK 3 — WORKED EXAMPLES + MALAY TRANSLATIONS

### Day 11 (Mon) — Examples Schema + Form 1 Examples

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W3D11-1` | Create `schema/examples.schema.json` | 🤖 | ✅ | Initialized global JSON schema to enforce the "Golden Format" structure for all worked examples (Scenario, Analogy, Alert, Working). |
| `O-W3D11-2` | 🧑🤖 Create worked examples for MT1-05, MT1-06, MT1-07 (3 examples each, progressive difficulty) | Collaborative | ✅ | Structured strictly in the "Golden Format" with progressive scaffolding. Injected targeted misconception alerts to preempt student errors and engaging real-world analogies. |

### Day 12 (Tue) — Form 2 & 3 Examples

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W3D12-1` | 🧑🤖 Create worked examples for MT2-01, MT2-02, MT2-03 | Collaborative | ✅ | Golden Format applied. Analogies crafted for abstract concepts (e.g., the FOIL handshake) alongside preemptive KBAT error traps specifically designed to guide AI tutoring behavior. |
| `O-W3D12-2` | 🧑🤖 Create worked examples for MT3-01 and MT3-09 | Collaborative | ✅ | Exam techniques enforced. Introduced explicit instruction warnings tied to grading constraints (e.g., the "Double-Decker Bus" analogy for strictly forcing positive indices). |

### Day 13 (Wed) — Malay Translation Structure

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W3D13-1` | Create `translations/ms/` directory inside each form's `topics/` folder (3 forms) | 🤖 | ✅ | Init topics/translations/ms/ across all 3 forms (Official i18n structural standard). |
| `O-W3D13-2` | 🧑🤖 Translate Form 1 topic names, learning objectives, misconceptions to Bahasa Melayu | Collaborative | ✅ | Translated F1 Algebra (MT1 05-07). Upgraded YAML schema to include strict DSKP `content_standards` & `performance_standards`. |
| `O-W3D13-3` | 🧑🤖 Translate Form 1 teaching notes to BM (since KSSM students learn in Malay) | Collaborative | ✅ | Translated F1 Algebra (MT1 05-07). Built 100% contextual KSSM conversational tutor persona ("Terbalik Simbol!", "Roti Canai hooks"). |

> [!WARNING]
> **Engineering Update Required**
> 
> * **Backend Struct Update (Go/TypeScript)**: The backend code that reads these `.yaml` files uses rigid data "structs". Because we just invented a brand new `content_standards` array and `performance_standards` array, the code doesn't know what they are. The engineers have to explicitly add these fields to their database parsers, otherwise, the parser will either silently ignore them or throw an Unmarshal Error and panic.
> * **Database Migration**: If `pai-bot` stores these topics in a database (like Postgres or MongoDB), the engineers need to update the database schema to store these new SK and TP text fields.
> * **Prompt Engineering**: The team working on the LLM backend must now write code to actively fetch these TP and SK definitions and inject them into the system prompt when the tutor evaluates a student's answer.

### Day 14 (Thu) — Form 2 & 3 Translations

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W3D14-1` | 🧑🤖 Translate Form 2 topics + teaching notes to BM | Collaborative | ✅ | Full standardization to "Golden Format" v2 + KPM DSKP metadata alignment. |
| `O-W3D14-2` | 🧑🤖 Translate Form 3 topics + teaching notes to BM | Collaborative | ⬜ | |
| `O-W3D14-3` | 🧑 Native speaker review of all BM translations — correct mathematical terminology | 🧑 Education Lead | ⬜ | |

### Day 15 (Fri) — Taxonomy + Documentation

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W3D15-1` | Create `taxonomy/mathematics/algebra.yaml` — classification tree for KSSM algebra | 🤖 | ⬜ | |
| `O-W3D15-2` | Write CONTRIBUTING.md: 3 contribution paths (teacher, developer, AI), YAML format guide with examples | 🤖 | ⬜ | |
| `O-W3D15-3` | Write comprehensive README.md: what it is, structure, how to consume, how to contribute | 🤖 | ⬜ | |

**Week 3 Output:** 24 worked examples. Malay translations for all 8 Algebra topics. Taxonomy defined. Docs complete.

---

## ACCELERATED — FORM 4 & FORM 5 FULL DSKP (via OSS Bot) ✅

> **Added:** Mar 2026 — Full KSSM Matematik Form 4 (10 topics) and Form 5 (8 topics) generated using [OSS Bot](https://github.com/p-n-ai/oss-bot). Each topic includes topic YAML, teaching notes, worked examples, and assessments.

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-ACC-1` | Restructure curricula folder to Country > Syllabus > Subject > Subject Grade > Topics hierarchy | 🧑 | ✅ | Applied to F1-F3 Algebra; `subject.yaml` → `subject-grade.yaml`, new `subject.yaml` at subject level |
| `O-ACC-2` | Create Form 4 subject-grade metadata (`subject-grade.yaml`) | 🤖 OSS Bot | ✅ | |
| `O-ACC-3` | Create 10 Form 4 topics (MT4-01 to MT4-10) with assessments, worked examples, and teaching notes | 🤖 OSS Bot | ✅ | Full DSKP coverage |
| `O-ACC-4` | Create Form 5 subject-grade metadata (`subject-grade.yaml`) | 🤖 OSS Bot | ✅ | |
| `O-ACC-5` | Create 8 Form 5 topics (MT5-01 to MT5-08) with assessments, worked examples, and teaching notes | 🤖 OSS Bot | ✅ | Full DSKP coverage |
| `O-ACC-6` | 🧑 Educator review of F4 & F5 content for KSSM accuracy | 🧑 Education Lead | ⬜ | Pending review — folded into O-W4D20-2 |

**Accelerated Output:** 18 new topics (F4: 10, F5: 8) with full content (topic YAML + teaching notes + worked examples + assessments). Total coverage: F1-F5 = 26 topics.

---

## WEEK 4 — NON-ALGEBRA TOPIC STUBS + QUALITY (scope partially superseded by Accelerated F4/F5)

### Day 16-17 (Mon-Tue) — Form 1 Non-Algebra Topics

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W4D16-1` | Create non-algebra subjects for Form 1: `numbers.yaml`, `measurement.yaml`, `statistics.yaml` | 🤖 | ⬜ | |
| `O-W4D16-2` | Create Level 0-1 topic stubs for Form 1 non-algebra (8-10 topics): id, name, LOs, prerequisites, difficulty | 🤖 | ⬜ | |
| `O-W4D16-3` | 🧑🤖 Elevate 3 high-priority Form 1 non-algebra topics to Level 2 (add misconceptions, teaching sequence) | Collaborative | ⬜ | |

### Day 18 (Wed) — Form 2 & 3 Non-Algebra Topics

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W4D18-1` | Create Level 0-1 stubs for Form 2 non-algebra (8-10 topics) | 🤖 | ⬜ | |
| `O-W4D18-2` | Create Level 0-1 stubs for Form 3 non-algebra (8-10 topics) | 🤖 | ⬜ | |
| `O-W4D18-3` | 🧑 Verify all prerequisite links across Algebra and non-Algebra topics are correct | 🧑 Education Lead | ⬜ | |

### Day 19-20 (Thu-Fri) — More Assessments + Quality

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W4D19-1` | 🧑 Add 5 MORE assessment questions per Algebra topic (bringing total to 10/topic = 80 total) | 🧑 Education Lead | ⬜ | |
| `O-W4D19-2` | 🧑 Add harder "exam-style" questions for Form 3 topics (PT3 exam format) | 🧑 Education Lead | ⬜ | |
| `O-W4D20-1` | Run full quality report for all 26 topics (F1-F5): how many topics at each level? | 🤖 | ⬜ | Scope expanded from 8 to 26 topics after Accelerated F4/F5 |
| `O-W4D20-2` | 🧑 Ensure ALL 26 topics are at Quality Level 3+ (Teachable) — includes educator review of F4/F5 OSS Bot content (O-ACC-6) | 🧑 Education Lead | ⬜ | Supersedes O-ACC-6; critical path to launch |

**Week 4 Output:** F1-F3 non-algebra stubs. 80+ assessment questions. Full quality report across all 26 topics (F1-F5).

---

## WEEK 5 — OPEN SOURCE PREP

### Day 21-22 (Mon-Tue) — Documentation + Cleanup

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W5D21-1` | Create "good first issues" for community: add teaching notes for stub topics, translate to Chinese, improve an assessment | 🤖 | ⬜ | |
| `O-W5D21-2` | Create CODEOWNERS: Education Lead auto-assigned on all content PRs | 🤖 | ⬜ | |
| `O-W5D21-3` | Create issue templates: new-topic, improve-content, translation, bug-report | 🤖 | ⬜ | |
| `O-W5D22-1` | `scripts/export-sqlite.py` — generate SQLite export of all curriculum data for offline apps | 🤖 | ⬜ | |
| `O-W5D22-2` | Add SQLite export to release workflow: tagged release generates downloadable oss.sqlite | 🤖 | ⬜ | |

### Day 23 (Wed) — Final Validation

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W5D23-1` | Run full CI: all YAML validates, no prerequisite cycles, all references valid, quality report clean | 🤖 | ⬜ | |
| `O-W5D23-2` | 🧑 Final read-through of all 26 topics' teaching notes and assessments for KSSM accuracy | 🧑 Education Lead | ⬜ | Scope expanded: F1-F5 (26 topics, not 8) |

### Day 24-25 (Thu-Fri) — Pre-Launch

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W5D24-1` | Tag v0.1.0: first public release (26 topics across F1-F5 at Level 3+) | 🤖 | ⬜ | Scope expanded from 8 Algebra + stubs to 26 full topics |
| `O-W5D25-1` | 🧑 Prepare curriculum section of launch blog: "Open School Syllabus — covering KSSM F1-F5 Matematik" | 🧑 Human | ⬜ | Updated from F1-F3 to F1-F5 |

**Week 5 Output:** Repo public-ready. v0.1.0 tagged. 26 topics across F1-F5. 10+ good first issues. SQLite export available.

---

## WEEK 6 — LAUNCH + COMMUNITY

### Day 26 (Mon) — LAUNCH DAY

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W6D26-1` | 🧑 Publish repo publicly. Announce alongside pai-bot. | 🧑 Human | ⬜ | |
| `O-W6D26-2` | 🧑 Post in Malaysian teacher communities: Telegram groups, Facebook groups for Guru Matematik | 🧑 Human | ⬜ | |

### Day 27-28 (Tue-Wed) — Community Response

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W6D27-1` | 🧑 Respond to every issue and PR within 24 hours | 🧑 Team | ⬜ | |
| `O-W6D28-1` | 🧑 Based on feedback, identify most-requested additional content (Chinese/Tamil translations? Science?) | 🧑 Human | ⬜ | |

### Day 29-30 (Thu-Fri) — First Community Contributions

| Task ID | Task | Owner | Status | Remark |
|---------|------|-------|--------|--------|
| `O-W6D29-1` | 🧑 Review and merge first community PRs. Be generous with praise. | 🧑 Education Lead | ⬜ | |
| `O-W6D30-1` | 🧑 Write curriculum section of 6-week report: F1-F5 coverage stats, quality levels, community contributions | 🧑 Human | ⬜ | |

**Week 6 Output:** Public repo with F1-F5 KSSM Matematik coverage. Community engagement. First external contributions. 5+ external contributors.

---

## Content Delivery Summary

| Milestone | F1-F3 Algebra | F4-F5 Full DSKP | Total Topics | Assessment Qs | Teaching Notes | Translations |
|-----------|--------------|-----------------|-------------|--------------|---------------|-|
| End Week 1 | 6 (F1:3, F2:3) | 0 | 6 | 15+ | 6 (BM & EN) | 0 |
| End Week 2 | 8 (all) | 0 | 8 | 40+ | 8 (all) | 0 |
| End Week 3 | 8 | 0 | 8 | 40+ | 8 | 8 (Malay) |
| **Accelerated** | **8** | **18 (F4:10, F5:8)** | **26** | **40+ (F1-F3) + F4/F5** | **26** | **3 (F1 EN)** |
| End Week 4 | 8 | 18 | 26+ stubs | 80+ | 26+ | 8 |
| End Week 5 | 8 | 18 | 26+ | 80+ | 26+ | 8 |
| End Week 6 | 8 | 18 | 26+ | 80+ | 26+ | 8+ |
 
