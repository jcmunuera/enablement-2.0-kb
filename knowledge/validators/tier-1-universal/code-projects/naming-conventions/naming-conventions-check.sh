#!/bin/bash
# naming-conventions-check.sh
# Validates naming conventions (classes, packages)

SERVICE_DIR=${1:-.}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS:${NC} $1"; }
fail() { echo -e "${RED}❌ FAIL:${NC} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "${YELLOW}⚠️  WARN:${NC} $1"; }

ERRORS=0
WARNINGS=0

# Check Java class names are PascalCase
if [ -d "$SERVICE_DIR/src/main/java" ]; then
    # Find Java files with lowercase first letter
    BAD_CLASSES=$(find "$SERVICE_DIR/src/main/java" -name "*.java" -type f -exec basename {} \; | grep -E '^[a-z]' || true)
    
    if [ -z "$BAD_CLASSES" ]; then
        pass "Java classes follow PascalCase convention"
    else
        warn "Some classes may not follow PascalCase convention"
        echo "$BAD_CLASSES" | head -3
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# Check package names are lowercase
if [ -d "$SERVICE_DIR/src/main/java" ]; then
    # Find directories with uppercase letters in path
    BAD_PACKAGES=$(find "$SERVICE_DIR/src/main/java" -type d -path "*/[A-Z]*" 2>/dev/null || true)
    
    if [ -z "$BAD_PACKAGES" ]; then
        pass "Package names are lowercase"
    else
        warn "Some package names may contain uppercase letters"
        echo "$BAD_PACKAGES" | head -3
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# Check for common naming patterns
if [ -d "$SERVICE_DIR/src/main/java" ]; then
    # Controllers should end with Controller
    NON_STANDARD_CONTROLLERS=$(find "$SERVICE_DIR/src/main/java" -path "*/controller/*" -name "*.java" ! -name "*Controller.java" -type f || true)
    
    if [ -z "$NON_STANDARD_CONTROLLERS" ]; then
        pass "Controllers follow naming convention (*Controller.java)"
    else
        warn "Some controllers don't end with 'Controller'"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    # Services should end with Service
    NON_STANDARD_SERVICES=$(find "$SERVICE_DIR/src/main/java" -path "*/service/*" -name "*.java" ! -name "*Service.java" -type f 2>/dev/null || true)
    
    if [ -z "$NON_STANDARD_SERVICES" ]; then
        pass "Services follow naming convention (*Service.java)"
    else
        warn "Some services don't end with 'Service'"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

if [ $ERRORS -eq 0 ]; then
    exit 0
else
    exit 1
fi
