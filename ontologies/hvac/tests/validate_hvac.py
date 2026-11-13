#!/usr/bin/env python3
"""Local HVAC ontology validation harness (no remote publish).

Checks:
  1) SysML definitions present (5 components + ports + interfaces)
  2) Catalog samples load and map to SysML attributes
  3) Valid refrigerant connections are complementary
  4) Invalid Evaporator.outlet → Compressor.discharge is rejected
  5) Refrigerant ports are not treated as air ports
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SYSML = ROOT / "src" / "HVAC.sysml"
CATALOG = ROOT / "catalog" / "samples.json"

REQUIRED_PARTS = [
    "Compressor",
    "Condenser",
    "Evaporator",
    "ExpansionValve",
    "Fan",
]
REQUIRED_PORTS = [
    "RefrigerantInlet",
    "RefrigerantOutlet",
    "AirInlet",
    "AirOutlet",
]
REQUIRED_INTERFACES = ["RefrigerantLine", "AirDuct"]

# Port ownership extracted for connection checks
COMPONENT_PORTS = {
    "Compressor": {"suction": "RefrigerantInlet", "discharge": "RefrigerantOutlet"},
    "Condenser": {
        "refrigerantIn": "RefrigerantInlet",
        "refrigerantOut": "RefrigerantOutlet",
    },
    "Evaporator": {
        "refrigerantIn": "RefrigerantInlet",
        "refrigerantOut": "RefrigerantOutlet",
    },
    "ExpansionValve": {
        "refrigerantIn": "RefrigerantInlet",
        "refrigerantOut": "RefrigerantOutlet",
    },
    "Fan": {"airIn": "AirInlet", "airOut": "AirOutlet"},
}

VALID_CONNECTIONS = [
    ("Compressor", "discharge", "Condenser", "refrigerantIn"),
    ("Condenser", "refrigerantOut", "ExpansionValve", "refrigerantIn"),
    ("ExpansionValve", "refrigerantOut", "Evaporator", "refrigerantIn"),
    ("Evaporator", "refrigerantOut", "Compressor", "suction"),
    ("Fan", "airOut", "Fan", "airIn"),
]

INVALID_CONNECTIONS = [
    ("Evaporator", "refrigerantOut", "Compressor", "discharge"),
    ("Fan", "airOut", "Compressor", "suction"),
    ("Compressor", "discharge", "Fan", "airIn"),
]


def complementary(src_type: str, dst_type: str) -> bool:
    pairs = {
        ("RefrigerantOutlet", "RefrigerantInlet"),
        ("AirOutlet", "AirInlet"),
    }
    return (src_type, dst_type) in pairs


def parse_part_defs(text: str) -> list[str]:
    return re.findall(r"\bpart\s+def\s+(\w+)", text)


def parse_port_defs(text: str) -> list[str]:
    return re.findall(r"\bport\s+def\s+(\w+)", text)


def parse_interface_defs(text: str) -> list[str]:
    return re.findall(r"\binterface\s+def\s+(\w+)", text)


def extract_part_block(text: str, name: str) -> str:
    m = re.search(rf"part\s+def\s+{name}\s*\{{", text)
    if not m:
        return ""
    start = m.end()
    depth = 1
    i = start
    while i < len(text) and depth:
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
        i += 1
    return text[start : i - 1]


def check_sysml(text: str, report: list[str]) -> int:
    fails = 0
    parts = parse_part_defs(text)
    ports = parse_port_defs(text)
    ifaces = parse_interface_defs(text)

    for name in REQUIRED_PARTS:
        if name in parts:
            report.append(f"PASS part def {name}")
        else:
            report.append(f"FAIL missing part def {name}")
            fails += 1

    for name in REQUIRED_PORTS:
        if name in ports:
            report.append(f"PASS port def {name}")
        else:
            report.append(f"FAIL missing port def {name}")
            fails += 1

    for name in REQUIRED_INTERFACES:
        if name in ifaces:
            report.append(f"PASS interface def {name}")
        else:
            report.append(f"FAIL missing interface def {name}")
            fails += 1

    # Port assignments on each component
    for comp, expected in COMPONENT_PORTS.items():
        block = extract_part_block(text, comp)
        for port_name, port_type in expected.items():
            pat = rf"port\s+{port_name}\s*:\s*{port_type}\b"
            if re.search(pat, block):
                report.append(f"PASS {comp}.{port_name} : {port_type}")
            else:
                report.append(f"FAIL {comp}.{port_name} : {port_type}")
                fails += 1

    report.append(f"INFO parsed_part_defs={len(set(parts))} unique={sorted(set(parts))}")
    return fails


def check_catalog(report: list[str]) -> int:
    fails = 0
    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    records = data.get("records", [])
    if len(records) != 5:
        report.append(f"FAIL catalog record count={len(records)} expected=5")
        fails += 1
    else:
        report.append("PASS catalog loaded 5 records")

    sysml_text = SYSML.read_text(encoding="utf-8")
    for rec in records:
        typ = rec.get("sysml_type", "")
        local = typ.split("#")[-1]
        if f"part def {local}" not in sysml_text:
            report.append(f"FAIL record {rec.get('id')} sysml_type {typ} not in HVAC.sysml")
            fails += 1
            continue
        block = extract_part_block(sysml_text, local)
        for prop in rec.get("properties", []):
            attr = prop.get("sysml_attribute")
            if attr and f"attribute {attr}" in block:
                report.append(f"PASS map {rec['id']}.{attr}")
            else:
                report.append(f"FAIL map {rec.get('id')}.{attr}")
                fails += 1
    return fails


def check_connections(report: list[str]) -> int:
    fails = 0
    for a, ap, b, bp in VALID_CONNECTIONS:
        at = COMPONENT_PORTS[a][ap]
        bt = COMPONENT_PORTS[b][bp]
        if complementary(at, bt):
            report.append(f"PASS valid {a}.{ap}({at}) -> {b}.{bp}({bt})")
        else:
            report.append(f"FAIL expected valid {a}.{ap}->{b}.{bp}")
            fails += 1

    for a, ap, b, bp in INVALID_CONNECTIONS:
        at = COMPONENT_PORTS[a][ap]
        bt = COMPONENT_PORTS[b][bp]
        if complementary(at, bt):
            report.append(f"FAIL expected reject {a}.{ap}->{b}.{bp}")
            fails += 1
        else:
            report.append(f"PASS reject {a}.{ap}({at}) -> {b}.{bp}({bt})")
    return fails


def main() -> int:
    report: list[str] = []
    if not SYSML.is_file():
        print(f"FAIL missing {SYSML}")
        return 2
    text = SYSML.read_text(encoding="utf-8")
    fails = 0
    fails += check_sysml(text, report)
    fails += check_catalog(report)
    fails += check_connections(report)

    print("\n".join(report))
    print("---")
    print(f"failures={fails}")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
