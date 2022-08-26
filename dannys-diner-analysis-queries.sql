/*
 "Danny's Diner" Case Study Queries
 Created by Elyzza Bobadilla in MySQL
 Original by Danny Ma: https://8weeksqlchallenge.com/case-study-1/
*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
	s.customer_id AS Customer,
	SUM(p.price) AS 'Total Amount Spent'
FROM sales s
JOIN menu p ON p.product_id = s.product_id
GROUP BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT
	customer_id AS Customer,
    COUNT(DISTINCT order_date) AS 'Number of Visits'
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
SELECT s.customer_id, MIN(s.order_date), m.product_name
FROM sales s
JOIN menu m ON m.product_id = s.product_id
GROUP BY customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name AS 'Menu Item', COUNT(s.product_id) AS 'Times Purchased'
FROM sales s
JOIN menu m ON m.product_id = s.product_id
GROUP BY m.product_id
ORDER BY COUNT(s.product_id) DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
# using a derived table
SELECT customer_id, product_name, Freq_Ordered
FROM (
	SELECT
		s.customer_id,
		m.product_name,
		COUNT(s.product_id) AS Freq_Ordered,
		DENSE_RANK() OVER(
		PARTITION BY s.customer_id
		ORDER BY COUNT(s.product_id) DESC
			) AS order_rank
	FROM sales s
	JOIN menu m ON m.product_id = s.product_id
	GROUP BY s.customer_id, s.product_id # don't use AND here in place of a comma or it will limit your results
) AS ranked
WHERE order_rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?
# using a derived table
SELECT customer_id, order_date, m.product_name
FROM (
SELECT
	s.customer_id,
    s.order_date,
    s.product_id,
    DENSE_RANK() OVER(
    PARTITION BY s.customer_id
    ORDER BY s.order_date
        ) order_rank
FROM sales s
INNER JOIN members mem ON mem.customer_id = s.customer_id
WHERE s.order_date > mem.join_date
) ranked
JOIN menu m ON m.product_id = ranked.product_id
WHERE order_rank = 1
ORDER BY ranked.customer_id;

-- 7. Which item was purchased just before the customer became a member?
# using a CTE
WITH ranked AS (
	SELECT
		s.customer_id,
		s.product_id,
		mem.join_date,
		s.order_date,
		DENSE_RANK() OVER(
			PARTITION BY s.customer_id
			ORDER BY s.order_date DESC
			) AS order_rank
	FROM sales s
	INNER JOIN members mem ON mem.customer_id = s.customer_id
	WHERE s.order_date < mem.join_date
)
SELECT r.customer_id, r.order_date, m.product_name, r.order_rank
FROM ranked r
JOIN menu m ON m.product_id = r.product_id
WHERE order_rank = 1
ORDER BY r.customer_id;

-- 8. What is the total items and amount spent for each member before they became a member?
WITH date_rank AS (
	SELECT s.customer_id, mem.join_date, s.order_date, s.product_id, m.price,
		DENSE_RANK() OVER (
			PARTITION BY s.customer_id
			ORDER BY s.order_date) AS order_rank
	FROM sales s
    INNER JOIN members mem ON mem.customer_id = s.customer_id
    JOIN menu m ON m.product_id = s.product_id
    WHERE s.order_date < mem.join_date
    ORDER BY s.customer_id
)
SELECT dr.customer_id, SUM(dr.price) AS Before_Member_Total
FROM date_rank dr
GROUP BY dr.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH pt AS (
SELECT s.customer_id, s.product_id, m.product_name, m.price,
	CASE s.product_id
		WHEN '1' THEN '200'
		WHEN '2' THEN '150'
		WHEN '3' THEN '120'
	END AS points
FROM sales s
JOIN menu m ON m.product_id = s.product_id
)
SELECT pt.customer_id, SUM(pt.points) AS Total_Points
FROM pt
GROUP BY pt.customer_id;

/*
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
not just sushi - how many points do customer A and B have at the end of January?

Note: Assume that question 9 rules apply to this question also (non-members: $1 spent/10pts, 2x pts if sushi)
*/
WITH point_ct AS (
SELECT
	s.customer_id,
	mem.join_date,
    s.order_date,
    DATE_ADD(mem.join_date, INTERVAL 6 DAY) AS lastDay,
    s.product_id, m.price,
	CASE
		WHEN s.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY) THEN m.price*20
		WHEN s.order_date NOT BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY) THEN (
			CASE WHEN s.product_id = '1' THEN m.price*20
            ELSE m.price*10
            END)
		END AS points
FROM sales s
INNER JOIN members mem ON mem.customer_id = s.customer_id
JOIN menu m ON m.product_id = s.product_id
ORDER BY s.customer_id, s.order_date)

SELECT pt.customer_id, SUM(pt.points)
FROM point_ct pt
WHERE pt.order_date BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY pt.customer_id
ORDER BY pt.customer_id;

/*
Bonus 1. The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without
needing to join the underlying tables using SQL. Recreate the following table output using the available data: [see post]

Clarification from Katie H. Xiemen (https://medium.com/analytics-vidhya/8-week-sql-challenge-case-study-week-1-dannys-diner-2ba026c897ab):
'I've checked with Danny on how to solve the question without having to use joins and this was his reply:
"For the danny’s diner - it’s actually supposed to be used with joins, it’s more that “the rest of the team” is not supposed to know SQL so
either a derived table or view using the table joins would be ideal ".
What he meant was that Danny (owner of Danny's Diner) and his team would not need to join the tables themselves as we've merged the tables
for him and the team.'
*/
SELECT s.customer_id, s.order_date, m.product_name, m.price,
	CASE
		WHEN s.order_date >= mem.join_date THEN 'Y'
		ELSE 'N'
	END AS 'member'
FROM sales s
LEFT JOIN members mem ON mem.customer_id = s.customer_id # left join so it doesn't exclude any customers
JOIN menu m ON m.product_id = s.product_id
ORDER BY s.customer_id, s.order_date, m.price DESC;