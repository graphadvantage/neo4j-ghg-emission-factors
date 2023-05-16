MATCH path = (s:Scope {Scope: 'Scope 3'})--(l:Level_1 {Level_1: 'Freighting goods'})-[*]->(f:Factor {UOM: 'tonne.km', GHG_Unit: 'kg CO2e of CO2'})
WHERE f.GHG_Conversion_Factor_2022 IS NOT NULL
AND (f.Level_4 IN ["Average"," All dwt"] OR f.Level_4 IS NULL)
AND (f.Description IN ["Unknown","Average laden"] OR f.Description IS NULL)
RETURN f.Description, f.GHG_Conversion_Factor_2022, f.GHG_Unit, f.Level_1, f.Level_2, f.Level_3, f.Level_4
