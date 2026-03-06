# oss â€” Daily Development Timeline

> **Repository:** `p-n-ai/oss`
> **Focus:** KSSM Matematik (Form 1, 2, 3) â€” Algebra first
> **Duration:** 6 weeks (Day 0 â†’ Day 30)

---

## Scope for oss

oss owns the **curriculum data**: YAML topic files, Markdown teaching notes, assessment questions, JSON Schemas, and validation CI. No runtime code â€” purely content + structure.

**First 6 months curriculum scope (aligned to official DSKP):**

| Form | Algebra Topics (Primary) | DSKP Chapters | Other Subjects (Backfill later) |
|------|-------------------------|---------------|-------------------------------|
| **Form 1** | Ungkapan Algebra, Persamaan Linear, Ketaksamaan Linear | Bab 5, 6, 7 | Nombor Nisbah, Faktor & Gandaan, Nisbah/Kadar/Kadaran, etc. |
| **Form 2** | Pola dan Jujukan, Pemfaktoran dan Pecahan Algebra, Rumus Algebra | Bab 1, 2, 3 | Poligon, Bulatan, Koordinat, Graf Fungsi, etc. |
| **Form 3** | Indeks, Garis Lurus | Bab 1, 9 | Bentuk Piawai, Matematik Pengguna, Trigonometri, etc. |

**Note:** Topic IDs follow DSKP chapter numbering (e.g., F1-05 = Form 1 Bab 5). Algebra topics are built first (Weeks 1-3), other topics backfilled (Weeks 4-6).

---

## KSSM Algebra Topic Map (DSKP-Aligned)

Topic IDs follow DSKP chapter numbering: `F{form}-{chapter}`.

```
Form 1 Algebra (3 topics â€” DSKP Bab 5, 6, 7)
â”œâ”€â”€ F1-05 Ungkapan Algebra (Algebraic Expressions)
â”œâ”€â”€ F1-06 Persamaan Linear (Linear Equations)
â””â”€â”€ F1-07 Ketaksamaan Linear (Linear Inequalities)

Form 2 Algebra (3 topics â€” DSKP Bab 1, 2, 3)
â”œâ”€â”€ F2-01 Pola dan Jujukan (Patterns & Sequences)
â”œâ”€â”€ F2-02 Pemfaktoran dan Pecahan Algebra (Factorisation & Algebraic Fractions)
â””â”€â”€ F2-03 Rumus Algebra (Algebraic Formulae)

Form 3 Algebra (2 topics â€” DSKP Bab 1, 9)
â”œâ”€â”€ F3-01 Indeks (Indices)
â””â”€â”€ F3-09 Garis Lurus (Straight Lines)
```

**Total Algebra topics: 8** â€” the primary validation set.

---

## DAY 0 â€” SETUP âœ…

| Task ID | Task | Owner | Time | Status |
|---------|------|-------|------|--------|
| `O-D0-1` | Initialize repo: `curricula/`, `schema/`, `concepts/`, `taxonomy/`, `scripts/`, `.github/workflows/` | ðŸ¤– Claude Code | 30min | âœ… Done |
| `O-D0-2` | Create 4 schemas: `topic`, `assessments`, `syllabus`, `subject` (JSON Schema Draft 2020-12). Remaining schemas (`examples`, `concept`, `taxonomy`) are created as their content types are first introduced. | ðŸ¤– Claude Code | 1hr | âœ… Done |
| `O-D0-3` | Create `curricula/malaysia/kssm/matematik-tingkatan1/syllabus.yaml` with board metadata | ðŸ¤– Claude Code | 30min | âœ… Done |
| `O-D0-4` | ðŸ§‘ Choose first 5 Algebra topics against official DSKP (Form 1: 3 topics + Form 2: 2 topics) | ðŸ§‘ Education Lead | 30min | âœ… Done |

**Exit:** Repo exists with schema files and syllabus structure for KSSM Matematik Form 1. âœ… **Completed**

---

## WEEK 1 â€” FORM 1 ALGEBRA CONTENT

### Day 1 (Mon) â€” Form 1 Algebra Topics (3 topics)

| Task ID | Task | Owner | Time | Status |
|---------|------|-------|------|--------|
| `O-W1D1-1` | Create `curricula/malaysia/kssm/matematik-tingkatan1/subjects/algebra.yaml` â€” subject metadata | ðŸ¤– | 15min | âœ… Done |
| `O-W1D1-2` | Create topic YAML stubs for F1-05, F1-06, F1-07: id, name, prerequisites, learning_objectives, difficulty, bloom_levels | ðŸ¤– | 30min | âœ… Done |
| `O-W1D1-3` | ðŸ§‘ Write F1-05 teaching notes (`05-ungkapan-algebra.teaching.md`) â€” real teacher quality, conversational, KSSM-aligned | ðŸ§‘ Education Lead | 2hr | âœ… Done |
| `O-W1D1-4` | ðŸ§‘ðŸ¤– AI-draft teaching notes for F1-06 and F1-07, Education Lead reviews and edits | Collaborative | 2hr | âœ… Done |

### Day 2 (Tue) â€” Assessments for Form 1 Algebra

| Task ID | Task | Owner | Time | Status |
|---------|------|-------|------|--------|
| `O-W1D2-1` | ðŸ§‘ Write 10 assessment questions for F1-05 (Ungkapan Algebra): answers, rubrics, hints, difficulty spread | ðŸ§‘ Education Lead | 2hr | âœ… Done |
| `O-W1D2-2` | ðŸ¤– AI-generate assessments for F1-06 (15 questions), Education Lead reviews and expands | Collaborative | 2hr | âœ… Done |
| `O-W1D2-3` | ðŸ¤– AI-generate assessments for F1-07 (10 questions), Education Lead reviews | Collaborative | 2hr | âœ… Done |
| `O-W1D2-4` | Create `.yamllint.yml` with formatting rules | ðŸ¤– | 15min | âœ… Done |

### Day 3 (Wed) â€” Validation Pipeline

| Task ID | Task | Owner | Status |
|---------|------|-------|--------|
| `O-W1D3-1` | GitHub Actions workflow `validate.yml`: yamllint + ajv-cli validation of all YAML against schemas | ðŸ¤– | âœ… Done |
| `O-W1D3-2` | `scripts/validate.sh` â€” run all schema validations locally | ðŸ¤– | âœ… Done |
| `O-W1D3-3` | Validate all existing content passes CI | ðŸ¤– | âœ… Done |

### Day 4 (Thu) â€” Form 2 Algebra Begins (3 topics)

| Task ID | Task | Owner | Status |
|---------|------|-------|--------|
| `O-W1D4-1` | Create `curricula/malaysia/kssm/matematik-tingkatan2/syllabus.yaml` + `subjects/algebra.yaml` | ðŸ¤– | âœ… Done |
| `O-W1D4-2` | Create topic YAML stubs for F2-01, F2-02, F2-03 with prerequisites linking to Form 1 | ðŸ¤– | âœ… Done |
| `O-W1D4-3` | ðŸ§‘ Write F2-02 teaching notes (Pemfaktoran dan Pecahan Algebra) â€” key topic, highest misconception rate | ðŸ§‘ Education Lead (2hr) | âœ… Done (Prepared by Thoriq, reviewed by Faiz) |
| `O-W1D4-4` | ðŸ§‘ðŸ¤– AI-draft teaching notes for F2-01 and F2-03 | Collaborative | âœ… Done (1st review by Thoriq, 2nd review by Faiz) |

### Day 5 (Fri) - Quality Check

| Task ID | Task | Owner | Status |
|---------|------|-------|--------|
| `O-W1D5-1` | Education Lead review of all Week 1 content for KSSM accuracy: BM/EN terminology and scope per form | Education Lead (2hr) | ✅ Done (QA report completed; issues #1-#4 resolved) |
| `O-W1D5-2` | Fix any schema validation failures | Claude Code | ⏳ In progress |

**Week 1 Output:** 6 topic YAMLs (F1: 3, F2: 3), 6 teaching notes, 15+ assessment questions. All pass CI.

---

## WEEK 2 â€” FORM 2 & 3 ALGEBRA + ASSESSMENTS

### Day 6 (Mon) â€” Form 2 Assessments

| Task ID | Task | Owner | Status |
|---------|------|-------|--------|
| `O-W2D6-1` | ðŸ§‘ Write assessments for F2-01, F2-02, F2-03 (5 questions each, Algebra focus) | ðŸ§‘ Education Lead (3hr) | âœ… Done (completed by Thoriq) |
| `O-W2D6-2` | ðŸ§‘ðŸ¤– AI-draft additional assessment questions for all F2 topics | Collaborative | âœ… Done |

**Implementation note (Mar 2026):** Form 2 learning objective IDs were aligned from `LOx` style to DSKP code format (for example `1.1.1`, `2.2.3`, `3.1.4`) to match PR #1 convention updates.

### Day 7 (Tue) â€” Form 3 Algebra Structure

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W2D7-1` | Create `curricula/malaysia/kssm/matematik-tingkatan3/syllabus.yaml` + `subjects/algebra.yaml` | ðŸ¤– |
| `O-W2D7-2` | Create topic YAML stubs for F3-01 and F3-09 with prerequisites linking to Form 2 | ðŸ¤– |
| `O-W2D7-3` | ðŸ§‘ Write F3-01 teaching notes (Indeks â€” Indices) | ðŸ§‘ Education Lead (2hr) |
| `O-W2D7-4` | ðŸ§‘ðŸ¤– AI-draft teaching notes for F3-09 (Garis Lurus) | Collaborative |

### Day 8 (Wed) â€” Form 3 Assessments

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W2D8-1` | ðŸ§‘ Write assessments for F3-01 and F3-09 (5 questions each) | ðŸ§‘ Education Lead (2hr) |
| `O-W2D8-2` | ðŸ§‘ðŸ¤– AI-draft additional assessment questions for F3 topics | Collaborative |

### Day 9 (Thu) â€” Cross-Form Prerequisites + Concepts

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W2D9-1` | `scripts/check-prerequisites.py` â€” detect cycles in prerequisite graph across all 3 forms | ðŸ¤– |
| `O-W2D9-2` | `scripts/check-references.py` â€” verify all topic_id and syllabus_id references are valid | ðŸ¤– |
| `O-W2D9-3` | Create `concepts/mathematics/linear-equation.yaml` bridging F1â†’F2â†’F3 linear equations | ðŸ¤– |
| `O-W2D9-4` | Create `concepts/mathematics/algebraic-expression.yaml` bridging expansion/factorisation across forms | ðŸ¤– |
| `O-W2D9-5` | ðŸ§‘ Verify prerequisite chain: can a Form 1 student's mastery correctly unlock Form 2 topics? | ðŸ§‘ Education Lead |

### Day 10 (Fri) â€” Quality Audit

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W2D10-1` | `scripts/assess-quality.py` â€” auto-assess quality levels for all topics | ðŸ¤– |
| `O-W2D10-2` | Add quality report to CI (runs on merge to main) | ðŸ¤– |
| `O-W2D10-3` | ðŸ§‘ Full quality audit: are all 8 Algebra topics at Level 3 (Teachable)? Fix any that aren't. | ðŸ§‘ Education Lead |

**Week 2 Output:** All 8 Algebra topics complete (F1:3 + F2:3 + F3:2). 40+ assessment questions. Prerequisite chain validated across 3 forms. Quality Level â‰¥3 for all topics.

---

## WEEK 3 â€” WORKED EXAMPLES + MALAY TRANSLATIONS

### Day 11 (Mon) â€” Examples Schema + Form 1 Examples

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W3D11-1` | Create `schema/examples.schema.json` | ðŸ¤– |
| `O-W3D11-2` | ðŸ§‘ðŸ¤– Create worked examples for F1-05, F1-06, F1-07 (3 examples each, progressive difficulty) | Collaborative (3hr) |

### Day 12 (Tue) â€” Form 2 & 3 Examples

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W3D12-1` | ðŸ§‘ðŸ¤– Create worked examples for F2-01, F2-02, F2-03 | Collaborative (3hr) |
| `O-W3D12-2` | ðŸ§‘ðŸ¤– Create worked examples for F3-01 and F3-09 | Collaborative (2hr) |

### Day 13 (Wed) â€” Malay Translation Structure

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W3D13-1` | Create `locales/ms/` directory structure mirroring all 3 forms | ðŸ¤– |
| `O-W3D13-2` | ðŸ§‘ðŸ¤– Translate Form 1 topic names, learning objectives, misconceptions to Bahasa Melayu | Collaborative |
| `O-W3D13-3` | ðŸ§‘ðŸ¤– Translate Form 1 teaching notes to BM (since KSSM students learn in Malay) | Collaborative |

### Day 14 (Thu) â€” Form 2 & 3 Translations

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W3D14-1` | ðŸ§‘ðŸ¤– Translate Form 2 topics + teaching notes to BM | Collaborative |
| `O-W3D14-2` | ðŸ§‘ðŸ¤– Translate Form 3 topics + teaching notes to BM | Collaborative |
| `O-W3D14-3` | ðŸ§‘ Native speaker review of all BM translations â€” correct mathematical terminology | ðŸ§‘ Education Lead |

### Day 15 (Fri) â€” Taxonomy + Documentation

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W3D15-1` | Create `taxonomy/mathematics/algebra.yaml` â€” classification tree for KSSM algebra | ðŸ¤– |
| `O-W3D15-2` | Write CONTRIBUTING.md: 3 contribution paths (teacher, developer, AI), YAML format guide with examples | ðŸ¤– |
| `O-W3D15-3` | Write comprehensive README.md: what it is, structure, how to consume, how to contribute | ðŸ¤– |

**Week 3 Output:** 24 worked examples. Malay translations for all 8 Algebra topics. Taxonomy defined. Docs complete.

---

## WEEK 4 â€” NON-ALGEBRA TOPIC STUBS + QUALITY

### Day 16-17 (Mon-Tue) â€” Form 1 Non-Algebra Topics

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W4D16-1` | Create non-algebra subjects for Form 1: `numbers.yaml`, `measurement.yaml`, `statistics.yaml` | ðŸ¤– |
| `O-W4D16-2` | Create Level 0-1 topic stubs for Form 1 non-algebra (8-10 topics): id, name, LOs, prerequisites, difficulty | ðŸ¤– |
| `O-W4D16-3` | ðŸ§‘ðŸ¤– Elevate 3 high-priority Form 1 non-algebra topics to Level 2 (add misconceptions, teaching sequence) | Collaborative |

### Day 18 (Wed) â€” Form 2 & 3 Non-Algebra Topics

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W4D18-1` | Create Level 0-1 stubs for Form 2 non-algebra (8-10 topics) | ðŸ¤– |
| `O-W4D18-2` | Create Level 0-1 stubs for Form 3 non-algebra (8-10 topics) | ðŸ¤– |
| `O-W4D18-3` | ðŸ§‘ Verify all prerequisite links across Algebra and non-Algebra topics are correct | ðŸ§‘ Education Lead |

### Day 19-20 (Thu-Fri) â€” More Assessments + Quality

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W4D19-1` | ðŸ§‘ Add 5 MORE assessment questions per Algebra topic (bringing total to 10/topic = 80 total) | ðŸ§‘ Education Lead |
| `O-W4D19-2` | ðŸ§‘ Add harder "exam-style" questions for Form 3 topics (PT3 exam format) | ðŸ§‘ Education Lead |
| `O-W4D20-1` | Run full quality report: how many topics at each level? | ðŸ¤– |
| `O-W4D20-2` | ðŸ§‘ Ensure ALL 8 Algebra topics are at Quality Level 3+ (Teachable) | ðŸ§‘ Education Lead |

**Week 4 Output:** ~25 non-algebra topic stubs. 80+ algebra assessment questions. Full quality report.

---

## WEEK 5 â€” OPEN SOURCE PREP

### Day 21-22 (Mon-Tue) â€” Documentation + Cleanup

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W5D21-1` | Create "good first issues" for community: add teaching notes for stub topics, translate to Chinese, improve an assessment | ðŸ¤– |
| `O-W5D21-2` | Create CODEOWNERS: Education Lead auto-assigned on all content PRs | ðŸ¤– |
| `O-W5D21-3` | Create issue templates: new-topic, improve-content, translation, bug-report | ðŸ¤– |
| `O-W5D22-1` | `scripts/export-sqlite.py` â€” generate SQLite export of all curriculum data for offline apps | ðŸ¤– |
| `O-W5D22-2` | Add SQLite export to release workflow: tagged release generates downloadable oss.sqlite | ðŸ¤– |

### Day 23 (Wed) â€” Final Validation

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W5D23-1` | Run full CI: all YAML validates, no prerequisite cycles, all references valid, quality report clean | ðŸ¤– |
| `O-W5D23-2` | ðŸ§‘ Final read-through of every teaching note and assessment for KSSM accuracy | ðŸ§‘ Education Lead |

### Day 24-25 (Thu-Fri) â€” Pre-Launch

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W5D24-1` | Tag v0.1.0: first public release (8 Algebra topics at Level 3+, 25+ non-algebra stubs) | ðŸ¤– |
| `O-W5D25-1` | ðŸ§‘ Prepare curriculum section of launch blog: "Open School Syllabus â€” covering KSSM F1-F3 Matematik" | ðŸ§‘ Human |

**Week 5 Output:** Repo public-ready. v0.1.0 tagged. 10+ good first issues. SQLite export available.

---

## WEEK 6 â€” LAUNCH + COMMUNITY

### Day 26 (Mon) â€” LAUNCH DAY

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W6D26-1` | ðŸ§‘ Publish repo publicly. Announce alongside pai-bot. | ðŸ§‘ Human |
| `O-W6D26-2` | ðŸ§‘ Post in Malaysian teacher communities: Telegram groups, Facebook groups for Guru Matematik | ðŸ§‘ Human |

### Day 27-28 (Tue-Wed) â€” Community Response

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W6D27-1` | ðŸ§‘ Respond to every issue and PR within 24 hours | ðŸ§‘ Team |
| `O-W6D28-1` | ðŸ§‘ Based on feedback, identify most-requested additional content (Chinese/Tamil translations? Science?) | ðŸ§‘ Human |

### Day 29-30 (Thu-Fri) â€” First Community Contributions

| Task ID | Task | Owner |
|---------|------|-------|
| `O-W6D29-1` | ðŸ§‘ Review and merge first community PRs. Be generous with praise. | ðŸ§‘ Education Lead |
| `O-W6D30-1` | ðŸ§‘ Write curriculum section of 6-week report: coverage stats, quality levels, community contributions | ðŸ§‘ Human |

**Week 6 Output:** Public repo with community engagement. First external contributions. 5+ external contributors.

---

## Content Delivery Summary

| Milestone | Algebra Topics | Non-Algebra Topics | Assessment Qs | Teaching Notes | Translations |
|-----------|---------------|--------------------|--------------|--------------|-|
| End Week 1 | 6 (F1:3, F2:3) | 0 | 15+ | 6 (BM & EN) | 0 |
| End Week 2 | 8 (all) | 0 | 40+ | 8 (all) | 0 |
| End Week 3 | 8 | 0 | 40+ | 8 | 8 (Malay) |
| End Week 4 | 8 | ~25 stubs | 80+ | 8+ | 8 |
| End Week 5 | 8 | ~25 | 80+ | 8+ | 8 |
| End Week 6 | 8 | ~25+ | 80+ | 8+ | 8+ |
 
