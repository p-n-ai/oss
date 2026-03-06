# O-W1D5-1 QA Report (KSSM Week 1 Content Review)

Task ID: `O-W1D5-1`  
Reviewer: Faiz (Education Lead)  
Date: 2026-03-06  
Scope: Form 1 Algebra Week 1 content in `oss`

## 1) Files Reviewed

- `curricula/malaysia/kssm/matematik-tingkatan1/subjects/algebra.yaml`
- `curricula/malaysia/kssm/matematik-tingkatan1/topics/algebra/05-ungkapan-algebra.yaml`
- `curricula/malaysia/kssm/matematik-tingkatan1/topics/algebra/06-persamaan-linear.yaml`
- `curricula/malaysia/kssm/matematik-tingkatan1/topics/algebra/07-ketaksamaan-linear.yaml`
- `curricula/malaysia/kssm/matematik-tingkatan1/topics/algebra/05-ungkapan-algebra.teaching.md`
- `curricula/malaysia/kssm/matematik-tingkatan1/topics/algebra/06-persamaan-linear.teaching.md`
- `curricula/malaysia/kssm/matematik-tingkatan1/topics/algebra/07-ketaksamaan-linear.teaching.md`
- `curricula/malaysia/kssm/matematik-tingkatan1/topics/algebra/05-ungkapan-algebra.assessments.yaml`
- `curricula/malaysia/kssm/matematik-tingkatan1/topics/algebra/06-persamaan-linear.assessments.yaml`
- `curricula/malaysia/kssm/matematik-tingkatan1/topics/algebra/07-ketaksamaan-linear.assessments.yaml`

## 2) QA Checklist Summary

| Topic | DSKP Scope | BM/EN Terminology | Teaching Flow | Assessment-LO Fit | Prereq Links | Status |
|---|---|---|---|---|---|---|
| F1-05 | Pass (minor LO mismatch noted) | Pass | Pass | Pass | Pass | Pass with minor fixes |
| F1-06 | Pass | Pass | Pass | Pass | Pass | Pass |
| F1-07 | **Fail (format/detail inconsistency in DSKP section)** | Pass | Pass | Pass | Pass | Needs fix |

## 3) Issue Log

| ID | Topic/File | Severity | Finding | Suggested Fix | Owner | Status |
|---|---|---|---|---|---|---|
| 1 | `07-ketaksamaan-linear.teaching.md` | High | DSKP section is summarized (`Standard Kandungan` only) and does not use full SK/SP breakdown style used in F1-05/F1-06. | Rewrite DSKP Anchors to full `Standard Kandungan & Pembelajaran` format with explicit SP numbering and full TP phrasing. | EL | Open |
| 2 | `05-ungkapan-algebra.yaml` vs `05-...teaching.md` | Medium | LO alignment mismatch: teaching notes include 5.1.5 (like/unlike terms), but YAML learning objectives do not include 5.1.5 explicitly. | Add LO 5.1.5 in YAML (or adjust teaching notes if intentionally excluded). | EL | Open |
| 3 | `05-...assessments.yaml` and teaching markdown files | Medium | Character encoding artifacts observed (e.g., `Ã—`, `â€”`). | Normalize files to UTF-8 and clean mojibake text to avoid display confusion. | BE/EL | Open |
| 4 | `05/06/07 *.yaml` metadata | Low | `provenance` appears as `ai-generated` even where content has human review/completion notes elsewhere. | Decide if provenance should represent initial draft only or final reviewed state; standardize policy. | BE-B + EL | Open |

## 4) Validation Check

- [x] File-level content review completed.
- [ ] Local script validation run (`scripts/validate.sh`) in this environment.
- [ ] CI-equivalent local validation completed.

Validation notes:

```text
`scripts/validate.sh` exists but this Windows environment does not provide bash/sh runtime.
Recommended: run validation in CI or a shell-enabled environment before closing all issues.
```

## 5) Final Decision

- Overall status: `PASS WITH MAJOR FIXES REQUIRED`
- Recommendation for timeline:
  - [ ] Mark `O-W1D5-1` as `Done`
  - [x] Keep `O-W1D5-1` open until issue #1 and #2 are fixed

Summary:

```text
Form 1 Week 1 content is mostly pedagogically strong and assessment coverage is usable.
However, F1-07 DSKP anchor formatting/detail is not aligned with F1-05/F1-06 standard,
and F1-05 LO mapping has one objective mismatch (5.1.5). Encoding cleanup is also needed.
Close O-W1D5-1 after these fixes and a validation run.
```

