#!/bin/bash
# hexagonal-structure-check.sh
# Validates Hexagonal Light architecture (ADR-009 compliance)

SERVICE_DIR=${1:-.}
BASE_PACKAGE_PATH=${2:-""}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS:${NC} $1"; }
fail() { echo -e "${RED}❌ FAIL:${NC} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "${YELLOW}⚠️  WARN:${NC} $1"; }

ERRORS=0

# Determine paths
if [ -n "$BASE_PACKAGE_PATH" ]; then
    DOMAIN_PATH="$SERVICE_DIR/src/main/java/$BASE_PACKAGE_PATH/domain"
    APP_PATH="$SERVICE_DIR/src/main/java/$BASE_PACKAGE_PATH/application"
    ADAPTER_PATH="$SERVICE_DIR/src/main/java/$BASE_PACKAGE_PATH/adapter"
    INFRA_PATH="$SERVICE_DIR/src/main/java/$BASE_PACKAGE_PATH/infrastructure"
else
    # Try to find hexagonal structure automatically
    DOMAIN_PATH=$(find "$SERVICE_DIR/src/main/java" -type d -name "domain" | head -1)
    APP_PATH=$(find "$SERVICE_DIR/src/main/java" -type d -name "application" | head -1)
    ADAPTER_PATH=$(find "$SERVICE_DIR/src/main/java" -type d -name "adapter" | head -1)
    INFRA_PATH=$(find "$SERVICE_DIR/src/main/java" -type d -name "infrastructure" | head -1)
fi

# ==========================================
# 1. STRUCTURE VALIDATION
# ==========================================

# Check domain layer exists
if [ -d "$DOMAIN_PATH" ]; then
    pass "Domain layer exists"
else
    fail "Domain layer missing: $DOMAIN_PATH"
fi

# Check application layer exists
if [ -d "$APP_PATH" ]; then
    pass "Application layer exists"
else
    fail "Application layer missing: $APP_PATH"
fi

# Check adapter layer exists
if [ -d "$ADAPTER_PATH" ]; then
    pass "Adapter layer exists"
else
    fail "Adapter layer missing: $ADAPTER_PATH"
fi

# Check infrastructure exists (optional)
if [ -d "$INFRA_PATH" ]; then
    pass "Infrastructure layer exists"
else
    warn "Infrastructure layer not found (optional)"
fi

# ==========================================
# 2. DOMAIN LAYER PURITY (CRITICAL - ADR-009)
# ==========================================

if [ -d "$DOMAIN_PATH" ]; then
    # Check for Spring annotations in domain
    SPRING_IN_DOMAIN=$(grep -r "@Service\|@Component\|@Autowired\|@Repository\|@Bean" "$DOMAIN_PATH" 2>/dev/null | wc -l || echo "0")
    if [ "$SPRING_IN_DOMAIN" -gt 0 ]; then
        fail "Spring annotations found in domain layer (ADR-009 violation)"
        grep -r "@Service\|@Component\|@Autowired\|@Repository\|@Bean" "$DOMAIN_PATH" 2>/dev/null | head -5 || true
    else
        pass "Domain layer is Spring-free (ADR-009 compliant)"
    fi
    
    # Check for JPA annotations in domain model
    DOMAIN_MODEL_PATH="$DOMAIN_PATH/model"
    if [ -d "$DOMAIN_MODEL_PATH" ]; then
        JPA_IN_MODEL=$(grep -r "@Entity\|@Table\|@Column\|@Id\|@GeneratedValue" "$DOMAIN_MODEL_PATH" 2>/dev/null | wc -l || echo "0")
        if [ "$JPA_IN_MODEL" -gt 0 ]; then
            fail "JPA annotations found in domain model (ADR-009 violation)"
            grep -r "@Entity\|@Table\|@Column\|@Id" "$DOMAIN_MODEL_PATH" 2>/dev/null | head -5 || true
        else
            pass "Domain model is JPA-free (ADR-009 compliant)"
        fi
    fi
    
    # Check repository is interface in domain
    REPO_PATH="$DOMAIN_PATH/repository"
    if [ -d "$REPO_PATH" ]; then
        REPO_IS_INTERFACE=$(grep -r "public interface.*Repository" "$REPO_PATH" 2>/dev/null | wc -l || echo "0")
        if [ "$REPO_IS_INTERFACE" -gt 0 ]; then
            pass "Repository is interface in domain layer"
        else
            fail "Repository should be an interface in domain layer"
        fi
        
        # Check repository has NO @Repository annotation
        REPO_ANNOTATION=$(grep -r "@Repository" "$REPO_PATH" 2>/dev/null | wc -l || echo "0")
        if [ "$REPO_ANNOTATION" -gt 0 ]; then
            fail "@Repository annotation in domain layer (should be in adapter)"
        else
            pass "Repository interface has no Spring annotations"
        fi
    fi
fi

# ==========================================
# 3. APPLICATION LAYER VALIDATION
# ==========================================

if [ -d "$APP_PATH" ]; then
    # Application services should have @Service
    SERVICE_COUNT=$(find "$APP_PATH" -name "*Service.java" -type f 2>/dev/null | wc -l)
    if [ "$SERVICE_COUNT" -gt 0 ]; then
        SERVICE_WITH_ANNOTATION=$(find "$APP_PATH" -name "*Service.java" -exec grep -l "@Service" {} \; 2>/dev/null | wc -l)
        if [ "$SERVICE_WITH_ANNOTATION" -gt 0 ]; then
            pass "Application services have @Service annotation"
        else
            warn "Application services missing @Service annotation"
        fi
    fi
fi

# ==========================================
# 4. ADAPTER LAYER VALIDATION
# ==========================================

if [ -d "$ADAPTER_PATH" ]; then
    # Check repository adapter implements domain interface
    ADAPTER_PERSISTENCE="$ADAPTER_PATH/persistence/adapter"
    if [ -d "$ADAPTER_PERSISTENCE" ]; then
        IMPL_REPO=$(grep -r "implements.*Repository" "$ADAPTER_PERSISTENCE" 2>/dev/null | wc -l || echo "0")
        if [ "$IMPL_REPO" -gt 0 ]; then
            pass "Repository adapter implements domain interface"
        else
            warn "Repository adapter should implement domain interface"
        fi
    fi
    
    # Check JPA entities are in adapter layer
    JPA_ENTITY_PATH="$ADAPTER_PATH/persistence/entity"
    if [ -d "$JPA_ENTITY_PATH" ]; then
        JPA_ENTITIES=$(grep -r "@Entity" "$JPA_ENTITY_PATH" 2>/dev/null | wc -l || echo "0")
        if [ "$JPA_ENTITIES" -gt 0 ]; then
            pass "JPA @Entity annotations in adapter layer (correct)"
        else
            warn "Expected JPA entities in adapter/persistence/entity"
        fi
    fi
    
    # Check adapter has @Repository annotation (not domain)
    ADAPTER_REPO=$(grep -r "@Repository" "$ADAPTER_PERSISTENCE" 2>/dev/null | wc -l || echo "0")
    if [ "$ADAPTER_REPO" -gt 0 ]; then
        pass "@Repository annotations in adapter layer (correct)"
    fi
fi

# ==========================================
# 5. TEST VALIDATION
# ==========================================

DOMAIN_TEST_PATH="$SERVICE_DIR/src/test/java"
if [ -n "$BASE_PACKAGE_PATH" ]; then
    DOMAIN_TEST_PATH="$SERVICE_DIR/src/test/java/$BASE_PACKAGE_PATH/domain"
else
    DOMAIN_TEST_PATH=$(find "$SERVICE_DIR/src/test/java" -type d -name "domain" | head -1)
fi

if [ -d "$DOMAIN_TEST_PATH" ]; then
    # Check domain tests don't use Spring
    SPRING_IN_DOMAIN_TESTS=$(grep -r "@SpringBootTest\|@DataJpaTest" "$DOMAIN_TEST_PATH" 2>/dev/null | wc -l || echo "0")
    if [ "$SPRING_IN_DOMAIN_TESTS" -gt 0 ]; then
        fail "Domain tests should not use @SpringBootTest (ADR-009 violation)"
        grep -r "@SpringBootTest\|@DataJpaTest" "$DOMAIN_TEST_PATH" 2>/dev/null | head -5 || true
    else
        pass "Domain tests don't use Spring context (ADR-009 compliant)"
    fi
    
    # Check domain tests use Mockito
    MOCKITO_IN_TESTS=$(grep -r "@ExtendWith(MockitoExtension.class)\|@Mock" "$DOMAIN_TEST_PATH" 2>/dev/null | wc -l || echo "0")
    if [ "$MOCKITO_IN_TESTS" -gt 0 ]; then
        pass "Domain tests use Mockito (recommended)"
    else
        warn "Domain tests should use Mockito for mocking"
    fi
else
    warn "Domain test directory not found"
fi

echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Hexagonal Architecture: VALIDATED (ADR-009 Compliant)${NC}"
    exit 0
else
    echo -e "${RED}❌ Hexagonal Architecture: VALIDATION FAILED${NC}"
    echo "   Errors: $ERRORS (ADR-009 violations)"
    exit 1
fi
