:auto LOAD CSV WITH HEADERS FROM 'file:///nyc_flights_200k-eof.csv' AS row
CALL {
WITH row
WITH row,
     (row.year + '-' + row.month + '-' + row.day + '-' +
     row.carrier + '-' + row.flight + '-' +
     coalesce(row.tailnum,'NA') + '-' +
     row.sched_dep_time + '-' + row.origin + '-' + row.dest) AS flightId

MERGE (f:Flight {id: flightId})
SET f.year           = toInteger(row.year),
f.month          = toInteger(row.month),
f.day            = toInteger(row.day),
f.dep_time       = toInteger(row.dep_time),
f.sched_dep_time = toInteger(row.sched_dep_time),
f.dep_delay      = toFloat(row.dep_delay),
f.arr_time       = toInteger(row.arr_time),
f.sched_arr_time = toInteger(row.sched_arr_time),
f.arr_delay      = toFloat(row.arr_delay),
f.flight_no      = toInteger(row.flight),
f.air_time       = toFloat(row.air_time),
f.distance       = toInteger(row.distance),
f.hour           = toInteger(row.hour),
f.minute         = toInteger(row.minute),
f.time_hour      = datetime(row.time_hour),
f.carrier        = row.carrier,
f.tailnum        = row.tailnum,
f.origin         = row.origin,
f.dest           = row.dest

MERGE (al:Airline {carrier: row.carrier})
MERGE (f)-[:OPERATED_BY_AIRLINE]->(al)

MERGE (o:Airport {faa: row.origin})
MERGE (d:Airport {faa: row.dest})
MERGE (f)-[:DEPARTED_FROM]->(o)
MERGE (f)-[:ARRIVED_AT]->(d)

MERGE (ac:Aircraft {tailnum: coalesce(row.tailnum, 'NA')})
MERGE (f)-[:OPERATED_BY_AIRCRAFT]->(ac)

} IN TRANSACTIONS OF 5000 ROWS;
