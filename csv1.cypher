LOAD CSV WITH HEADERS FROM 'file:///nyc_airports.csv' AS row
WITH row
  WHERE row.faa IS NOT NULL AND row.faa <> ''
MERGE (a:Airport {faa: row.faa})
SET a.name  = row.name,
a.lat   = toFloat(row.lat),
a.lon   = toFloat(row.lon),
a.alt   = toInteger(row.alt),
a.tz    = toInteger(row.tz),
a.dst   = row.dst,
a.tzone = row.tzone;

LOAD CSV WITH HEADERS FROM 'file:///nyc_airlines.csv' AS row
WITH row
  WHERE row.carrier IS NOT NULL AND row.carrier <> ''
MERGE (al:Airline {carrier: row.carrier})
SET al.name = row.name;
