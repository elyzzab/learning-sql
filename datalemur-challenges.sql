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
date functions, and I got the syntax correct thanks to a post on sqlines. */
SELECT e.user_id
FROM texts t
JOIN emails e ON t.email_id = e.email_id
WHERE t.action_date = e.signup_date + INTERVAL '1 day'
AND t.signup_action = 'Confirmed';

-- "Sales Team Compensation"
/* From the SQL September challenges. I was to total compensation for employees using their total amount of deals, base salary, compensation rate,
accelerator for compensation, and quota. This was the first Medium difficulty challenge I've attempted and it went well after using test cases and
making changes where needed. I felt ready to try this challenge after being at my new, SQL-heavy job for a while. */
-- SELECT * FROM employee_contract;
WITH sums AS (
  SELECT distinct emp.employee_id
    , emp.base
    , emp.commission
    , emp.quota
    , emp.accelerator
    , SUM(d.deal_size) OVER (PARTITION BY d.employee_id) as deals_sum
  FROM employee_contract emp
  JOIN deals d
    ON emp.employee_id = d.employee_id
)
SELECT employee_id, (base + (CASE
  WHEN deals_sum - quota > 0
  THEN (deals_sum-quota)*commission*accelerator + (quota*commission)
  WHEN deals_sum - quota < 0
  THEN deals_sum*commission
  END)) AS total_compensation
FROM sums
ORDER BY total_compensation DESC, employee_id ASC

-- "Booking Referral Source [Airbnb SQL Interview Question]"
/* From the SQL September challenges, Medium difficulty. I was to find the top marketing channel, then the percentage of first rental bookings that used
this marketing channel. This query took a while to write, and I even gave up a few times. Eventually, I viewed the solutions for guidance after giving
it my best effort. Turns out I wasn't too far behind from the official solution, but the direction I was taking was a lot more complicated than it needed
to be. Afterwards, I went through my own query and fixed it up, making sure I knew what each part did and why. */
WITH all_data AS (
SELECT ba.booking_id
  , b.user_id -- not needed in solution
  , CASE
      WHEN channel IS NULL THEN 'unknown'
      ELSE channel
    END AS new_channel
  , b.booking_date -- not needed in solution
  , ROW_NUMBER() OVER (PARTITION BY b.user_id ORDER BY b.booking_date ASC)
FROM booking_attribution ba
JOIN bookings b ON b.booking_id = ba.booking_id
)
, first_book AS (
  SELECT new_channel
    , COUNT(*) as ct_bookings
  FROM all_data
  WHERE row_number = 1
  GROUP BY new_channel
)
SELECT new_channel
  , ROUND(
    (100.0*(ct_bookings / 
      (
        SELECT SUM(ct_bookings)
        FROM first_book
      )
    ))
    , 0) as first_booking_pct
FROM first_book
ORDER BY ct_bookings DESC
LIMIT 1;
