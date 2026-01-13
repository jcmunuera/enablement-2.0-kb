# Runtime Schemas

This directory contains JSON Schemas for validating generated artifacts.

## Files

| Schema | Purpose | Version |
|--------|---------|---------|
| `manifest.schema.json` | Validates `.enablement/manifest.json` | 1.0 |

## Usage

### Validation in JavaScript/Node:

```javascript
const Ajv = require('ajv');
const ajv = new Ajv();
const schema = require('./manifest.schema.json');
const validate = ajv.compile(schema);

const manifest = JSON.parse(fs.readFileSync('.enablement/manifest.json'));
const valid = validate(manifest);
if (!valid) console.log(validate.errors);
```

### Validation in Python:

```python
import jsonschema
import json

with open('runtime/schemas/manifest.schema.json') as f:
    schema = json.load(f)
    
with open('.enablement/manifest.json') as f:
    manifest = json.load(f)
    
jsonschema.validate(manifest, schema)
```

### Validation in CLI (ajv-cli):

```bash
ajv validate -s runtime/schemas/manifest.schema.json -d output/customer-api/.enablement/manifest.json
```

## Schema Design

The manifest schema enforces:
- Required fields for traceability
- Consistent naming patterns (skill IDs, module IDs)
- Structured validation results
- File checksums for integrity verification

---

*Managed by C4E Team*
