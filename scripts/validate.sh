#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$REPO_ROOT"

ERRORS=0
ARTIFACT_TYPES=(
  syllabus
  subject
  subject_grade
  topic
  topic_variant
  assessment
  assessment_variant
  example
  example_variant
  concept
  taxonomy
)

echo "=== OSS Curriculum Validation ==="

run_check() {
  local label="$1"
  shift

  if "$@"; then
    echo "PASS: ${label}"
  else
    echo "FAIL: ${label}"
    ERRORS=$((ERRORS + 1))
  fi
}

run_check "content YAML syntax" ruby scripts/check-yaml-syntax.rb
run_check "exact artifact inventory" ruby scripts/check-inventory.rb

for artifact_type in "${ARTIFACT_TYPES[@]}"; do
  schema=""
  data_args=()

  while IFS='|' read -r listed_type listed_schema file; do
    [ "$listed_type" = "$artifact_type" ] || continue
    schema="$listed_schema"
    data_args+=("-d" "$file")
  done < <(ruby scripts/list-schema-targets.rb "$artifact_type")

  count=$((${#data_args[@]} / 2))
  if [ "$count" -eq 0 ]; then
    echo "PASS: 0 ${artifact_type} artifact(s) (inventory expects none)"
    continue
  fi

  if [ "$artifact_type" = "topic_variant" ]; then
    ajv_command=(ajv validate --spec=draft2020 -c ajv-formats \
      -r schema/topic.schema.json -s "$schema" "${data_args[@]}")
  else
    ajv_command=(ajv validate --spec=draft2020 -c ajv-formats \
      -s "$schema" "${data_args[@]}")
  fi

  if "${ajv_command[@]}" >/dev/null 2>&1; then
    echo "PASS: ${count} ${artifact_type} artifact(s)"
  else
    echo "FAIL: ${artifact_type} schema validation"
    "${ajv_command[@]}" || true
    ERRORS=$((ERRORS + 1))
  fi
done

run_check "prerequisite graph integrity" ruby scripts/check-prerequisites.rb
run_check "cross-reference integrity" ruby scripts/check-references.rb
run_check "quality assessment" ruby scripts/assess-quality.rb --report

if [ "$ERRORS" -eq 0 ]; then
  echo "PASS: all OSS validations passed"
  exit 0
fi

echo "FAIL: ${ERRORS} validation group(s) failed"
exit 1
