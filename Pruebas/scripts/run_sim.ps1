param(
    [string]$VivadoBin = $env:VIVADO_BIN,
    [switch]$Headless
)

# Intento de autodetección
if (-not $VivadoBin -or -not (Test-Path $VivadoBin)) {
    $default = "C:\Xilinx\Vivado\*\bin\vivado.bat"
    $candidates = Get-ChildItem -Path $default -ErrorAction SilentlyContinue | Sort-Object FullName -Descending
    if ($candidates) { $VivadoBin = $candidates[0].FullName }
}

if (-not $VivadoBin -or -not (Test-Path $VivadoBin)) {
    Write-Error "No se encontró Vivado. Defina VIVADO_BIN con la ruta a vivado.bat."
    exit 1
}

$root = Split-Path -Parent $PSScriptRoot
$tcl = Join-Path $root 'scripts\sim_program_counter.tcl'
if ($Headless) { $env:HEADLESS = '1' }

& $VivadoBin -mode tcl -source $tcl
