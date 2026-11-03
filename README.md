## Churn Analysis: RavenStack startup (SQL and Power BI)

An end-to-end data analytics project to build churn analysis for RavenStack using SQL queries for data cleaning and EDA and an interactive Power BI dashboard for analytics and visualization. This analysis answers a main business question: What causes customer churn? Where do the operational failures occur: from lead acquisition to product experience?

---

## Project overview 

**Case study:** RavenStack is a stealth-mode SaaS startup that delivers an AI collaboration tool for teams and the tool provides basic, pro, and enterprise subscription plans. 

**Business context/ problem:** RavenStack piloted its platform and collected detailed data on every sign-up, feature interaction, support ticket, and cancellation. Before scaling and public launch, leadership needs to evaluate these pilot results to understand customer churn patterns and where failures occur.

**Analytical Approach:** This project combines a structure of two layers:

•	SQL Layer: Cleans raw customer tables, validates relationships, and executes exploratory data analysis (EDA) to calculate churn baseline.

•	Power BI Layer: Transforms SQL outputs into an interactive 3-page executive dashboard to highlight revenue risk and operational failure points for leadership.

---

## Data source
The dataset used for this project is [RavenStack: Synthetic SaaS Dataset](https://www.kaggle.com/datasets/rivalytics/saas-subscription-and-churn-analytics-dataset) published on Kaggle

•	Author: River @ Rivalytics.

•	Tables and scope: accounts (500); subscriptions (5,000); feature usage (25,000); support tickets (2,000); churn events (600)

---

## SQL Analysis

**Tool:** SQL Server Management Studio 

**File:** [`Customer_Churn_Queries.sql`](Customer_Churn_Queries.sql)  

**Analysis steps:**
I extracted, linked, cleaned and explored the raw data in SQL Server to validate data and explore initial patterns:

•	**Linking tables:** I set up primary key (PK) and foreign key (FK) relationships across accounts, subscriptions, feature_usage, support_tickets, and churn_events tables. I added a unique ID to the feature_usage table to clean up duplicate records. 

•	**Data cleaning:** I fixed data types for currency fields, checked all five tables for duplicate rows using CTEs, filled in missing feedback text with 'No feedback provided', and cleaned up inconsistent spacing and capital letters across category names.

•	**Multi-Table Integration and Analysis:** Including joining data across the customer journey. I used LEFT JOIN queries: one to merge account information, subscription revenues and churn records and another to link the account and support tickets tables to create a single, clear view of the customer life cycle

•	**Exploratory Data Analysis (EDA):** I used SELECT, COUNT, SUM, AVG, GROUP BY, and ORDER BY statements to measure baseline conversion rate and total refund amounts by churn reason, and evaluate ticket volumes, resolution times, and customer satisfaction scores across ticket priority levels. 
 
---

## Power BI dashboard**

**Tool:** Power BI Desktop

**Pages:** 3

**Data model:** Star-schema style relationship between 5 tables: accounts, subscriptions, feature usage, support tickets, churn events, with 10 custom DAX measures.

**Page 1: Executive Overview: acquisition leak** 
Tracks key metrics: Trial Conversion (80.60%), Active ARR ($86.05M), ARR Loss Rate (24.72%), ARPU ($22.55K), and Churn Rate (22.00%). 
•	Main question: Where in the sales funnel is the startup losing revenue, and which customer acquisition channels bring in the highest-risk accounts?

 ![Executive Overview](assets/executive_overview.jpg)

**Page 2: Revenue impact & Churn drivers: financial bleed**

Sorts the financial impact by subscription plan, location, and why customers left. Since some customers listed multiple reasons for leaving, the data was cleaned up so each customer was only counted once. Accounts that didn't give a reason are labeled as 'Unspecified'.
•	Main question: How much money ($ ARR) is this startup losing, which customer plan tiers and geographic markets are bleeding the most, and what reasons are customers giving when they cancel?
 
 ![Revenue Impact & Churn Drivers](assets/revenue_impact.jpg)
 
**Page 3: Product & support friction: operational root cause**
Investigate technical support delays that lead customers to cancel.

•	Main question: which specific features are breaking, how are those product defects impacting customer support response times and CSAT, and what operational fixes will stop the churn?
 
![Product & Support Friction](assets/product_support.jpg)

---

## Key business insights and recommendations

![Key Business Insights & Actions](assets/Business_insights.jpg)


---

## Technical challenges

**•	Adding auto_feature_id:** Setting usage_id as the primary key failed because SQL Server flagged 21 duplicate IDs. However, these weren't duplicate rows; they were separate user actions from different subscriptions that accidentally shared the same ID  (due to a data-generation bug).

o	Deleting these rows would have removed usage times and error records needed for churn analysis. Instead, I added a brand-new auto-incrementing column (auto_feature_id) to serve as a primary key without losing any underlying data. I used AI as a coding assistant to research standard SQL techniques for handling duplicate IDs with unique rows


---
## Tools and Techniques 

**SQL:** SQL Server Management, SELECT, ALTER, UPDATE, ADD, WHERE, GROUP BY, ORDER BY, LEFT JOIN, COUNT, SUM, AVG, CASE WHEN, CTE (Common Table Expression).

**Power BI:** Power BI Desktop, Power Query, data modeling and table relationships, DAX measures (CALCULATE, DIVIDE, SUM, AVERAGE), KPI cards, stacked area chart, clustered bar chart, stacked column chart, clustered column chart, matrix and Line and clustered column chart. 

---

**License:** Permissive MIT-like License (Synthetic dataset, educational/portfolio use with attribution)

---
**Author** 
**Wejdan Akaleek**




