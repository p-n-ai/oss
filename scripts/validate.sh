#!/usr/bin/env bash
set -euo pipefail

ERRORS=0

echo "=== OSS Curriculum Validation ==="

# YAML lint
if yamllint -c .yamllint.yml curricula/ concepts/ taxonomy/ 2>/dev/null; then
  echo "PASS: YAML lint"
else
  echo "FAIL: YAML lint"
  ERRORS=$((ERRORS + 1))
fi

# Schema validation

validate_files() {
  local schema="$1"
  local pattern="$2"
  local label="$3"
  local count=0
  local fails=0

  while IFS= read -r -d '' file; do
    count=$((count + 1))
    if ! ajv validate --spec=draft2020 -s "$schema" -d "$file" > /dev/null 2>&1; then
      echo "FAIL: $file"
      ajv validate --spec=draft2020 -s "$schema" -d "$file" 2>&1 || true
      fails=$((fails + 1))
    fi
  done < <(eval "$pattern")

  if [ $count -eq 0 ]; then
    echo "SKIP: No $label files found"
  elif [ $fails -eq 0 ]; then
    echo "PASS: $count $label file(s)"
  else
    echo "FAIL: $fails/$count $label file(s) failed"
    ERRORS=$((ERRORS + fails))
  fi
}

while IFS='|' read -r schema pattern label; do
  validate_files "$schema" "$pattern" "$label"
done <<'EOF'
schema/syllabus.schema.json|find curricula -name 'syllabus.yaml' -print0|syllabus
schema/subject.schema.json|find curricula -path '*/subjects/*.yaml' -print0|subject
schema/topic.schema.json|find curricula -path '*/topics/*' -name '*.yaml' ! -name '*.examples.yaml' ! -name '*.assessments.yaml' -print0|topic
schema/assessments.schema.json|find curricula -name '*.assessments.yaml' -print0|assessment
schema/examples.schema.json|find curricula -name '*.examples.yaml' -print0|example
schema/concept.schema.json|find concepts -name '*.yaml' -print0 2>/dev/null|concept
schema/taxonomy.schema.json|find taxonomy -name '*.yaml' -print0 2>/dev/null|taxonomy
EOF

# Integrity scripts
run_check_script() {
  local script="$1"
  local label="$2"

  if [ ! -f "$script" ]; then
    echo "SKIP: $label"
    return
  fi

  if ruby "$script"; then
    echo "PASS: $label"
  else
    echo "FAIL: $label"
    ERRORS=$((ERRORS + 1))
  fi
}

run_check_script "scripts/check-prerequisites.rb" "prerequisite graph integrity"
run_check_script "scripts/check-references.rb" "cross-reference integrity"

if [ ! -f "scripts/assess-quality.rb" ]; then
  echo "SKIP: quality assessment"
elif ruby scripts/assess-quality.rb --report; then
  echo "PASS: quality assessment"
else
  echo "FAIL: quality assessment"
  ERRORS=$((ERRORS + 1))
fi

# Summary
if [ $ERRORS -eq 0 ]; then
  echo "PASS: All validations passed"
  exit 0
else
  echo "FAIL: $ERRORS validation error(s) found"
  exit 1
fi
