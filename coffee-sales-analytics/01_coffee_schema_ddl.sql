-- 1) Create coffee.sales Table Definition (DDL)
CREATE TABLE IF NOT EXISTS coffee.sales (
  sale_id     bigserial PRIMARY KEY,
  sale_date   date        NOT NULL,
  sale_time   time(6)     NOT NULL,
  sale_ts     timestamp   GENERATED ALWAYS AS (sale_date + sale_time) STORED,
  hour_of_day smallint    NOT NULL CHECK (hour_of_day BETWEEN 0 AND 23),
  cash_type   text        NOT NULL CHECK (cash_type IN ('cash','card')),
  amount      numeric(10,2) NOT NULL CHECK (amount >= 0),
  coffee_name text        NOT NULL,
  time_of_day text        NOT NULL CHECK (time_of_day IN ('Morning','Afternoon','Night')),
  weekday     text        NOT NULL,
  month_name  text        NOT NULL,
  weekdaysort smallint    NOT NULL CHECK (weekdaysort BETWEEN 1 AND 7),
  monthsort   smallint    NOT NULL CHECK (monthsort BETWEEN 1 AND 12)
);

-- 2) First, import the CSV content into the temporary staging table coffee.sales_raw using the TEXT datatype for all columns. This ensures that all raw data is captured accurately without premature type conversion.
create table if not exists coffee.sales_raw (
    "Date"         text,
    "Time"         text,
    "hour_of_day"  text,
    "cash_type"    text,
    "money"        text,
    "coffee_name"  text,
    "Time_of_Day"  text,
    "Weekday"      text,
    "Month_name"   text,
    "Weekdaysort"  text,
    "Monthsort"    text
);

/* 3) This step implements the crucial Data Transformation phase: migrating data from the temporary staging table (sales_raw) to the final analytical schema (sales), 
performing essential cleansing operations (e.g., TRIM, case normalization, and NULL handling) and rigorous type casting.*/
INSERT INTO coffee.sales
  (sale_date, sale_time, hour_of_day, cash_type, amount,
   coffee_name, time_of_day, weekday, month_name, weekdaysort, monthsort)
SELECT
  CASE
    WHEN "Date" ~ '^\d{2}[./]\d{2}[./]\d{4}$' THEN to_date("Date",'DD.MM.YYYY')
    WHEN "Date" ~ '^\d{4}-\d{2}-\d{2}$'       THEN to_date("Date",'YYYY-MM-DD')
    ELSE NULL
  END                                           AS sale_date,
  NULLIF(trim("Time"),'')::time                 AS sale_time,
  NULLIF(trim("hour_of_day"),'')::smallint      AS hour_of_day,
  lower(trim(cash_type))                        AS cash_type,
  NULLIF(regexp_replace(trim("money"), '[^0-9.,]','','g'),'')::numeric(10,2) AS amount,
  trim(coffee_name)                             AS coffee_name,
  initcap(trim("Time_of_Day"))                  AS time_of_day,
  trim("Weekday")                               AS weekday,
  trim("Month_name")                            AS month_name,
  NULLIF("Weekdaysort",'')::smallint            AS weekdaysort,
  NULLIF("Monthsort",'')::smallint              AS monthsort
FROM coffee.sales_raw;
-- 4) Once the data has been successfully transferred, we can delete the temporary table coffee.sales_raw.
