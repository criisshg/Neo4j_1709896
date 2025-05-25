// 1. Castellví de Rosanes – habitants per any
MATCH (m:Municipi {id: "CR"})<-[:PERTANY_A]-(p:Padro)-[:CONTE]->(l:Llar)
MATCH (i:Individu)-[:VIU]->(l)
WHERE i.cognom IS NOT NULL AND i.cognom <> "nan"
RETURN p.any AS AnyPadro, 
       COUNT(i) AS NumeroHabitants, 
       COLLECT(DISTINCT i.cognom) AS LlistaCognoms
ORDER BY AnyPadro;


// 2. Coinquilins de rafel marti el 1838 a SFLL

// grafic
MATCH (i:Individu)
WHERE toLower(i.nom) = "rafel" AND toLower(i.cognom) = "marti"
  AND i.any = 1838
WITH i
MATCH (i)-[:VIU]->(l:Llar)<-[:VIU]-(altres:Individu)
WHERE i <> altres
  AND altres.nom IS NOT NULL AND trim(toLower(altres.nom)) <> "nan"
  AND altres.cognom IS NOT NULL AND trim(toLower(altres.cognom)) <> "nan"
  AND altres.segonCognom IS NOT NULL AND trim(toLower(altres.segonCognom)) <> "nan"
RETURN l, collect(altres) AS Coinquilins;

// taula
MATCH (i:Individu)
WHERE toLower(i.nom) = "rafel" AND toLower(i.cognom) = "marti"
  AND i.any = 1838
WITH i
MATCH (i)-[:VIU]->(l:Llar)<-[:VIU]-(altres:Individu)
WHERE i <> altres
  AND altres.nom IS NOT NULL AND trim(toLower(altres.nom)) <> "nan"
  AND altres.cognom IS NOT NULL AND trim(toLower(altres.cognom)) <> "nan"
RETURN DISTINCT 
  altres.nom AS Nom, 
  altres.cognom AS Cognom, 
  altres.segonCognom AS SegonCognom;



// 3. Totes les instàncies de "miguel estape bofill"
MATCH (i:Individu)
WHERE toLower(i.nom) = "miguel"
  AND toLower(i.cognom) = "estape"
  AND toLower(i.segonCognom) = "bofill"
MATCH (i)-[:SAME_AS*]-(altres:Individu)
RETURN DISTINCT 
  altres.nom AS Nom, 
  COLLECT(DISTINCT altres.cognom) AS LlistaCognoms, 
  COLLECT(DISTINCT altres.segonCognom) AS LlistaSegonCognoms;



// 4. Mitjana de fills per llar a SFLL l’any 1881
CALL {
  MATCH (m:Municipi {id: "SFLL"})<-[:PERTANY_A]-(p:Padro {any: 1881})-[:CONTE]->(l:Llar)<-[:VIU]-(i:Individu)
  WITH l.id AS id_llar, COUNT(i) AS fillsPerLlar
  RETURN 
    SUM(fillsPerLlar) AS TotalFills,
    COUNT(id_llar) AS NombreLlars,
    ROUND(1.0 * SUM(fillsPerLlar) / COUNT(id_llar), 2) AS MitjaFillsPerLlar
}
RETURN *;



// 5. Famílies amb més de 3 fills a Castellví de Rosanes
MATCH (m:Municipi {id: "CR"})<-[:PERTANY_A]-(p:Padro)-[:CONTE]->(l:Llar)
MATCH (i:Individu)-[:VIU]->(l)
WITH l, COUNT(i) AS NumeroFills
WHERE NumeroFills > 3
RETURN 
  l.id AS IdLlar,
  l.carrer AS Carrer,
  l.numero AS Numero,
  NumeroFills
ORDER BY NumeroFills DESC
LIMIT 20;



// 6. Carrer amb menys habitants per any a SFLL
MATCH (m:Municipi {nom: "Sant Feliu de Llobregat"})<-[:PERTANY_A]-(p:Padro)-[:CONTE]->(l:Llar)<-[:VIU]-(i:Individu)
WITH p.any AS AnyPadro, l.carrer AS Carrer, COUNT(i) AS NumHabitants
WITH AnyPadro, Carrer, NumHabitants
ORDER BY AnyPadro, NumHabitants ASC
WITH AnyPadro, collect({carrer: Carrer, habitants: NumHabitants})[0] AS MinData
RETURN AnyPadro, MinData.carrer AS CarrerAmbMenysHabitants, MinData.habitants AS NumHabitants
ORDER BY AnyPadro ASC;