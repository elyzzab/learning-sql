/*
 "Pizza Runner" Case Study - Analysis Queries (Sections A & B) for Github SQL Portfolio
 Created by Elyzza Bobadilla in MySQL
 Original by Danny Ma: https://8weeksqlchallenge.com/case-study-2/
*/
-- Note: temporary table names - clean_runner_orders, clean_customer_orders



/* -------------------------------------------
	Section A: Pizza Metrics
   ------------------------------------------- */

-- 1. How many pizzas were ordered?
SELECT COUNT(pizza_id) AS "# of Pizzas Ordered"
FROM clean_customer_orders;

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS "Number of Orders"
FROM clean_customer_orders;

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS "Number of Successful Deliveries"
FROM clean_runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT
	o.pizza_id, p.pizza_name,
	COUNT(p.pizza_id) AS "Number Delivered"
FROM clean_customer_orders o
JOIN pizza_names p ON o.pizza_id = p.pizza_id
JOIN clean_runner_orders r ON r.order_id = o.order_id
WHERE r.cancellation IS NULL
GROUP BY p.pizza_id;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
	o.customer_id, p.pizza_name,
	COUNT(o.order_id) OVER( PARTITION BY o.customer_id ) AS "Number Ordered"
FROM clean_customer_orders o
JOIN pizza_names p ON o.pizza_id = p.pizza_id
GROUP BY o.customer_id, o.pizza_id;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT order_id, COUNT(pizza_id)
FROM clean_customer_orders
GROUP BY order_id
ORDER BY COUNT(pizza_id) DESC
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- return: partition by customer, filter delivered pizzas only, (extras or exclusions) > 0, (extras or exclusions) = 0
WITH successful_orders AS (
	SELECT r.order_id, r.cancellation, o.customer_id, o.pizza_id, o.exclusions, o.extras
	FROM clean_runner_orders r
	JOIN clean_customer_orders o ON r.order_id = o.order_id
	WHERE r.cancellation IS NULL
)
SELECT s.customer_id,
	SUM(CASE
		WHEN (s.extras NOT LIKE "0") OR (s.exclusions NOT LIKE "0") THEN 1
        	ELSE 0
        END) AS Count_ModPizza,
	SUM(CASE
		WHEN (s.extras = "0" AND s.exclusions = "0") THEN 1
        	ELSE 0
        END) AS Count_PlainPizza
FROM successful_orders s
GROUP BY s.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
WITH successful_orders AS (
	SELECT r.order_id, r.cancellation, o.customer_id, o.pizza_id, o.exclusions, o.extras
	FROM clean_runner_orders r
	JOIN clean_customer_orders o ON r.order_id = o.order_id
	WHERE r.cancellation IS NULL
)
SELECT
	SUM(CASE
	    WHEN (s.extras NOT LIKE "0" AND s.exclusions NOT LIKE "0") THEN 1
	    ELSE 0
        END) AS Count_veryModPizza
FROM successful_orders s;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
-- A. with respect to date
WITH PizzaHour AS (
	SELECT
		order_id,
		customer_id,
		pizza_id, order_time,
		DATE_FORMAT(order_time, '%H') AS OrderHour,
		DATE_FORMAT(order_time, '%d') AS DayDate
	FROM clean_customer_orders
)
SELECT
	DayDate,
	OrderHour,
	COUNT(pizza_id) AS PizzaVolume
FROM PizzaHour
GROUP BY DayDate, OrderHour;

-- B. ignoring date
WITH PizzaHour AS (
	SELECT
		order_id,
		customer_id,
		pizza_id, order_time,
		DATE_FORMAT(order_time, '%H') AS OrderHour,
		DATE_FORMAT(order_time, '%d') AS DayDate
	FROM clean_customer_orders
)
SELECT
	OrderHour,
	COUNT(pizza_id) AS PizzaVolume
FROM PizzaHour
GROUP BY OrderHour
ORDER BY OrderHour ASC;

-- 10. What was the volume of orders for each day of the week?
-- A. with respect to date
WITH PizzaDay AS (
	SELECT
		order_id,
		customer_id,
		pizza_id, order_time,
		DATE_FORMAT(order_time, '%W') AS OrderWeekday,
		DATE_FORMAT(order_time, '%d') AS DayDate
	FROM clean_customer_orders
)
SELECT
	DayDate,
	OrderWeekday,
	COUNT(pizza_id) AS PizzaVolume
FROM PizzaDay
GROUP BY DayDate, OrderWeekday;

-- B. ignoring date
WITH PizzaDay AS (
	SELECT
		order_id,
		customer_id,
		pizza_id, order_time,
		DATE_FORMAT(order_time, '%W') AS OrderWeekday,
		DATE_FORMAT(order_time, '%d') AS DayDate
	FROM clean_customer_orders
)
SELECT
	OrderWeekday,
	COUNT(pizza_id) AS PizzaVolume
FROM PizzaDay
GROUP BY OrderWeekday;



/* -------------------------------------------
	Section B: Runner and Customer Experience
   ------------------------------------------- */

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
-- assumption: registration = signing up
WITH runners_weekly AS (
	SELECT
		runner_id,
		registration_date,
		WEEK(registration_date) AS weekNum
    FROM runners
)
SELECT
	weekNum,
	COUNT(DISTINCT runner_id) AS "# of Runners Signed Up"
FROM runners_weekly
GROUP BY weekNum;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH runner_pickup AS (
	SELECT
		o.order_id,
		r.runner_id,
		CAST(o.order_time AS datetime) AS castedOrder,
		CAST(r.pickup_time AS datetime) AS castedPickup
	FROM clean_runner_orders r
    JOIN clean_customer_orders o ON r.order_id = o.order_id
    GROUP BY o.order_time
)
-- SELECT order_id, runner_id, newOrder, newPickup, TIMEDIFF(newPickup, newOrder) -- run to check my work
SELECT
	runner_id,
	ROUND(AVG(TIME_TO_SEC(TIMEDIFF(castedPickup, castedOrder)))/60) AS AvgPickupMin
FROM runner_pickup
GROUP BY runner_id; -- comment out to check my work
-- ORDER BY runner_id; -- comment out to check my work

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH pizza_prep AS (
	SELECT
		o.order_id,
		COUNT(o.pizza_id) AS numPizzas,
		CAST(o.order_time AS datetime) AS castedOrder,
		CAST(r.pickup_time AS datetime) AS castedPickup,
		SEC_TO_TIME(TIME_TO_SEC(TIMEDIFF(CAST(r.pickup_time AS datetime), CAST(o.order_time AS datetime)))) AS prepDuration,
		minute(TIMEDIFF(CAST(r.pickup_time AS datetime), CAST(o.order_time AS datetime))) AS prepMinutes
    FROM clean_runner_orders r
    JOIN clean_customer_orders o ON r.order_id = o.order_id
    WHERE r.pickup_time IS NOT NULL
    GROUP BY o.order_time
)
SELECT
	numPizzas, (AVG(TIME_TO_SEC(prepDuration)))/60 AS AvgPrepMin_precise,
	ROUND((AVG(TIME_TO_SEC(prepDuration)))/60) AS AvgPrepMin_rounded
FROM pizza_prep
GROUP BY numPizzas; -- it seems like the average prep time increases as number of pizzas increases

-- 4. What was the average distance travelled for each customer?
WITH customer_distance AS(
	SELECT
		o.customer_id,
		o.order_id,
        	r.distance_km
	FROM clean_customer_orders o
	JOIN clean_runner_orders r ON o.order_id = r.order_id
	GROUP BY o.order_id
	ORDER BY o.customer_id, o.order_id
)
SELECT
	customer_id,
	AVG(distance_km)
FROM customer_distance
GROUP BY customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
WITH runner_pickup AS (
	SELECT
		o.order_id,
		r.runner_id,
		CAST(o.order_time AS datetime) AS castedOrder,
        	CAST(r.pickup_time AS datetime) AS castedPickup,
		TIMEDIFF(CAST(r.pickup_time AS datetime), CAST(o.order_time AS datetime)) AS DiffTime
	FROM clean_runner_orders r
	JOIN clean_customer_orders o ON r.order_id = o.order_id
	GROUP BY o.order_time
)
SELECT
	MIN(DiffTime) AS "Shortest Delivery",
	MAX(DiffTime) AS "Longest Delivery",
	TIMEDIFF(MAX(DiffTime), MIN(DiffTime)) AS "Difference Between Delivery Times"
FROM runner_pickup;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT
	order_id,
	runner_id,
	distance_km,
	duration_min,
-- 	distance_km*1000 AS distanceMeters,
 	duration_min/60 AS durationHour,
    (distance_km)/(duration_min/60) AS kmh
FROM clean_runner_orders
WHERE pickup_time IS NOT NULL
ORDER BY runner_id ASC, kmh;
/* kmh is the average speed for each runner for each delivery.
As duration decreased, with distance staying the same, kmh increased -> time and speed are directly proportional
As duration stayed the same and distance increased, kmh increased -> distance and speed are directly proportional */

-- 7. What is the successful delivery percentage for each runner?
With OrderCount AS (
SELECT
	runner_id,
	COUNT(order_id) AS TotalOrders,
	SUM(
		CASE
			WHEN pickup_time IS NULL THEN 1
			ELSE 0
		END) AS NumOrdersNull
FROM clean_runner_orders
GROUP BY runner_id
)
SELECT
	runner_id,
	ROUND(((TotalOrders - NumOrdersNull)/TotalOrders)*100) AS "Percent of Successful Deliveries"
FROM OrderCount;
