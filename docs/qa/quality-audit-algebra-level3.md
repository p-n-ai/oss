# Quality Audit Report (Level 3: Teachable) - Algebra F1-F3
**Date:** 18 March 2026
**Task ID:** O-W2D10-3
**Auditor:** Education Lead (Faiz) 
**Status:** In Progress
---

## 🎯 Audit Objective
To perform a full quality review of all 8 KSSM Algebra topics (Form 1 to Form 3) and ensure they meet the **Level 3 "Teachable" Standard**. This means the AI Tutor has all the necessary content, metadata, pacing instructions, and assessment tools to confidently teach a student.

## 📚 The 8 Algebra Topics
- **F1-05:** Ungkapan Algebra  
- **F1-06:** Persamaan Linear  
- **F1-07:** Ketaksamaan Linear  
- **F2-01:** Pola dan Jujukan  
- **F2-02:** Pemfaktoran dan Pecahan Algebra  
- **F2-03:** Rumus Algebra  
- **F3-01:** Indeks  
- **F3-09:** Garis Lurus  

---

## 📋 Quality Criteria (Level 3 Standard)

To pass the audit, every topic must fulfil the following criteria:

### 1. Structure & Metadata (`[topic_id].yaml`)
- [ ] Contains correct DSKP `learning_objectives` with mapped Bloom’s levels.
- [ ] Proper minimum score, assessment count, and spaced repetition logic defined.
- [ ] Links both the `teaching.md` (AI Teaching Notes) and `assessments.yaml` files.
- [ ] Prerequisites are accurately defined (already audited in O-W2D9-5).

### 2. Teaching Notes (`[topic_id].teaching.md`)
- [ ] Conversational and pedagogical tone for the AI tutor to adopt.
- [ ] **Bite-Sized Delivery:** Content is structured to be delivered in short chat bubbles (max 2-3 paragraphs at a time) rather than walls of text.
- [ ] **Check for Understanding (CFU):** Frequent pause points where the AI asks the student to confirm understanding before moving on.
- [ ] **Tone & Localization:** Tone is approachable, encouraging, and primed to understand KSSM-specific terminology/mixed languages ("Dwibahasa").
- [ ] **High Alert Misconceptions:** Explicitly listed "traps" to help the AI anticipate common student errors.
- [ ] **Curriculum Guardrails:** Instructions preventing the AI from accidentally teaching higher-level concepts too early.

### 3. Assessments (`[topic_id].assessments.yaml`)
- [ ] Covers a diverse range of questions across Cognitive levels (TP1 to TP6).
- [ ] Minimum of 10-15 questions to ensure robust testing capabilities.
- [ ] **Input Tolerance Rules:** Rubric explicitly instructs the AI to accept equivalent algebraic expressions (e.g., $x+y$ and $y+x$, ignoring spacing).
- [ ] **Scaffolded Hints:** Hints progressively reveal the answer (Hint 1: Concept -> Hint 2: Setup -> Hint 3: First step) rather than giving the answer away immediately.
- [ ] Uses strict YAML formatting (e.g., folded scalars `>-` for multi-line text).
- [ ] Mathematical notation uses correct LaTeX, but is verified to be readable in standard chat apps (or platform limits are accounted for).

### 4. Live Chat Simulation (Dry Run)
- [ ] Run one "happy path" (student gets it right).
- [ ] Run one "struggle path" (student gets it wrong, needs Dwibahasa support, handles equivalent expression input).

---

## 🔍 Audit Progress / Findings Tracker

*(We will update this matrix as we audit each topic)*

| Form | Topic ID | Metadata YAML | Teaching Notes | Assessments YAML | Status / Remarks |
|:---|:---|:---:|:---:|:---:|:---|
| F1 | `F1-05` | ✅ | ✅ | ✅ | Done (Batch 1) - Added CFU & Input Tolerance |
| F1 | `F1-06` | ✅ | ✅ | ✅ | Done (Batch 1) - Added CFU & Input Tolerance |
| F1 | `F1-07` | ✅ | ✅ | ✅ | Done (Batch 1) - Added CFU & Input Tolerance |
| F2 | `F2-01` | ⬜ | ⬜ | ⬜ | pending review |
| F2 | `F2-02` | ⬜ | ⬜ | ⬜ | pending review |
| F2 | `F2-03` | ⬜ | ⬜ | ⬜ | pending review |
| F3 | `F3-01` | ⬜ | ⬜ | ⬜ | pending review |
| F3 | `F3-09` | ⬜ | ⬜ | ⬜ | pending review |

---

## 🛑 Action Items & Fixes Required
*(Any gaps discovered during the audit will be documented here for resolution.)*

1. *None yet - starting audit.*
