CREATE EXTENSION postgis;
CREATE EXTENSION postgis_sfcgal;
CREATE EXTENSION pgrouting;

-- For debug purprose
SELECT postgis_full_version();

CREATE TABLE taichung_addresses (
  "street" character varying(255),
  "location" geometry(POINT, 4326),
  "raw_x" character varying(255),
  "raw_y" character varying(255),
  "housenumber" character varying(255)
);

CREATE INDEX street_idx ON taichung_addresses USING BTREE ("street");
CREATE INDEX location_idx ON taichung_addresses USING GIST ("location");

CREATE TABLE taichung_streets_group (
  id serial,
  "street" character varying(255),
  "points" geometry,
  "polygon" geometry,
  "axis" geometry
);

CREATE TABLE real_points_to_polygon_temp (
  id integer,
  x float,
  y float
);

CREATE OR REPLACE FUNCTION TCTile_RealPointsToPolygon(
  param_points geometry) RETURNS geometry AS
$$
  DECLARE
    var_resultgeom geometry;
  BEGIN
    DELETE FROM real_points_to_polygon_temp;
    INSERT INTO real_points_to_polygon_temp
      SELECT (dump).path[1] AS id, ST_X((dump).geom) AS x, ST_Y((dump).geom) AS y
      FROM ST_Dump(param_points) AS dump;

    var_resultgeom := pgr_PointsAsPolygon('SELECT * FROM real_points_to_polygon_temp');
    RETURN var_resultgeom;
  EXCEPTION WHEN OTHERS THEN
    -- It usually happens when real points are less than 3
    RETURN ST_ConvexHull(param_points);
  END;
$$ LANGUAGE plpgsql VOLATILE STRICT;
ALTER FUNCTION TCTile_RealPointsToPolygon(geometry) OWNER TO postgres;

-- http://gis.stackexchange.com/questions/106854/
CREATE OR REPLACE FUNCTION ST_SmartConcaveHull(
  param_geom geometry, param_pctconvex float, param_allow_holes boolean DEFAULT false) RETURNS geometry AS
$$
  DECLARE
    var_resultgeom geometry;
  BEGIN
    var_resultgeom := ST_ConcaveHull(param_geom, param_pctconvex, param_allow_holes);
    IF ST_GeometryType(var_resultgeom) = 'ST_Polygon' THEN RETURN var_resultgeom;
    ELSE RETURN ST_ConvexHull(param_geom);
    END IF;
  EXCEPTION WHEN OTHERS THEN
    return ST_ConvexHull(param_geom);
  END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;
ALTER FUNCTION ST_SmartConcaveHull(geometry, float, boolean) OWNER TO postgres;

CREATE OR REPLACE FUNCTION ST_SmartApproximateMedialAxis(
  param_geom geometry) RETURNS geometry AS
$$
  BEGIN RETURN ST_ApproximateMedialAxis(param_geom);
  EXCEPTION WHEN OTHERS THEN RETURN NULL;
  END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;
ALTER FUNCTION ST_SmartApproximateMedialAxis(geometry) OWNER TO postgres;

