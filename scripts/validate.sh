#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

ERRORS=0

echo "=== OSS Curriculum Validation ==="
echo ""

# 1. YAML Lint
echo "--- YAML Lint ---"
if yamllint -c .yamllint.yml curricula/ concepts/ taxonomy/ 2>/dev/null; then
  echo -e "${GREEN}PASS${NC}: YAML lint"
else
  echo -e "${RED}FAIL${NC}: YAML lint"
  ERRORS=$((ERRORS + 1))
fi

# 2. Schema validation
echo ""
echo "--- Schema Validation ---"

validate_files() {
  local schema="$1"
  local pattern="$2"
  local label="$3"
  local count=0
  local fails=0

  while IFS= read -r -d '' file; do
    count=$((count + 1))
    if ! ajv validate --spec=draft2020 -s "$schema" -d "$file" > /dev/null 2>&1; then
      echo -e "${RED}FAIL${NC}: $file"
      ajv validate --spec=draft2020 -s "$schema" -d "$file" 2>&1 || true
      fails=$((fails + 1))
    fi
  done < <(eval "$pattern")

  if [ $count -eq 0 ]; then
    echo -e "${YELLOW}SKIP${NC}: No $label files found"
  elif [ $fails -eq 0 ]; then
    echo -e "${GREEN}PASS${NC}: $count $label file(s)"
  else
    echo -e "${RED}FAIL${NC}: $fails/$count $label file(s) failed"
    ERRORS=$((ERRORS + fails))
  fi
}

validate_files "schema/syllabus.schema.json" \
  "find curricula -name 'syllabus.yaml' -print0" "syllabus"

validate_files "schema/subject.schema.json" \
  "find curricula -path '*/subjects/*.yaml' -print0" "subject"

validate_files "schema/topic.schema.json" \
  "find curricula -path '*/topics/*' -name '*.yaml' ! -name '*.examples.yaml' ! -name '*.assessments.yaml' -print0" "topic"

validate_files "schema/assessments.schema.json" \
  "find curricula -name '*.assessments.yaml' -print0" "assessment"

validate_files "schema/examples.schema.json" \
  "find curricula -name '*.examples.yaml' -print0" "example"

validate_files "schema/concept.schema.json" \
  "find concepts -name '*.yaml' -print0 2>/dev/null" "concept"

validate_files "schema/taxonomy.schema.json" \
  "find taxonomy -name '*.yaml' -print0 2>/dev/null" "taxonomy"

# Summary
echo ""
echo "=== Summary ==="
if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}All validations passed!${NC}"
  exit 0
else
  echo -e "${RED}$ERRORS validation error(s) found${NC}"
  exit 1
fi
