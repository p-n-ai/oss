# Curriculum Development Maturity Levels (0-3)

This document defines the 4 stages of content maturity for any given topic in the KSSM Mathematics curriculum. These levels ensure that the AI Tutor has sufficient pedagogical context before being "unlocked" for student interaction.

---

### Phase 1: Level 0-1 — The Metadata Stub
*   **Status:** Skeletal/Structural
*   **Purpose:** To map out the curriculum tree and prerequisite dependencies without writing full content.
*   **Mandatory Fields:**
    *   `id`: (e.g., MT3-01)
    *   `name_en`: Official KSSM Title (English)
    *   `content_standards`: Standard Kandungan grouping.
    *   `learning_objectives`: High-level goals from the DSKP.
    *   `prerequisites`: ID links to earlier topics.
    *   `difficulty`: Initial assessment (1-5).

---

### Phase 2: Level 2 — Pedagogical Enrichment
*   **Status:** Drafted/Instructional
*   **Purpose:** To provide the "Teacher's Brain" for the AI, focusing on how a student usually fails and how the AI should react.
*   **Mandatory Additions:**
    *   **Common Misconceptions:** 3-5 high-alert error patterns.
    *   **Teaching Sequence:** The logic flow for the AI to follow.
    *   **Draft Teaching Notes:** Initial `teaching.md` content following the 7 Pillars.

---

### Phase 3: Level 3 — The Golden Version (Teachable)
*   **Status:** Production-Ready / Fully Audited
*   **Purpose:** The final, high-fidelity version of the topic, fully aligned with the **Golden Format v2**. This level is required before a topic is considered "Completed" in the repository.
*   **Mandatory Requirements:**
    *   **Bilingual Parity:** Both English (Root) and Malay (Translation) files are fully audited and synced.
    *   **Assessment Coverage:** 10-15 questions in `assessments.yaml` (min coverage of OAP, OPB, Subjective).
    *   **Worked Examples:** 3+ examples in `examples.yaml` with Scenario, Analogy, Alert, and Working.
    *   **Holistic Assessment:** Includes a defined **Chatbot Projek Mini** (TP6) requiring physical/creative student interaction.
    *   **Integration:** Explicit STEM/Technology hooks (e.g., GeoGebra/Excel).

---

### Quality Assurance (QA) Check
Topics move from Level 2 to Level 3 only after passing the 4 core auditor prompts:
1. `topic-metadata-prompt.md`
2. `teaching-notes-prompt.md`
3. `assessments-prompt.md`
4. `examples-prompt.md`

---

## 📊 Curriculum Development Progress Tracker

### Legend
*   **0️⃣** : Level 0 Stub (Metadata structurally incomplete)
*   **1️⃣** : Level 1 Base (Basic Metadata & LOs)
*   **2️⃣** : Level 2 Pedagogical Enrichment (Teaching logic added to Metadata)
*   **⏳** : Yet to create the file / translation
*   **🚧** : Drafted / AI Generated without standard QA
*   **✅** : Level 3 Teachable (Golden Version, fully audited)

### 📘 Form 1 (F1)

| Chapter | Meta (EN) | Meta (MS) | Teach (EN) | Teach (MS) | Assess (EN) | Assess (MS) | Exam (EN) | Exam (MS) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| MT1-01 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| MT1-02 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| MT1-03 | ✅ | ✅ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT1-04 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT1-05 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT1-06 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT1-07 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT1-08 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT1-09 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT1-10 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT1-11 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT1-12 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT1-13 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |

### 📗 Form 2 (F2)

| Chapter | Meta (EN) | Meta (MS) | Teach (EN) | Teach (MS) | Assess (EN) | Assess (MS) | Exam (EN) | Exam (MS) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| MT2-01 | 1️⃣ | 🚧 | ✅ | ✅ | ✅ | ⏳ | ✅ | ⏳ |
| MT2-02 | 1️⃣ | 🚧 | ✅ | ✅ | ✅ | ⏳ | ✅ | ⏳ |
| MT2-03 | 1️⃣ | 🚧 | ✅ | ✅ | ✅ | ⏳ | ✅ | ⏳ |
| MT2-04 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT2-05 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT2-06 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT2-07 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT2-08 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT2-09 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT2-10 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT2-11 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT2-12 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT2-13 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |

### 📕 Form 3 (F3)

| Chapter | Meta (EN) | Meta (MS) | Teach (EN) | Teach (MS) | Assess (EN) | Assess (MS) | Exam (EN) | Exam (MS) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| MT3-01 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| MT3-02 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT3-03 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT3-04 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT3-05 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT3-06 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT3-11 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT3-08 | 1️⃣ | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ | 🚧 | ⏳ |
| MT3-09 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
