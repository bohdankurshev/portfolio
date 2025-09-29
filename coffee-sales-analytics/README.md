# Coffee Sales Analytics ☕📊

**Goal:** Build an end-to-end mini project using SQL + BI to analyze a coffee shop’s transactions: revenue trends, peaks by hour/weekday, and top products.

**Tech stack:** PostgreSQL (SQL), Looker Studio (BI).

---

## 1. Dataset & Source
- **Source:** Kaggle — *Coffee Sales Dataset*  
  Link: https://www.kaggle.com/datasets/navjotkaushal/coffee-sales-dataset
- **Granularity:** one row = one transaction
- **Key fields (raw):**
  - `hour_of_day` (0–23), `cash_type` (cash/card), `money` (amount),
  - `coffee_name`, `Time_of_Day` (Morning/Afternoon/Night),
  - `Weekday`, `Month_name`, `Weekdaysort` (1–7), `Monthsort` (1–12),
  - `Date` (DD.MM.YYYY or YYYY-MM-DD), `Time` (HH:MM:SS).

---

## 2. Database Design & ETL Pipeline
### Final Schema
Final table: `coffee.sales`  
Computed column: `sale_ts = sale_date + sale_time` for time-series analysis.

### Data Cleaning & Transformation
The pipeline includes rigorous data cleansing scripts (SQL) to handle inconsistencies in the raw CSV (e.g., date format normalization, `TRIM`, and type casting) before loading data into the final schema.

---

## 3. Project Output / Dashboard 📈

The cleaned data was used to create a comprehensive BI dashboard, visualizing key metrics and providing actionable insights on sales performance.

**View the Live Dashboard:**
* **Looker Studio Link:** [Coffee Sales Dashboard](https://lookerstudio.google.com/reporting/f8fce0c9-4bc9-4a6f-a5e2-1bdddfea0acc/page/zfmZF)

**Documentation:**
* A detailed PDF report is available in the attached files for a static view of the final analysis.
