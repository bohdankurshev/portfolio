# DAX Measures Documentation

A structured and professionally formatted collection of DAX measures with clear explanations, designed to provide a transparent and comprehensive overview of the analytical logic used in this Power BI project.

---

## 1. **Core Metrics (Totals & Averages)**

### **Total Revenue**
```DAX
// Calculates total revenue based on quantity sold multiplied by product price
Total Revenue = SUMX(
    'Sales Data',
    'Sales Data'[OrderQuantity] * RELATED('Product Lookup'[ProductPrice])
)
```

### **Total Cost**
```DAX
// Computes total cost of all sold items based on product cost
Total Cost = SUMX(
    'Sales Data',
    'Sales Data'[OrderQuantity] * RELATED('Product Lookup'[ProductCost])
)
```

### **Total Profit**
```DAX
// Profit = Revenue − Cost
Total Profit = [Total Revenue] - [Total Cost]
```

### **Total Orders**
```DAX
// Distinct count of all order numbers
Total Orders = DISTINCTCOUNT('Sales Data'[OrderNumber])
```

### **Total Customers**
```DAX
// Number of unique customers
Total Customers = DISTINCTCOUNT('Sales Data'[CustomerKey])
```

### **Quantity Sold**
```DAX
// Total items sold
Quantity Sold = SUM('Sales Data'[OrderQuantity])
```

### **Quantity Returned**
```DAX
// Total returned quantity from returns table
Quantity Returned = SUM('Returns Data'[ReturnQuantity])
```

### **Average Retail Price**
```DAX
// Average product price across all products
Average Retail Price = AVERAGE('Product Lookup'[ProductPrice])
```

### **Average Revenue per Customer**
```DAX
// Average revenue generated per each unique customer
Average Revenue per Customer = DIVIDE(
    [Total Revenue],
    [Total Customers]
)
```

---

## 2. **Adjusted Metrics**

### **Adjusted Price**
```DAX
// Adjusts retail price by percentage value from adjustment table
Adjusted Price = [Average Retail Price] * (1 + 'Price Adjustment (%)'[Price Adjustment (%) Value])
```

### **Adjusted Revenue**
```DAX
// Revenue recalculated using the adjusted price
Adgusted Revenue = SUMX(
    'Sales Data',
    'Sales Data'[OrderQuantity] * [Adjusted Price]
)
```

### **Adjusted Profit**
```DAX
// Profit based on adjusted revenue
Adjusted Profit = [Adgusted Revenue] - [Total Cost]
```

---

## 3. **Rolling & Time‑Intelligence Measures**

### **10‑day Rolling Revenue**
```DAX
// Revenue over the past 10 days ending on the selected date
10-day Rolling Revenue = CALCULATE(
    [Total Revenue],
    DATESINPERIOD(
        'Calendar Lookup'[Date],
        MAX('Calendar Lookup'[Date]),
        -10,
        DAY
    )
)
```

### **90‑day Rolling Profit**
```DAX
// Profit accrued over the last 90 days
90-day Rolling Profit = CALCULATE(
    [Total Profit],
    DATESINPERIOD(
        'Calendar Lookup'[Date],
        MAX('Calendar Lookup'[Date]),
        -90,
        DAY
    )
)
```

### **YTD Revenue**
```DAX
// Year-to-date revenue
YTD Revenue = CALCULATE(
    [Total Revenue],
    DATESYTD('Calendar Lookup'[Date])
)
```

### **Previous Month Revenue / Profit / Orders / Returns**
```DAX
Previous Month Revenue = CALCULATE([Total Revenue], DATEADD('Calendar Lookup'[Date], -1, MONTH))
Previous Month Profit  = CALCULATE([Total Profit],  DATEADD('Calendar Lookup'[Date], -1, MONTH))
Previous Month Orders  = CALCULATE([Total Orders],  DATEADD('Calendar Lookup'[Date], -1, MONTH))
Previous Month Returns = CALCULATE([Total Returns], DATEADD('Calendar Lookup'[Date], -1, MONTH))
```

---

## 4. **Targets & Gaps (Performance KPI)**

### **Revenue Target**
```DAX
// Target = last month's revenue +10%
Revenue Target = [Previous Month Revenue] * 1.1
```

### **Revenue Target Gap**
```DAX
// Difference between actual and target revenue
Revenue Target Gap = [Total Revenue] - [Revenue Target]
```

### **Revenue Target Gap with Arrow**
```DAX
// Adds ↑ or ↓ depending on whether the KPI meets the target
Revenue Target Gap with Arrow =
VAR uparrow = UNICHAR(129129)
VAR downarrow = UNICHAR(129131)
VAR revenuegap = [Revenue Target Gap]
RETURN IF(
    revenuegap < 0,
    FORMAT(ROUND(revenuegap, 0), "$#,###") & " " & downarrow,
    FORMAT(ROUND(revenuegap, 0), "$#,###") & " " & uparrow
)
```

### **Order Target & Gap**
```DAX
Order Target = [Previous Month Orders] * 1.1
Order Target Gap = [Total Orders] - [Order Target]
```

### **Profit Target & Gap**
```DAX
Profit Target = [Previous Month Profit] * 1.1
Profit Target Gap = [Total Profit] - [Profit Target]
```

---

## 5. **Return‑Related Metrics**

### **Total Returns**
```DAX
// Number of return records
Total Returns = COUNT('Returns Data'[ReturnQuantity])
```

### **Return Rate**
```DAX
// Percentage of returned items compared to sold items
Return Rate = DIVIDE(
    [Quantity Returned],
    [Quantity Sold],
    "No Sales"
)
```

### **Bike Returns / Sales / Bike Return Rate**
```DAX
// Filtering by product category "Bikes"
Bike Returns = CALCULATE([Total Returns], 'Product Categories Lookup'[CategoryName] = "Bikes")
Bike Sales   = CALCULATE([Quantity Sold], 'Product Categories Lookup'[CategoryName] = "Bikes")
Bike Return Rate = DIVIDE([Bike Returns], [Bike Sales])
```

### **All Orders / All Returns**
```DAX
// Removes filters to calculate overall totals
All Orders   = CALCULATE([Total Orders], ALL('Sales Data'))
All Returnes = CALCULATE([Total Returns], ALL('Returns Data'))
```

### **Percentage of All Orders / Returns**
```DAX
% of All Orders   = DIVIDE([Total Orders], [All Orders])
% of All Returns  = DIVIDE([Total Returns], [All Returnes])
```

---

## 6. **Segmentation Metrics**

### **Bulk Orders**
```DAX
// Orders where more than 1 item was purchased
Bulk Orders = CALCULATE(
    [Total Orders],
    'Sales Data'[OrderQuantity] > 1
)
```

### **High Ticket Orders**
```DAX
// Orders with price greater than overall average price
High Ticket Orders = CALCULATE(
    [Total Orders],
    FILTER(
        'Product Lookup',
        'Product Lookup'[ProductPrice] > [Overall Average Price]
    )
)
```

### **Overall Average Price**
```DAX
// Average price without filters
Overall Average Price = CALCULATE(
    [Average Retail Price],
    ALL('Product Lookup')
)
```

---

## 7. **Detail Measures (Customer View)**
```DAX
Total Orders (Customer Detail) = IF(
    HASONEVALUE('Customer Lookup'[CustomerKey]),
    [Total Orders],
    "-"
)

Total Revenue (Customer Detail) = IF(
    HASONEVALUE('Customer Lookup'[CustomerKey]),
    [Total Revenue],
    "-"
)
```

---

## 8. **Special Visual Measures**
### **Revenue Sparkline (SVG Image)**
This block originates from an online article teaching SVG sparklines in Power BI. During class, we substituted our own measures and calendar fields.

```DAX
// Static-color SVG sparkline for revenue trend
Revenue Sparkline =
VAR LineColour = "%2320E2D7"
VAR PointColour = "%23333333"
VAR Defs = "<defs>
    <linearGradient id='grad' x1='0' y1='25' x2='0' y2='50' gradientUnits='userSpaceOnUse'>
        <stop stop-color='#20E2D7' offset='0' />
        <stop stop-color='#20E2D7' offset='0.3' />
        <stop stop-color='#333333' offset='1' />
    </linearGradient>
</defs>"

VAR XMinDate = MIN('Calendar Lookup'[Start of Month])
VAR XMaxDate = MAX('Calendar Lookup'[Start of Month])

VAR YMinValue = MINX(VALUES('Calendar Lookup'[Start of Month]), CALCULATE([Total Revenue]))
VAR YMaxValue = MAXX(VALUES('Calendar Lookup'[Start of Month]), CALCULATE([Total Revenue]))

VAR SparklineTable = ADDCOLUMNS(
    SUMMARIZE('Calendar Lookup', 'Calendar Lookup'[Start of Month]),
    "X", INT(150 * DIVIDE('Calendar Lookup'[Start of Month] - XMinDate, XMaxDate - XMinDate)),
    "Y", INT(50  * DIVIDE([Total Revenue] - YMinValue, YMaxValue - YMinValue))
)

VAR Lines = CONCATENATEX(
    SparklineTable,
    [X] & "," & 50 - [Y],
    " ",
    'Calendar Lookup'[Start of Month]
)

VAR LastSparkYValue = MAXX(FILTER(SparklineTable, 'Calendar Lookup'[Start of Month] = XMaxDate), [Y])
VAR LastSparkXValue = MAXX(FILTER(SparklineTable, 'Calendar Lookup'[Start of Month] = XMaxDate), [X])

VAR SVGImageURL =
    "data:image/svg+xml;utf8," &
    "<svg xmlns='http://www.w3.org/2000/svg' x='0px' y='0px' viewBox='-7 -7 164 64'>" &
    Defs &
    "<polyline fill='url(#grad)' fill-opacity='0.3' stroke='transparent' stroke-width='0' points=' 0 50 " & Lines & " 150 150 Z '/>" &
    "<polyline fill='transparent' stroke='" & LineColour & "' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' points=' " & Lines & " '/>" &
    "<circle cx='" & LastSparkXValue & "' cy='" & 50 - LastSparkYValue & "' r='4' stroke='" & LineColour & "' stroke-width='2' fill='" & PointColour & "' />" &
    "</svg>"
RETURN
    SVGImageURL
```

---

## 9. **Calendar‑Based Metrics**

### **Weekend Orders**
```DAX
// Orders placed on Saturday or Sunday
Weekend Orders = CALCULATE(
    [Total Orders],
    'Calendar Lookup'[Weekend] = "Weekend"
)
```

---

## End of File

