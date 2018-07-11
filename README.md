# Taichung City Street Tile

A total solution tile generator using Docker Compose,
for detecting streets then generating tile from Taichung City address data.

Database:

* PostgreSQL 10
* PostGIS 2.4
* Python 2.7

Tile server:

* CartoCSS (thus Node.js)
* Mapnik
* MapProxy
* uWSGI

## Installation

Download and unzip address CSV file from <http://gishub.taichung.gov.tw/>,
then copy `TGOS_66.CSV` into the `db/data` folder, renaming to `data.csv`.

Run `docker-compose up` to build Docker images and lanuch both
the database and tile container.

Now, open another terminal, run the following command to import addresses:

    docker-compose run db python /process.py

It may take several minutes, so be patient :)

Now a WMTS server will be ready at port `8787`. You can append an entry
in JOSM like the following to get started:

    wmts:http://127.0.0.1:8787/wmts/1.0.0/WMTSCapabilities.xml


## Tips

Dump the data with:

    docker-compose run db bash
    pg_dump --data-only -h db -U tile_db tile_db > /data/dump.sql
    exit


Generate the SHP:

    docker-compose run db bash
    pgsql2shp -f /data/group.shp -h db -u tile_db tile_db "SELECT street, ST_Buffer(polygon, 0.0001) FROM taichung_streets_group;"
    exit

## License

Code under MIT
