:auto LOAD CSV WITH HEADERS FROM 'file:///AircraftRegistractionData.csv' AS row
CALL {
WITH row, ('N'+ row.Nnumber) as row_Nnumber
MERGE (ac:Aircraft {tailnum: row_Nnumber})
SET
ac.year = toInteger(row.Year),
ac.manufacturer = row.Manufacturer,
ac.model = row.Model,
ac.type = row.Type,
ac.engine = row.Engine,
ac.category = row.Category,
ac.no_engines = (CASE WHEN row.No_Engines = '' THEN NULL ELSE toInteger(row.No_Engines) END),
ac.no_seats = (CASE WHEN row.No_seats = '' THEN NULL ELSE toInteger(row.No_seats) END),
ac.weight = (CASE WHEN row.Weight = '' THEN NULL ELSE toInteger(row.Weight) END),
ac.speed = (CASE WHEN row.Speed = '' THEN NULL ELSE toInteger(row.Speed) END)

MERGE (o:Owner {name: coalesce(row.Name, 'NA'), city: row.City, state: row.State})
MERGE (o)-[:OWNS]->(ac)

} IN TRANSACTIONS OF 5000 ROWS;
