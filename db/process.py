# -*- coding: utf-8 -*-

import re
import sys
from io import BytesIO
from zipfile import ZipFile
import psycopg2
import unicodecsv
import requests
import unicodedata

def write_data(csvfile, conn):
    output = BytesIO()
    reader = unicodecsv.DictReader(csvfile)
    writer = unicodecsv.DictWriter(
        output, ['street', 'housenumber', 'raw_x', 'raw_y'])
    count = 0
    print "Converting CSV for importing..."
    for row in reader:
        street = u'%s%s%s%s' % (
            row[u'街、路段'], row[u'地區'], row[u'巷'], row[u'弄'])
        housenumber = row[u'號']
        x = row[u'橫座標']
        y = row[u'縱座標']
        # http://stackoverflow.com/questions/2422177/
        street = unicodedata.normalize('NFKC', street)
        housenumber = unicodedata.normalize('NFKC', housenumber)
        writer.writerow({
            'street': street,
            'housenumber': housenumber,
            'raw_x': x,
            'raw_y': y
        })
        count += 1
    print "%d addresses added" % count
    output.seek(0)
    with conn.cursor() as cur:
        print "Importing CSV using COPY..."
        cur.copy_expert(
            sql="COPY taichung_addresses (street, housenumber, raw_x, raw_y)"
                "FROM stdin WITH CSV HEADER DELIMITER as ',';",
            file=output
        )
        print "Converting Coordinates..."
        cur.execute(
            "UPDATE taichung_addresses SET location = "
            "ST_Transform(ST_SetSRID(ST_MakePoint("
            "CAST(raw_x as double precision), CAST(raw_y as double precision)"
            "), 3826), 4326);"
        )
        """
        # concave_hull based solution as below
            INSERT INTO taichung_streets_group (concave_hull, street)
            SELECT ST_SimplifyPreserveTopology(ST_ConcaveHull(unnest(ST_ClusterWithin(ST_Buffer("
            location, 0.0001), 0.001)), 0.99, true), 0.05), 
            street from taichung_addresses GROUP BY street;
        """
        print "Calculating groups..."
        cur.execute(
            "INSERT INTO taichung_streets_group (points, street) "
            "SELECT unnest(ST_ClusterWithin(location, 0.001)),"
            "street FROM taichung_addresses WHERE street IS NOT NULL "
            "GROUP BY street;"
        )
        # pgr_PointsAsPolygon works great with large set.
        print "Calaulating Alpha Shapes for >= 100 points..."
        cur.execute(
            "UPDATE taichung_streets_group SET polygon = "
            "TCTile_RealPointsToPolygon(points) WHERE ST_NPoints(points) >= 100;"
        )
        # Optimize as pgr_PointsAsPolygon sucks at huge amount of small set.
        # Sometimes (2 as previously run) the below would fail, so try again.
        print "Calaulating Concave Hull for < 100 points..."
        cur.execute(
            "UPDATE taichung_streets_group SET polygon = "
            "ST_SimplifyPreserveTopology(ST_SmartConcaveHull(points, 0.99, true), 0.05) "
            "WHERE polygon IS NULL;"
        )
        # To ensure everything is polygon...
        print "Adding buffers..."
        cur.execute(
            "UPDATE taichung_streets_group SET polygon = "
            "ST_Buffer(polygon, 0.0001);"
        )
        # https://github.com/Oslandia/SFCGAL/issues/133
        print "Preparing Medial axis..."
        cur.execute(
            "UPDATE taichung_streets_group SET axis = ST_SmartApproximateMedialAxis"
            "(ST_GeomFromEWKT(ST_AsEWKT(polygon)));"
        )
    print "OK"


with open('/data/data.csv', 'rb') as csvfile, \
     psycopg2.connect(dbname="postgres", user="postgres", host="db") \
     as conn:
    print "Writing..."
    write_data(csvfile, conn)
