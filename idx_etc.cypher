MATCH (f:Flight {flight_no: 111})-[:OPERATED_BY_AIRCRAFT]->(a:Aircraft {tailnum: 'N612JB'})
match (f)-[*]->(ctd)
RETURN f, ctd;

CREATE CONSTRAINT flight_id_unique IF NOT EXISTS
FOR (f:Flight) REQUIRE f.id IS UNIQUE;

CREATE CONSTRAINT airline_carrier_unique IF NOT EXISTS
FOR (a:Airline) REQUIRE a.carrier IS UNIQUE;

CREATE CONSTRAINT airport_faa_unique IF NOT EXISTS
FOR (a:Airport) REQUIRE a.faa IS UNIQUE;

CREATE CONSTRAINT aircraft_tailnum_unique IF NOT EXISTS
FOR (a:Aircraft) REQUIRE a.tailnum IS UNIQUE;

CREATE CONSTRAINT owner_name_unique IF NOT EXISTS
FOR (o:Owner) REQUIRE o.name IS UNIQUE;


