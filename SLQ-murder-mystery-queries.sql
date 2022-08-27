/*
SQL Murder Mystery queries (done in SQLite)
Created by Elyzza Bobadilla for SQL Portfolio
Originally by Joon Park and Cathe He
SPOILERS BELOW! Try it yourself first at https://mystery.knightlab.com/
*/

/* Finding crime suspects */
-- Find the crime scene report from January 15, 2018
SELECT *
FROM crime_scene_report
WHERE date = '20180115' AND type = 'murder'; 

-- Find witness 1 ("Annabel") and confirm she lives on "Franklin Ave" - YES
SELECT id, name, address_street_name
FROM person
WHERE address_street_name = 'Franklin Ave' AND name LIKE 'Annabel%'; -- her person id is 16371

-- View Annabel Miller's witness testimony
SELECT *
FROM interview
WHERE person_id = '16371'; -- Annabel worked out last week, January 9th

-- Find people who were at the gym on January 9th while Annabel was there
SELECT mem.id, p.id, mem.name, c.check_in_date, c.check_in_time, c.check_out_time
FROM person p
JOIN get_fit_now_member mem ON mem.person_id = p.id
JOIN get_fit_now_check_in c ON c.membership_id = mem.id
WHERE c.check_in_date = '20180109' AND c.check_out_time >= 1600 -- members who checked out as/after Annabel checked in
-- Annabel's member id is 90081
-- suspect 1: Joe Germuska (member id: 48Z7A, person id: 28819)
-- suspect 2: Jeremy Bowers (member id: 48Z55, person id:67318)


/* Narrowing down the suspect with information from witness 2 */
-- Find witness 2 information, who lives on the last house on "Northwestern Dr"
SELECT id, name, address_number, address_street_name
FROM person
WHERE address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC; -- last house resident is Morty Schapiro  (person id:14887)

-- View Morty Schapiro's witness testimony
SELECT *
FROM interview
WHERE person_id = '14887';
/*
I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag.
The membership number on the bag started with "48Z".
Only gold members have those bags.
The man got into a car with a plate that included "H42W".
*/

-- Check which of the suspects are gold members
SELECT person_id, name, membership_status
FROM get_fit_now_member
WHERE id LIKE '48Z%'; -- both Joe and Jeremy are gold members

-- Check suspect plate numbers
SELECT p.id, p.name, d.plate_number
FROM person p
JOIN drivers_license d ON d.id = p.license_id
WHERE d.plate_number LIKE '%H42W%'; -- confirmed that plate belongs to Jeremy Bowers - the murderer!


/* More Villains */
-- View Jeremy Bowers' testimony
SELECT  *
FROM interview
WHERE person_id IN ('67318','28819');
/*
"I was hired by a woman with a lot of money. I don't know her name but I know she's
around 5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S.
I know that she attended the SQL Symphony Concert 3 times in December 2017."
*/

-- Constraint: find the mastermind using no more than 2 queries
-- 1. Check who went to the SQL Symphony Concert 3x
SELECT person_id, COUNT(event_id)
FROM facebook_event_checkin
WHERE date LIKE '201712%' AND event_name = 'SQL Symphony Concert'
GROUP BY person_id
--ORDER BY COUNT(event_id) DESC;
HAVING COUNT(event_id) >= 3; -- person_id's who went 3x: 99716, 24556

-- 2. Check person_id against driver's license (DL) description
SELECT p.id, p.name, d.id, d.height, d.hair_color, d.car_make, d.car_model
FROM person p
JOIN drivers_license d ON d.id = p.license_id
WHERE p.id IN ('99716','24556');
-- only person with a registered DL is Miranda Priestly (person id: 99716) - the mastermind!