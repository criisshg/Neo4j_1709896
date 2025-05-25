// ────────────────
// CONSTRAINTS I ÍNDEXS
// ────────────────
CREATE CONSTRAINT municipi_id_unique IF NOT EXISTS
FOR (m:Municipi) REQUIRE m.id IS UNIQUE;

CREATE CONSTRAINT llar_id_unique IF NOT EXISTS
FOR (l:Llar) REQUIRE l.id IS UNIQUE;

CREATE CONSTRAINT padro_id_unique IF NOT EXISTS
FOR (p:Padro) REQUIRE p.id IS UNIQUE;

CREATE CONSTRAINT individu_id_unique IF NOT EXISTS
FOR (i:Individu) REQUIRE i.id IS UNIQUE;


// ────────────────
// NODES
// ────────────────

// Municipis
LOAD CSV WITH HEADERS FROM 'file:///dades/HABITATGES.csv' AS row
WITH row WHERE row.Municipi IS NOT NULL
MERGE (m:Municipi {id: row.Municipi});

// Llars
LOAD CSV WITH HEADERS FROM 'file:///dades/FAMILIA.csv' AS row
WITH row WHERE row.IdLlar IS NOT NULL
MERGE (l:Llar {id: toInteger(row.IdLlar)})
SET l.tipus = row.TipusLlar;

LOAD CSV WITH HEADERS FROM 'file:///dades/HABITATGES.csv' AS row
WITH row WHERE row.Id_Llar IS NOT NULL
MERGE (l:Llar {id: toInteger(row.Id_Llar)})
SET l.carrer = row.Carrer,
    l.numero = row.Numero;

// Padró
LOAD CSV WITH HEADERS FROM 'file:///dades/HABITATGES.csv' AS row
WITH row
WHERE row.Id_Llar IS NOT NULL AND row.Any_Padro IS NOT NULL AND row.Municipi IS NOT NULL
MERGE (p:Padro {id: row.Municipi + "_" + row.Any_Padro + "_" + row.Id_Llar})
SET p.any = toInteger(row.Any_Padro);

// Individus
LOAD CSV WITH HEADERS FROM 'file:///dades/INDIVIDUAL.csv' AS row
WITH row WHERE row.IdIndividu IS NOT NULL
MERGE (i:Individu {id: toInteger(row.IdIndividu)})
SET i.nom = row.Nom,
    i.edat = toInteger(row.Edat),
    i.sexe = row.Sexe,
    i.cognom = row.Cognom;


// ────────────────
// RELACIONS
// ────────────────

// Padro → Municipi
LOAD CSV WITH HEADERS FROM 'file:///dades/HABITATGES.csv' AS row
WITH row
WHERE row.Municipi IS NOT NULL AND row.Id_Llar IS NOT NULL AND row.Any_Padro IS NOT NULL
MATCH (m:Municipi {id: row.Municipi})
MATCH (p:Padro {id: row.Municipi + "_" + row.Any_Padro + "_" + row.Id_Llar})
MERGE (p)-[:PERTANY_A]->(m);

// Padro → Llar
LOAD CSV WITH HEADERS FROM 'file:///dades/HABITATGES.csv' AS row
WITH row
WHERE row.Id_Llar IS NOT NULL AND row.Municipi IS NOT NULL AND row.Any_Padro IS NOT NULL
MATCH (p:Padro {id: row.Municipi + "_" + row.Any_Padro + "_" + row.Id_Llar})
MATCH (l:Llar {id: toInteger(row.Id_Llar)})
MERGE (p)-[:CONTE]->(l);

// Individu → Llar (VIU)
LOAD CSV WITH HEADERS FROM 'file:///dades/VIU.csv' AS row
WITH row
WHERE row.IdIndividu IS NOT NULL AND row.IdLlar IS NOT NULL
MATCH (i:Individu {id: toInteger(row.IdIndividu)})
MATCH (l:Llar {id: toInteger(row.IdLlar)})
MERGE (i)-[:VIU]->(l);

// Relació SAME_AS entre individus
LOAD CSV WITH HEADERS FROM 'file:///dades/SAME_AS.csv' AS row
WITH row
WHERE row.IdIndividu1 IS NOT NULL AND row.IdIndividu2 IS NOT NULL
MATCH (i1:Individu {id: toInteger(row.IdIndividu1)})
MATCH (i2:Individu {id: toInteger(row.IdIndividu2)})
MERGE (i1)-[:SAME_AS]->(i2);