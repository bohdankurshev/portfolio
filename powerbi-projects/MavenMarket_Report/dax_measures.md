# DAX Measures Documentation

A structured and professionally formatted collection of DAX measures with clear explanations, designed to provide a transparent and comprehensive overview of the analytical logic used in this Power BI project.

---

## **1. Base Aggregations & Quantities**
Fundamental metrics for counting transactions, returns, and product quantities.

```dax
// Counts the total number of rows in the Transaction_Data table
Total Transactions = COUNTROWS(Transaction_Data)

// Counts the total number of rows in the Return_Data table
Total Returns = COUNTROWS(Return_Data)

// Calculates the sum of quantity sold from transactions
Quantity Sold = SUM(Transaction_Data[quantity])

// Calculates the sum of quantity returned
Quantity Returned = SUM(Return_Data[quantity])

// Counts the distinct number of products available in the catalog
Unique Products = DISTINCTCOUNT(Products[product_name])
```

---

## **2. Financial Performance (Revenue, Cost, Profit)**
Core financial metrics calculated using iterators (**SUMX**) for row‑by‑row computations.

```dax
// Calculates total revenue by multiplying quantity by retail price
Total Revenue =
SUMX(
    Transaction_Data,
    Transaction_Data[quantity] * RELATED(Products[product_retail_price])
)

// Calculates total cost by multiplying quantity by product cost
Total Cost =
SUMX(
    Transaction_Data,
    Transaction_Data[quantity] * RELATED(Products[product_cost])
)

// Gross profit (Revenue - Cost)
Total Profit =
[Total Revenue] - [Total Cost]
```

---

## **3. Time Intelligence**
Measures for YTD analysis, month‑over‑month comparison, and rolling windows.

```dax
// Year-to-Date revenue
YTD Revenue =
TOTALYTD([Total Revenue], 'Calendar'[date])

// Revenue for the previous month
Last Month Revenue =
CALCULATE(
    [Total Revenue],
    PREVIOUSMONTH('Calendar'[date])
)

// Profit for the previous month
Last Month Profit =
CALCULATE(
    [Total Profit],
    PREVIOUSMONTH('Calendar'[date])
)

// Transactions for the previous month
Last Month Transactions =
CALCULATE(
    [Total Transactions],
    PREVIOUSMONTH('Calendar'[date])
)

// Returns for the previous month
Last Month Returns =
CALCULATE(
    [Total Returns],
    PREVIOUSMONTH('Calendar'[date])
)

// 60-day rolling revenue
60-Day Revenue =
CALCULATE(
    [Total Revenue],
    DATESINPERIOD('Calendar'[date], MAX('Calendar'[date]), -60, DAY)
)
```

---

## **4. Targets & Variance Analysis**
Used to evaluate performance against a 5% growth target.

```dax
// Target of 5% growth over last month's revenue
Revenue Target =
[Last Month Revenue] * 1.05

// Gap between current revenue and the target
Revenue Target Gap =
[Total Revenue] - [Revenue Target]
```

---

## **5. Ratios, Filters & Context Manipulation**
Return rate, weekend statistics, and ALL() context removal.

```dax
// Return rate (returned quantity / sold quantity)
Return Rate =
DIVIDE([Quantity Returned], [Quantity Sold])

// Weekend-only transactions
Weekend Transactions =
CALCULATE(
    [Total Transactions],
    'Calendar'[Weekend] = "Y"
)

// Percentage of transactions on weekends
% Weekend Transactions =
DIVIDE([Weekend Transactions], [Total Transactions])

// Removes filters to show grand total
All Transactions =
CALCULATE([Total Transactions], ALL('Transaction_Data'))

// Removes filters to show grand total
All Returns =
CALCULATE([Total Returns], ALL('Return_Data'))
```

---

## End of File

