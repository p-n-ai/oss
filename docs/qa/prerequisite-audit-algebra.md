# Curriculum Prerequisites Audit Report (Form 1 - Form 3 Algebra)
**Date:** 17 March 2026
**Task ID:** O-W2D9-5
**Auditor:** Education Lead (Faiz) 
**Status:** In Progress
---

## A. Summary
The overall health of the prerequisite chain is **Moderate**. While the baseline connections correctly link fundamental expression handling (F1-05) to heavier manipulation tasks (F2-02, F2-03), there are significant **missing prerequisites for equation-solving applications** and an alarming **misrepresentation of the `F1-06` scope** in the concept files. Many Form 2 and Form 3 topics implicitly assume linear equation mastery (F1-06) without formally requiring it in the YAML configuration.

---

## B. Critical Issues (Must Fix)

| Status | Topic ID | Issue in Prerequisite Mapping | Why it is a problem | Suggested Fix |
|:---:| :--- | :--- | :--- | :--- |
| ⬜ | **F1-07** (Linear Inequalities) | `F1-06` (Linear Eq) is mapped as *recommended*, not *required*. | Solving linear inequalities (e.g., $2x + 1 > 7$) is functionally identical to solving linear equations. A student who cannot balance an equation cannot balance an inequality. | Upgrade `F1-06` to **required** in `07-ketaksamaan-linear.yaml`. |
| ⬜ | **F3-01** (Indices) | Missing `F1-06` (Linear Eq) in *required*. | The highest cognitive jump in Forms 3 Indices (Subchapter 1.2.7) requires solving index equations (e.g., $3^{2x-1} = 27 \rightarrow 2x-1 = 3$). A student lacking `F1-06` mastery will be structurally blocked here. | Add `F1-06` to **required** in `01-indeks.yaml`. |
| ⬜ | **F2-01** (Patterns & Sequences) | `F1-06` (Linear Eq) is mapped as *missing/recommended*. | Students are required to find the $n$-th position of a term (e.g., if $T_n = 5n - 2$ equals 48, find $n$). This requires manipulating the simple equation $5n - 2 = 48$. | Upgrade `F1-06` to **required** in `01-pola-dan-jujukan.yaml`. |

---

## C. Learning Gaps

1. **Graphical Intersections vs. Coordinate Geometry**
   - **Required Skill:** Understanding what an intersection means graphically. 
   - **Where introduced:** Taught aggressively early in Form 1 (**F1-06**) via Simultaneous Linear Equations.
   - **Impacted topics:** Without formal $y = mx + c$ principles (which only appear two years later in **F3-09**), Form 1 students are forced to plot simultaneous lines using crude substitution. The conceptual bridge between F1-06 intersections and F3-09 formal slope/gradient logic is empty for all of Form 2, leading to major cognitive dissonance over "straight lines".

2. **Solving equations via algebraic fractions**
   - **Required Skill:** Solving $x$ when $x$ is trapped in a denominator.
   - **Where introduced:** **F2-02** (Algebraic fractions) teaches the calculation, but the cross-application only happens loosely before **F2-03** (Formulae). 
   - **Impacted topics:** Students will struggle with subject formulas involving denominators (e.g. $y = \frac{k}{x}$ ) because the equation mechanics (F1-06) and fraction mechanics (F2-02) were never purposefully merged prior to F2-03.

---

## D. Concept Coverage Issues

**1. `concepts/mathematics/linear-equation.yaml`**
*   **Missing Subskill / Factual Error:** The file explicitly declares the `F1-06` scope as *"Linear equations in one variable, basic solving"*. This is **categorically false**. The `F1-06` topic syllabus objectives clearly dictate solving *"simultaneous linear equations in two variables using various methods and graphical representation"*.
*   **Redundant Concept:** By underselling F1-06, the scope for `F3-09` (*"Straight lines, linear equations in two variables, and intersection reasoning"*) seems like an introductory concept, when in fact students already covered "intersection reasoning" graphically in Form 1. 

**2. `concepts/mathematics/algebraic-expression.yaml`**
*   **Poor Sequencing (Missing Knots):** The progression jumps linearly from substitution (**F1-05**) straight to expansion/factorisation (**F2-02**) and indices (**F3-01**). It completely ignores **F2-01** (generalising algebraic patterns like $3n+1$) and **F2-03** (algebraic formula manipulation), which are essential milestones of "Expression manipulation" mapped across the syllabus.

---

## E. Progression Breakdown (F1 $\rightarrow$ F2 $\rightarrow$ F3)

**Linear Equation Chain (F1-06 $\rightarrow$ F2-03 $\rightarrow$ F3-09)**
*   *Progression:* Students handle $ax+b=c$ and $(ax+by=c)$ in Form 1 (huge load). In Form 2, they make variables the subject of formulas (F2-03). In Form 3, they structure these directly into $y=mx+c$ formats (F3-09). 
*   *Weak Transition:* The transition from F2-03 to F3-09 is incredibly smooth. However, the internal F1-06 leap going from one-variable straight to simultaneous 2-variable graphs in the same month is historically the biggest failure point for KSSM Form 1 students.

**Algebraic Expression Chain (F1-05 $\rightarrow$ F2-02 $\rightarrow$ F3-01)**
*   *Progression:* Great scaling of symbolic notation. They learn single terms in Form 1, binomial expansion/brackets in Form 2, and formal index manipulations in Form 3. 
*   *Weak Transition:* The integration of F2-02 (Factorisation) into F3-01 (Indices) is slightly messy because Index equations ($a^x$) behave fundamentally different from polynomial mechanics ($x^a$). 

---

## F. Recommendations

1. **Mandatory YAML Adjustments:**
   * Edit `07-ketaksamaan-linear.yaml`, `01-pola-dan-jujukan.yaml`, and `01-indeks.yaml` to move `F1-06` from `recommended` (or non-existent) to the `required` dependencies list.
2. **Refactor Concept Nodes:** 
   * Edit `linear-equation.yaml` to include *"simultaneous linear equations graphically and algebraically"* in the F1-06 scope. 
3. **Teaching Notes Realignment:** 
   * The Teaching Notes for F1-06 must specifically "throttle" the graphical simultaneous intersection subchapters so teachers don't attempt to teach $y = mx + c$ properties too early (stealing the difficulty from F3-09). 

---

## G. Simulated Student Failure Cases

**Case 1: The Inequality Blocker (F1-07)**
*   *What they don’t understand:* Student attempts to solve $4x - 5 > 15$ and cannot isolate $x$ using inverse operations (adding 5, dividing by 4).
*   *Which prerequisite failed:* **F1-06** (Linear Equations). Since it was only flagged as a "recommended" dependency, the routing script allowed them to bypass mastery of balancing equations.
*   *How to fix:* Hard-lock F1-07 until an F1-06 mastery score of $\ge 0.75$ is verified.

**Case 2: The Index Equation Wall (F3-01)**
*   *What they don’t understand:* Despite perfectly applying index laws to reach $3^{2x-1} = 3^3$, the student cannot algebraically secure the calculation $2x - 1 = 3 \rightarrow x=2$.
*   *Which prerequisite failed:* **F1-06** (Linear Equations). They inherently grasp indices but possess zero intuition for two-step algebraic solving.
*   *How to fix:* Mapping `F1-06` as a hard requirement for F3-01 immediately fixes this pathing issue.

**Case 3: The "Subject of Formula" Lockout (F2-03)**
*   *What they don’t understand:* A student attempting to make $r$ the subject in $p = qr - sr$ is helplessly stuck. 
*   *Which prerequisite failed:* **F2-02** (Factorisation). They don't know the core mechanic of extracting a common bracket to get $p = r(q-s)$. 
*   *How to fix:* The prerequisite is mapped correctly in the YAML! However, the AI tutor must recognize the specific failure point inside F2-03 and deploy a fallback dynamic micro-lesson on "Factoring Common Variables" (pulling an F2-02 snippet) rather than explaining F2-03 mechanics.
