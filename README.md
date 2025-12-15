# hyprtiles

Self-hosted vector tiles. No rate limits, no API keys, works offline.

## what it does

Downloads OSM data, generates vector tiles with tilemaker, serves via Martin. Swap this into any MapLibre/Mapbox GL app.

## setup

```bash
# 1. download osm data (~520MB)
.\scripts\download-data.ps1

# 2. generate tiles (~2 min)
.\scripts\generate-tiles.ps1

# 3. run tile server
docker-compose up -d
```

tiles available at `http://localhost:3000/kerala/{z}/{x}/{y}`

## demo

open `demo/index.html` - has light/dark themes, POIs, the works.

## files

```
config/          # tilemaker config (openmaptiles schema)
scripts/         # download + generate scripts
demo/            # demo map with styling
docker-compose.yml
```

`data/` and `tiles/` are gitignored - run the scripts to generate.

## coverage

kerala + parts of tamil nadu/karnataka. bbox: `74.5,8.0,78.5,13.5`

~238MB mbtiles, 42k tiles at z14.

## integration

```js
const map = new maplibregl.Map({
  container: "map",
  style: {
    version: 8,
    sources: {
      tiles: {
        type: "vector",
        tiles: ["http://localhost:3000/kerala/{z}/{x}/{y}"],
        maxzoom: 14,
      },
    },
    layers: [
      /* see demo/index.html */
    ],
  },
});
```

## deployment

**vps**: copy repo, run scripts, `docker-compose up -d`

**cdn**: convert to pmtiles, upload to r2/s3

```bash
pmtiles convert tiles/kerala.mbtiles tiles/kerala.pmtiles
```

## layers

water, waterway, landcover, landuse, park, building, transportation, transportation_name, place, poi, aeroway, aerodrome_label, mountain_peak, housenumber, boundary

all standard openmaptiles schema.
