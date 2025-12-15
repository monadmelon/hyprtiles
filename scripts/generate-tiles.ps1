# HyprTiles - Generate Vector Tiles
# Uses tilemaker to generate MBTiles from OSM PBF

$ErrorActionPreference = "Stop"

$PROJECT_ROOT = Join-Path $PSScriptRoot ".."
$DATA_DIR = Join-Path $PROJECT_ROOT "data"
$TILES_DIR = Join-Path $PROJECT_ROOT "tiles"
$TOOLS_DIR = Join-Path $PROJECT_ROOT "tools"
$INPUT_FILE = Join-Path $DATA_DIR "kerala.osm.pbf"
$OUTPUT_FILE = Join-Path $TILES_DIR "kerala.mbtiles"
$BBOX = "74.5,8.0,78.5,13.5"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  HyprTiles - Tile Generation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check input
if (-not (Test-Path $INPUT_FILE)) {
    Write-Host "[!] Input file not found. Run download-data.ps1 first." -ForegroundColor Red
    exit 1
}

# Create tiles directory
if (-not (Test-Path $TILES_DIR)) {
    New-Item -ItemType Directory -Path $TILES_DIR -Force | Out-Null
}

# Download tilemaker if needed
$TILEMAKER_EXE = Join-Path $TOOLS_DIR "build\RelWithDebInfo\tilemaker.exe"
if (-not (Test-Path $TILEMAKER_EXE)) {
    Write-Host "[*] Downloading tilemaker..." -ForegroundColor Blue
    
    $zipUrl = "https://github.com/systemed/tilemaker/releases/download/v2.4.0/tilemaker-windows.zip"
    $zipPath = Join-Path $PROJECT_ROOT "tilemaker.zip"
    
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
    Expand-Archive -Path $zipPath -DestinationPath $TOOLS_DIR -Force
    Remove-Item $zipPath
    
    Write-Host "[+] Tilemaker downloaded" -ForegroundColor Green
}

# Check for config files
$CONFIG_JSON = Join-Path $TOOLS_DIR "resources\config-openmaptiles.json"
$PROCESS_LUA = Join-Path $TOOLS_DIR "resources\process-openmaptiles.lua"

if (-not (Test-Path $CONFIG_JSON)) {
    Write-Host "[!] Config files not found in tools/resources" -ForegroundColor Red
    exit 1
}

# Generate tiles
Write-Host "[*] Generating vector tiles..." -ForegroundColor Blue
Write-Host "    Input: kerala.osm.pbf" -ForegroundColor Gray
Write-Host "    Output: kerala.mbtiles" -ForegroundColor Gray

$startTime = Get-Date

& $TILEMAKER_EXE `
    --input $INPUT_FILE `
    --output $OUTPUT_FILE `
    --config $CONFIG_JSON `
    --process $PROCESS_LUA `
    --bbox $BBOX

$duration = (Get-Date) - $startTime

if (Test-Path $OUTPUT_FILE) {
    $size = [math]::Round((Get-Item $OUTPUT_FILE).Length / 1MB, 2)
    Write-Host ""
    Write-Host "[+] Success: kerala.mbtiles ($size MB)" -ForegroundColor Green
    Write-Host "    Time: $([math]::Round($duration.TotalSeconds, 1)) seconds" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Next: docker-compose up -d" -ForegroundColor Yellow
} else {
    Write-Host "[!] Tile generation failed" -ForegroundColor Red
    exit 1
}
