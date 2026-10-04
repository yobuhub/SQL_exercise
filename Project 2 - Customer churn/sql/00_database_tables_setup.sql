/* 
Project Telecom Customer Churn

Purpose : 
🗺️ Explore: Which age groups send more SMS messages than make phone calls?
📊 Visualize: Create a plot visualizing the number of distinct phone calls by age group. Within the chart, differentiate between short, medium, and long calls (by the number of seconds).
🔎 Analyze: Are there significant differences between the length of phone calls between different tariff plans?

Engine: Microsoft SQL Server, running inside a Docker container.

Data source : Iranian Churn, donated on 4/8/2020
Kaggle: https://www.kaggle.com/datasets/royjafari/customer-churn
Original dataset : https://archive.ics.uci.edu/dataset/563/iranian+churn+dataset

*/

-- 1. Creating a database

IF DB_ID('churn_telecom') IS NULL
    CREATE DATABASE churn_telecom;
GO

USE churn_telecom;
GO

-- 2. Creating a source table inside the database

IF OBJECT_ID('dbo.churn', 'U') IS NOT NULL DROP TABLE dbo.churn;

CREATE TABLE dbo.churn
(
    call_failure            VARCHAR(50),
    complains               VARCHAR(50),
    subscription_length     VARCHAR(50),
    charge_amount           VARCHAR(50),
    seconds_of_use          VARCHAR(50),
    frequency_of_use        VARCHAR(50),
    frequency_of_sms        VARCHAR(50),
    distinct_called_numbers VARCHAR(50),
    age_group               VARCHAR(50),
    tariff_plan             VARCHAR(50),
    status                  VARCHAR(50),
    age                     VARCHAR(50),
    customer_value          VARCHAR(50),
    fn                      VARCHAR(50),
    fp                      VARCHAR(50),
    churn                   VARCHAR(50)
);
GO

-- 3. Bulk inserting the data into the source table

/*
As I'm using docker alongside SQL Server, I need to upload the file to the docker container beforehand in powershell:
> docker exec sqlserver mkdir -p /var/opt/mssql/raw_data
> docker cp "C:\path\to\Customer_Churn.csv" sqlserver:/var/opt/mssql/raw_data/customer_churn.csv
> docker exec sqlserver chmod -R 755 /var/opt/mssql/raw_data
*/

TRUNCATE TABLE dbo.churn;
GO

BULK INSERT dbo.churn
FROM '/var/opt/mssql/raw_data/customer_churn.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0d0a',
    TABLOCK
);
GO

-- 4. Conducting sanity check to see if all data is uploaded properly

SELECT COUNT(*) AS churn_rows FROM dbo.churn; -- needs to return 3150 rows

SELECT TOP 5 * FROM dbo.churn; -- needs to return all 16 columns