/* This file holds notable challenges from DataLemur that taught me something new about SQL. Done in PostgreSQL 14. */

-- "Data Science Skills"
/* I was to select candidates that had all 3 required skills. Originally I tried using a CASE statement,
but the given hints alluded to a much cleaner solution. */
SELECT candidate_id
FROM candidates
WHERE skill IN ('Python','Tableau','PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(skill) = 3;

-- "Duplicate Job Listings"
/* I was to find duplicate job entries for a job board (shared same job title, description, and company_id).
I failed the first time but got it the second time, and my query varies quite a bit from the official solution.
I think I did "too much heavy lifting" in the CTE I created; AKA, if someone were to try and re-create my work,
they wouldn't be able to see my train of thought. Will try to be more thorough with my statements next time
(as if I were to preview the query and question again after a long SQL-free vacation). */
WITH filtered_jobs AS (
    SELECT COUNT(DISTINCT company_id) AS dup_job_count
    FROM job_listings
    GROUP BY company_id
    HAVING COUNT(company_id) >= 2
      AND COUNT(title) >= 2
      AND COUNT(description) >= 2
)
SELECT SUM(dup_job_count)
FROM filtered_jobs;

-- "Second Day Confirmation"
/* I was to find users who signed up on TikTok via email and received a text confirmation but confirmed their account the day AFTER
and not the day of their sign-up. I didn't use any hints this time. The only thing that gave me some difficulty was the SQL dialect's
date functions, and I got the syntax correct thanks to a post on sqlines.
*/
SELECT e.user_id
FROM texts t
JOIN emails e ON t.email_id = e.email_id
WHERE t.action_date = e.signup_date + INTERVAL '1 day'
AND t.signup_action = 'Confirmed';
