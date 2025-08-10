-- SQL Query to create and import data from csv files:

-- 0. Create a database 
CREATE DATABASE ccdb;

-- 1. Create cc_detail table

CREATE TABLE cc_detail (
    Client_Num INT,
    Card_Category VARCHAR(20),
    Annual_Fees INT,
    Activation_30_Days INT,
    Customer_Acq_Cost INT,
    Week_Start_Date DATE,
    Week_Num VARCHAR(20),
    Qtr VARCHAR(10),
    current_year INT,
    Credit_Limit DECIMAL(10,2),
    Total_Revolving_Bal INT,
    Total_Trans_Amt INT,
    Total_Trans_Ct INT,
    Avg_Utilization_Ratio DECIMAL(10,3),
    Use_Chip VARCHAR(10),
    Exp_Type VARCHAR(50),
    Interest_Earned DECIMAL(10,3),
    Delinquent_Acc VARCHAR(5)
);


-- 2. Create cc_detail table

CREATE TABLE cust_detail (
    Client_Num INT,
    Customer_Age INT,
    Gender VARCHAR(5),
    Dependent_Count INT,
    Education_Level VARCHAR(50),
    Marital_Status VARCHAR(20),
    State_cd VARCHAR(50),
    Zipcode VARCHAR(20),
    Car_Owner VARCHAR(5),
    House_Owner VARCHAR(5),
    Personal_Loan VARCHAR(5),
    Contact VARCHAR(50),
    Customer_Job VARCHAR(50),
    Income INT,
    Cust_Satisfaction_Score INT
);


-- 3. Copy csv data into SQL (remember to update the file name and file location in below query)

-- copy cc_detail table

COPY cc_detail
FROM 'D:\credit_card.csv' 
DELIMITER ',' 
CSV HEADER;


-- copy cust_detail table

COPY cust_detail
FROM 'D:\customer.csv' 
DELIMITER ',' 
CSV HEADER;



-- If you are getting below error, then use the below point:  
   -- ERROR:  date/time field value out of range: "0"
   -- HINT:  Perhaps you need a different "datestyle" setting.

-- Check the Data in Your CSV File: Ensure date column values are formatted correctly and are in a valid format that PostgreSQL can recognize (e.g., YYYY-MM-DD). And correct any incorrect or missing date values in the CSV file. 
   -- or
-- Update the Datestyle Setting: Set the datestyle explicitly for your session using the following command:
SET datestyle TO 'ISO, DMY';

-- Now, try to COPY the csv files!


-- 4. Insert additional data into SQL, using same COPY function

-- copy additional data (week-53) in cc_detail table

COPY cc_detail
FROM 'D:\cc_add.csv' 
DELIMITER ',' 
CSV HEADER;


-- copy additional data (week-53) in cust_detail table (remember to update the file name and file location in below query)

COPY cust_detail
FROM 'D:\cust_add.csv' 
DELIMITER ',' 
CSV HEADER;

## Key Analyses and Visualizations

Below are 20 analytical questions, each with an advanced SQL query and a corresponding Metabase visualization. These questions cover revenue analysis, customer segmentation, trend analysis, and correlation studies, demonstrating a wide range of SQL techniques and visualization strategies.

### 1. Total Revenue by Customer Job Type

**Question**: What is the total revenue by customer job type?\
**Objective**: Understand which job types (e.g., Engineer, Teacher) drive the most revenue to prioritize marketing efforts.\
**Visualization**: Bar chart with `Customer_Job` on the x-axis and `Total_Revenue` (in millions, with 'M' suffix) on the y-axis.\
**Business Value**: Identifies high-value professions for targeted campaigns.\
**SQL Query**:

```sql
SELECT 
    c.Customer_Job, 
    CONCAT(ROUND(SUM(t.Total_Revenue) / 1000000, 2), 'M') AS Total_Revenue_By_Job
FROM customer c
JOIN transaction_detail t ON c.Client_Num = t.Client_Num
GROUP BY c.Customer_Job
ORDER BY SUM(t.Total_Revenue) DESC;
```

**Visualization Setup**: Bar chart; x-axis: `Customer_Job`; y-axis: `Total_Revenue_By_Job` (numeric, parsed from string); sort descending for clarity.

### 2. Revenue by Age Group and Gender

**Question**: What is the total revenue distribution by age group and gender?\
**Objective**: Analyze revenue contributions across demographic segments.\
**Visualization**: Stacked bar chart with `Age_Group` on the x-axis, `Total_Revenue` on the y-axis, stacked by `Gender`.\
**Business Value**: Highlights demographic segments for personalized offerings.\
**SQL Query**:

```sql
SELECT 
    c.Age_Group, 
    c.Gender, 
    CONCAT(ROUND(SUM(t.Total_Revenue) / 1000000, 2), 'M') AS Total_Revenue
FROM customer c
JOIN transaction_detail t ON c.Client_Num = t.Client_Num
GROUP BY c.Age_Group, c.Gender
ORDER BY c.Age_Group, c.Gender;
```

**Visualization Setup**: Stacked bar chart; x-axis: `Age_Group`; y-axis: `Total_Revenue` (parsed numeric); stack by `Gender` (e.g., blue for Male, pink for Female).

### 3. Quarter-over-Quarter Revenue Growth by Age Group

**Question**: What is the quarter-over-quarter revenue growth percentage for each age group?\
**Objective**: Track revenue trends over time by age group to identify growth patterns.\
**Visualization**: Line chart with `Qtr` on the x-axis, `Growth_Percentage` on the y-axis, and separate lines per `Age_Group`.\
**Business Value**: Pinpoints age groups with increasing/decreasing revenue for strategic adjustments.\
**SQL Query**:

```sql
WITH QuarterlyRevenue AS (
    SELECT 
        c.Age_Group,
        t.Qtr,
        SUM(t.Total_Revenue) AS Total_Revenue
    FROM customer c
    JOIN transaction_detail t ON c.Client_Num = t.Client_Num
    GROUP BY c.Age_Group, t.Qtr
)
SELECT 
    Age_Group,
    Qtr,
    Total_Revenue,
    ROUND((Total_Revenue - LAG(Total_Revenue) OVER (PARTITION BY Age_Group ORDER BY Qtr)) / LAG(Total_Revenue) OVER (PARTITION BY Age_Group ORDER BY Qtr) * 100, 2) AS Growth_Percentage
FROM QuarterlyRevenue
ORDER BY Age_Group, Qtr;
```

**Visualization Setup**: Line chart; x-axis: `Qtr`; y-axis: `Growth_Percentage`; series by `Age_Group`; add tooltips for `Total_Revenue`.

### 4. Top 3 Customers by Revenue within Job Type and Income Group

**Question**: Who are the top 3 customers by total revenue within each job type and income group?\
**Objective**: Identify high-value customers within specific segments for targeted retention.\
**Visualization**: Table or grouped bar chart showing top customers per `Customer_Job` and `Income_Group`.\
**Business Value**: Enables personalized engagement with top spenders.\
**SQL Query**:

```sql
WITH CustomerRevenue AS (
    SELECT 
        c.Client_Num,
        c.Customer_Job,
        c.Income_Group,
        SUM(t.Total_Revenue) AS Total_Revenue
    FROM customer c
    JOIN transaction_detail t ON c.Client_Num = t.Client_Num
    GROUP BY c.Client_Num, c.Customer_Job, c.Income_Group
)
SELECT 
    Client_Num,
    Customer_Job,
    Income_Group,
    Total_Revenue,
    DENSE_RANK() OVER (PARTITION BY Customer_Job, Income_Group ORDER BY Total_Revenue DESC) AS Revenue_Rank
FROM CustomerRevenue
WHERE Revenue_Rank <= 3
ORDER BY Customer_Job, Income_Group, Revenue_Rank;
```

**Visualization Setup**: Table; columns: `Client_Num`, `Customer_Job`, `Income_Group`, `Total_Revenue`, `Revenue_Rank`; filter by top ranks.

### 5. Average Credit Utilization by Delinquency and Education Level

**Question**: What is the average credit utilization ratio for customers with delinquent accounts vs. non-delinquent, by education level?\
**Objective**: Compare credit behavior across education levels and delinquency status.\
**Visualization**: Grouped bar chart with `Education_Level` on the x-axis, `Avg_Util_Delinquent` and `Avg_Util_Non_Delinquent` as bars.\
**Business Value**: Informs risk assessment and credit limit strategies.\
**SQL Query**:

```sql
SELECT 
    c.Education_Level,
    AVG(CASE WHEN t.Delinquent_Acc = 1 THEN t.Avg_Utilization_Ratio ELSE NULL END) AS Avg_Util_Delinquent,
    AVG(CASE WHEN t.Delinquent_Acc = 0 THEN t.Avg_Utilization_Ratio ELSE NULL END) AS Avg_Util_Non_Delinquent
FROM customer c
JOIN transaction_detail t ON c.Client_Num = t.Client_Num
GROUP BY ROLLUP(c.Education_Level);
```

**Visualization Setup**: Grouped bar chart; x-axis: `Education_Level`; y-axis: utilization ratios; bars for `Avg_Util_Delinquent` and `Avg_Util_Non_Delinquent`.

### 6. Transaction Amount by Expense Type and Card Category (Pivot)

**Question**: What is the total transaction amount by expense type and card category in a matrix view?\
**Objective**: Understand spending patterns across card types and expense categories.\
**Visualization**: Heatmap with `Card_Category` on rows, `Exp_Type` on columns, and `Total_Amt` as intensity.\
**Business Value**: Identifies popular card-expense combinations for product optimization.\
**SQL Query**:

```sql
SELECT 
    t.Card_Category,
    SUM(CASE WHEN t.Exp_Type = 'Travel' THEN t.Total_Trans_Amt ELSE 0 END) AS Travel_Amt,
    SUM(CASE WHEN t.Exp_Type = 'Entertainment' THEN t.Total_Trans_Amt ELSE 0 END) AS Entertainment_Amt,
    SUM(CASE WHEN t.Exp_Type = 'Grocery' THEN t.Total_Trans_Amt ELSE 0 END) AS Grocery_Amt,
    SUM(t.Total_Trans_Amt) AS Total_Amt
FROM transaction_detail t
GROUP BY t.Card_Category;
```

**Visualization Setup**: Heatmap; rows: `Card_Category`; columns: `Travel_Amt`, `Entertainment_Amt`, `Grocery_Amt`; color intensity: amount values.

### 7. Customers Below Average Satisfaction by Marital Status and Gender

**Question**: Which customers have satisfaction scores below the average for their marital status and gender, and what is their revenue contribution?\
**Objective**: Identify at-risk customers for retention efforts.\
**Visualization**: Table or scatter plot with `Cust_Satisfaction_Score` vs. `Customer_Revenue`, colored by `Marital_Status`.\
**Business Value**: Targets low-satisfaction customers for improved service.\
**SQL Query**:

```sql
SELECT 
    c.Client_Num,
    c.Marital_Status,
    c.Gender,
    c.Cust_Satisfaction_Score,
    SUM(t.Total_Revenue) AS Customer_Revenue
FROM customer c
JOIN transaction_detail t ON c.Client_Num = t.Client_Num
WHERE c.Cust_Satisfaction_Score < (
    SELECT AVG(c2.Cust_Satisfaction_Score)
    FROM customer c2
    WHERE c2.Marital_Status = c.Marital_Status AND c2.Gender = c.Gender
)
GROUP BY c.Client_Num, c.Marital_Status, c.Gender, c.Cust_Satisfaction_Score
ORDER BY Customer_Revenue DESC;
```

**Visualization Setup**: Table; columns: `Client_Num`, `Marital_Status`, `Gender`, `Cust_Satisfaction_Score`, `Customer_Revenue`; or scatter plot with `Customer_Revenue` (y-axis), `Cust_Satisfaction_Score` (x-axis), colored by `Marital_Status`.

### 8. Running Total of Revenue by State Over Weeks

**Question**: What is the running total of revenue over weeks for each state?\
**Objective**: Track cumulative revenue trends geographically over time.\
**Visualization**: Line chart with `Week_Num` on the x-axis, `Running_Total` on the y-axis, and lines per `state_cd`.\
**Business Value**: Identifies high-growth regions for resource allocation.\
**SQL Query**:

```sql
SELECT 
    c.state_cd,
    t.Week_Num,
    SUM(t.Total_Revenue) AS Weekly_Revenue,
    SUM(SUM(t.Total_Revenue)) OVER (PARTITION BY c.state_cd ORDER BY t.Week_Num) AS Running_Total
FROM customer c
JOIN transaction_detail t ON c.Client_Num = t.Client_Num
GROUP BY c.state_cd, t.Week_Num
ORDER BY c.state_cd, t.Week_Num;
```

**Visualization Setup**: Line chart; x-axis: `Week_Num`; y-axis: `Running_Total`; series by `state_cd`; tooltips for `Weekly_Revenue`.

### 9. Cohort Analysis: Acquisition Cost vs. Lifetime Revenue

**Question**: What are the average acquisition cost and lifetime revenue for customers activated within 30 days vs. those who weren’t?\
**Objective**: Compare ROI for early vs. late-activated customers.\
**Visualization**: Bar chart with `Cohort` (Early/Late) on the x-axis, `Avg_Cohort_Acq_Cost` and `Avg_Cohort_Revenue` as bars.\
**Business Value**: Justifies onboarding investments for early activation.\
**SQL Query**:

```sql
WITH Cohorts AS (
    SELECT 
        Client_Num,
        CASE WHEN Activation_30_Days = 1 THEN 'Activated_Early' ELSE 'Activated_Late' END AS Cohort
    FROM transaction_detail
    GROUP BY Client_Num, Activation_30_Days
),
RevenueAndCost AS (
    SELECT 
        co.Client_Num,
        co.Cohort,
        AVG(t.Customer_Acq_Cost) AS Avg_Acq_Cost,
        SUM(t.Total_Revenue) AS Lifetime_Revenue
    FROM Cohorts co
    JOIN transaction_detail t ON co.Client_Num = t.Client_Num
    GROUP BY co.Client_Num, co.Cohort
)
SELECT 
    Cohort,
    AVG(Avg_Acq_Cost) AS Avg_Cohort_Acq_Cost,
    AVG(Lifetime_Revenue) AS Avg_Cohort_Revenue,
    ROUND(AVG(Lifetime_Revenue / NULLIF(Avg_Acq_Cost, 0)), 2) AS Revenue_To_Cost_Ratio
FROM RevenueAndCost
GROUP BY Cohort;
```

**Visualization Setup**: Grouped bar chart; x-axis: `Cohort`; y-axis: `Avg_Cohort_Acq_Cost` and `Avg_Cohort_Revenue`; tooltip for `Revenue_To_Cost_Ratio`.

### 10. Interest Earned Distribution by Use Chip Method

**Question**: What is the distribution of interest earned by use chip method, using percentiles?\
**Objective**: Analyze how payment methods impact interest earnings.\
**Visualization**: Box plot with `Use_Chip` on the x-axis, `Interest_Earned` distribution (quartiles).\
**Business Value**: Informs payment method promotions based on profitability.\
**SQL Query**:

```sql
SELECT 
    t.Use_Chip,
    t.Interest_Earned,
    NTILE(4) OVER (PARTITION BY t.Use_Chip ORDER BY t.Interest_Earned) AS Quartile
FROM transaction_detail t
ORDER BY t.Use_Chip, t.Interest_Earned DESC;
```

**Visualization Setup**: Box plot; x-axis: `Use_Chip`; y-axis: `Interest_Earned`; group by `Quartile` for distribution.

### 11. Revenue Trends by Card Category Over Quarters

**Question**: How has revenue trended quarter-over-quarter by card category?\
**Objective**: Track revenue performance across card types (e.g., Gold, Platinum).\
**Visualization**: Line chart with `Qtr` on the x-axis, `Total_Revenue` on the y-axis, lines per `Card_Category`.\
**Business Value**: Identifies high-performing card types for promotions.\
**SQL Query**:

```sql
WITH QuarterlyRevenue AS (
    SELECT 
        t.Qtr,
        t.Card_Category,
        SUM(t.Total_Revenue) AS Total_Revenue
    FROM transaction_detail t
    GROUP BY t.Qtr, t.Card_Category
)
SELECT 
    Qtr,
    Card_Category,
    Total_Revenue,
    LAG(Total_Revenue) OVER (PARTITION BY Card_Category ORDER BY Qtr) AS Previous_Quarter_Revenue
FROM QuarterlyRevenue
ORDER BY Card_Category, Qtr;
```

**Visualization Setup**: Line chart; x-axis: `Qtr`; y-axis: `Total_Revenue`; series by `Card_Category`.

### 12. Average Transaction Amount by State and Expense Type

**Question**: What is the average transaction amount by state and expense type?\
**Objective**: Compare spending patterns geographically and by category.\
**Visualization**: Heatmap with `state_cd` on rows, `Exp_Type` on columns, and `Avg_Trans_Amt` as intensity.\
**Business Value**: Targets regional marketing based on spending habits.\
**SQL Query**:

```sql
SELECT 
    c.state_cd,
    t.Exp_Type,
    AVG(t.Total_Trans_Amt) AS Avg_Trans_Amt
FROM customer c
JOIN transaction_detail t ON c.Client_Num = t.Client_Num
GROUP BY c.state_cd, t.Exp_Type
ORDER BY c.state_cd, Avg_Trans_Amt DESC;
```

**Visualization Setup**: Heatmap; rows: `state_cd`; columns: `Exp_Type`; intensity: `Avg_Trans_Amt`.

### 13. Satisfaction Score Distribution by Income Group and Job Type

**Question**: What is the customer satisfaction score distribution by income group and job type?\
**Objective**: Understand satisfaction across economic and professional segments.\
**Visualization**: Violin plot with `Income_Group` on the x-axis, `Cust_Satisfaction_Score` distribution, faceted by `Customer_Job`.\
**Business Value**: Identifies segments needing service improvements.\
**SQL Query**:

```sql
WITH SatisfactionStats AS (
    SELECT 
        c.Income_Group,
        c.Customer_Job,
        AVG(c.Cust_Satisfaction_Score) AS Avg_Score,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY c.Cust_Satisfaction_Score) AS Median_Score
    FROM customer c
    GROUP BY c.Income_Group, c.Customer_Job
)
SELECT * FROM SatisfactionStats
ORDER BY Income_Group, Avg_Score DESC;
```

**Visualization Setup**: Violin plot; x-axis: `Income_Group`; y-axis: `Avg_Score`; facet by `Customer_Job`.

### 14. Credit Utilization by Education and Delinquency Status

**Question**: How does credit utilization ratio vary by education level and delinquent status?\
**Objective**: Analyze credit behavior across education and risk profiles.\
**Visualization**: Grouped bar chart with `Education_Level` on the x-axis, `Avg_Util_Delinquent` and `Avg_Util_Non_Delinquent` as bars.\
**Business Value**: Informs credit risk policies.\
**SQL Query**:

```sql
SELECT 
    c.Education_Level,
    AVG(CASE WHEN t.Delinquent_Acc = 1 THEN t.Avg_Utilization_Ratio END) AS Avg_Util_Delinquent,
    AVG(CASE WHEN t.Delinquent_Acc = 0 THEN t.Avg_Utilization_Ratio END) AS Avg_Util_Non_Delinquent
FROM customer c
JOIN transaction_detail t ON c.Client_Num = t.Client_Num
GROUP BY c.Education_Level;
```

**Visualization Setup**: Grouped bar chart; x-axis: `Education_Level`; y-axis: utilization ratios; bars for delinquent/non-delinquent.

### 15. Top 5 Expense Types by Transaction Volume Over Weeks

**Question**: What are the top 5 expense types by total transaction volume over weeks?\
**Objective**: Identify high-activity expense categories over time for trend analysis.\
**Visualization**: Stacked area chart with `Week_Num` on the x-axis, `Total_Volume` on the y-axis, areas by `Exp_Type`.\
**Business Value**: Highlights seasonal or trending expense categories for marketing focus.\
**SQL Query**:

```sql
WITH RankedExpenses AS (
    SELECT 
        t.Week_Num,
        t.Exp_Type,
        SUM(t.Total_Trans_Vol) AS Total_Volume,
        RANK() OVER (PARTITION BY t.Week_Num ORDER BY SUM(t.Total_Trans_Vol) DESC) AS Volume_Rank
    FROM transaction_detail t
    GROUP BY t.Week_Num, t.Exp_Type
)
SELECT 
    Week_Num,
    Exp_Type,
    Total_Volume
FROM RankedExpenses
WHERE Volume_Rank <= 5
ORDER BY Week_Num, Volume_Rank;
```

**Visualization Setup**: Stacked area chart; x-axis: `Week_Num`; y-axis: `Total_Volume`; areas by `Exp_Type`; enable tooltips for exact volumes.

### 16. Correlation Between Acquisition Cost and Lifetime Revenue

**Question**: What is the correlation between customer acquisition cost and lifetime revenue by activation status?\
**Objective**: Assess ROI of acquisition spend and impact of early activation.\
**Visualization**: Scatter plot with `Avg_Acq_Cost` on the x-axis, `Avg_Lifetime_Revenue` on the y-axis, colored by `Activation_30_Days`, with trend lines.\
**Business Value**: Guides marketing budget allocation and onboarding strategies.\
**SQL Query**:

```sql
SELECT 
    t.Client_Num,
    t.Activation_30_Days,
    AVG(t.Customer_Acq_Cost) AS Avg_Acq_Cost,
    SUM(t.Total_Revenue) AS Avg_Lifetime_Revenue,
    SUM(t.Total_Trans_Vol) AS Total_Trans_Vol
FROM transaction_detail t
GROUP BY t.Client_Num, t.Activation_30_Days
ORDER BY t.Activation_30_Days, Avg_Acq_Cost;
```

**Visualization Setup**: Scatter plot; x-axis: `Avg_Acq_Cost`; y-axis: `Avg_Lifetime_Revenue`; color by `Activation_30_Days`; bubble size: `Total_Trans_Vol` (if supported, else tooltip); enable trend lines.

### 17. Interest Earned by Use Chip and Marital Status

**Question**: How does interest earned distribute by use chip method and marital status?\
**Objective**: Analyze profitability across payment methods and marital status.\
**Visualization**: Pie chart per `Use_Chip`, segmented by `Marital_Status`.\
**Business Value**: Optimizes payment method promotions.\
**SQL Query**:

```sql
SELECT 
    t.Use_Chip,
    c.Marital_Status,
    SUM(t.Interest_Earned) AS Total_Interest
FROM customer c
JOIN transaction_detail t ON c.Client_Num = t.Client_Num
GROUP BY t.Use_Chip, c.Marital_Status
ORDER BY t.Use_Chip, Total_Interest DESC;
```

**Visualization Setup**: Pie chart; group by `Use_Chip`; segments by `Marital_Status`; size by `Total_Interest`.

### 18. Revenue Contribution by Personal Loan and House Ownership

**Question**: What is the revenue contribution percentage by personal loan status and house ownership?\
**Objective**: Understand revenue distribution across loan and ownership segments.\
**Visualization**: Stacked 100% bar chart with `Personal_loan` on the x-axis, `Revenue_Percentage` stacked by `House_Owner`.\
**Business Value**: Targets high-revenue customer profiles.\
**SQL Query**:

```sql
WITH RevenueByOwnership AS (
    SELECT 
        c.Personal_loan,
        c.House_Owner,
        SUM(t.Total_Revenue) AS Group_Revenue
    FROM customer c
    JOIN transaction_detail t ON c.Client_Num = t.Client_Num
    GROUP BY c.Personal_loan, c.House_Owner
)
SELECT 
    Personal_loan,
    House_Owner,
    Group_Revenue,
    ROUND(Group_Revenue / SUM(Group_Revenue) OVER () * 100, 2) AS Revenue_Percentage
FROM RevenueByOwnership
ORDER BY Revenue_Percentage DESC;
```

**Visualization Setup**: Stacked 100% bar chart; x-axis: `Personal_loan`; y-axis: `Revenue_Percentage`; stack by `House_Owner`.

### 19. Running Total of Transactions for High-Income Customers

**Question**: What is the running total of transactions by quarter for high-income customers?\
**Objective**: Track transaction activity for high-income customers over time.\
**Visualization**: Line chart with `Qtr` on the x-axis, `Running_Total` on the y-axis.\
**Business Value**: Focuses on high-value customer activity trends.\
**SQL Query**:

```sql
SELECT 
    t.Qtr,
    SUM(t.Total_Trans_Amt) AS Quarterly_Trans_Amt,
    SUM(SUM(t.Total_Trans_Amt)) OVER (ORDER BY t.Qtr) AS Running_Total
FROM customer c
JOIN transaction_detail t ON c.Client_Num = t.Client_Num
WHERE c.Income_Group = 'High'
GROUP BY t.Qtr
ORDER BY t.Qtr;
```

**Visualization Setup**: Line chart; x-axis: `Qtr`; y-axis: `Running_Total`; tooltip for `Quarterly_Trans_Amt`.

### 20. Total Revenue by Customer (Initial Query)

**Question**: What is the total revenue per customer?\
**Objective**: Provide a baseline view of individual customer revenue contributions.\
**Visualization**: Bar chart with `Client_Num` on the x-axis, `Total_Customer_Revenue` on the y-axis (top N customers for clarity).\
**Business Value**: Identifies top revenue-generating customers for retention focus.\
**SQL Query**:

```sql
SELECT 
    Client_Num, 
    SUM(Total_Revenue) AS Total_Customer_Revenue
FROM transaction_detail
GROUP BY Client_Num
ORDER BY Total_Customer_Revenue DESC
LIMIT 20;  -- Limit to top 20 for visualization.
```

**Visualization Setup**: Bar chart; x-axis: `Client_Num`; y-axis: `Total_Customer_Revenue`; filter to top 20.

