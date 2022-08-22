/*
 "Teava Boba Shop" Demo Database - Queries for Github SQL Portfolio
 Created by Elyzza Bobadilla in MySQL
*/

/* Querying the Data*/
-- view all of the new data
SELECT *
FROM bobashopmenu;

-- average and round the price per drink type
SELECT drink_type AS 'Drink Type', ROUND(AVG(price),2) AS 'Average Price'
FROM bobashopmenu
GROUP BY drink_type;

-- check for duplicates (accidentally ran query to create menu table twice)
SELECT drink_title, count(drink_title)
FROM bobashopmenu
GROUP BY drink_title;

-- drop duplicated rows
DELETE FROM bobashopmenu
WHERE product_id > 10;

-- return drinks with 'tea' in their names
SELECT drink_title, price
FROM bobashopmenu
WHERE drink_title LIKE '%tea';

-- check which drinks are the most expensive and what to try if drink is non-dairy
SELECT drink_title, addon, price,
CASE
	WHEN dairy = 'no' OR dairy = 'varies' THEN 'try this'
	ELSE 'no thanks'
	END AS 'drinks to try'
FROM bobashopmenu
ORDER BY price DESC;

-- average drink type categories and return those with average price less than $4
SELECT drink_type, ROUND(AVG(price),2)
FROM bobashopmenu
GROUP BY drink_type
HAVING AVG(price) < 4;

-- doing the same thing as the last query but with a temporary table
CREATE TEMPORARY TABLE DrinkTypeAverages
AS
SELECT drink_type, ROUND(AVG(price),2) AS AveragePrice
FROM bobashopmenu
GROUP BY drink_type;

SELECT drink_type, AveragePrice
FROM DrinkTypeAverages
WHERE AveragePrice < 4;

-- union to see all the customers from both customer and customer2 table
SELECT location_id, first_name, last_name FROM customer
UNION
SELECT location_id, first_name, last_name FROM customer2;

-- create a temporary table to hold all customers and join customer tables
CREATE TEMPORARY TABLE AllCustomers
AS
SELECT l.shop_title, c.location_id, c.customer_id, c.first_name, c.last_name FROM customer c
JOIN shoplocations l ON l.location_id = c.location_id
UNION
SELECT l.shop_title, cc.location_id, cc.customer_id, cc.first_name, cc.last_name FROM customer2 cc
JOIN shoplocations l ON l.location_id = cc.location_id;

-- query order #, order date, shop title, customer first name and last name initial, and drink names with temporary table and joins
SELECT
	o.order_item_id AS 'Order#',
	o.order_date AS 'Order Date',
	a.shop_title AS 'Shop Location',
	concat(a.first_name, " ", LEFT(a.last_name,1), ".") AS 'Customer Name',
	b.drink_title 'Drink'
FROM AllCustomers a
JOIN orders o ON a.customer_id = o.customer_id AND a.location_id = o.location_id
JOIN bobashopmenu b ON b.product_id = o.product_id
ORDER BY o.order_date
;
