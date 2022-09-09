/*
 "Pizza Runner" Case Study - Table Cleaning Queries for Github Portfolio
 Created by Elyzza Bobadilla in MySQL
 Original by Danny Ma: https://8weeksqlchallenge.com/case-study-2/
*/

/* Cleaning the Runner Orders table */
-- check what's currently in the runner orders table
SELECT * FROM pizza_runner.runner_orders;

-- create a temporary table to hold the cleaned data so as not to alter original table
DROP TABLE IF EXISTS clean_runner_orders;
CREATE TEMPORARY TABLE clean_runner_orders(
	SELECT
		order_id,
		runner_id,
		CASE
			WHEN pickup_time = 'null' THEN NULL
			ELSE pickup_time
			END AS pickup_time,
		CASE
			WHEN distance LIKE '%km' THEN SUBSTRING(distance, 1, length(distance)-2)
			WHEN distance LIKE '% km' THEN SUBSTRING(distance, 1, length(distance)-3)
			WHEN distance = "null" THEN NULL
			ELSE distance
			END AS distance_km,
		CASE
			WHEN duration LIKE '% minutes' THEN SUBSTRING(duration, 1, length(duration)-8)
			WHEN duration LIKE '% mins' THEN SUBSTRING(duration, 1, length(duration)-5)
			WHEN duration LIKE '%mins' THEN SUBSTRING(duration, 1, length(duration)-4)
			WHEN duration LIKE '% minute' THEN SUBSTRING(duration, 1, length(duration)-7)
			WHEN duration LIKE '%minutes' THEN SUBSTRING(duration, 1, length(duration)-7)
			WHEN duration = "null" THEN NULL
			ELSE duration
			END AS duration_min,
		CASE
			WHEN cancellation = 'null' THEN NULL
			WHEN cancellation = "" THEN NULL
			ELSE cancellation
			END AS cancellation
		FROM runner_orders
);

-- check results of cleaning
SELECT * FROM clean_runner_orders;


/* Cleaning the Customer Orders table */
-- check what's currently in the customer orders table
SELECT * FROM pizza_runner.customer_orders;

-- create a temporary table to hold cleaned data
DROP TABLE IF EXISTS clean_customer_orders;
CREATE TEMPORARY TABLE clean_customer_orders(
SELECT order_id, customer_id, pizza_id,
	CASE
		WHEN exclusions = "" THEN "0"
        	WHEN exclusions = "null" THEN "0"
        	ELSE exclusions
        END AS exclusions,
	CASE
		WHEN extras = "" THEN "0"
        	WHEN extras = "null" THEN "0"
        	WHEN extras IS NULL THEN "0"
        	ELSE extras
        END as extras,
    order_time
FROM customer_orders);

-- check results of the cleaning
SELECT * FROM clean_customer_orders;
