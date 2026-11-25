\# E-commerce Sales Analysis | 2024–2025



An end-to-end data analytics project analysing two years of e-commerce transactional data to evaluate sales performance, customer behaviour, product profitability, marketing acquisition channels, and operational efficiency.



\*\*Tools:\*\* Python | Pandas | NumPy | MySQL | SQL | Power BI



\## 1. Business Overview



This project analyses an e-commerce business using four datasets: orders, order items, products, and customers.



The objective is to transform raw transactional data into meaningful business insights through data cleaning, exploratory analysis, SQL querying, KPI development, and interactive Power BI dashboards.



The analysis covers January 2024 to December 2025.



\## 2. Tools \& Technologies



| Tool | Application |

|---|---|

| Python | Data cleaning and exploratory analysis |

| Pandas \& NumPy | Data manipulation and preprocessing |

| Jupyter Notebook | Analysis and documentation |

| MySQL | Database management and SQL analysis |

| Power BI | Interactive dashboards and visualization |

| Excel / CSV | Data storage and preparation |



\## 3. Project Workflow



\### Phase 1: Data Cleaning \& Preparation

\- Imported and inspected four original datasets.

\- Identified and removed 38 duplicate order rows.

\- Standardized inconsistent product category names.

\- Investigated missing transaction prices.

\- Created cleaned datasets for analysis.

\- Flagged missing-price records rather than estimating transaction values.



\### Phase 2: Exploratory Data Analysis (EDA)

\- Analysed sales and revenue trends.

\- Examined customer purchasing patterns.

\- Evaluated product and category performance.

\- Investigated customer acquisition channels.

\- Analysed order outcomes, discounts, and payment methods.



\### Phase 3: SQL Analysis

\- Imported cleaned datasets into MySQL.

\- Created analytical views.

\- Developed SQL queries for business performance analysis.

\- Calculated revenue, profitability, customer, and operational KPIs.



\### Phase 4: Power BI Dashboard

\- Connected MySQL analytical data to Power BI.

\- Developed data relationships and a calendar table.

\- Created KPI cards and interactive visualizations.

\- Analysed revenue trends, customer behaviour, products, acquisition channels, and payment methods.



\## 4. Key Business Performance Metrics



| KPI | Result |

|---|---:|

| Net Revenue | $1,858,121 |

| Gross Profit | $914,173 |

| Gross Profit Margin | 49.2% |

| Revenue Growth (2025 vs 2024) | 20.9% |

| Completed Orders | 8,456 |

| Priced Completed Orders | 8,397 |

| Average Order Value | $221 |

| Return Rate | 4.4% |

| Cancellation Rate | 3.7% |

| Repeat Buyers | 64% |



\*Revenue includes completed orders with available transaction prices, net of discounts. Gross profit uses product unit cost.\*



\## 5. Key Business Insights



\### Sales Performance

\- Revenue increased by 20.9% from 2024 to 2025.

\- Completed order volume increased by 18%.

\- Q4 2025 recorded the highest quarterly revenue at $300K.

\- November was the strongest month, with $127.2K revenue in 2025.

\- November and December contributed 21.7% of total revenue.



\### Product \& Category Performance

\- Furniture generated the highest category revenue at $318.6K.

\- Furniture also recorded the highest return rate at 10.5%.

\- Storage achieved the highest gross margin at 55.6%.

\- The top 10 products accounted for 23.6% of total revenue.

\- Cotton Patio Chair was the leading product, generating $66.6K.



\### Customer \& Acquisition Analysis

\- 3,600 customers registered, with 2,047 making at least one purchase.

\- 64% of buyers made repeat purchases.

\- Referral customers recorded the highest revenue per buyer at $1,095.

\- Referral also achieved the highest repeat purchase rate at 73.4%.

\- Organic search contributed 41% of revenue.

\- Paid social customers had the lowest revenue per buyer at $644.



\### Discount Analysis

\- Approximately 15% of orders used discount codes.

\- HOLIDAY20 was the most frequently used discount code.

\- HOLIDAY20 orders recorded the lowest gross margin at 38.0%.

\- Orders without discount codes achieved a 50.4% gross margin.



\### Operational Analysis

\- 91.8% of orders were completed.

\- Returns removed $114.7K of potential revenue.

\- Cancellations removed $74.5K of potential revenue.

\- Credit cards contributed 57% of revenue.

\- Apple Pay recorded the lowest return rate at 3.3%.



\## 6. Business Recommendations



1\. \*\*Reduce Furniture Returns:\*\* Investigate product descriptions, sizing, assembly instructions, and potential damage issues.

2\. \*\*Optimize Marketing Channels:\*\* Rebalance paid social spending and test increased investment in organic search and referrals.

3\. \*\*Expand Referral Marketing:\*\* Introduce referral incentives to attract high-value, repeat customers.

4\. \*\*Improve Discount Strategy:\*\* Review HOLIDAY20 and test minimum basket requirements or smaller discounts.

5\. \*\*Prepare for Seasonal Demand:\*\* Align inventory, staffing, and campaigns with the November–December sales peak.

6\. \*\*Improve Customer Conversion:\*\* Develop targeted campaigns for registered customers who have not purchased.

7\. \*\*Improve Data Quality:\*\* Address missing transaction prices at the source.



\## 7. Data Quality \& Limitations



\- Removed 38 duplicate order rows.

\- Standardized product categories into eight categories.

\- Identified 199 order lines with missing unit prices (1.27%).

\- Excluded missing-price records from revenue calculations rather than estimating transaction values.

\- All orders, items, products, and customers were successfully linked.

\- Marketing spend was unavailable, so acquisition cost and return on ad spend could not be calculated.

\- Profit calculations exclude shipping, payment fees, and overheads.



\## 8. Project Structure



```text

ecommerce-sales-analysis/

│

├── data/

│   ├── customers.csv

│   ├── customers\_clean.csv

│   ├── orders.csv

│   ├── orders\_clean.csv

│   ├── order\_items.csv

│   ├── order\_items\_clean.csv

│   ├── products.csv

│   └── products\_clean.csv

│

├── python/

│   └── e-commerce sales.ipynb

│

├── sql/

│   └── sql.sql

│

├── powerbi/

│   └── dash.pbix

│

├── screenshots/

│

├── report/

│   └── E-commerce Sales Business Report, 2024–2025.docx

│

├── README.md

└── .gitignore

```



\## 9. Dashboard Preview



Explore the Power BI dashboard screenshots in the `screenshots/` folder.



Open the `.pbix` file in Power BI Desktop to explore the interactive dashboard.



\## 10. Skills Demonstrated



\- Data Cleaning \& Preprocessing

\- Exploratory Data Analysis

\- Python \& Pandas

\- SQL \& MySQL

\- Data Modeling

\- Power BI Dashboard Development

\- Business KPI Development

\- Customer Segmentation

\- Revenue \& Profitability Analysis

\- Business Intelligence

\- Data Visualization

\- Analytical Problem Solving



\---



\*\*Project developed by Fathima Hiba N M\*\*  

Data Analytics Portfolio | 2026

