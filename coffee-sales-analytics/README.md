# Coffee Sales Analytics ☕📊

**Goal:** build an end-to-end mini project using SQL + BI to analyze a coffee shop’s transactions: revenue trends, peaks by hour/weekday, and top products.

**Tech stack:** PostgreSQL (SQL), Looker Studio (BI).

---

## Dataset
- **Source:** Kaggle — *Coffee Sales Dataset*  
  Link: https://www.kaggle.com/datasets/navjotkaushal/coffee-sales-dataset
- **Granularity:** one row = one transaction
- **Key fields (raw):**
  - `hour_of_day` (0–23), `cash_type` (cash/card), `money` (amount),
  - `coffee_name`, `Time_of_Day` (Morning/Afternoon/Night),
  - `Weekday`, `Month_name`, `Weekdaysort` (1–7), `Monthsort` (1–12),
  - `Date` (DD.MM.YYYY or YYYY-MM-DD), `Time` (HH:MM:SS).

---

## Database layout
Final table: `coffee.sales`  
Computed column `sale_ts = sale_date + sale_time` for time-series analysis
