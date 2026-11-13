# ontological-minimal-definitions

Minimal SysML v2 ontological definitions for OS20 engineering components.

## HVAC ontology — `@os20/hvac-ontology` `0.1.0`

| Path | Purpose |
|---|---|
| [`ontologies/hvac/`](ontologies/hvac/) | OS20 ontology package (`role = "ontology"`) |
| [`ontologies/hvac/src/HVAC.sysml`](ontologies/hvac/src/HVAC.sysml) | 5 components + ports + positive circuit |
| [`ontologies/hvac/catalog/`](ontologies/hvac/catalog/) | Synthetic category-property samples |
| [`examples/hvac-refrigeration-circuit/`](examples/hvac-refrigeration-circuit/) | Consumer package with path dependency |
| [`ontologies/hvac/tests/validate_hvac.ps1`](ontologies/hvac/tests/validate_hvac.ps1) | Local definition / mapping / connection checks |

### Components

1. `Compressor` — suction `RefrigerantInlet`, discharge `RefrigerantOutlet`
2. `Condenser` — refrigerant in/out
3. `Evaporator` — refrigerant in/out
4. `ExpansionValve` — refrigerant in/out
5. `Fan` — air in/out

Numeric values live only in the catalog (synthetic). SysML defines structure and semantics.

### Local checks

```powershell
cd ontologies/hvac
os20 check --offline
.\tests\validate_hvac.ps1

cd ..\..\examples\hvac-refrigeration-circuit
os20 resolve
os20 check --locked --offline
```

### Product Data seed

```text
ontologies/hvac/catalog/seed_hvac_samples.sql
```

Apply against the portal product-data Postgres DB, then open package `@example/hvac-ontology-samples` on the Data tab.

Search components via:

```powershell
os20 --workspace ontologies/hvac inspect symbols Compressor
```

**Do not publish** unless explicitly authorized.
