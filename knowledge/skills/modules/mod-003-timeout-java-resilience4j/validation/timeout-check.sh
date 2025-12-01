#!/bin/bash
# =============================================================================
# MOD-003: Timeout Pattern Validation Script
# Tier 3 validation for Resilience4j TimeLimiter implementation
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0

# Target directory (passed as argument)
TARGET_DIR="${1:-.}"

echo "=============================================="
echo "MOD-003: Timeout Pattern Validation"
echo "Target: $TARGET_DIR"
echo "=============================================="

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ((ERRORS++))
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    ((WARNINGS++))
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

info() {
    echo -e "[INFO] $1"
}

# -----------------------------------------------------------------------------
# Validation checks
# -----------------------------------------------------------------------------

echo ""
echo "--- Structural Constraints ---"

# Check 1: @TimeLimiter not in domain layer
info "Checking @TimeLimiter not in domain layer..."
if grep -r "@TimeLimiter" "$TARGET_DIR/src/main/java" 2>/dev/null | grep -q "/domain/"; then
    error "@TimeLimiter annotation found in domain layer - MUST be in application layer only"
else
    success "@TimeLimiter not in domain layer"
fi

# Check 2: @TimeLimiter not directly on controllers
info "Checking @TimeLimiter not on controllers..."
if grep -r "@TimeLimiter" "$TARGET_DIR/src/main/java" 2>/dev/null | grep -q "/controller/"; then
    warning "@TimeLimiter found on controller - SHOULD be on application service"
else
    success "@TimeLimiter not on controllers"
fi

# Check 3: Methods with @TimeLimiter return CompletableFuture
info "Checking @TimeLimiter methods return CompletableFuture..."
TIMELIMITER_FILES=$(grep -rl "@TimeLimiter" "$TARGET_DIR/src/main/java" 2>/dev/null || true)
RETURN_OK=true
for file in $TIMELIMITER_FILES; do
    # Check if method after @TimeLimiter returns CompletableFuture
    if grep -A5 "@TimeLimiter" "$file" | grep -q "public.*CompletableFuture"; then
        : # OK
    else
        if grep -A5 "@TimeLimiter" "$file" | grep -q "public"; then
            error "In $file: @TimeLimiter method does not return CompletableFuture - REQUIRED"
            RETURN_OK=false
        fi
    fi
done
if [ "$RETURN_OK" = true ] && [ -n "$TIMELIMITER_FILES" ]; then
    success "@TimeLimiter methods return CompletableFuture"
fi

# Check 4: Annotation order (CircuitBreaker before TimeLimiter before Retry)
info "Checking annotation order..."
for file in $TIMELIMITER_FILES; do
    # Check CircuitBreaker before TimeLimiter
    if grep -q "@CircuitBreaker" "$file" && grep -q "@TimeLimiter" "$file"; then
        CB_LINE=$(grep -n "@CircuitBreaker" "$file" | head -1 | cut -d: -f1)
        TL_LINE=$(grep -n "@TimeLimiter" "$file" | head -1 | cut -d: -f1)
        if [ -n "$CB_LINE" ] && [ -n "$TL_LINE" ] && [ "$TL_LINE" -lt "$CB_LINE" ]; then
            error "In $file: @TimeLimiter appears before @CircuitBreaker - wrong order"
        fi
    fi
    
    # Check TimeLimiter before Retry
    if grep -q "@TimeLimiter" "$file" && grep -q "@Retry" "$file"; then
        TL_LINE=$(grep -n "@TimeLimiter" "$file" | head -1 | cut -d: -f1)
        R_LINE=$(grep -n "@Retry" "$file" | head -1 | cut -d: -f1)
        if [ -n "$TL_LINE" ] && [ -n "$R_LINE" ] && [ "$R_LINE" -lt "$TL_LINE" ]; then
            error "In $file: @Retry appears before @TimeLimiter - wrong order"
        fi
    fi
done
if [ $ERRORS -eq 0 ]; then
    success "Annotation order correct"
fi

echo ""
echo "--- Configuration Constraints ---"

# Check 5: TimeLimiter configuration exists in application.yml
info "Checking timelimiter configuration exists..."
if [ -f "$TARGET_DIR/src/main/resources/application.yml" ]; then
    if grep -q "resilience4j:" "$TARGET_DIR/src/main/resources/application.yml" && \
       grep -q "timelimiter:" "$TARGET_DIR/src/main/resources/application.yml"; then
        success "Resilience4j timelimiter configuration found"
    else
        error "resilience4j.timelimiter configuration not found in application.yml"
    fi
else
    error "application.yml not found"
fi

# Check 6: Timeout duration configured
info "Checking timeoutDuration configured..."
if [ -f "$TARGET_DIR/src/main/resources/application.yml" ]; then
    if grep -q "timeoutDuration:" "$TARGET_DIR/src/main/resources/application.yml"; then
        success "timeoutDuration configured"
    else
        warning "timeoutDuration not explicitly configured - using defaults"
    fi
fi

echo ""
echo "--- Dependency Constraints ---"

# Check 7: Resilience4j dependency
info "Checking Resilience4j dependency..."
if [ -f "$TARGET_DIR/pom.xml" ]; then
    if grep -q "resilience4j-spring-boot" "$TARGET_DIR/pom.xml"; then
        success "Resilience4j dependency found"
    else
        error "Resilience4j dependency not found in pom.xml"
    fi
elif [ -f "$TARGET_DIR/build.gradle" ]; then
    if grep -q "resilience4j" "$TARGET_DIR/build.gradle"; then
        success "Resilience4j dependency found"
    else
        error "Resilience4j dependency not found in build.gradle"
    fi
else
    warning "No pom.xml or build.gradle found"
fi

# Check 8: Spring AOP dependency
info "Checking Spring AOP dependency..."
if [ -f "$TARGET_DIR/pom.xml" ]; then
    if grep -q "spring-boot-starter-aop" "$TARGET_DIR/pom.xml"; then
        success "Spring AOP dependency found"
    else
        error "spring-boot-starter-aop dependency not found - required for @TimeLimiter"
    fi
fi

echo ""
echo "--- Testing Constraints ---"

# Check 9: Test files exist for services with @TimeLimiter
info "Checking test coverage for timeout..."
for file in $TIMELIMITER_FILES; do
    CLASS_NAME=$(basename "$file" .java)
    TEST_FILE="$TARGET_DIR/src/test/java"
    if find "$TEST_FILE" -name "${CLASS_NAME}Test.java" 2>/dev/null | grep -q .; then
        success "Test found for $CLASS_NAME"
    else
        warning "No test found for $CLASS_NAME with @TimeLimiter"
    fi
done

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

echo ""
echo "=============================================="
echo "Validation Summary"
echo "=============================================="
echo -e "Errors:   ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}VALIDATION FAILED${NC}"
    exit 1
else
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}VALIDATION PASSED WITH WARNINGS${NC}"
    else
        echo -e "${GREEN}VALIDATION PASSED${NC}"
    fi
    exit 0
fi
