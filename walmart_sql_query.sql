SELECT * FROM walmart
DROP TABLE walmart
-- DATA EXPLORATION
SELECT COUNT(*) FROM walmart

SELECT
     payment_method,
	 COUNT(*)
FROM walmart
GROUP BY payment_method

SELECT COUNT(DISTINCT branch) FROM walmart
SELECT MAX(quantity) FROM walmart
SELECT MIN(quantity) FROM walmart

-- BUsiness Problem
-- Q1. Find different payment meethod and number of transaction, number of quantity sold
SELECT
      payment_method,
	  COUNT(*) as number_of_transaction,
	  SUM(quantity) as quantity_sold
FROM walmart
GROUP BY payment_method

--Q2. Identify the highest_rated category in each branch, displaying the branch, category, avg rating
SELECT *
FROM
(SELECT
   branch,
   category,
   AVG(rating) as avg_rating,
   RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
FROM walmart
GROUP BY branch,category)

WHERE rank =1

-- Q3. Identify the busiest day for each branch based on the number of transactions
SELECT *
FROM
(SELECT 
branch,
TO_CHAR(TO_DATE(DATE,'DD/MM/YY'),'Day') as day_name,
COUNT(*) as no_of_trans,
RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC ) as rank
FROM walmart
GROUP BY 1,2)
WHERE rank=1

--Q4. Calculate the total quantity of items sod per payment method. List payment_method and total_quantity.
SELECT
      payment_method,
	  sum(quantity) as quantity_sold
FROM walmart
GROUP BY payment_method

--Q5.Determine the average, minimum, and maximum rating of products for each city.
--List the city , average_rating, min_rating, and max_rating

SELECT 
city,
category,
AVG(rating) as avg_rating,
MIN(rating) as min_rating,
MAX(rating) as max_rating
FROM walmart
GROUP BY city, category
ORDER BY city

--Q6. Calculate the total profit for each category by considering total_profit as
--(unit_profit * quantity*profit_margin). List category and total_profit, ordered from highest to lowest profit
SELECT
category,
SUM(total* profit_margin) as profit

FROM walmart
GROUP BY 1
order by 2 DESC

--Q7. Determine the most common payment method for each branch. display branch and the preferred_payment_method
WITH cte
AS
(SELECT
branch,
payment_method,
COUNT(*) AS total_trans,
RANK() OVER(PARTITION BY branch ORDER BY COUNT(*)) AS rank
FROM walmart
GROUP BY 1,2)
SELECT * from cte
WHERE rank=1

--Q8.Categorize sales into 3 groups MORNING, AFTERNOON AND EVENING
--   Find out which of the shift and numbers of invoices
SELECT 
branch,
CASE  
    WHEN EXTRACT (HOUR FROM(time:: time))<12 THEN 'MORNING'
    WHEN EXTRACT (HOUR FROM(time:: time)) BETWEEN 12 AND 17 THEN 'AFTERNOON'
	ELSE 'EVENING'
END day_time,
COUNT(*)
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC

--Q9.Identify 5 branch with decrease ratio in revenue compare to last year (current year 2023 and last year 2022)
SELECT *,
EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY') )as formated_date
FROM walmart

WITH revenue_2022
AS
(
SELECT
      branch,
	  SUM(total) as revenue
FROM walmart
WHERE  EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2022
GROUP BY 1
),

revenue_2023
AS
(
SELECT
      branch,
	  SUM(total) as revenue
FROM walmart
WHERE  EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2023
GROUP BY 1
)

SELECT 
      ls.branch,
	  ls.revenue,
	  cs.revenue,
	  ROUND((ls.revenue - cs.revenue)::numeric /ls.revenue :: numeric *100,2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch= cs.branch
WHERE 
ls.revenue> cs.revenue
order by 4 DESC
LIMIT 5


	 