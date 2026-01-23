#!/bin/bash
# traceability-check.sh
# Universal validator - applies to ALL outputs from ALL domains
#
# Validates .enablement/manifest.json exists and contains required fields
# Updated for Model v3.0 (skill removed, discovery-based)

set -e

OUTPUT_DIR="${1:-.}"
ERRORS=0
WARNINGS=0

# Output functions
pass() { echo -e "✅ PASS: $1"; }
fail() { echo -e "❌ FAIL: $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "⚠️  WARN: $1"; WARNINGS=$((WARNINGS + 1)); }
skip() { echo -e "⏭️  SKIP: $1"; }

echo "════════════════════════════════════════════════════════════"
echo "  TIER 1 - TRACEABILITY VALIDATION (Universal)"
echo "════════════════════════════════════════════════════════════"
echo "  Target: $OUTPUT_DIR"
echo "════════════════════════════════════════════════════════════"

# Check 1: .enablement directory exists
if [ -d "$OUTPUT_DIR/.enablement" ]; then
    pass ".enablement/ directory exists"
else
    fail ".enablement/ directory not found"
    echo "    Every generated output MUST include .enablement/ directory"
    exit 1
fi

# Check 2: manifest.json exists
MANIFEST="$OUTPUT_DIR/.enablement/manifest.json"
if [ -f "$MANIFEST" ]; then
    pass "manifest.json exists"
else
    fail "manifest.json not found in .enablement/"
    exit 1
fi

# Check 3: Valid JSON
if jq empty "$MANIFEST" 2>/dev/null; then
    pass "manifest.json is valid JSON"
else
    fail "manifest.json is not valid JSON"
    exit 1
fi

# Check 4: Required top-level fields (Model v3.0)
# Note: "skill" removed in v3.0, replaced by discovery-based flow
REQUIRED_FIELDS=("generation" "enablement" "status")
for field in "${REQUIRED_FIELDS[@]}"; do
    if jq -e ".$field" "$MANIFEST" > /dev/null 2>&1; then
        pass "Required field '$field' present"
    else
        fail "Required field '$field' missing"
    fi
done

# Check 5: generation.id is valid UUID (warning only)
GEN_ID=$(jq -r '.generation.id // empty' "$MANIFEST")
if [ -n "$GEN_ID" ]; then
    UUID_REGEX='^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    if [[ "$GEN_ID" =~ $UUID_REGEX ]]; then
        pass "generation.id is valid UUID"
    else
        warn "generation.id is not a valid UUID format: $GEN_ID"
    fi
else
    warn "generation.id is empty or missing"
fi

# Check 6: generation.timestamp is valid ISO-8601 (warning only)
TIMESTAMP=$(jq -r '.generation.timestamp // empty' "$MANIFEST")
if [ -n "$TIMESTAMP" ]; then
    # Basic ISO-8601 check (YYYY-MM-DDTHH:MM:SS)
    if [[ "$TIMESTAMP" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2} ]]; then
        pass "generation.timestamp is valid ISO-8601"
    else
        warn "generation.timestamp format may be invalid: $TIMESTAMP"
    fi
else
    warn "generation.timestamp is empty or missing"
fi

# Check 7: enablement.version present (Model v3.0)
ENABLEMENT_VERSION=$(jq -r '.enablement.version // empty' "$MANIFEST")
if [ -n "$ENABLEMENT_VERSION" ]; then
    pass "enablement.version present: $ENABLEMENT_VERSION"
else
    warn "enablement.version is empty or missing"
fi

# Check 8: discovery block present (recommended for v3.0)
if jq -e ".discovery" "$MANIFEST" > /dev/null 2>&1; then
    pass "discovery block present"
    
    # Check discovery.stack
    STACK=$(jq -r '.discovery.stack // empty' "$MANIFEST")
    if [ -n "$STACK" ]; then
        pass "discovery.stack: $STACK"
    else
        warn "discovery.stack is empty"
    fi
else
    warn "discovery block missing (recommended for traceability)"
fi

# Check 9: status.overall is valid value
STATUS=$(jq -r '.status.overall // empty' "$MANIFEST")
if [ -n "$STATUS" ]; then
    if [[ "$STATUS" =~ ^(SUCCESS|PARTIAL|FAILED|PENDING)$ ]]; then
        pass "status.overall is valid ($STATUS)"
    else
        fail "status.overall must be SUCCESS, PARTIAL, FAILED, or PENDING (got: $STATUS)"
    fi
else
    fail "status.overall is missing"
fi

# Summary
echo ""
echo "════════════════════════════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
    echo "  ✅ TRACEABILITY: PASSED ($WARNINGS warnings)"
else
    echo "  ❌ TRACEABILITY: FAILED ($ERRORS errors, $WARNINGS warnings)"
fi
echo "════════════════════════════════════════════════════════════"

exit $ERRORS
