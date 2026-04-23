#!/usr/bin/env bash
set -euo pipefail

BASE_REF="${1:-${GITHUB_BASE_REF:-main}}"
ERRORS=0

echo "=== OSS Changed Files Validation ==="

if git rev-parse --verify --quiet "origin/${BASE_REF}" >/dev/null; then
  BASE_COMMIT="origin/${BASE_REF}"
elif git rev-parse --verify --quiet "${BASE_REF}" >/dev/null; then
  BASE_COMMIT="${BASE_REF}"
else
  echo "Fetching base ref: ${BASE_REF}"
  git fetch --no-tags --depth=1 origin "${BASE_REF}"
  BASE_COMMIT="origin/${BASE_REF}"
fi

mapfile -t CHANGED_FILES < <(
  {
    git diff --name-only --diff-filter=ACMR "${BASE_COMMIT}...HEAD"
    git diff --name-only --diff-filter=ACMR
    git diff --name-only --cached --diff-filter=ACMR
    git ls-files --others --exclude-standard
  } |
    awk '
      /^(curricula|concepts|taxonomy)\// && /\.ya?ml$/ { print }
      /^\.github\/workflows\/.*\.ya?ml$/ { print }
      /^schema\/.*\.schema\.json$/ { print }
      /^scripts\/validate/ { print }
      /^\.yamllint\.yml$/ { print }
    ' |
    sort -u
)

if [ "${#CHANGED_FILES[@]}" -eq 0 ]; then
  echo "SKIP: No changed validation-relevant files"
  exit 0
fi

printf "Changed validation-relevant files:\n"
printf -- "- %s\n" "${CHANGED_FILES[@]}"

mapfile -t YAML_FILES < <(printf "%s\n" "${CHANGED_FILES[@]}" | awk '/^(curricula|concepts|taxonomy)\/.*\.ya?ml$/')
mapfile -t YAMLLINT_FILES < <(
  printf "%s\n" "${CHANGED_FILES[@]}" |
    awk '/^(curricula|concepts|taxonomy)\/.*\.ya?ml$/ || /^\.yamllint\.yml$/'
)
mapfile -t WORKFLOW_FILES < <(printf "%s\n" "${CHANGED_FILES[@]}" | awk '/^\.github\/workflows\/.*\.ya?ml$/')

if [ "${#YAMLLINT_FILES[@]}" -gt 0 ]; then
  if yamllint -c .yamllint.yml "${YAMLLINT_FILES[@]}"; then
    echo "PASS: YAML lint for changed files"
  else
    echo "FAIL: YAML lint for changed files"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "SKIP: No changed yamllint-covered files"
fi

if [ "${#WORKFLOW_FILES[@]}" -gt 0 ]; then
  ruby -e 'require "yaml"; ARGV.each { |file| YAML.load_file(file) }' "${WORKFLOW_FILES[@]}"
  echo "PASS: workflow YAML parses"
fi

schema_for_file() {
  local file="$1"

  case "$file" in
    concepts/*.yaml)
      echo "schema/concept.schema.json"
      ;;
    taxonomy/*.yaml)
      echo "schema/taxonomy.schema.json"
      ;;
    curricula/*/syllabus.yaml)
      echo "schema/syllabus.schema.json"
      ;;
    curricula/*/subjects/*.yaml)
      echo "schema/subject.schema.json"
      ;;
    curricula/*.assessments.yaml|curricula/**/*.assessments.yaml)
      echo "schema/assessments.schema.json"
      ;;
    curricula/*.examples.yaml|curricula/**/*.examples.yaml)
      echo "schema/examples.schema.json"
      ;;
    curricula/*/topics/*.yaml|curricula/**/topics/*.yaml)
      echo "schema/topic.schema.json"
      ;;
    *)
      return 1
      ;;
  esac
}

SCHEMA_FILES_CHANGED=false
for file in "${CHANGED_FILES[@]}"; do
  if [[ "$file" == schema/*.schema.json ]]; then
    SCHEMA_FILES_CHANGED=true
    break
  fi
done

if [ "$SCHEMA_FILES_CHANGED" = true ]; then
  echo "FAIL: Schema files changed; run full validation on this PR"
  echo "Changed schema files can affect untouched curriculum files."
  ERRORS=$((ERRORS + 1))
elif [ "${#YAML_FILES[@]}" -gt 0 ]; then
  schema_count=0
  schema_fails=0

  for file in "${YAML_FILES[@]}"; do
    if schema="$(schema_for_file "$file")"; then
      schema_count=$((schema_count + 1))
      if ajv validate --spec=draft2020 -s "$schema" -d "$file" >/dev/null; then
        echo "PASS: $file"
      else
        echo "FAIL: $file"
        ajv validate --spec=draft2020 -s "$schema" -d "$file" || true
        schema_fails=$((schema_fails + 1))
      fi
    else
      echo "SKIP: No schema mapping for $file"
    fi
  done

  if [ "$schema_fails" -eq 0 ]; then
    echo "PASS: $schema_count changed schema-validatable file(s)"
  else
    echo "FAIL: $schema_fails/$schema_count changed schema-validatable file(s)"
    ERRORS=$((ERRORS + schema_fails))
  fi
else
  echo "SKIP: No changed YAML files for schema validation"
fi

if printf "%s\n" "${CHANGED_FILES[@]}" | grep -Eq '^scripts/validate'; then
  bash -n scripts/validate.sh
  bash -n scripts/validate-changed.sh
  echo "PASS: validation scripts parse"
fi

if [ "$ERRORS" -eq 0 ]; then
  echo "PASS: Changed files validation passed"
  exit 0
fi

echo "FAIL: $ERRORS changed-files validation error(s) found"
exit 1
