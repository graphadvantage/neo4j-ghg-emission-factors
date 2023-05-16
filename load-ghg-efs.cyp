

//1 tonne-kilometer = 0.684945 ton-miles.
//1.459972 tonne-kilometers = 1 ton mile

//f.GHG_CONVERSION_FACTOR_2022
// ton-miles*1.459972* "0.01305" kg CO2e of CO2 per tonne.km UOM

// https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2022
// https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1105317/ghg-conversion-factors-2022-flat-format.xls

//load nodes, make property keys upper case along the way
LOAD CSV WITH HEADERS
FROM 'ghg-conversion-factors-2022-flat-format.csv' AS map
FIELDTERMINATOR ','
WITH  apoc.map.clean(map,[],[""]) AS m
CREATE (f:Factor) SET f+=m;

// Clean up
MATCH (n:Factor)
WHERE n.Scope IS NULL DELETE n;

// Set indexes
CREATE INDEX Level_1 FOR (n:Level_1) ON n.Level_1;
CREATE INDEX Level_2 FOR (n:Level_2) ON n.Level_2;
CREATE INDEX Level_3 FOR (n:Level_3) ON n.Level_3;
CREATE INDEX Level_4 FOR (n:Level_4) ON n.Level_4;

// Set index on factors for full text searching
CREATE FULLTEXT INDEX Factor_FT FOR (n:Factor) ON EACH [n.LEVEL_1,n.LEVEL_2,n.LEVEL_3,n.LEVEL_4,n.DESCRIPTION]


// Build EF Tree, starting at deepest leaves
//L4
MATCH (n:Factor)
WHERE n.Level_1 IS NOT NULL
AND n.Level_2 IS NOT NULL
AND n.Level_3 IS NOT NULL
AND n.Level_4 IS NOT NULL
WITH COLLECT(n) AS factors
UNWIND factors AS f
MERGE (s:Scope {Scope: f.Scope})
WITH s,f
MERGE (l1:Level_1 {Level_1: f.Level_1})
WITH s,f,l1
MERGE (s)-[:HAS_LEVEL]->(l1)
MERGE (l2:Level_2 {Level_2: f.Level_2,Level_1: f.Level_1})
WITH f,l1,l2
MERGE (l1)-[:HAS_LEVEL]->(l2)
MERGE (l3:Level_3 {Level_3: f.Level_3,Level_2: f.Level_2,Level_1: f.Level_1})
WITH f,l2,l3
MERGE (l2)-[:HAS_LEVEL]->(l3)
MERGE (l4:Level_4 {Level_4: f.Level_4, Level_3: f.Level_3,Level_2: f.Level_2,Level_1: f.Level_1})
WITH f,l3,l4
MERGE (l3)-[:HAS_LEVEL]->(l4)
WITH f,l4
MERGE (l4)-[:HAS_FACTOR]-(f);

//L3
MATCH (n:Factor)
WHERE n.Level_1 IS NOT NULL
AND n.Level_2 IS NOT NULL
AND n.Level_3 IS NOT NULL
AND n.Level_4 IS NULL
WITH COLLECT(n) AS factors
UNWIND factors AS f
MERGE (s:Scope {Scope: f.Scope})
WITH s,f
MERGE (l1:Level_1 {Level_1: f.Level_1})
WITH s,f,l1
MERGE (s)-[:HAS_LEVEL]->(l1)
MERGE (l2:Level_2 {Level_2: f.Level_2,Level_1: f.Level_1})
WITH f,l1,l2
MERGE (l1)-[:HAS_LEVEL]->(l2)
MERGE (l3:Level_3 {Level_3: f.Level_3,Level_2: f.Level_2,Level_1: f.Level_1})
WITH f,l2,l3
MERGE (l2)-[:HAS_LEVEL]->(l3)
WITH f,l3
MERGE (l3)-[:HAS_FACTOR]-(f);

//L2
MATCH (n:Factor)
WHERE n.Level_1 IS NOT NULL
AND n.Level_2 IS NOT NULL
AND n.Level_3 IS NULL
AND n.Level_4 IS NULL
WITH COLLECT(n) AS factors
UNWIND factors AS f
MERGE (s:Scope {Scope: f.Scope})
WITH s,f
MERGE (l1:Level_1 {Level_1: f.Level_1})
WITH s,f,l1
MERGE (s)-[:HAS_LEVEL]->(l1)
MERGE (l2:Level_2 {Level_2: f.Level_2,Level_1: f.Level_1})
WITH f,l1,l2
MERGE (l1)-[:HAS_LEVEL]->(l2)
WITH f,l2
MERGE (l2)-[:HAS_FACTOR]-(f);

//L1
MATCH (n:Factor)
WHERE n.Level_1 IS NOT NULL
AND n.Level_2 IS NULL
AND n.Level_3 IS NULL
AND n.Level_4 IS NULL
WITH COLLECT(n) AS factors
UNWIND factors AS f
MERGE (s:Scope {Scope: f.Scope})
WITH s,f
MERGE (l1:Level_1 {Level_1: f.Level_1})
WITH s,f,l1
MERGE (s)-[:HAS_LEVEL]->(l1)
WITH f,l1
MERGE (l1)-[:HAS_FACTOR]-(f);
