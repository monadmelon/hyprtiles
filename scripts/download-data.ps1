# HyprTiles - Download OSM Data
# Downloads Southern Zone OSM data and extracts Kerala region

$ErrorActionPreference = "Stop"

$DATA_DIR = Join-Path $PSScriptRoot "..\data"
$OSM_URL = "https://download.geofabrik.de/asia/india/southern-zone-latest.osm.pbf"
$TEMP_FILE = Join-Path $DATA_DIR "southern-zone.osm.pbf"
$OUTPUT_FILE = Join-Path $DATA_DIR "kerala.osm.pbf"
$BBOX = "74.5,8.0,78.5,13.5"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  HyprTiles - Kerala Data Download" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Create data directory
if (-not (Test-Path $DATA_DIR)) {
    New-Item -ItemType Directory -Path $DATA_DIR -Force | Out-Null
}

# Download OSM data if not cached
if (-not (Test-Path $TEMP_FILE)) {
    Write-Host "[*] Downloading Southern Zone OSM data (~520MB)..." -ForegroundColor Blue
    Write-Host "    This may take a few minutes..." -ForegroundColor Gray
    Invoke-WebRequest -Uri $OSM_URL -OutFile $TEMP_FILE -UseBasicParsing
    Write-Host "[+] Download complete" -ForegroundColor Green
} else {
    Write-Host "[*] Using cached southern-zone.osm.pbf" -ForegroundColor Blue
}

# Check for Docker
$docker = Get-Command docker -ErrorAction SilentlyContinue
if (-not $docker) {
    Write-Host "[!] Docker not found. Please install Docker Desktop." -ForegroundColor Red
    exit 1
}

# Extract Kerala region
Write-Host "[*] Extracting Kerala region (bbox: $BBOX)..." -ForegroundColor Blue
$dataPath = (Resolve-Path $DATA_DIR).Path -replace '\\', '/'

docker run --rm -v "${dataPath}:/data" openmaptiles/openmaptiles-tools `
    osmium extract --bbox $BBOX /data/southern-zone.osm.pbf -o /data/kerala.osm.pbf --overwrite

if (Test-Path $OUTPUT_FILE) {
    $size = [math]::Round((Get-Item $OUTPUT_FILE).Length / 1MB, 2)
    Write-Host "[+] Extraction complete: kerala.osm.pbf ($size MB)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next: .\scripts\generate-tiles.ps1" -ForegroundColor Yellow
} else {
    Write-Host "[!] Extraction failed" -ForegroundColor Red
    exit 1
}
