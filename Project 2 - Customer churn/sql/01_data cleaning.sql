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
        - complains - binary status (1 - complains, 0 - does not complain)
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

-- 3. Changing flags for binary data types

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

UPDATE dbo.churn_staging
SET complains = 'complaints not received'
WHERE complains = '0'

UPDATE dbo.churn_staging
SET complains = 'complaints received'
WHERE complains = '1'

-- 4. Checking for null values

-- True nulls

SELECT
    COUNT(*) AS total_rows,
    (COUNT(*) - COUNT(call_failure)) * 100.0 / COUNT(*) as missing_call_failure_pct,
    (COUNT(*) - COUNT(complains)) * 100.0 / COUNT(*) as missing_complains_pct,
    (COUNT(*) - COUNT(subscription_length)) * 100.0 / COUNT(*) as missing_subscription_length_pct,
    (COUNT(*) - COUNT(charge_amount)) * 100.0 / COUNT(*) as missing_charge_amount_pct,
    (COUNT(*) - COUNT(seconds_of_use)) * 100.0 / COUNT(*) as missing_seconds_of_use_pct,
    (COUNT(*) - COUNT(frequency_of_use)) * 100.0 / COUNT(*) as missing_frequency_of_use_pct,
    (COUNT(*) - COUNT(frequency_of_sms)) * 100.0 / COUNT(*) as missing_frequency_of_sms_pct,
    (COUNT(*) - COUNT(distinct_called_numbers)) * 100.0 / COUNT(*) as missing_distinct_called_numbers_pct,
    (COUNT(*) - COUNT(age_group)) * 100.0 / COUNT(*) as missing_age_group_pct,
    (COUNT(*) - COUNT(tariff_plan)) * 100.0 / COUNT(*) as missing_tariff_plan_pct,
    (COUNT(*) - COUNT([status])) * 100.0 / COUNT(*) as missing_status_pct,
    (COUNT(*) - COUNT(age)) * 100.0 / COUNT(*) as missing_age_pct,
    (COUNT(*) - COUNT(customer_value)) * 100.0 / COUNT(*) as missing_customer_value_pct,
    (COUNT(*) - COUNT(fn)) * 100.0 / COUNT(*) as missing_fn_pct,
    (COUNT(*) - COUNT(fp)) * 100.0 / COUNT(*) as missing_fp_pct,
    (COUNT(*) - COUNT(churn)) * 100.0 / COUNT(*) as missing_churn_pct
FROM dbo.churn_staging;

-- No NULLS detected in the dataset

-- Hidden nulls

SELECT
    COUNT(*) AS total_rows,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM(call_failure)))            NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_call_failure_pct,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM(complains)))               NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_complains_pct,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM(subscription_length)))     NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_subscription_length_pct,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM(charge_amount)))           NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_charge_amount_pct,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM(seconds_of_use)))          NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_seconds_of_use_pct,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM(frequency_of_use)))        NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_frequency_of_use_pct,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM(frequency_of_sms)))        NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_frequency_of_sms_pct,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM(distinct_called_numbers))) NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_distinct_called_numbers_pct,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM(age_group)))               NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_age_group_pct,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM(tariff_plan)))             NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_tariff_plan_pct,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM([status])))                NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_status_pct,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM(age)))                     NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_age_pct,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM(customer_value)))          NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_customer_value_pct,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM(fn)))                      NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_fn_pct,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM(fp)))                      NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_fp_pct,
    (COUNT(*) - COUNT(CASE WHEN UPPER(LTRIM(RTRIM(churn)))                   NOT IN ('', 'NA', '-', 'NULL') THEN 1 END)) * 100.0 / COUNT(*) AS missing_churn_pct
FROM dbo.churn_staging;

-- No hidden nulls detected

-- 5. Altering data types

-- backup copy before the changes

SELECT * INTO dbo.churn_staging_backup FROM dbo.churn_staging;

-- trial casting

SELECT
    SUM(CASE WHEN TRY_CAST(call_failure AS TINYINT)             IS NULL THEN 1 ELSE 0 END) AS call_failure_bad,
    SUM(CASE WHEN TRY_CAST(subscription_length AS TINYINT)      IS NULL THEN 1 ELSE 0 END) AS subscription_length_bad,
    SUM(CASE WHEN TRY_CAST(charge_amount AS TINYINT)            IS NULL THEN 1 ELSE 0 END) AS charge_amount_bad,
    SUM(CASE WHEN TRY_CAST(seconds_of_use AS INT)               IS NULL THEN 1 ELSE 0 END) AS seconds_of_use_bad,
    SUM(CASE WHEN TRY_CAST(frequency_of_use AS SMALLINT)        IS NULL THEN 1 ELSE 0 END) AS frequency_of_use_bad,
    SUM(CASE WHEN TRY_CAST(frequency_of_sms AS SMALLINT)        IS NULL THEN 1 ELSE 0 END) AS frequency_of_sms_bad,
    SUM(CASE WHEN TRY_CAST(distinct_called_numbers AS TINYINT)  IS NULL THEN 1 ELSE 0 END) AS distinct_called_numbers_bad,
    SUM(CASE WHEN TRY_CAST(age_group AS TINYINT)                IS NULL THEN 1 ELSE 0 END) AS age_group_bad,
    SUM(CASE WHEN TRY_CAST(age AS TINYINT)                      IS NULL THEN 1 ELSE 0 END) AS age_bad,
    SUM(CASE WHEN TRY_CAST(customer_value AS DECIMAL(10,4))     IS NULL THEN 1 ELSE 0 END) AS customer_value_bad,
    SUM(CASE WHEN TRY_CAST(fn AS DECIMAL(10,4))                 IS NULL THEN 1 ELSE 0 END) AS fn_bad,
    SUM(CASE WHEN TRY_CAST(fp AS DECIMAL(10,4))                 IS NULL THEN 1 ELSE 0 END) AS fp_bad
FROM dbo.churn_staging;

-- no errors detected

ALTER TABLE dbo.churn_staging ALTER COLUMN call_failure            TINYINT       NULL;
ALTER TABLE dbo.churn_staging ALTER COLUMN subscription_length     TINYINT       NULL;
ALTER TABLE dbo.churn_staging ALTER COLUMN charge_amount           TINYINT       NULL;
ALTER TABLE dbo.churn_staging ALTER COLUMN seconds_of_use          INT           NULL;
ALTER TABLE dbo.churn_staging ALTER COLUMN frequency_of_use        SMALLINT      NULL;
ALTER TABLE dbo.churn_staging ALTER COLUMN frequency_of_sms        SMALLINT      NULL;
ALTER TABLE dbo.churn_staging ALTER COLUMN distinct_called_numbers TINYINT       NULL;
ALTER TABLE dbo.churn_staging ALTER COLUMN age_group               TINYINT       NULL;
ALTER TABLE dbo.churn_staging ALTER COLUMN age                     TINYINT       NULL;
ALTER TABLE dbo.churn_staging ALTER COLUMN customer_value          DECIMAL(10,4) NULL;
ALTER TABLE dbo.churn_staging ALTER COLUMN fn                      DECIMAL(10,4) NULL;
ALTER TABLE dbo.churn_staging ALTER COLUMN fp                      DECIMAL(10,4) NULL;

SELECT column_name, data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'churn_staging'

-- Data type change was successful

-- 6. Checking for duplicates values

