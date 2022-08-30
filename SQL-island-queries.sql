/*
SQL Island Game Queries
Created by Elyzza Bobadilla for SQL Portfolio
Game developed by Johannes Schildgen, University of Kaiserslautern, Germany
with contributions from Isabell Ruth and Marlene van den Ecker
Play the game here: https://sql-island.informatik.uni-kl.de/
*/

-- See all village names, id, and village chiefs
SELECT *
FROM village;

-- See all inhabitants
SELECT *
FROM inhabitant;

-- Find a butcher for free sausages
SELECT *
FROM INHABITANT
WHERE job = 'butcher';

-- Find friendly inhabitants only
SELECT *
FROM INHABITANT
WHERE state = 'friendly';

-- Find a weaponsmith to forge me a sword
SELECT *
FROM INHABITANT
WHERE state = 'friendly' AND job = 'weaponsmith';

-- Find other -smith's who are also friendly
SELECT *
FROM INHABITANT
WHERE job LIKE '%smith' AND state = 'friendly';

-- Find my personid
SELECT personid
FROM INHABITANT
WHERE name = 'Stranger';

-- Find out how much gold I have
SELECT gold
FROM INHABITANT
WHERE name = 'Stranger';

-- Find items to sell since I have 0 gold
SELECT *
FROM ITEM
WHERE owner IS NULL;

-- Make all ownerless items mine to sell
UPDATE item
SET owner = 20
WHERE owner IS NULL;

-- Show me all of my items
SELECT *
FROM item
WHERE owner = 20;

-- Find a dealer/merchant to sell items to
SELECT *
FROM inhabitant
WHERE (job = 'dealer' OR job = 'merchant') AND state = 'friendly';

-- Someone bought a ring and teapot from me
UPDATE item
SET owner = 15
WHERE item = 'ring' OR item = 'teapot';

-- Change my name from 'Stranger' to 'Ely'
UPDATE inhabitant
SET name = 'Ely'
WHERE name = 'Stranger';

-- Find a baker to work for to earn more money, order by richest
SELECT *
FROM inhabitant
WHERE job = 'baker'
ORDER BY gold DESC;

-- Find a pilot to fly me home
SELECT *
FROM inhabitant
WHERE job = 'pilot';

-- *given query* find village where pilot is held captive (apparently, this is a join)
SELECT village.name
FROM village, inhabitant
WHERE village.villageid = inhabitant.villageid AND inhabitant.name = 'Dirty Dieter';

-- Find name of chief of Onionville village where the pilot is being held
SELECT village.chief, inhabitant.name, inhabitant.personid
FROM village, inhabitant
WHERE village.villageid = inhabitant.villageid
	AND village.chief = inhabitant.personid
	AND village.name = 'Onionville';

-- Find all female Onionville villagers
SELECT COUNT(*)
FROM inhabitant, village
WHERE village.villageid = inhabitant.villageid
	AND village.name = 'Onionville'
	AND inhabitant.gender = 'f';
	
-- Find name of the sole female Onionville villager
SELECT inhabitant.name
FROM inhabitant, village
WHERE village.villageid = inhabitant.villageid
	AND village.name = 'Onionville'
	AND inhabitant.gender = 'f';
	
-- Find gold amount of all bakers, dealers, and merchants
SELECT SUM(gold)
FROM inhabitant
WHERE job IN ('baker','dealer','merchant');

-- Find average gold amount for inhabitants based on state
SELECT inhabitant.state, AVG(inhabitant.gold)
FROM inhabitant
GROUP BY inhabitant.state
ORDER BY AVG(inhabitant.gold);

-- Eliminate the kidnapper's sister
DELETE FROM inhabitant
WHERE name = 'Dirty Diane';

-- Free the pilot
UPDATE inhabitant
SET state = 'friendly'
WHERE job = 'pilot';