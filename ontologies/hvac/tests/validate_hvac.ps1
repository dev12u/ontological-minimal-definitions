# Local HVAC ontology validation harness (PowerShell; no remote publish).
$ErrorActionPreference = "Stop"
$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
# script is ontologies/hvac/tests -> package root is parent of tests
$Pkg = Split-Path $PSScriptRoot -Parent
$Sysml = Join-Path $Pkg "src\HVAC.sysml"
$Catalog = Join-Path $Pkg "catalog\samples.json"

$fails = 0
function Pass([string]$m) { Write-Host "PASS $m" }
function Fail([string]$m) { Write-Host "FAIL $m"; $script:fails++ }
function Info([string]$m) { Write-Host "INFO $m" }

if (-not (Test-Path $Sysml)) { Fail "missing $Sysml"; exit 2 }
$text = [System.IO.File]::ReadAllText($Sysml)

$requiredParts = @("Compressor","Condenser","Evaporator","ExpansionValve","Fan")
$requiredPorts = @("RefrigerantInlet","RefrigerantOutlet","AirInlet","AirOutlet")

foreach ($n in $requiredParts) {
  if ($text -match "part\s+def\s+$n\b") { Pass "part def $n" } else { Fail "part def $n" }
}
foreach ($n in $requiredPorts) {
  if ($text -match "port\s+def\s+$n\b") { Pass "port def $n" } else { Fail "port def $n" }
}

$componentPorts = @{
  Compressor = @{ suction = "RefrigerantInlet"; discharge = "RefrigerantOutlet" }
  Condenser = @{ refrigerantIn = "RefrigerantInlet"; refrigerantOut = "RefrigerantOutlet" }
  Evaporator = @{ refrigerantIn = "RefrigerantInlet"; refrigerantOut = "RefrigerantOutlet" }
  ExpansionValve = @{ refrigerantIn = "RefrigerantInlet"; refrigerantOut = "RefrigerantOutlet" }
  Fan = @{ airIn = "AirInlet"; airOut = "AirOutlet" }
}

foreach ($comp in $componentPorts.Keys) {
  foreach ($port in $componentPorts[$comp].Keys) {
    $ptype = $componentPorts[$comp][$port]
    if ($text -match "port\s+$port\s*:\s*$ptype\b") { Pass "$comp.$port : $ptype" }
    else { Fail "$comp.$port : $ptype" }
  }
}

# Catalog
$cat = Get-Content $Catalog -Raw | ConvertFrom-Json
if ($cat.records.Count -eq 5) { Pass "catalog loaded 5 records" } else { Fail "catalog count=$($cat.records.Count)" }

foreach ($rec in $cat.records) {
  $local = ((($rec.sysml_type -split "#")[-1] -split "::")[-1])
  if ($text -notmatch "part\s+def\s+$local\b") { Fail "sysml_type $($rec.sysml_type)"; continue }
  foreach ($prop in $rec.properties) {
    $attr = $prop.sysml_attribute
    if ($text -match "attribute\s+$attr\b") { Pass "map $($rec.id).$attr" }
    else { Fail "map $($rec.id).$attr" }
  }
}

function Complementary([string]$a, [string]$b) {
  return (($a -eq "RefrigerantOutlet" -and $b -eq "RefrigerantInlet") -or
          ($a -eq "AirOutlet" -and $b -eq "AirInlet"))
}

$valid = @(
  @("Compressor","discharge","Condenser","refrigerantIn"),
  @("Condenser","refrigerantOut","ExpansionValve","refrigerantIn"),
  @("ExpansionValve","refrigerantOut","Evaporator","refrigerantIn"),
  @("Evaporator","refrigerantOut","Compressor","suction"),
  @("Fan","airOut","Fan","airIn")
)
$invalid = @(
  @("Evaporator","refrigerantOut","Compressor","discharge"),
  @("Fan","airOut","Compressor","suction"),
  @("Compressor","discharge","Fan","airIn")
)

foreach ($c in $valid) {
  $at = $componentPorts[$c[0]][$c[1]]
  $bt = $componentPorts[$c[2]][$c[3]]
  if (Complementary $at $bt) { Pass "valid $($c[0]).$($c[1])($at) -> $($c[2]).$($c[3])($bt)" }
  else { Fail "expected valid $($c[0]).$($c[1]) -> $($c[2]).$($c[3])" }
}
foreach ($c in $invalid) {
  $at = $componentPorts[$c[0]][$c[1]]
  $bt = $componentPorts[$c[2]][$c[3]]
  if (Complementary $at $bt) { Fail "expected reject $($c[0]).$($c[1]) -> $($c[2]).$($c[3])" }
  else { Pass "reject $($c[0]).$($c[1])($at) -> $($c[2]).$($c[3])($bt)" }
}

# Positive circuit present in SysML
if ($text -match "interface\s+dischargeLine\s+connect") { Pass "positive dischargeLine present" }
else { Fail "positive dischargeLine missing" }

Write-Host "---"
Write-Host "failures=$fails"
exit $(if ($fails -gt 0) { 1 } else { 0 })
