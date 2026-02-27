# Open School Syllabus (OSS) — Business Plan

*Last updated: February 2026*

---

## Executive Summary

Open School Syllabus (OSS) is a structured, machine-readable, open curriculum repository — Wikipedia for curricula, but validated, versioned, and AI-ready. Every topic, learning objective, teaching strategy, misconception, and assessment is stored as schema-validated YAML that any learning platform, AI tutor, or educational tool can consume.

OSS is not a product. It is **shared infrastructure** for education — the same way OpenStreetMap is shared infrastructure for mapping. No single company should own the world's curricula. OSS makes them open, structured, and continuously improved by educators, AI agents, and student interaction data.

---

## Problem

### The Curriculum Duplication Problem

Every AI tutoring startup, every learning app, every school management system independently recreates the same curriculum data. They download syllabus PDFs, manually extract learning objectives, type them into proprietary databases, and build custom content around them. This work is repeated thousands of times across the industry.

**The waste is staggering:** An estimated 10,000+ organizations worldwide maintain private, incompatible copies of essentially the same educational standards. Each copy is incomplete, often outdated, and trapped behind proprietary walls.

### The AI Readiness Gap

LLMs can teach effectively when given structured curriculum context — but raw PDFs and unstructured documents produce inconsistent results. For an AI agent to teach quadratic equations well, it needs more than the syllabus specification. It needs the teaching sequence, common misconceptions with remediations, prerequisite mappings, graded assessment questions with rubrics, and pedagogical guidance specific to the conversation medium.

This structured, AI-ready curriculum data doesn't exist in any open, standardized form.

### The Contribution Bottleneck

Teachers are the world's largest repository of pedagogical knowledge — what works, what doesn't, what mistakes students make, what explanations click. But there is no mechanism for teachers to contribute this knowledge into a structured, machine-readable format that AI systems can use. The knowledge lives and dies in individual classrooms.

---

## Solution

OSS provides three things:

### 1. A Standard Schema for Curriculum Data

A set of JSON Schemas defining how to represent educational content in YAML:

- **Syllabus:** Top-level qualification (e.g., Cambridge IGCSE Mathematics 0580)
- **Subject:** Groups of related topics within a syllabus
- **Topic:** The core unit — learning objectives, prerequisites, teaching sequence, misconceptions, mastery criteria, Bloom's taxonomy mapping
- **Teaching Notes:** Markdown files written specifically for AI agents — how to teach this topic conversationally
- **Assessments:** Practice questions with rubrics, hints, distractors, and AI grading guidance
- **Examples:** Worked examples at varying difficulty
- **Concepts:** Universal concepts that bridge the same idea across different curricula

### 2. A Growing Repository of Validated Curriculum Content

Starting with Mathematics (Cambridge IGCSE + Malaysia KSSM), expanding to every subject and every national curriculum through community contributions.

Quality levels ensure consumers know what they're getting:
- ⬜ Level 0 (Stub): Name + learning objectives
- ⭐ Level 1 (Basic): + prerequisites, difficulty
- ⭐⭐ Level 2 (Structured): + teaching sequence, misconceptions
- ⭐⭐⭐ Level 3 (Teachable): + teaching notes, examples, assessments → **AI agents can teach effectively from this**
- ⭐⭐⭐⭐ Level 4 (Complete): + translations, cross-curriculum links, peer-reviewed
- ⭐⭐⭐⭐⭐ Level 5 (Gold): + validated by curriculum authority, backed by student data

### 3. A Self-Improving Feedback Loop

When consumed by [P&AI Bot](https://github.com/p-n-ai/pai-bot), the curriculum improves automatically. The AI agent observes patterns across thousands of students — misconceptions, effective explanations, engagement rates — and generates data-backed improvement suggestions. Educators review and merge them. The curriculum gets better because people use it.

---

## Target Users

### Primary: Learning Platform Builders

Developers building AI tutors, adaptive learning platforms, or educational apps. They consume OSS as a data dependency via Git clone, submodule, or API.

**Value:** Skip months of curriculum structuring. Start building product features on Day 1.

### Secondary: Educators

Teachers, curriculum designers, and education specialists. They contribute teaching notes, assessments, misconceptions, and translations.

**Value:** Their pedagogical expertise reaches millions of students through AI agents — not just their own classroom.

### Tertiary: Researchers

Education researchers studying curriculum alignment, pedagogical effectiveness, and cross-cultural learning patterns.

**Value:** First standardized, machine-readable dataset for cross-curriculum analysis.

### Institutional: Curriculum Authorities

National education ministries and exam boards (Cambridge, IB, College Board) who maintain official curricula.

**Value:** A structured, digital representation of their curriculum that education technology can consume programmatically — reducing misinterpretation and improving compliance.

---

## Content Strategy

### Seed Content (Weeks 0–4)

The Pandai team seeds the initial content from existing Pandai materials and official syllabus documents:

| Curriculum | Subject | Topics | Quality Target |
|-----------|---------|--------|----------------|
| Cambridge IGCSE 0580 | Mathematics | 8 (Algebra + Number) | Level 3 (Teachable) |
| Malaysia KSSM Form 3 | Mathematics | 5 | Level 3 (Teachable) |

Seeding is done by the Education Lead with Claude Code assistance: human writes teaching notes for 2–3 topics, AI generates drafts for the rest, human reviews and edits all.

### Growth Content (Weeks 5–12)

Three sources of new content:

1. **Community educators** — contribute via web form, GitHub issues, or direct PRs. The [OSS Bot](https://github.com/p-n-ai/oss-bot) structures natural language contributions into valid YAML.

2. **AI-assisted generation** — the OSS Bot scaffolds new syllabi from official PDF documents, generating Level 0–1 stubs that educators then enrich.

3. **P&AI feedback loop** — the P&AI Bot observes student interactions and generates data-backed improvement suggestions (tagged `ai-observed`, requiring educator review before merge).

### Scale Content (Month 3+)

Target: **50+ curricula scaffolded, 10+ at Level 3 (Teachable) within 12 months.** Growth is driven by demand — when a school in India deploys P&AI, Indian educators contribute CBSE content. Each deployment creates local contributors.

---

## Contribution Model

### Who Contributes What

| Contributor | What They Add | Volume | Quality |
|------------|---------------|--------|---------|
| **Pandai team** | Seed curricula, schema design, quality standards | High initially, declining | Highest |
| **Teachers** | Teaching notes, misconceptions, assessments | Growing over time | High (domain expertise) |
| **AI (OSS Bot)** | Scaffolds, translations, structured imports | High volume | Medium (requires human review) |
| **P&AI Bot** | Data-backed improvements from student interactions | Automatic, growing with usage | Medium-High (statistical backing) |
| **Students** | Indirect — their learning data informs improvements | Passive | N/A |

### Quality Assurance

All contributions go through GitHub's PR review process:

- **Schema validation** runs automatically on every PR (CI blocks invalid YAML)
- **Human review** is required for all merges — at least one educator for content PRs
- **Provenance tracking** — every piece of content tracks its source (`human`, `ai-assisted`, `ai-generated`, `ai-observed`)
- **Copyright checks** — the OSS Bot flags content that resembles copyrighted exam papers

### Contribution Interfaces

Teachers don't use Git. Three interfaces, same pipeline:

| Interface | Audience | Complexity |
|-----------|----------|-----------|
| **Web form** (contribute.opensyllabus.org) | Teachers who've never seen GitHub | None — type in natural language |
| **GitHub Issues** | Teachers familiar with GitHub | Low — describe what to add/fix |
| **Direct PRs** | Developers and power users | Standard Git workflow |
| **@oss-bot commands** | Community members in Issues/PRs | Comment with commands |

---

## Licensing Strategy

**License: Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)**

This is a deliberate choice:

- **BY (Attribution):** Anyone can use OSS, but must credit the source. This builds brand awareness and ensures contributors get recognition.
- **SA (ShareAlike):** Any derived works must be shared under the same license. This prevents companies from taking the curriculum, improving it, and locking improvements behind proprietary walls. **Every improvement flows back to the commons.**

The ShareAlike clause is the key mechanism for sustainability. It means a company can build a commercial product on OSS (great — that's the point), but any curriculum improvements they make must be published openly. This creates a one-way valve: content flows in, never out.

### Why Not Apache 2.0 (Like pai-bot)?

Apache 2.0 would allow companies to fork the curriculum, improve it, and never contribute back. For code (pai-bot), this is acceptable — the value is in the network effect and hosted service. For curriculum content, the commons must be protected. CC BY-SA ensures it.

---

## Market Position

OSS is **not a product.** It is **infrastructure** that makes products possible. The analogy is:

| Infrastructure | Products Built On It |
|---------------|---------------------|
| OpenStreetMap | Google Maps competitors, logistics apps, Uber |
| Wikipedia | Alexa, Siri, Google Knowledge Graph |
| Linux | Android, AWS, 90% of the internet |
| **Open School Syllabus** | **P&AI, future AI tutors, adaptive learning platforms, school management systems** |

### Why This Hasn't Been Done Before

1. **No economic incentive** — curriculum data is a cost center for EdTech companies, not a revenue source. Nobody wanted to open-source it.
2. **No standard** — every company invented its own schema. There was no agreement on what "structured curriculum" even looks like.
3. **Teacher contribution was impractical** — before AI agents, structuring teacher knowledge into machine-readable format required curriculum design expertise.

OSS solves all three: P&AI creates the economic incentive (better curriculum = better product), the JSON Schemas define the standard, and AI-powered contribution tools eliminate the formatting barrier for teachers.

---

## Growth Model

### The Self-Improving Flywheel

```
Better curriculum data
        ↑
        │
   AI-observed improvements ←── Student interaction data
   + Teacher contributions           │
        ↑                            │
        │                            ▼
   OSS gets richer          P&AI teaches more effectively
        ↑                            │
        │                            ▼
   More platforms use OSS ←── More students use platforms
```

### Phase 1: Pandai-Bootstrapped (Months 1–3)

P&AI Bot is the first and primary consumer. OSS grows because P&AI needs it. The Pandai team seeds content. Every student interaction generates data that improves the curriculum.

**Milestone:** 2 curricula at Level 3, 50+ topics, consumed by 500+ students.

### Phase 2: Community-Powered (Months 3–6)

As P&AI goes open-source, early adopters deploy their own instances. Teachers in their schools contribute local curriculum content. The OSS Bot enables non-technical contributions.

**Milestone:** 10+ curricula scaffolded, 5 countries represented, first community-contributed syllabus reaches Level 3.

### Phase 3: Multi-Platform (Months 6–12)

Other learning platforms discover OSS and start consuming it. They don't need to use P&AI — OSS is platform-agnostic. Each new consumer creates economic incentive to improve the data.

**Milestone:** 3+ platforms consuming OSS beyond P&AI. 200+ topics across 10+ curricula.

### Phase 4: Self-Sustaining (Year 2+)

Contribution rate exceeds consumption rate. AI-observed improvements from multiple platforms make OSS the most accurate and complete curriculum dataset on Earth. National education ministries reference OSS as the canonical digital representation of their curricula.

**Milestone:** Every major curriculum on Earth scaffolded. 50+ at Level 3+. Data-backed pedagogical insights published as research.

---

## Key Metrics

### Content Metrics

| Metric | Week 4 | Month 3 | Month 6 | Month 12 |
|--------|--------|---------|---------|----------|
| Curricula scaffolded | 2 | 5 | 15 | 50+ |
| Curricula at Level 3+ | 2 | 3 | 10 | 25+ |
| Total topics | 13 | 50 | 200 | 1,000+ |
| Languages | 2 (en, ms) | 3 | 5 | 10+ |
| Universal concepts mapped | 10 | 30 | 100 | 500+ |

### Community Metrics

| Metric | Week 6 | Month 3 | Month 6 | Month 12 |
|--------|--------|---------|---------|----------|
| GitHub stars | 100+ | 300+ | 1,000+ | 3,000+ |
| Contributors | 5 | 15 | 50+ | 200+ |
| Countries represented | 2 | 5 | 10 | 20+ |
| PRs per month | 10 | 30 | 100+ | 500+ |
| AI-observed improvements/month | 0 | 10 | 50+ | 200+ |

### Consumption Metrics

| Metric | Week 6 | Month 3 | Month 6 | Month 12 |
|--------|--------|---------|---------|----------|
| Platforms consuming OSS | 1 (P&AI) | 1–2 | 3+ | 10+ |
| Students learning from OSS content | 500 | 2,000 | 10,000 | 100,000+ |
| Self-hosted OSS clones | 3+ | 10+ | 30+ | 100+ |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Nobody contributes | Medium | High | P&AI drives demand. OSS Bot lowers friction. Pandai funds baseline content. |
| Content quality is inconsistent | Medium | Medium | Schema validation blocks structural errors. Educator review required for all merges. Quality levels set expectations. |
| Copyright issues with exam board content | Medium | High | Never copy from copyrighted materials. Generate original content aligned to publicly available specifications. Copyright check in CI. |
| Competing open curriculum effort emerges | Low | Medium | First-mover advantage + data flywheel from P&AI. Welcome competition — more open curricula is a net positive. |
| Schema needs to evolve | Certain | Low | Versioned schemas. Backward-compatible changes only. Migration tools for breaking changes. |
| AI-generated content is pedagogically wrong | Medium | Medium | All AI content requires human educator review. Provenance tracking lets consumers filter by trust level. |

---

## Sustainability

OSS costs almost nothing to maintain:

| Cost | Amount | Who Pays |
|------|--------|----------|
| GitHub hosting | Free (open source) | GitHub |
| CI/CD (schema validation) | Free tier | GitHub Actions |
| Domain (opensyllabus.org) | ~$15/year | Pandai |
| Team time | 5–10 hrs/week | Pandai (allocated from P&AI team) |
| OSS Bot hosting | ~$20/month | Pandai |

The primary cost is human time for content review. This scales with community size — as more educators join, review capacity grows organically because experienced contributors become reviewers.

**Long-term sustainability does not depend on Pandai.** If Pandai were to disappear tomorrow, OSS would continue because: the data is open (CC BY-SA), the schemas are documented, any fork is complete, and the community can maintain the CI pipeline on GitHub's free tier.

---

## Relationship to P&AI Bot

OSS and P&AI Bot are designed to be independent but synergistic:

| Dimension | OSS | P&AI Bot |
|-----------|-----|----------|
| License | CC BY-SA 4.0 | Apache 2.0 |
| Purpose | Curriculum data | Learning platform |
| Can exist independently? | Yes — any platform can consume it | Yes — can use any curriculum source |
| Better together? | Yes — P&AI provides the data flywheel | Yes — OSS provides the best curriculum data |
| Contributors | Teachers, AI agents, curriculum designers | Software engineers |
| Release cadence | Daily (content updates) | Weekly (platform releases) |

**OSS is designed to outlive P&AI.** Even if P&AI Bot fails or pivots, the structured curriculum data benefits the entire education ecosystem. This is the social impact play — building durable public infrastructure, not just a product.

---

## Vision

**Every curriculum on Earth, structured, open, and AI-ready. Maintained by the educators who teach it and improved by the students who learn from it.**

OSS is not about technology. It is about ensuring that when an AI tutor teaches a child in rural Indonesia the same mathematics that a child in London learns, the curriculum guidance is equally rich, equally thoughtful, and equally effective — because the world's teachers contributed their knowledge to a shared commons that belongs to everyone.

---

*A [Pandai](https://pandai.app) initiative. Built by educators and AI, for everyone.*
