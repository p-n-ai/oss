# Telegram Live Chat Simulation Results - Algebra (F1-F3)
**Date:** [Enter Date]
**Tester:** Education Lead (Faiz)
**Environment:** Telegram Bot (`pai-bot` staging)
**Status:** In Progress / Completed

---

## 🎯 Test Objective
To provide visual proof and documentation that the AI Tutor correctly follows the **Level 3: Teachable Standard** defined in the curriculum (`teaching.md` and `assessments.yaml`). Specifically, we are testing for:
1. **Bite-Sized Pacing** (no walls of text).
2. **Check for Understanding (CFU)** (pause and prompt).
3. **Tone & Dwibahasa** (approachable, handles Malay-English mixing).
4. **Input Tolerance** (accepts mathematically equivalent answers).

---

## 🟢 1. Happy Path Simulation
**Scenario:** A student easily understands the concept and answers the CFU prompt correctly. The AI should deliver a short explanation, ask a CFU, and smoothly transition to the next step upon receiving the correct answer.

### Evidence:
*(Insert screenshot here: e.g., `![Happy Path - Bite Sized Delivery](./assets/happy_path_01.png)`)*

### Notes / Observations:
- [ ] Did the AI stick to 1-2 short paragraphs? Yes / No
- [ ] Did the AI pause for the CFU prompt? Yes / No

---

## 🔴 2. Struggle Path Simulation
**Scenario:** A student gives a wrong answer or struggles to understand. They mix English and Malay ("Cikgu, I tak faham..."). The AI must adapt its tone, provide a scaffolded hint, and accept an equivalent variation of the correct answer (e.g., ignoring spaces or reversing terms like `y+8`).

### Evidence (Dwibahasa & Tone Support):
*(Insert screenshot here: e.g., `![Struggle Path - Dwibahasa](./assets/struggle_path_01.png)`)*

### Evidence (Input Tolerance / Equivalent Answers):
*(Insert screenshot here: e.g., `![Struggle Path - Input Tolerance](./assets/struggle_path_02.png)`)*

### Notes / Observations:
- [ ] Did the AI use KSSM terminology correctly? Yes / No
- [ ] Did the AI give a hint instead of just giving away the answer? Yes / No
- [ ] Did the AI accept an equivalent expression (e.g., $x+y$ and $y+x$)? Yes / No

---

## 🛑 Action Items / Bug Reports
*(Document any regressions or AI hallucinations here to pass back to the engineering team.)*

1. *None yet - starting test.*
