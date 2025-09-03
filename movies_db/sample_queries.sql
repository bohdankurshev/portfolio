/*======================================================================
   Movies DB — My Learning Queries
   Author: Bohdan Kurshev
   DBMS: PostgreSQL
   -------------------------------------------------------------------
   Note:
   This file contains a structured collection of SQL queries completed 
   as part of my training homeworks and practice exercises. 

   Queries are organized progressively, starting from simple SELECT 
   statements and DISTINCT filtering, and moving step by step through 
   conditions, string/date functions, logical operators, aggregates, 
   and JSON operations. 

   The goal of this file is to demonstrate the gradual development of 
   SQL skills and the ability to apply theory to practical tasks on a 
   toy "Movies DB". Each block reflects a separate topic covered during 
   the learning process.
 
   Tables:
     movies(movie_id, title, release_date, runtime_min, budget_usd, genres, rating_mpaa, is_series, metadata, created_at)
     people(person_id, full_name, birth_date, country, created_at)
     castings(casting_id, movie_id, person_id, role_type, character_name, billing_order, salary_usd)
     box_office_daily(movie_id, revenue_date, territory, revenue_usd)
     user_ratings(rating_id, movie_id, user_id, rating, review_text, rated_at)
====================================================================== */


/* =========================
   1) SELECT & DISTINCT  (перша домашка)
========================= */

-- 1
SELECT title
FROM movies;

-- 2
SELECT release_date
FROM movies;

-- 3
SELECT DISTINCT country
FROM people;

-- 4
SELECT full_name, birth_date
FROM people
WHERE birth_date > DATE '1980-01-01';

-- 5
SELECT title, runtime_min
FROM movies;

-- 6
SELECT DISTINCT territory
FROM box_office_daily;

-- 7
SELECT *
FROM user_ratings;

-- 8
SELECT *
FROM box_office_daily
WHERE revenue_date > DATE '2015-01-01';

-- 9
SELECT title, genres
FROM movies;

-- 10
SELECT title, budget_usd
FROM movies
WHERE budget_usd > 50000000;


/* =========================
   2) Фільтри й логіка (AND/OR/IN/BETWEEN/LIKE/NOT/NULL) — друга домашка
========================= */

-- 1) Фільми з бюджетом понад 80 млн
SELECT title
FROM movies AS m
WHERE m.budget_usd > 80000000;

-- 2) Люди, народжені до 1985 року
SELECT full_name
FROM people AS p
WHERE birth_date < DATE '1985-01-01';

-- 3) Фільми між 2000 і 2015
SELECT title
FROM movies AS m
WHERE release_date BETWEEN DATE '2000-01-01' AND DATE '2015-12-31';

-- 4) Усі фільми, крім тих, що зняті в US (через box_office_daily)
SELECT m.title, b.territory, b.revenue_date
FROM box_office_daily AS b
JOIN movies AS m ON b.movie_id = m.movie_id
WHERE b.territory NOT IN ('US');

-- 5) Люди з невідомою країною
SELECT full_name, country
FROM people
WHERE country IS NULL;

-- 6) Назви фільмів, що починаються на "The"
SELECT title
FROM movies AS m
WHERE title LIKE 'The%';

-- 7) Оцінки 5, 7 або 9
SELECT rating
FROM user_ratings AS ur
WHERE rating IN (5, 7, 9);

-- 8) box_office_daily з KR або FR
SELECT territory
FROM box_office_daily AS bod
WHERE bod.territory = 'KR' OR bod.territory = 'FR';

-- 9) Фільми з бюджетом < 50 млн
SELECT title
FROM movies AS m
WHERE m.budget_usd < 50000000;

-- 10) Люди, народжені після 1975 і з відомою country
SELECT full_name, birth_date, country
FROM people
WHERE birth_date > DATE '1975-01-01'
  AND country IS NOT NULL;


/* =========================
   3) String functions (LEFT/RIGHT/UPPER/LOWER/TRIM) — третя домашка
========================= */

-- 1) Назви фільмів і перші 5 символів
SELECT title, LEFT(title, 5) AS short_title
FROM movies;

-- 2) Останні 2 символи у всіх імен людей
SELECT full_name, RIGHT(full_name, 2) AS last_2_initials
FROM people;

-- 3) Назви фільмів у верхньому регістрі
SELECT UPPER(title) AS upper_title
FROM movies;

-- 4) Назви фільмів у нижньому регістрі
SELECT LOWER(title) AS lower_title
FROM movies;

-- 5) TRIM приклад (я перевіряв на штучних пробілах)
SELECT TRIM(full_name) AS clean_name
FROM people;

-- 6) Перші 4 + '...' + останні 4
SELECT title, LEFT(title, 4) || '...' || RIGHT(title, 4) AS short_title
FROM movies;

-- 7) Перші 3 символи + '...'
SELECT title, LEFT(title, 3) || '...' AS short_title
FROM movies;

-- 8) «Нормалізація» імен: перша літера велика, решта малі
SELECT
  full_name,
  UPPER(LEFT(full_name, 1)) || LOWER(SUBSTRING(full_name FROM 2)) AS normalized_name
FROM people;

-- 9) Фільми, де перші 3 символи = 'The'
SELECT title
FROM movies AS m
WHERE title LIKE 'The%';

-- 10) Очистити ' Inception ' (демо)
SELECT TRIM(title) AS clean_title
FROM movies
WHERE title LIKE '%Inc%';


/* =========================
   4) Date/Time (EXTRACT, AGE, INTERVAL, NOW) — четверта домашка
========================= */

-- 1) Фільми з роком релізу
SELECT title, EXTRACT(YEAR FROM release_date) AS release_year
FROM movies;

-- 2) Місяць виходу кожного фільму
SELECT title, EXTRACT(MONTH FROM release_date) AS release_month
FROM movies;

-- 3) Люди + рік народження
SELECT full_name, EXTRACT(YEAR FROM birth_date) AS birth_year
FROM people;

-- 4) Люди, народжені у червні
SELECT full_name, birth_date
FROM people
WHERE EXTRACT(MONTH FROM birth_date) = 6;

-- 5) Дата релізу + 100 днів  (випр.: '100 days')
SELECT title, release_date, release_date + INTERVAL '100 days' AS hundred_days_later
FROM movies;

-- 6) Вік людини в роках
SELECT full_name, DATE_PART('year', AGE(birth_date)) AS age_years
FROM people;

-- 7) День тижня релізу
SELECT title, EXTRACT(DOW FROM release_date) AS dow_release
FROM movies;

-- 8) Фільми, що вийшли після 2010  (у домашці було < 2010 — тут виправлено)
SELECT title, release_date
FROM movies AS m
WHERE EXTRACT(YEAR FROM m.release_date) > 2010;

-- 9) Люди молодші за 50
SELECT full_name
FROM people
WHERE DATE_PART('year', AGE(birth_date)) < 50;

-- 10) Сьогоднішня дата (DD.MM.YYYY) — варіанти
SELECT NOW()::date;
SELECT TO_CHAR(NOW(), 'DD.MM.YYYY') AS today_ua;


/* =========================
   5) Logical functions (CASE, COALESCE, NULLIF) — п’ята домашка
========================= */

-- 1) Категорії бюджету
SELECT title, budget_usd,
CASE
  WHEN budget_usd <  50000000 THEN 'Low budget'
  WHEN budget_usd >= 50000000 AND budget_usd <= 100000000 THEN 'Medium budget'
  ELSE 'High budget'
END AS budget_category
FROM movies;

-- 2) Вікові категорії людей
SELECT full_name,
CASE
  WHEN DATE_PART('year', AGE(birth_date)) < 30 THEN 'young'
  WHEN DATE_PART('year', AGE(birth_date)) BETWEEN 30 AND 50 THEN 'middle_age'
  ELSE 'old'
END AS age_category
FROM people;

-- 3) COALESCE для country
SELECT full_name, COALESCE(country, 'Unknown') AS country_clean
FROM people;

-- 4) NULLIF для оцінок
SELECT rating_id, NULLIF(rating, 0) AS rating_clean
FROM user_ratings;

-- 5) Бюджет з підстановкою, варіант без тексту (0 як заглушка)
SELECT title, COALESCE(budget_usd, 0) AS budget_usd_clean
FROM movies;

-- 6) К-сть фільмів із високим бюджетом (>= 100M)  (коментар: у мене була дискусія про THEN 1)
SELECT COUNT(*) AS blockbusters
FROM movies
WHERE budget_usd >= 100000000;

-- 7) Категорія епохи релізу (мій творчий поділ)
SELECT title, CASE
  WHEN DATE_PART('year', release_date) BETWEEN 1970 AND 1989 THEN 'Classic era'
  WHEN DATE_PART('year', release_date) BETWEEN 1990 AND 2009 THEN 'Millennium era'
  WHEN DATE_PART('year', release_date) BETWEEN 2010 AND 2019 THEN 'Modern era'
  ELSE 'Other'
END AS era
FROM movies;

-- 8) Positive / Negative оцінки
SELECT rating,
CASE
  WHEN rating >= 7 THEN 'Positive'
  ELSE 'Negative'
END AS overall_feedback
FROM user_ratings;

-- 9) Domestic vs Foreign по box_office_daily (distinct по movie_id)
SELECT DISTINCT movie_id,
CASE WHEN territory = 'US' THEN 'Domestic' ELSE 'Foreign' END AS market
FROM box_office_daily;

-- 10) «Summer release» через CASE + варіант через WHERE
SELECT title,
CASE WHEN DATE_PART('month', release_date) BETWEEN 6 AND 8 THEN 'Yes' ELSE 'No' END AS summer_release
FROM movies;

SELECT title, release_date
FROM movies
WHERE DATE_PART('month', release_date) BETWEEN 6 AND 8;


/* =========================
   6) Aggregates (без HAVING/груп, потім один demo з GROUP BY) — шоста домашка
========================= */

-- 1) Середній вік людей (округлення)
SELECT ROUND(AVG(DATE_PART('year', AGE(birth_date)))) AS avg_age
FROM people;

-- 2) Сумарний US-дохід "Inception"
SELECT m.title, SUM(box.revenue_usd) AS total_usd
FROM box_office_daily AS box
JOIN movies AS m ON box.movie_id = m.movie_id
WHERE m.title = 'Inception'
GROUP BY m.title;

-- 3) К-сть унікальних фільмів у box_office_daily
SELECT COUNT(DISTINCT movie_id) AS box_unique_films
FROM box_office_daily;

-- 4) Мін/макс бюджет
SELECT MIN(budget_usd) AS min_budget, MAX(budget_usd) AS max_budget
FROM movies;

-- 5) Середня оцінка
SELECT AVG(rating) AS avg_rating
FROM user_ratings;


/* =========================
   7) JSON (jsonb) — сьома домашка
========================= */

-- 1) imdb_id
SELECT title, metadata ->> 'imdb_id' AS imdb_id
FROM movies;

-- 2) origin
SELECT title, metadata ->> 'origin' AS origin
FROM movies;

-- 3) К-сть мов (правильний спосіб)
SELECT title, jsonb_array_length(metadata->'languages') AS lang_count
FROM movies;

-- 4) Перша мова
SELECT title, metadata->'languages'->>0 AS first_language
FROM movies;

-- 5) Розпакувати ключ-значення
SELECT title, key, value
FROM movies, jsonb_each_text(metadata) AS m(key, value);
