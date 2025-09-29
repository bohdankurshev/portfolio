/*
(File Description)
This file contains the core Analytical SQL Queries used directly to power the project's final Business Intelligence (BI) Dashboard.
These queries represent the culmination of the data pipeline, extracting key performance indicators (KPIs) and summarized metrics from the cleaned coffee.sales table. 
They are specifically structured to optimize performance for the chosen visualization tools.
*/

-- 20) Daily Revenue Trend: Creates a table aggregating total revenue by day to visualize sales trends over time, primarily for a line chart
select
sale_date, to_char(sum(amount),'FM$999,999,999,990.00') as revenue 
from sales 
group by sale_date 
order by 1;

-- 21) Hourly Sales Performance: Analyzes orders and revenue by the hour of the day. Uses the 75th percentile to identify and flag peak hours for operational planning and staffing
with hourly as (
select hour_of_day, count(*)    as orders_cnt, sum(amount) as revenue, avg(amount) as avg_ticket
from sales
group by hour_of_day
),
p as (
select percentile_disc(0.75) within group (order by revenue) as p75
from hourly
)
select h.hour_of_day, h.orders_cnt, h.revenue, h.avg_ticket, (h.revenue >= p.p75) as is_peak
from hourly h
cross join p
order by h.hour_of_day;

-- 22) Weekday by Hour Sales Matrix: Generates a granular matrix showing order frequency, total revenue, and average ticket size across every combination of weekday and hour, ideal for a heatmap visualization
select weekday, weekdaysort, hour_of_day, count(*) as orders_cnt, sum(amount) as revenue, avg(amount) as avg_ticket
from sales
group by weekdaysort, weekday, hour_of_day
order by weekdaysort, hour_of_day;

-- 23) Top Product Revenue: Ranks coffee products by total revenue using the DENSE_RANK window function. Calculates the revenue share percentage for each item, focusing on the top-performing coffees.
with coffee_agg as (
select coffee_name, count(*) as orders_cnt, sum(amount) as revenue, avg(amount) as avg_ticket
from sales
group by coffee_name
),
top5 as (
select coffee_name, orders_cnt, revenue, avg_ticket,
dense_rank() over (order by revenue desc) as rnk
from coffee_agg
)
select coffee_name, orders_cnt, revenue, avg_ticket, round(100.0 * revenue / sum(revenue) over (), 2) as revenue_share_pct, rnk
from top5
where rnk <= 5
order by revenue desc;

/* 24) Cumulative Revenue Tracking: Calculates the running total of revenue across the entire period using a window function (SUM() OVER...). 
This metric is crucial for tracking overall project growth, assessing long-term performance, and visualizing the accumulated sales trajectory */
with daily as (
  select sale_date, sum(amount) as day_amount
  from sales
  group by sale_date
)
select
  sale_date,
  day_amount,
  sum(day_amount) over (order by sale_date) as cum_revenue
from daily
order by sale_date;
