# Determinism Rules for Code Generation

**Version:** 1.2  
**Date:** 2026-01-13  
**Status:** Active

---

## Purpose

This document defines mandatory rules to ensure **deterministic code generation** across the Enablement 2.0 platform. Following these rules guarantees that:

1. Multiple executions with the same input produce **identical** code
2. Generated code follows established **best practices**
3. Code quality is **predictable and consistent**

---

## Scope

These rules apply to:
- All CODE domain modules (`mod-code-*`)
- All CODE domain skills (`skill-code-*`)
- All generated Java/Spring Boot code

---

## Global Patterns

### 1. Value Objects (Entity IDs)

**Rule:** Entity IDs MUST be `record` types wrapping `UUID`.

```java
// ✅ CORRECT
public record CustomerId(UUID value) {
    
    public CustomerId {
        Objects.requireNonNull(value, "CustomerId must not be null");
    }
    
    public static CustomerId generate() {
        return new CustomerId(UUID.randomUUID());
    }
    
    public static CustomerId of(String value) {
        return new CustomerId(UUID.fromString(value));
    }
    
    public static CustomerId of(UUID value) {
        return new CustomerId(value);
    }
    
    @Override
    public String toString() {
        return value.toString();
    }
}

// ❌ WRONG - String instead of UUID
public record CustomerId(String value) { ... }

// ❌ WRONG - Class instead of record
public class CustomerId {
    private final String value;
    ...
}
```

**Rationale:**
- `record` ensures immutability
- `UUID` provides type safety and uniqueness
- Compact constructor validates non-null

---

### 2. Request DTOs

**Rule:** Request DTOs MUST be `record` types with validation annotations.

```java
// ✅ CORRECT
public record CreateCustomerRequest(
    @NotBlank(message = "First name is required")
    String firstName,
    
    @NotBlank(message = "Last name is required")
    String lastName,
    
    @Email(message = "Invalid email format")
    String email,
    
    @Past(message = "Date of birth must be in the past")
    LocalDate dateOfBirth
) {}

// ❌ WRONG - Class with Lombok
@Data
@Builder
public class CreateCustomerRequest {
    private String firstName;
    ...
}
```

**Rationale:**
- Records are immutable (DTOs should not change)
- Less boilerplate than Lombok
- Validation annotations work with records

---

### 3. Response DTOs

**Rule:** Response DTOs follow conditional pattern:

| Condition | Pattern |
|-----------|---------|
| No HATEOAS | `record` |
| With HATEOAS | `class extends RepresentationModel` |

```java
// ✅ CORRECT - Without HATEOAS
public record CustomerResponse(
    String id,
    String firstName,
    String lastName,
    String email,
    CustomerStatus status,
    Instant createdAt
) {}

// ✅ CORRECT - With HATEOAS
@Relation(collectionRelation = "customers", itemRelation = "customer")
public class CustomerResponse extends RepresentationModel<CustomerResponse> {
    
    private String id;
    private String firstName;
    // ... getters and setters required for HATEOAS
}
```

**Rationale:**
- HATEOAS requires `extends RepresentationModel` which records cannot do
- Without HATEOAS, records provide immutability

---

### 4. Domain Entities

**Rule:** Domain entities MUST be `class` (not record).

```java
// ✅ CORRECT
public class Customer {
    
    private final CustomerId id;
    private String firstName;
    private String lastName;
    private CustomerStatus status;
    private final Instant createdAt;
    private Instant updatedAt;
    
    // Constructor, business methods, getters...
    
    public void activate() {
        this.status = CustomerStatus.ACTIVE;
        this.updatedAt = Instant.now();
    }
}

// ❌ WRONG - Record (entities are mutable by design)
public record Customer(...) {}
```

**Rationale:**
- Entities have lifecycle and mutable state
- Business methods modify internal state
- Records are immutable by design

---

### 5. Domain Enums

**Rule:** Domain enums MUST be simple (no attributes). Code mapping belongs in Mapper.

```java
// ✅ CORRECT - Simple enum
public enum CustomerStatus {
    ACTIVE,
    INACTIVE,
    BLOCKED
}

// ✅ CORRECT - Mapping in Mapper class
@Component
public class SystemApiMapper {
    
    private CustomerStatus toStatus(String code) {
        return switch (code) {
            case "A" -> CustomerStatus.ACTIVE;
            case "I" -> CustomerStatus.INACTIVE;
            case "B" -> CustomerStatus.BLOCKED;
            default -> throw new IllegalArgumentException("Unknown code: " + code);
        };
    }
    
    private String toCode(CustomerStatus status) {
        return switch (status) {
            case ACTIVE -> "A";
            case INACTIVE -> "I";
            case BLOCKED -> "B";
        };
    }
}

// ❌ WRONG - Enum with code attribute
public enum CustomerStatus {
    ACTIVE("A"),
    INACTIVE("I"),
    BLOCKED("B");
    
    private final String code;
    
    CustomerStatus(String code) { this.code = code; }
    
    public static CustomerStatus fromCode(String code) { ... }
}
```

**Rationale:**
- Separates domain concept from external representation
- Mapper is the single place for transformation logic
- Enum stays pure domain, mapper handles integration

---

### 6. External API DTOs

**Rule:** DTOs for external APIs (System API, third-party) MUST be `record`.

```java
// ✅ CORRECT
public record PartyResponse(
    @JsonProperty("CUST_ID") String custId,
    @JsonProperty("CUST_FNAME") String custFname,
    @JsonProperty("CUST_LNAME") String custLname,
    @JsonProperty("CUST_STATUS") String custStatus,
    @JsonProperty("SYS_RC") String sysRc,
    @JsonProperty("SYS_MSG") String sysMsg
) {}

// ❌ WRONG - Lombok @Data
@Data
@Builder
@Jacksonized
public class PartyResponse {
    @JsonProperty("CUST_ID")
    private String custId;
    ...
}
```

**Rationale:**
- External DTOs are data carriers (immutable)
- `@JsonProperty` works with records
- No need for Lombok complexity

---

### 7. Mappers

**Rule:** Mappers MUST be dedicated `@Component` classes with clear responsibilities.

```java
// ✅ CORRECT
@Component
public class PartyMapper {
    
    private static final DateTimeFormatter DATE_FORMAT = 
        DateTimeFormatter.ofPattern("yyyy-MM-dd");
    
    public Customer toDomain(PartyResponse response) {
        return new Customer(
            toCustomerId(response.custId()),
            toProperCase(response.custFname()),
            toProperCase(response.custLname()),
            response.custEmailAddr().toLowerCase(),
            parseDate(response.custDob()),
            toStatus(response.custStatus()),
            Instant.now(),
            Instant.now()
        );
    }
    
    public PartyCreateRequest toRequest(Customer customer) {
        return new PartyCreateRequest(
            customer.getFirstName().toUpperCase(),
            customer.getLastName().toUpperCase(),
            customer.getEmail().toUpperCase(),
            formatDate(customer.getDateOfBirth())
        );
    }
    
    // Private helper methods for transformations
    private CustomerId toCustomerId(String mainframeId) { ... }
    private CustomerStatus toStatus(String code) { ... }
    private String toCode(CustomerStatus status) { ... }
    private String toProperCase(String value) { ... }
    private LocalDate parseDate(String date) { ... }
    private String formatDate(LocalDate date) { ... }
}
```

**Rationale:**
- Single responsibility for transformation
- All mapping logic in one place
- Testable in isolation

---

## Required Annotations

### Generated Code Annotations

All generated files MUST include Javadoc with:

```java
/**
 * [Class description]
 * 
 * @generated {skill-id} v{version}
 * @module {module-id}
 * @variant {variant-id}  // Only if non-default variant used
 */
```

**Example:**

```java
/**
 * Customer aggregate root.
 * 
 * @generated skill-021-api-rest-java-spring v2.1.0
 * @module mod-code-015-hexagonal-base-java-spring
 */
public class Customer { ... }

/**
 * REST client for Parties System API.
 * 
 * @generated skill-021-api-rest-java-spring v2.1.0
 * @module mod-code-018-api-integration-rest-java-spring
 * @variant restclient
 */
@Component
public class PartiesApiClient { ... }
```

---

## Forbidden Patterns

| Pattern | Reason | Alternative |
|---------|--------|-------------|
| Lombok `@Data` on DTOs | Records are cleaner, immutable | Java `record` |
| Lombok `@Slf4j` | Inconsistent logging setup | Explicit `LoggerFactory.getLogger()` |
| Code mapping in Enum | Couples domain to external systems | Mapper class |
| `String` for entity IDs | Type safety loss | `record` with `UUID` |
| `@TimeLimiter` for sync calls | Forces CompletableFuture unnecessarily | Client-level timeout config |
| Inline validation in constructors | Inconsistent validation | Dedicated validation methods or annotations |
| Mutable DTOs | Data carriers should be immutable | `record` |

---

## Validation

### Tier-3 Validation Scripts

Each module SHOULD include validation scripts that check determinism rules:

```bash
#!/bin/bash
# determinism-check.sh

# Check: All entity IDs are records with UUID
grep -r "public record.*Id(" --include="*.java" | grep -v "UUID" && \
    echo "❌ FAIL: Entity IDs must use UUID" && exit 1

# Check: No Lombok @Data on DTOs
grep -r "@Data" --include="*.java" | grep -E "(Request|Response|Dto)" && \
    echo "❌ FAIL: DTOs must be records, not @Data classes" && exit 1

# Check: Enums have no constructor with parameters
grep -rA5 "public enum" --include="*.java" | grep -E "^\s+[A-Z_]+\(" && \
    echo "❌ FAIL: Enums must be simple (no attributes)" && exit 1

echo "✅ PASS: Determinism rules validated"
exit 0
```

---

## Code Style Conventions (v1.1)

> **NEW in v1.1:** These conventions ensure consistent code style across generations.

### Method Ordering

**Rule:** Methods in generated classes MUST follow this order:

```
1. Static factory methods (of, from, create, generate)
2. Constructor(s)
3. Public business methods (alphabetically)
4. Public getters (alphabetically)
5. Protected methods (alphabetically)
6. Private methods (alphabetically)
7. equals/hashCode/toString (if not record)
8. Builder class (if applicable)
```

**Example:**

```java
public class CustomerApplicationService {
    
    // 1. Static factory (none in this case)
    
    // 2. Constructor
    public CustomerApplicationService(CustomerRepository repository) {
        this.repository = repository;
    }
    
    // 3. Public business methods (alphabetically)
    public CustomerResponse createCustomer(CreateCustomerRequest request) { ... }
    
    public void deleteCustomer(CustomerId id) { ... }
    
    public CustomerResponse getCustomer(CustomerId id) { ... }
    
    public List<CustomerResponse> listCustomers() { ... }
    
    public CustomerResponse updateCustomer(CustomerId id, UpdateCustomerRequest request) { ... }
    
    // 4. Private methods
    private Customer mapToDomain(CreateCustomerRequest request) { ... }
    
    private CustomerResponse mapToResponse(Customer customer) { ... }
}
```

### Javadoc Standards

**Rule:** Generated code MUST include Javadoc for:
- Class/interface declarations
- Public methods
- Complex private methods

**Javadoc Template:**

```java
/**
 * Brief description (one line).
 * 
 * Extended description if needed (optional).
 * 
 * @param paramName parameter description
 * @return return value description
 * @throws ExceptionType when this happens
 * 
 * @generated {skillId} v{skillVersion}
 * @module {moduleId}
 */
```

**Mandatory Javadoc Elements:**

| Element | Required | Example |
|---------|----------|---------|
| Brief description | ✅ Yes | `Customer repository port.` |
| @param | ✅ If has params | `@param id the customer ID` |
| @return | ✅ If non-void | `@return the customer if found` |
| @throws | ⚠️ If throws | `@throws CustomerNotFoundException` |
| @generated | ✅ Yes | `@generated skill-021 v2.3.0` |
| @module | ✅ Yes | `@module mod-code-015` |

**Example:**

```java
/**
 * Find customer by ID.
 * 
 * Retrieves customer from System API and maps to domain model.
 * 
 * @param id the customer ID (must not be null)
 * @return Optional containing the customer if found, empty otherwise
 * @throws SystemApiUnavailableException if System API is down
 * 
 * @generated skill-021-api-rest-java-spring v2.3.0
 * @module mod-code-017-persistence-systemapi
 */
public Optional<Customer> findById(CustomerId id) {
    ...
}
```

---

## Method Ordering Convention (v1.2)

**Rule:** Methods in generated classes MUST follow this order:

### For all classes:

```
1. Static factory methods (of(), from(), create())
2. Constructor(s)
3. Public methods (alphabetical)
4. Package-private methods (alphabetical)
5. Private methods (alphabetical)
```

### For Controllers:

```
1. POST (create)
2. GET by ID (read one)
3. GET all (read many/list)
4. PUT (update)
5. PATCH (partial update)
6. DELETE (delete)
```

### For Repositories:

```
1. findById()
2. findAll()
3. save()
4. deleteById()
5. existsById()
6. Custom query methods (alphabetical)
```

### For Services:

```
1. Create operations
2. Read operations (get, find, list)
3. Update operations
4. Delete operations
5. Validation/utility methods
```

**Example - ApplicationService:**

```java
@Service
public class CustomerApplicationService {
    
    // 1. Create
    public CustomerResponse createCustomer(CreateCustomerRequest request) { ... }
    
    // 2. Read
    public CustomerResponse getCustomer(UUID id) { ... }
    public Page<CustomerResponse> listCustomers(Pageable pageable) { ... }
    
    // 3. Update
    public CustomerResponse updateCustomer(UUID id, UpdateCustomerRequest request) { ... }
    
    // 4. Delete
    public void deleteCustomer(UUID id) { ... }
}
```

---

## Javadoc Standards (v1.2)

**Rule:** All public classes and methods MUST have Javadoc comments.

### Class-level Javadoc:

```java
/**
 * Brief description of the class purpose.
 * 
 * <p>Additional details if needed, explaining behavior or constraints.</p>
 * 
 * @generated {skillId} v{skillVersion}
 * @module {moduleId}
 */
public class CustomerApplicationService { ... }
```

### Method-level Javadoc:

```java
/**
 * Brief description of what the method does.
 * 
 * @param paramName description of the parameter
 * @return description of return value
 * @throws ExceptionType when this exception is thrown
 */
public CustomerResponse getCustomer(UUID id) { ... }
```

### Required Tags:

| Element | Required Tags |
|---------|---------------|
| Public class | Description + `@generated` + `@module` |
| Public method | Description + `@param` (all) + `@return` (if not void) + `@throws` (if applicable) |
| Interface | Description + purpose |
| Enum | Description + each constant |

### Forbidden:

```java
// ❌ WRONG - No Javadoc
public CustomerResponse getCustomer(UUID id) { ... }

// ❌ WRONG - Empty Javadoc
/**
 */
public CustomerResponse getCustomer(UUID id) { ... }

// ❌ WRONG - Redundant/useless Javadoc
/**
 * Gets the customer.
 * @param id the id
 * @return the customer
 */
public CustomerResponse getCustomer(UUID id) { ... }
```

### Correct:

```java
/**
 * Retrieves a customer by their unique identifier.
 * 
 * @param id the customer's UUID
 * @return the customer data including personal information and status
 * @throws CustomerNotFoundException if no customer exists with the given ID
 */
public CustomerResponse getCustomer(UUID id) { ... }
```

---

## Applicability by Module

| Module | Applies | Notes |
|--------|---------|-------|
| mod-code-015-hexagonal-base | ✅ Full | Core patterns |
| mod-code-016-persistence-jpa | ✅ Full | JPA entities follow entity rules |
| mod-code-017-persistence-systemapi | ✅ Full | External DTOs, mappers |
| mod-code-018-api-integration-rest | ✅ Full | Client DTOs |
| mod-code-019-api-public-exposure | ✅ Partial | HATEOAS exception for Response |
| mod-code-020-compensation | ✅ Full | Domain types |
| mod-code-001/002/003/004 (Resilience) | ⚠️ Limited | Focus on annotation placement |

---

## Related Documents

- `model/standards/authoring/MODULE.md` - Module authoring guide
- `model/standards/ASSET-STANDARDS-v1.4.md` - Asset standards
- `runtime/flows/code/GENERATE.md` - Generation flow with variant selection
- `runtime/schemas/manifest.schema.json` - Manifest JSON Schema (v1.1)

---

**Last Updated:** 2026-01-13
