# OSS structure research

Research date: 2026-08-13

Repository snapshots:

- `p-n-ai/pai-bot@92f7978`.
- Pinned `p-n-ai/oss@5ab96fde231bcd02b1cc89828db41cd69d95c02d`.
- The OSS pin is the direct parent of current OSS `main@320b484`.

The pinned commit and current `main` have the same Git tree, so content staleness is not the problem.

## Recommendation

Keep OSS as one Git-backed, schema-first authoring repository. Do not make a database or API authoritative.

Separate authoring layout from distribution layout:

1. Group each topic's source files inside one topic directory.
2. Give every curriculum entity a stable, namespace-safe logical URI.
3. Separate locale-neutral identity and grading semantics from localized prose.
4. Keep one versioned schema set at the repository root.
5. Generate one deterministic manifest with paths, types, sizes, and SHA-256 digests.
6. Release a minimal runtime bundle containing only manifested consumer data.
7. Make `pai-bot` verify the manifest instead of duplicating expected corpus counts.

The current submodule boundary is acceptable during migration. Git submodules preserve separate repository histories while pinning one repository inside another. That matches OSS ownership today. See the [Git submodule documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules).

The urgent problem is the missing package contract, not the repository boundary.

## Current-state inventory

The OSS authoring repository is small enough to remain Git-native:

| Item | At the pinned revision |
|---|---:|
| Tracked file content | about 4.35 MB |
| Filesystem allocation for the working tree | about 10 MB |
| Packed Git objects | about 3.52 MiB |
| Classified content YAML | 562 |
| Canonical topics | 152 |
| Locale topic variants | 53 |
| Canonical assessments | 115 |
| Locale assessment variants | 53 |
| Canonical examples | 115 |
| Locale example variants | 53 |
| Canonical teaching notes | 115 |
| Locale teaching notes | 56 |
| Syllabi / subjects / subject-grades | 1 / 3 / 15 |
| Concepts / taxonomies | 2 / 0 |
| Nested schema copies | 20 files, 87,781 bytes |

OSS's validator owns nine root schemas and classifies content using paths and filename suffixes. Its expected inventory lives in `scripts/lib/oss_validation.rb`.

The current authoring hierarchy is:

```text
curricula/{country}/{syllabus}/{subject}/{subject-grade}/
├── subject-grade.yaml
├── *.jsu.md
└── topics/
    ├── {topic-id}.yaml
    ├── {topic-id}.teaching.md
    ├── {topic-id}.examples.yaml
    ├── {topic-id}.assessments.yaml
    └── translations/{locale}/
        ├── {topic-id}.yaml
        ├── {topic-id}.teaching.md
        ├── {topic-id}.examples.yaml
        └── {topic-id}.assessments.yaml
```

Most content files are seven path segments deep. Locale artifacts are nine segments deep.

The repository also contains subject-local `schema/` directories. These contain 20 historical schema files beside the nine authoritative root schemas.

`pai-bot` consumes OSS through these paths:

- [`.gitmodules`](https://github.com/p-n-ai/pai-bot/blob/92f7978cf321772a9f9958bbc460e1003db175e6/.gitmodules) pins OSS as the `oss/` submodule.
- [`internal/curriculum/loader.go`](https://github.com/p-n-ai/pai-bot/blob/92f7978cf321772a9f9958bbc460e1003db175e6/internal/curriculum/loader.go) hashes, walks, classifies, decodes, and validates the tree.
- [`internal/retrieval/curriculum_seed.go`](https://github.com/p-n-ai/pai-bot/blob/92f7978cf321772a9f9958bbc460e1003db175e6/internal/retrieval/curriculum_seed.go) creates in-memory retrieval documents from teachable topics.
- [`internal/curriculum/types.go`](https://github.com/p-n-ai/pai-bot/blob/92f7978cf321772a9f9958bbc460e1003db175e6/internal/curriculum/types.go) exposes physical paths and file digests through `SourceRef`.
- [`internal/agent/prompt_builder.go`](https://github.com/p-n-ai/pai-bot/blob/92f7978cf321772a9f9958bbc460e1003db175e6/internal/agent/prompt_builder.go) includes source paths and revisions in model evidence.
- [`internal/agent/context_packets.go`](https://github.com/p-n-ai/pai-bot/blob/92f7978cf321772a9f9958bbc460e1003db175e6/internal/agent/context_packets.go) exposes those paths as citation filenames.
- [`deploy/docker/Dockerfile`](https://github.com/p-n-ai/pai-bot/blob/92f7978cf321772a9f9958bbc460e1003db175e6/deploy/docker/Dockerfile) copies the entire authoring repository into the runtime image.
- [`internal/curriculum/oss_integration_test.go`](https://github.com/p-n-ai/pai-bot/blob/92f7978cf321772a9f9958bbc460e1003db175e6/internal/curriculum/oss_integration_test.go) duplicates expected corpus counts.

## Observed problems

### 1. There is no machine-readable package boundary

OSS has no content manifest, package descriptor, release tag, or published GitHub release.

Consumers must discover files by recursively walking an authoring tree. They cannot inspect one file to learn:

- which artifacts form one supported snapshot;
- which schema version governs each artifact;
- which files are runtime content;
- which files are authoring-only material;
- which digest identifies each artifact;
- which locales and curricula are included.

The [Data Package specification](https://specs.frictionlessdata.io/data-package/) defines a package through a top-level descriptor and a resource list. Its model fits this missing boundary without constraining OSS's YAML format.

### 2. Authoring and runtime concerns are mixed

The runtime image receives the entire `oss/` tree. This includes contributor documentation, CI scripts, schemas, review notes, JSU material, and historical schema copies.

Only curriculum YAML and teaching Markdown affect `pai-bot`'s snapshot digest. Taxonomy is not included in that digest.

The loader walks the tree once to compute the snapshot hash. It walks the tree again to classify and decode content.

This is not a current scale emergency. It is an unclear contract that worsens with corpus growth.

### 3. Physical paths are observable product data

`SourceRef.Path` enters teaching evidence, prompt context, retrieval citations, and trace metadata.

Moving files today would change externally visible citations. It would also change the snapshot digest because that digest includes relative paths.

A structural cleanup must therefore introduce logical artifact identities before moving content.

### 4. Corpus truth is duplicated and already drifting

OSS validates 115 canonical assessments, examples, and teaching notes at the pinned revision.

The `pai-bot` integration test still expects 114 of each. Running the isolated test against the exact gitlink fails.

The test normally skips when the submodule is absent. Several CI jobs initialize submodules, but the Docker CI job does not.

GitHub's official checkout action documents `submodules: false` as the default. See [`actions/checkout`](https://github.com/actions/checkout#usage).

The package manifest should own inventory. Consumer tests should assert supported schema and required features, then compare loader results with the manifest.

### 5. Topic identity will collide across curricula

OSS declares canonical topic IDs globally unique. Its documented format uses only subject prefix, grade, and sequence.

For example, the convention assigns `PH12-01` to India CBSE Physics. Another country using Physics grade 12 would naturally produce the same ID.

The validator's `topic_key(_syllabus_id, topic_id)` discards `syllabus_id`. Runtime maps also key topics only by `topic.ID`.

This blocks predictable multi-curriculum growth.

1EdTech CASE uses globally unique identifiers so learning resources and cross-framework associations remain addressable. See the [CASE 1.1 specification](https://standards.1edtech.org/case/specifications/standards/v1p1).

W3C also recommends persistent identifiers for datasets and entities within datasets. See [Data on the Web Best Practices](https://www.w3.org/TR/dwbp/).

### 6. Locale variants duplicate stable semantics

Current locale directories contain full topic, assessment, and example copies.

The validators must prove that localized copies preserve question IDs, objective references, answer types, and other canonical semantics.

This creates avoidable drift risk. Identity, relationships, grading rules, and mastery policy should exist once.

Localized names, statements, question prose, hints, feedback, and teaching notes should vary by locale.

### 7. Schema authority is ambiguous

Nine schemas at `schema/` are authoritative. Twenty divergent schema files remain under subject directories.

Several nested schemas reuse the same `$id` despite having different bytes. The root topic variant references an unversioned GitHub schema URL.

JSON Schema defines `$id` as a schema resource's canonical URI. It recommends absolute identifiers and `$schema` dialect declarations. See [JSON Schema Core 2020-12](https://json-schema.org/draft/2020-12/json-schema-core).

OSS should have one schema authority per version, with immutable versioned identifiers.

### 8. Licensing and release provenance are incomplete

The README links `LICENSE` and displays CC BY-SA 4.0. The file does not exist at the pinned revision.

GitHub therefore reports no detected repository license. OSS also has no tags or releases.

W3C recommends machine-readable license, provenance, quality, and version metadata. See [Data on the Web Best Practices](https://www.w3.org/TR/dwbp/).

GitHub releases can package named iterations and downloadable assets. Immutable releases can lock their tag and assets after publication. See [GitHub release management](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository) and [immutable releases](https://docs.github.com/en/enterprise-cloud@latest/code-security/concepts/supply-chain-security/immutable-releases).

## Options

| Option | Benefits | Costs | Decision |
|---|---|---|---|
| Keep the current tree | No migration | Preserves path coupling, duplication, and missing package metadata | Reject |
| Tidy folders only | Easier browsing | Breaks citations and hashes without fixing identity or packaging | Reject |
| Git authoring plus manifested releases | Clear ownership, reproducibility, small runtime input, gradual migration | Requires manifest tooling and compatibility work | Recommend |
| Database or API as source of truth | Supports dynamic queries | Adds runtime operations and weakens Git review portability | Reject now |
| Split each curriculum into repositories | Independent ownership | Adds coordination, schema drift, and cross-curriculum complexity | Defer |

The recommended option preserves the current strengths: reviewable YAML, Git history, schemas, and deterministic validation.

## Recommended authoring tree

```text
oss/
├── LICENSE
├── README.md
├── CONTRIBUTING.md
├── content/
│   ├── curricula/
│   │   └── malaysia/
│   │       └── malaysia-kssm/
│   │           ├── syllabus.yaml
│   │           └── subjects/
│   │               └── malaysia-kssm-matematik/
│   │                   ├── subject.yaml
│   │                   └── grades/
│   │                       └── malaysia-kssm-matematik-tingkatan-1/
│   │                           ├── subject-grade.yaml
│   │                           ├── source/                 # Authoring-only official mappings
│   │                           │   └── jsu.md
│   │                           └── topics/
│   │                               └── MT1-01/
│   │                                   ├── topic.yaml      # Identity, graph, mastery, grading links
│   │                                   ├── locales/
│   │                                   │   ├── en.yaml     # Localized topic and objective prose
│   │                                   │   └── ms.yaml
│   │                                   ├── teaching/
│   │                                   │   ├── en.md
│   │                                   │   └── ms.md
│   │                                   ├── assessments/
│   │                                   │   ├── contract.yaml # IDs, types, correct keys, objectives
│   │                                   │   ├── en.yaml       # Questions, choices, hints, feedback
│   │                                   │   └── ms.yaml
│   │                                   └── examples/
│   │                                       ├── en.yaml
│   │                                       └── ms.yaml
│   ├── concepts/
│   └── taxonomy/
├── schema/
│   └── v1/
│       ├── manifest.schema.json
│       ├── topic.schema.json
│       ├── topic-locale.schema.json
│       ├── assessment-contract.schema.json
│       └── ...
├── manifest.json                       # Generated and reproducible
├── scripts/
└── docs/
    ├── architecture/                   # Current contracts and decisions
    ├── contributing/                   # Contributor-facing guides
    ├── quality/                        # Current review reports
    └── archive/                        # Historical plans, never active instructions
```

This tree optimizes the human change unit: one topic directory contains every source artifact for that topic.

It also makes locale boundaries explicit. Adding a locale no longer requires copying identity, graph, mastery, or grading policy.

The exact split should follow consumer tests. Do not split fields until their locale behavior is proven.

## Logical identities

Keep short codes such as `MT1-01` for display and official alignment. Stop using them as global primary keys.

Use a stable logical URI as the authoritative key:

```text
urn:oss:curriculum:malaysia-kssm:topic:MT1-01
urn:oss:curriculum:malaysia-kssm:topic:MT1-01:assessment:Q1
urn:oss:concept:algebraic-expression
```

Alternatively, use persistent HTTPS URIs if OSS can commit to resolving them.

Relations should use logical URIs. Compatibility fields may retain short IDs during migration.

Artifact identities should add kind and locale without depending on storage paths:

```text
urn:oss:artifact:malaysia-kssm:MT1-01:topic:en
urn:oss:artifact:malaysia-kssm:MT1-01:teaching:ms
urn:oss:artifact:malaysia-kssm:MT1-01:assessment-contract
```

## Generated manifest

Generate `manifest.json` from validated authoring content. Commit it initially so submodule consumers receive it.

Minimum top-level fields:

```json
{
  "format_version": "1",
  "dataset_version": "2026.08.0",
  "schema_version": "1",
  "source_commit": "5ab96fde231bcd02b1cc89828db41cd69d95c02d",
  "root_digest": "sha256:...",
  "resources": []
}
```

Each resource should contain:

- `logical_id`;
- `kind`;
- `curriculum_id`, `subject_id`, and `topic_id` where applicable;
- `locale` when applicable;
- relative `path` as a storage locator;
- schema URI;
- media type;
- byte size;
- SHA-256 digest;
- provenance and quality metadata;
- dependency identities for referenced artifacts.

This borrows proven descriptor properties without claiming full OCI conformance. OCI descriptors require media type, digest, and size. See the [OCI descriptor specification](https://github.com/opencontainers/image-spec/blob/main/descriptor.md).

The manifest should be complete. Every runtime file must appear exactly once, and every listed file must exist.

That invariant follows the integrity model in [RFC 8493 BagIt](https://datatracker.ietf.org/doc/rfc8493/): completeness covers all payload files, and validity verifies every checksum.

Generate inventory counts from `resources`. Remove hand-maintained count constants after transition.

## Runtime distribution

CI should build a deterministic release bundle from the manifest:

```text
oss-runtime-v1/
├── manifest.json
├── schemas/
│   └── v1/...
└── data/
    ├── curricula/...
    ├── concepts/...
    └── taxonomy/...
```

The runtime bundle should exclude:

- contributor documentation;
- CI and maintenance scripts;
- QA reports and trackers;
- authoring source mappings;
- obsolete schema copies;
- unreferenced artifacts.

Create a deterministic archive with sorted paths, normalized timestamps, normalized ownership, and fixed permissions.

Publish the archive, manifest, and archive checksum on a versioned GitHub release.

Keep the submodule transport during the first migration. `pai-bot` can load the generated manifest from the pinned commit.

Move to release assets only after bundle production and rollback are proven.

## Migration sequence

### 1. Establish legal and package metadata

- Add the intended license file after legal confirmation.
- Add dataset version, schema version, provenance, and source metadata.
- Generate the first manifest without moving any content.

### 2. Introduce logical identity before path changes

- Add namespace-safe entity and artifact URIs.
- Add logical identity to `pai-bot` source references and citations.
- Keep physical paths as compatibility metadata.
- Preserve current citation rendering until consumers accept logical URIs.

### 3. Make the manifest authoritative

- Generate it from OSS's validated classifier.
- Fail CI when regeneration changes the checked-in manifest.
- Verify every file's path, byte size, digest, schema, identity, and locale.
- Derive inventory reports from the manifest.
- Replace `pai-bot`'s hand-written corpus counts with manifest comparisons.

### 4. Version and deduplicate schemas

- Move authoritative schemas under `schema/v1/`.
- Give every schema an immutable versioned `$id`.
- Make all `$ref` values resolve inside the versioned schema set.
- Remove subject-local schema copies after proving they are unused.

### 5. Split locale-neutral contracts from localized prose

- Start with one representative topic containing assessments and examples.
- Prove canonical grading and locale rendering through fixtures.
- Add round-trip checks from old to new shapes.
- Migrate remaining topics mechanically after the pilot passes.

### 6. Move to topic directories

- Move one subject-grade at a time.
- Generate old-path aliases in the manifest during one compatibility window.
- Keep logical artifact identities and per-file digests stable where bytes remain stable.
- Record path changes without changing entity identity.

### 7. Produce and consume the runtime bundle

- Build the minimal bundle in OSS CI.
- Validate it with the same manifest verifier used by consumers.
- Test `pai-bot` against the unpacked bundle.
- Copy only the bundle into application images.
- Publish a versioned release after cross-repository checks pass.

## Validation and CI implications

OSS pull requests should run these gates:

1. YAML and Markdown syntax checks.
2. JSON Schema validation using immutable schema identifiers.
3. Entity uniqueness using logical URIs.
4. Referential integrity across prerequisites, concepts, objectives, and companion artifacts.
5. Locale invariants for grading identities and answer types.
6. Pedagogical quality and provenance policy checks.
7. Manifest regeneration and clean-tree verification.
8. Manifest completeness, size, and digest verification.
9. Deterministic bundle rebuild verification.
10. Compatibility checks for supported prior manifest versions.

`pai-bot` pull requests should run these gates:

1. Initialize the pinned OSS submodule for every curriculum-dependent job.
2. Verify manifest format and schema compatibility before loading.
3. Verify the package digest and every resource digest.
4. Compare loaded counts and identities with the manifest.
5. Exercise one canonical and one localized topic end-to-end.
6. Preserve logical citation identities when physical paths change.
7. Build application images from the runtime bundle, not the authoring tree.

Production startup should log dataset version, root digest, schema version, and loaded inventory.

Production should fail readiness when configured curriculum exists but fails integrity or schema checks.

An explicitly optional curriculum path may still degrade gracefully. That policy should not hide a corrupted configured package.

## What not to do

- Do not reorganize paths before adding logical identities.
- Do not use Git commit SHA as the only dataset version.
- Do not use short topic codes as global keys.
- Do not keep full localized copies of stable grading semantics.
- Do not ship docs, scripts, and review artifacts in runtime images.
- Do not duplicate corpus counts across repositories.
- Do not introduce an authoritative database or API for this scale.
- Do not split repositories by curriculum before ownership requires it.

## Decision summary

OSS is already correctly separated as an open curriculum repository. Its YAML-and-Git authoring model should remain.

The optimization is a contract and packaging change:

```text
reviewable authoring sources
  -> validated logical model
  -> generated content manifest
  -> deterministic minimal runtime bundle
  -> verified pai-bot loader and citations
```

This preserves contribution ergonomics while making releases reproducible, identities durable, and runtime consumption explicit.

## Primary sources

- [Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [`actions/checkout` submodule behavior](https://github.com/actions/checkout#usage)
- [Frictionless Data Package](https://specs.frictionlessdata.io/data-package/)
- [Frictionless Data Resource](https://specs.frictionlessdata.io/data-resource/)
- [JSON Schema Core 2020-12](https://json-schema.org/draft/2020-12/json-schema-core)
- [W3C Data on the Web Best Practices](https://www.w3.org/TR/dwbp/)
- [1EdTech CASE 1.1](https://standards.1edtech.org/case/specifications/standards/v1p1)
- [RFC 8493 BagIt](https://datatracker.ietf.org/doc/rfc8493/)
- [OCI content descriptors](https://github.com/opencontainers/image-spec/blob/main/descriptor.md)
- [GitHub release management](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository)
- [GitHub immutable releases](https://docs.github.com/en/enterprise-cloud@latest/code-security/concepts/supply-chain-security/immutable-releases)
