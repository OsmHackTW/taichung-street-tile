# Taichung City Street Tile

A total solution tile generator using Docker Compose,
for generating tile from New Taipei City bus stops data.

Database:

* PostgreSQL 9.6
* PostGIS 2.3
* Python

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

Now a WMTS server will be ready at port `8888`. You can append an entry
in JOSM like the following to get started:

    wmts:http://127.0.0.1:8888/wmts/1.0.0/WMTSCapabilities.xml


## License

Code under MIT
