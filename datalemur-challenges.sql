/* This file holds notable challenges from DataLemur that taught me something new about SQL. Done in PostgreSQL 14. */

-- "Data Science Skills"
/* I was to select candidates that had all 3 required skills. Originally I tried using a CASE statement,
but the code hinted at a much cleaner solution. */
SELECT candidate_id
FROM candidates
WHERE skill IN ('Python','Tableau','PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(skill) = 3;
