USING PERIODIC COMMIT
LOAD CSV WITH HEADERS from "file:///AllData.csv" AS line WITH line, SPLIT(TRIM(line.Beneficiaries), " ") as benes
UNWIND benes as bene
MERGE (project:Project { id: toInteger(line.`Internal ID`) })
ON CREATE 
SET project.name = line.Project
SET project.description = coalesce(line.Description, 'NONE')
SET project.strategicObjective = coalesce(line.SO, 'NONE')
SET project.director = coalesce(line.Director, 'NONE')
SET project.architectPartner = coalesce(line.`Architect Partner`, 'NONE')
SET project.status = coalesce(line.`Status (derived from internal Phase)`, 'NONE')
SET project.sponsoringArea = line.`Sponsoring Area`
SET project.beneficiaries = line.Beneficiaries
SET project.phase = coalesce(line.`Internal Phase`, 'NONE')

//Strategic Objectives and relations
MERGE (so:StrategicObjective {name: toUpper(coalesce(line.SO, 'NONE'))})
MERGE (project)-[:STRATEGIC_OBJECTIVE]->(so)

//Sponsors and relations
MERGE (sponsor:Sponsor { name: toUpper(line.`Sponsoring School Area`) })
MERGE (project)-[:SPONSOR]->(sponsor)

//Beneficiaries and relations
MERGE (benefic:Beneficiary {name: toUpper(bene)})
MERGE (project)-[:BENEFICIARY]->(benefic) ;
