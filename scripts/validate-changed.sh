#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$REPO_ROOT"

BASE_REF="${1:-${GITHUB_BASE_REF:-main}}"
EXPLICIT_BASE=false
[ "$#" -gt 0 ] && EXPLICIT_BASE=true
ERRORS=0

echo "=== OSS Changed Files Validation ==="

if [ "$EXPLICIT_BASE" = true ] && git rev-parse --verify --quiet "${BASE_REF}" >/dev/null; then
  BASE_COMMIT="${BASE_REF}"
elif git rev-parse --verify --quiet "origin/${BASE_REF}" >/dev/null; then
  BASE_COMMIT="origin/${BASE_REF}"
elif git rev-parse --verify --quiet "${BASE_REF}" >/dev/null; then
  BASE_COMMIT="${BASE_REF}"
else
  echo "Fetching base ref: ${BASE_REF}"
  git fetch --no-tags --depth=1 origin "${BASE_REF}"
  BASE_COMMIT="$(git rev-parse FETCH_HEAD)"
fi

if git merge-base "$BASE_COMMIT" HEAD >/dev/null 2>&1; then
  COMMITTED_DIFF="${BASE_COMMIT}...HEAD"
else
  COMMITTED_DIFF="${BASE_COMMIT}..HEAD"
fi

CHANGED_FILES=()
while IFS= read -r file; do
  [ -n "$file" ] && CHANGED_FILES+=("$file")
done < <(
  {
    git diff --name-only --diff-filter=ACMRD "$COMMITTED_DIFF"
    git diff --name-only --diff-filter=ACMRD
    git diff --name-only --cached --diff-filter=ACMRD
    git ls-files --others --exclude-standard
  } |
    awk '
      /^(curricula|concepts|taxonomy)\// && /\.ya?ml$/ { print }
      /^\.github\/workflows\/.*\.ya?ml$/ { print }
      /^schema\/.*\.schema\.json$/ { print }
      /^scripts\/(validate|check-|list-schema-targets|assess-quality|lib\/oss_validation)/ { print }
      /^\.yamllint\.yml$/ { print }
    ' |
    sort -u
)

if [ "${#CHANGED_FILES[@]}" -eq 0 ]; then
  echo "PASS: no changed validation-relevant files"
  exit 0
fi

printf "Changed validation-relevant files:\n"
printf -- "- %s\n" "${CHANGED_FILES[@]}"

CONTENT_YAML=()
WORKFLOW_YAML=()
FULL_GATE_REQUIRED=false

for file in "${CHANGED_FILES[@]}"; do
  if [ ! -e "$file" ]; then
    case "$file" in
      curricula/*|concepts/*|taxonomy/*|schema/*.schema.json|scripts/validate*|scripts/check-*|scripts/list-schema-targets.rb|scripts/assess-quality.rb|scripts/lib/oss_validation.rb)
        FULL_GATE_REQUIRED=true
        ;;
    esac
    continue
  fi

  case "$file" in
    curricula/*|concepts/*|taxonomy/*)
      CONTENT_YAML+=("$file")
      ;;
    .github/workflows/*.yaml|.github/workflows/*.yml)
      WORKFLOW_YAML+=("$file")
      ;;
  esac

  case "$file" in
    schema/*.schema.json|scripts/validate*|scripts/check-*|scripts/list-schema-targets.rb|scripts/assess-quality.rb|scripts/lib/oss_validation.rb)
      FULL_GATE_REQUIRED=true
      ;;
  esac
done

YAMLLINT_FILES=("${CONTENT_YAML[@]}" "${WORKFLOW_YAML[@]}")
if [ "${#YAMLLINT_FILES[@]}" -gt 0 ]; then
  if ruby scripts/check-yamllint-regressions.rb "$BASE_COMMIT" "${YAMLLINT_FILES[@]}"; then
    echo "PASS: no yamllint regressions in touched YAML"
  else
    echo "FAIL: yamllint regressions in touched YAML"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "PASS: no touched YAML style targets"
fi

if [ "${#WORKFLOW_YAML[@]}" -gt 0 ]; then
  if ruby -e 'require "yaml"; ARGV.each { |file| YAML.safe_load(File.read(file), permitted_classes: [], aliases: false) }' "${WORKFLOW_YAML[@]}"; then
    echo "PASS: workflow YAML syntax"
  else
    echo "FAIL: workflow YAML syntax"
    ERRORS=$((ERRORS + 1))
  fi
fi

if [ "$FULL_GATE_REQUIRED" = true ]; then
  if ./scripts/validate.sh; then
    echo "PASS: full semantic gate required by schema or validator change"
  else
    echo "FAIL: full semantic gate required by schema or validator change"
    ERRORS=$((ERRORS + 1))
  fi
elif [ "${#CONTENT_YAML[@]}" -gt 0 ]; then
  schema_fails=0

  for file in "${CONTENT_YAML[@]}"; do
    target="$(ruby scripts/list-schema-targets.rb | awk -F'|' -v file="$file" '$3 == file { print; exit }')"
    if [ -z "$target" ]; then
      echo "FAIL: no deterministic schema target for ${file}"
      schema_fails=$((schema_fails + 1))
      continue
    fi

    IFS='|' read -r artifact_type schema target_file <<EOF
$target
EOF

    if [ "$artifact_type" = "topic_variant" ]; then
      ajv_command=(ajv validate --spec=draft2020 -c ajv-formats \
        -r schema/topic.schema.json -s "$schema" -d "$target_file")
    else
      ajv_command=(ajv validate --spec=draft2020 -c ajv-formats \
        -s "$schema" -d "$target_file")
    fi

    if "${ajv_command[@]}" >/dev/null 2>&1; then
      echo "PASS: ${file}"
    else
      echo "FAIL: ${file}"
      "${ajv_command[@]}" || true
      schema_fails=$((schema_fails + 1))
    fi
  done

  if [ "$schema_fails" -eq 0 ]; then
    echo "PASS: ${#CONTENT_YAML[@]} changed schema-validatable file(s)"
  else
    ERRORS=$((ERRORS + schema_fails))
  fi

  if ruby scripts/check-inventory.rb; then
    echo "PASS: exact artifact inventory"
  else
    echo "FAIL: exact artifact inventory"
    ERRORS=$((ERRORS + 1))
  fi

  if ruby scripts/check-prerequisites.rb; then
    echo "PASS: prerequisite graph integrity"
  else
    echo "FAIL: prerequisite graph integrity"
    ERRORS=$((ERRORS + 1))
  fi

  if ruby scripts/check-references.rb; then
    echo "PASS: cross-reference integrity"
  else
    echo "FAIL: cross-reference integrity"
    ERRORS=$((ERRORS + 1))
  fi

  if ruby scripts/assess-quality.rb --report; then
    echo "PASS: quality assessment"
  else
    echo "FAIL: quality assessment"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "PASS: no changed content schema targets"
fi

if bash -n scripts/validate.sh &&
  bash -n scripts/validate-changed.sh &&
  ruby -c scripts/check-yamllint-regressions.rb >/dev/null; then
  echo "PASS: validation script syntax"
else
  echo "FAIL: validation script syntax"
  ERRORS=$((ERRORS + 1))
fi

if [ "$ERRORS" -eq 0 ]; then
  echo "PASS: changed-files validation passed"
  exit 0
fi

echo "FAIL: ${ERRORS} changed-files validation group(s) failed"
exit 1
