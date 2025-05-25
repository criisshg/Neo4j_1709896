//Crear nodes Municipi
LOAD CSV WITH HEADERS FROM 'file:///HABITATGES.csv' AS row
WITH DISTINCT row.municipi AS nom
WHERE nom IS NOT NULL
MERGE (:Municipi {nom: nom})

//Crear nodes Ocupacio
LOAD CSV WITH HEADERS FROM 'file:///INDIVIDUAL.csv' AS row
WITH DISTINCT row.ofici AS nom
WHERE nom IS NOT NULL AND nom <> "nan"
MERGE (:Ocupacio {nom: nom})

//Connectar Individu amb Ocupacio
LOAD CSV WITH HEADERS FROM 'file:///INDIVIDUAL.csv' AS row
MATCH (i:Individu {id: row.id})
MATCH (o:Ocupacio {nom: row.ofici})
MERGE (i)-[:TE_OCUPACIO]->(o)

//Connectar Habitatge amb Municipi
LOAD CSV WITH HEADERS FROM 'file:///HABITATGES.csv' AS row
MATCH (h:Habitatge {id: row.id})
MATCH (m:Municipi {nom: row.municipi})
MERGE (h)-[:PERTANY_A]->(m)


