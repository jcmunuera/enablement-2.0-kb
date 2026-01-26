// ═══════════════════════════════════════════════════════════════════════════════
// Template: Response.java.tpl
// Module: mod-code-015-hexagonal-base-java-spring
// ═══════════════════════════════════════════════════════════════════════════════
// Output: {{basePackage}}/application/dto/{{Entity}}Response.java
// Purpose: Response DTO for {{Entity}}
// ═══════════════════════════════════════════════════════════════════════════════
// REQUIRED VARIABLES: {{Entity}} {{FieldName}} {{^last}} {{basePackage}} {{fieldName}} {{skillId}} {{skillVersion}} {{type}} 
// ═══════════════════════════════════════════════════════════════════════════════

package {{basePackage}}.application.dto;

import {{basePackage}}.domain.model.{{Entity}};
import java.time.Instant;

/**
 * Response DTO for {{Entity}}.
 * 
 * Uses record for immutability (per DETERMINISM-RULES.md).
 * 
 * @generated {{skillId}} v{{skillVersion}}
 * @module mod-code-015-hexagonal-base-java-spring
 */
public record {{Entity}}Response(
    {{#fields}}
    {{type}} {{fieldName}}{{^last}},{{/last}}
    {{/fields}}
) {
    
    /**
     * Factory method to create response from domain entity.
     */
    public static {{Entity}}Response from({{Entity}} entity) {
        if (entity == null) {
            return null;
        }
        return new {{Entity}}Response(
            {{#fields}}
            entity.get{{FieldName}}(){{^last}},{{/last}}
            {{/fields}}
        );
    }
}
