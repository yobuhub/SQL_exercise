-- 1. Conducting an overview of the collected data to identify key features and possible errors or duplicates

SELECT TOP 5 *
FROM dbo.churn

-- Investigating ranges

SELECT
    MAX(call_failure) as max_call_failure,
    MIN(call_failure) as min_call_failure,
    MAX(complains) as max_complains,
    MIN(complains) as min_complains,
    MAX(subscription_length) as max_subscription_length,
    MIN(subscription_length) as min_subscription_length,
    MAX(charge_amount) as max_charge_amount,
    MIN(charge_amount) as min_charge_amount,
    MAX(seconds_of_use) as max_seconds_of_use,
    MIN(seconds_of_use) as min_seconds_of_use,
    MAX(frequency_of_use) as max_frequency_of_use,
    MIN(frequency_of_use) as min_frequency_of_use,
    MAX(frequency_of_sms) as max_frequency_of_sms,
    MIN(frequency_of_sms) as min_frequency_of_sms,
    MAX(distinct_called_numbers) as max_distinct_called_numbers,
    MIN(distinct_called_numbers) as min_distinct_called_numbers,
    MAX(age_group) as max_age_group,
    MIN(age_group) as min_age_group,
    MAX(tariff_plan) as max_tariff_plan,
    MIN(tariff_plan) as min_tariff_plan,
    MAX([status]) as max_status,
    MIN([status]) as min_status,
    MAX(age) as max_age,
    MIN(age) as min_age,
    MAX(customer_value) as max_customer_value,
    MIN(customer_value) as min_customer_value,
    MAX(fn) as max_fn,
    MIN(fn) as min_fn,
    MAX(fp) as max_fp,
    MIN(fp) as min_fp,
    MAX(churn) as max_churn,
    MIN(churn) as min_churn
FROM dbo.churn

SELECT column_name, data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'churn'

/*
1.  Per additional information, the dataset consists of randomly collected records of an Iranian telecom company over a 12-month period
2.  Each of 3150 rows of data represent a single customer over a year period
3.  The data table consist of 16 columns, all of which are set to varchar(50)
4.  Columns consist of:
        - call failure - total number of call failures to the client (<0;9>)
        - complaints - binary status (1 - complaint, 0 - no complaint)
        - subscription length - total months of subscription (<9;10>)
        - charge amount - ordinal attribute (0: lowest, 9: highest amount)
        - second of use - total seconds of calls (<0;99>)
        - frequency of use - total number of calls (<0;99>)
        - frequency of SMS - total number of text messages to the client (<0,99>)
        - distinct called numbers - total number of distinct phone calls (<0;97>)
        - age group - ordinal attribute (1: youngest 5: oldest age)
        - tariff plan - binary (1: pay as you go, 2: contractual)
        - status - binary (1: active, 2:non-active)
        - age - age of customer  (<15;55>)
        - customer value - calculated metric (<0;999+>)
        - churn - binary (1: churn, 0: non-churn)
        - fn - false negative (<99+;100+>)
        - fp - false positive (<0;998+>)
5.  All of the attributes except for attribute churn is the aggregated data of the first 9 months. 
    The churn labels are the state of the customers at the end of 12 months. The three months is the designated planning gap.
*/

-- 2. Creating a staging table for data cleaning

SELECT *
INTO dbo.churn_staging
FROM dbo.churn

-- 3. Changing column names and flags for binary data types

-- churn

UPDATE dbo.churn_staging
SET churn = 'non-churn'
WHERE churn = '0'

UPDATE dbo.churn_staging
SET churn = 'churn'
WHERE churn = '1'

-- tariff plan

UPDATE dbo.churn_staging
SET tariff_plan = 'contractual'
WHERE tariff_plan = '2'

UPDATE dbo.churn_staging
SET tariff_plan = 'pay as you go'
WHERE tariff_plan = '1'

-- status

UPDATE dbo.churn_staging
SET [status] = 'active'
WHERE [status] = '1'

UPDATE dbo.churn_staging
SET [status] = 'non-active'
WHERE [status] = '2'

-- complains


