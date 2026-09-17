--==================================================================
-- Customer Conversion and Churn Analysis: RavenStack SaaS Startup
-- SQL Queries 
-- Author : Wejdan Alakaleek
--==================================================================
--==================================================================
--Step1 : Creating the database
--==================================================================
Create DATABASE RavenStack_Startup; 
USE RavenStack_Startup
--==================================================================
--==================================================================
--Step 2 : Import CSV files
--==================================================================
--Imported 5 CSV files: ravenstack_accounts, ravenstack_churn_events, ravenstack_feature_usage, ravenstack_subscriptions, ravenstack_support_tickets 
SELECT *
FROM accounts
--==================================================================
--==================================================================
--Step 3: Define Relationships: Connect the tables using primary and foreign keys
--==================================================================
ALTER TABLE accounts ADD CONSTRAINT PK_Accounts PRIMARY KEY (account_id);
ALTER TABLE subscriptions ADD CONSTRAINT PK_Subscriptions PRIMARY KEY (subscription_id);
ALTER TABLE churn_events ADD CONSTRAINT PK_Churn_events PRIMARY KEY (churn_event_id);
ALTER TABLE support_tickets ADD CONSTRAINT PK_Support_tickets PRIMARY KEY (ticket_id);
ALTER TABLE subscriptions ADD CONSTRAINT FK_Sub_Account FOREIGN KEY (account_id) REFERENCES accounts (account_id);
ALTER TABLE churn_events ADD CONSTRAINT FK_Churn_Account FOREIGN KEY (account_id) REFERENCES accounts (account_id);
ALTER TABLE support_tickets ADD CONSTRAINT FK_Support_Account FOREIGN KEY (account_id) REFERENCES accounts (account_id);
Add Auto incremeting PK to the feature_usage to handel the non-unigq source  
Alter TABLE feature_usage ADD auto_feature_id INT IDENTITY (1,1) PRIMARY KEY;
ALTER TABLE feature_usage ADD CONSTRAINT FK_Sub_Feature FOREIGN KEY (subscription_id) REFERENCES subscriptions (subscription_id);
SELECT*
FROM feature_usage
--==================================================================
--==================================================================
--Step 4: Data Cleaning 
--==================================================================
-- 4.1 Fixing type of data 
--Fixing subscriptions table
ALTER TABLE subscriptions
ALTER COLUMN mrr_amount DECIMAL (10,2) NOT NULL
ALTER TABLE subscriptions
ALTER COLUMN arr_amount DECIMAL (10,2) NOT NULL

--Fixing churn_events table
ALTER TABLE churn_events 
ALTER COLUMN refund_amount_usd DECIMAL (10,2) NOT NULL 

-- 4.2 Duplicates 
--Checking for dupplicates values in accounts Table 
;
WITH duplicate_cte AS 
(SELECT *,
ROW_NUMBER () OVER (PARTITION BY account_id, account_name, industry 
ORDER BY account_id) AS row_num
FROM accounts)
SELECT *
FROM duplicate_cte
WHERE row_num > 1

--Checking for dupplicates values in subscriptions table
WITH duplicate_cte AS 
(SELECT *,
ROW_NUMBER () OVER (PARTITION BY subscription_id, [start_date], end_date
ORDER BY subscription_id) AS row_num
FROM subscriptions)
SELECT *
FROM duplicate_cte
WHERE row_num > 1

--Checking for dupplicates values in churn_events Table 
WITH duplicate_cte AS 
(SELECT *,
ROW_NUMBER () OVER (PARTITION BY churn_event_id, churn_date, reason_code 
ORDER BY churn_event_id) AS row_num
FROM churn_events)
SELECT *
FROM duplicate_cte
WHERE row_num > 1

--Checking for dupplicates values in feature_usage Table 
WITH duplicate_cte AS 
(SELECT *,
ROW_NUMBER () OVER (PARTITION BY usage_id, auto_feature_id
ORDER BY auto_feature_id) AS row_num
FROM feature_usage)
SELECT *
FROM duplicate_cte
WHERE row_num > 1

--Checking for dupplicates values in support_tickets Table
WITH duplicate_cte AS 
(SELECT *,
ROW_NUMBER () OVER (PARTITION BY ticket_id, submitted_at, closed_at
ORDER BY ticket_id) AS row_num
FROM support_tickets)
SELECT *
FROM duplicate_cte
WHERE row_num > 1

--4.3 Checking Null Value
--Checking some fields have zero NULLs
SELECT 
SUM(CASE WHEN account_name IS NULL THEN 1 ELSE 0 END) AS missing_account_name,
SUM(CASE WHEN signup_date IS NULL THEN 1 ELSE 0 END) AS missing_signup_date
FROM accounts;

SELECT 
SUM(CASE WHEN [start_date] IS NULL THEN 1 ELSE 0 END) AS missing_start_date,
SUM(CASE WHEN mrr_amount IS NULL THEN 1 ELSE 0 END) AS missing_mrr
FROM subscriptions;

--Data Profilling: Checking for NULL values in tables that have columns defined to allow NULL values 
SELECT 'subscriptions' AS Table_name,'end_date' AS column_name, COUNT(*) AS null_count 
FROM subscriptions WHERE end_date IS NULL
SELECT 'churn_events' AS Table_name,'feedback_text' AS column_name, COUNT(*) AS null_count 
FROM churn_events WHERE feedback_text IS NULL
SELECT 'support_tickets' AS Table_name,'satisfaction_score' AS column_name, COUNT(*) AS null_count 
FROM support_tickets WHERE satisfaction_score IS NULL

--Fixing nulls in the churn_event table
UPDATE churn_events
SET feedback_text = 'No feedback provided'
WHERE feedback_text IS NULL;

--4.4 Audit some columns to spot casing or whightspace 
SELECT DISTINCT referral_source
FROM accounts
SELECT DISTINCT plan_tier
FROM subscriptions

--Standardize values 
UPDATE accounts
SET plan_tier  = UPPER(LEFT(TRIM(plan_tier), 1)) + LOWER(SUBSTRING(TRIM(plan_tier), 2, LEN(plan_tier)))
UPDATE subscriptions
SET billing_frequency = UPPER(LEFT(TRIM(billing_frequency), 1)) + LOWER(SUBSTRING(TRIM(billing_frequency), 2, LEN(billing_frequency)))

UPDATE feature_usage
SET feature_name = UPPER(LEFT(TRIM(feature_name), 1)) + LOWER(SUBSTRING(TRIM(feature_name), 2, LEN(feature_name)))

UPDATE support_tickets
SET [priority] = UPPER(LEFT(TRIM([priority]), 1)) + LOWER(SUBSTRING(TRIM([priority]), 2, LEN([priority])))

UPDATE churn_events
SET reason_code  = UPPER(LEFT(TRIM(reason_code), 1)) + LOWER(SUBSTRING(TRIM(reason_code), 2, LEN(reason_code))),
    feedback_text  = UPPER(LEFT(TRIM(feedback_text), 1)) + LOWER(SUBSTRING(TRIM(feedback_text), 2, LEN(feedback_text)))
WHERE feedback_text IS NOT NULL 
AND feedback_text<> 'No feedback provided';

SELECT priority
FROM support_tickets
--==================================================================



--==================================================================
--Step 5: Join quaries 
--==================================================================
--Join Accounts, Subscriptions and Churn: customer life-cycle
SELECT 
a.account_id,
a.account_name,
a.industry,
a.referral_source,
a.is_trial,
a.churn_flag,
s.plan_tier,
s.mrr_amount,
c.reason_code AS churn_reason,
c.refund_amount_usd 
FROM accounts a 
LEFT JOIN subscriptions s ON a.account_id = s.account_id
LEFT JOIN churn_events c ON a.account_id = c.account_id

----Join Accounts and support_tickets
SELECT 
a.account_id,
a.account_name,
st.ticket_id,
st.resolution_time_hours,
st.[priority],
st.satisfaction_score
FROM accounts a 
LEFT JOIN support_tickets st ON a.account_id = st.account_id
use RavenStack_Startup
----==================================================================
----Step 6: Exploratory Data Analysis (EDA)  
----==================================================================
----5.1 Explore conversion baseline
----how many trial accounts converted vs remained in trial/paid status?
SELECT 
   is_trial,
   COUNT(account_id) AS total_account
FROM accounts
GROUP BY is_trial

----5.2 Explore churn baseline
----what are the churn reasons and refund amounts
SELECT 
   reason_code,
   SUM(refund_amount_usd) AS total_refund_usd
FROM churn_events
GROUP BY reason_code
ORDER BY total_refund_usd DESC; 

----5.3 Explore support performance
----how does support ticket volum, average resolution time, users satisfaction vary across priory level?

SELECT 
   priority,
   COUNT(ticket_id) AS total_tickets,
   AVG(resolution_time_hours) AS total_resolution_time,
   AVG(satisfaction_score) AS avg_satisfaction
FROM support_tickets
GROUP BY priority
ORDER BY total_tickets DESC; 


