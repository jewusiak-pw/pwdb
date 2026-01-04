MATCH (ac:Aircraft)<-[:OWNS]-(o:Owner)
match (ac)<-[:OPERATED_BY_AIRCRAFT]-(f:Flight)
  WHERE toLower(o.name) CONTAINS 'bank of utah'
RETURN o, ac;


MATCH (o:Owner)-[:OWNS]->(ac:Aircraft)<-[:OPERATED_BY_AIRCRAFT]-(f:Flight)
RETURN
  o.name  AS owner,
  o.state AS state,
  count(f) AS flights_no,
  count(DISTINCT ac) AS owned_aircraft
  ORDER BY flights_no DESC
  LIMIT 5;

MATCH (f:Flight)-[:OPERATED_BY_AIRLINE]->(al:Airline)
  WHERE f.arr_delay IS NOT NULL
RETURN
  al.carrier AS airline,
  al.name    AS airline_name,
  avg(f.arr_delay) AS avg_arrival_delay
  ORDER BY avg_arrival_delay DESC;

MATCH (ac:Aircraft {engine: '2'})-[:OPERATED_BY_AIRCRAFT]-(f:Flight)
MATCH (f)-[:DEPARTED_FROM]->(o:Airport)
MATCH (f)-[:ARRIVED_AT]->(d:Airport)
WITH o.faa AS origin, d.faa AS dest, count(*) AS flights
RETURN
  'turboprop' AS aircraft_category,
  origin,
  dest,
  flights
  ORDER BY flights DESC
  LIMIT 3

UNION

MATCH (ac:Aircraft {engine: '4'})-[:OPERATED_BY_AIRCRAFT]-(f:Flight)
MATCH (f)-[:DEPARTED_FROM]->(o:Airport)
MATCH (f)-[:ARRIVED_AT]->(d:Airport)
WITH o.faa AS origin, d.faa AS dest, count(*) AS flights
RETURN
  'turbojet' AS aircraft_category,
  origin,
  dest,
  flights
  ORDER BY flights DESC
  LIMIT 3;


MATCH (f:Flight)-[:OPERATED_BY_AIRLINE]->(a:Airline)
MATCH (ac)<-[:OPERATED_BY_AIRCRAFT]-(f:Flight)
WITH a,
     count(DISTINCT ac) AS aircraft_count,
     count(f) AS flight_count
  WHERE flight_count > 10 and aircraft_count > 10
RETURN
  a.name AS carrier,
  aircraft_count,
  flight_count,
  (flight_count *1.0 / aircraft_count) AS flights_per_aircraft
  ORDER BY flights_per_aircraft DESC;
