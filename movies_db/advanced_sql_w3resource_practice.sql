/*
====================================================================
Bohdan’s Advanced SQL Practice — W3Resource Tasks AND Salary_DB FROM Kaggle
--------------------------------------------------------------------
This file collects my own SQL query solutions from practice
with W3Resource tasks. 
It contains more advanced examples: JOINs (INNER/LEFT/RIGHT/FULL),
GROUP BY with HAVING, correlated subqueries, and even a
window function (RANK).
====================================================================
*/

-- ==================================================================
-- 1. JOINs (INNER, LEFT, RIGHT, FULL)
-- ==================================================================

-- [J01] INNER JOIN — Products with their companies
-- Show only those products that have a company.
SELECT i.pro_name  AS "item name",
       i.pro_price AS "price",
       c.com_name  AS "company name"
FROM item_mast i
INNER JOIN company_mast c
  ON i.pro_com = c.com_id;

-- [J02] LEFT JOIN — All customers and their orders (customers without orders kept).
SELECT a.cust_name AS "customer name",
       a.city,
       b.ord_no,
       b.ord_date,
       b.purch_amt
FROM customer a
LEFT JOIN orders b
  ON a.customer_id = b.customer_id;

-- [J03] RIGHT JOIN — All products, with companies if they exist.
SELECT b.pro_name  AS "item name",
       b.pro_price AS "price",
       a.com_name  AS "company name"
FROM company_mast a
RIGHT JOIN item_mast b
  ON a.com_id = b.pro_com;

-- [J04] FULL OUTER JOIN — Customer Order Placement Report
-- Include orders from known customers (with grade) and 
-- orders from customers missing in the list.
SELECT a.cust_name AS "customer name",
       a.city,
       b.ord_no,
       b.ord_date,
       b.purch_amt
FROM customer a
FULL OUTER JOIN orders b
  ON a.customer_id = b.customer_id;


-- ==================================================================
-- 2. Aggregate Functions (GROUP BY, HAVING)
-- ==================================================================

-- [A01] Departments with more than 2 employees.
SELECT d.dpt_name AS department,
       COUNT(*)   AS emp_count
FROM emp_department d
JOIN emp_details e
  ON d.dpt_code = e.emp_dept
GROUP BY d.dpt_name
HAVING COUNT(*) > 2;

-- [A02] Departments with at least 3 employees and avg salary > 5000.
SELECT d.dpt_name AS department,
       COUNT(*)   AS emp_count,
       ROUND(AVG(e.salary), 2) AS avg_salary
FROM emp_department d
JOIN emp_details e
  ON d.dpt_code = e.emp_dept
GROUP BY d.dpt_name
HAVING COUNT(*) >= 3
   AND AVG(e.salary) > 5000;


-- ==================================================================
-- 3. Subqueries (placeholders for future additions)
-- ==================================================================

-- [S01] Product(s) with max price per company (correlated subquery).
SELECT i.pro_name,
       i.pro_price,
       c.com_name
FROM item_mast i
JOIN company_mast c
  ON i.pro_com = c.com_id
WHERE i.pro_price = (
    SELECT MAX(i2.pro_price)
    FROM item_mast i2
    WHERE i2.pro_com = c.com_id
);

-- (placeholder for future subquery examples…)
/*Задача #1 Вивести всіх спеціалістів, які живуть в країнах, де
середня з/п  вища за середню серед усіх країн*/
-- Перший підзапит пошук середньої з/п.
SELECT AVG (salary_in_usd)
FROM salaries
-- Другий підзапит порівняння
SELECT company_location
FROM salaries
WHERE year = 2023
GROUP BY 1
HAVING AVG (salary_in_usd) >
(
SELECT AVG (salary_in_usd)
FROM salaries
WHERE year = 2023
);
-- Запит із двома вкладеними запитами
SELECT *
FROM salaries
WHERE emp_location IN (
SELECT company_location
FROM salaries
WHERE year = 2023
GROUP BY 1
HAVING AVG (salary_in_usd) >
(
SELECT AVG (salary_in_usd)
FROM salaries
WHERE year = 2023
)
)

/* Задача #2 Знайти мінімальну заробітну плату серед максимальних
з/п по країнах в 2023 році*/
-- 1. Пошук максимальних заробітних плат в 2023 році
-- 2. Знайти мінімальну з/п
SELECT company_location, MAX(salary_in_usd)
FROM salaries
GROUP BY 1;
----------------------------------------------
SELECT MIN (t.salary_in_usd)
FROM (
SELECT company_location, MAX(salary_in_usd) AS salary_in_usd
FROM salaries
GROUP BY 1
) AS t;
-- Простіша альтернатива, щоб уникнути підзапиту, коли непотрібно
SELECT company_location, MAX(salary_in_usd) AS salary_in_usd
FROM salaries
GROUP BY 1
ORDER BY 2 ASC
LIMIT 1;

/* Задача #3. По кожній професії вивести різницю між середньою
з/п та максиимальною з/п усіх спеціалістів*/
-- 1. Максимальна з/п
-- 2. Таблиця професій і середніх зп
-- 3. Результат різниця заробітних плат
SELECT MAX (salary_in_usd)
FROM salaries

SELECT job_title, AVG(salary_in_usd) - (SELECT MAX (salary_in_usd)
FROM salaries) AS difference
FROM salaries
GROUP BY job_title;

/* Задача #4. Вивести дані по співробітнику, який отримує другу
по розміру з/п в таблиці*/
SELECT *
FROM
(
SELECT *
FROM salaries
ORDER BY salary_in_usd DESC
LIMIT 2
) AS t
ORDER BY salary_in_usd ASC
LIMIT 1;

SELECT *
FROM salaries
ORDER BY salary_in_usd DESC
LIMIT 1 OFFSET 1;

-- ==================================================================
-- 4. Window Functions
-- ==================================================================

-- [W01] Find product(s) with max price per company (RANK over partition).
WITH ranked AS (
  SELECT i.pro_name,
         i.pro_price,
         i.pro_com,
         RANK() OVER (PARTITION BY i.pro_com ORDER BY i.pro_price DESC) AS rnk
  FROM item_mast i
)
SELECT c.com_name AS company,
       r.pro_name,
       r.pro_price
FROM ranked r
JOIN company_mast c
  ON c.com_id = r.pro_com
WHERE r.rnk = 1;

