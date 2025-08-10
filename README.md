# Credit_Card_Financial_Dashboard
## Project Overview

This project delivers a comprehensive, interactive dashboard for analyzing customer behavior, revenue patterns, and transaction trends using data from `customer.csv` and `transaction_detail.csv`. The objective is to provide actionable business insights, such as identifying high-value customer segments, optimizing acquisition strategies, and tracking spending patterns over time. The dashboard leverages advanced SQL queries (featuring window functions, CTEs, and pivots) and Metabase visualizations to present data-driven findings in an accessible and impactful way.

This repository showcases my expertise in:

- Crafting complex SQL queries to extract and transform data for business analysis.
- Designing intuitive visualizations (e.g., scatter plots, area charts, heatmaps) in Metabase.
- Translating data insights into strategic recommendations for marketing, customer retention, and operational efficiency.

## Tools and Technologies

- **SQL**: Used for data extraction, transformation, and aggregation from relational datasets. Queries employ advanced techniques like `RANK()`, `PARTITION BY`, `PIVOT`, `PERCENTILE_CONT`, and `ROLLUP` for robust analysis.
- **Metabase**: Open-source business intelligence tool for creating interactive visualizations and dashboards. Selected for its seamless SQL integration, user-friendly interface, and support for charts like scatter plots, line charts, and heatmaps.
- **Datasets**:
  - `customer.csv`: Contains customer demographics (e.g., `Client_Num`, `Age_Group`, `Gender`, `Customer_Job`, `Income_Group`, `Education_Level`, `Marital_Status`, `state_cd`, `House_Owner`, `Personal_loan`, `Cust_Satisfaction_Score`).
  - `transaction_detail.csv`: Includes transaction data (e.g., `Client_Num`, `Total_Revenue`, `Total_Trans_Vol`, `Total_Trans_Amt`, `Exp_Type`, `Card_Category`, `Qtr`, `Week_Num`, `Customer_Acq_Cost`, `Activation_30_Days`, `Delinquent_Acc`, `Avg_Utilization_Ratio`, `Use_Chip`, `Interest_Earned`, `Total_Revolving_Bal`).

