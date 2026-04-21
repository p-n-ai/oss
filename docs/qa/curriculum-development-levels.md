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
    *   `difficulty`: `beginner`, `intermediate`, or `advanced`.

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
    * - [x] Teaching Notes Standardization
    - [x] Write MT3-05 English Root Teaching Notes (MT3-05.teaching.md)
    - [x] Create MT3-05 Malay Translation Teaching Notes (translations/ms/MT3-05.teaching.md)
    - [x] Update Curriculum Progress Tracker for Teach
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

