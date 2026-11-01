-- ============================================================
-- 01_create_database_and_tables.sql   (SQL Server / T-SQL)
-- Creates the database and loads the RAW file into raw_telco_churn.
-- Every raw column is text on purpose: types are set later in 02_data_cleaning.sql.
-- Load file: data/raw/Telco_customer_churn.csv  (7,043 rows, 33 columns, header row)
-- ============================================================
IF DB_ID('ChurnDB') IS NULL CREATE DATABASE ChurnDB;
GO
USE ChurnDB;
GO

DROP TABLE IF EXISTS raw_telco_churn;
GO

CREATE TABLE raw_telco_churn (
    CustomerID         VARCHAR(100),
    Count              VARCHAR(100),
    Country            VARCHAR(100),
    State              VARCHAR(100),
    City               VARCHAR(100),
    ZipCode            VARCHAR(100),
    LatLong            VARCHAR(100),
    Latitude           VARCHAR(100),
    Longitude          VARCHAR(100),
    Gender             VARCHAR(100),
    SeniorCitizen      VARCHAR(100),
    Partner            VARCHAR(100),
    Dependents         VARCHAR(100),
    TenureMonths       VARCHAR(100),
    PhoneService       VARCHAR(100),
    MultipleLines      VARCHAR(100),
    InternetService    VARCHAR(100),
    OnlineSecurity     VARCHAR(100),
    OnlineBackup       VARCHAR(100),
    DeviceProtection   VARCHAR(100),
    TechSupport        VARCHAR(100),
    StreamingTV        VARCHAR(100),
    StreamingMovies    VARCHAR(100),
    Contract           VARCHAR(100),
    PaperlessBilling   VARCHAR(100),
    PaymentMethod      VARCHAR(100),
    MonthlyCharges     VARCHAR(100),
    TotalCharges       VARCHAR(100),
    ChurnLabel         VARCHAR(100),
    ChurnFlag          VARCHAR(100),
    ChurnScore         VARCHAR(100),
    CLTV               VARCHAR(100),
    ChurnReason        VARCHAR(100)
);
GO

-- 
BULK INSERT raw_telco_churn
FROM "D:\Agentic_Ai\customer-churn-analytics-powerbi-sql\data\raw_data\Telco_customer_churn.csv"
WITH (
    FORMAT          = 'CSV',      -- handles the quoted LatLong column (it contains a comma)
    FIELDQUOTE      = '"',
    FIRSTROW        = 2,          -- skip the header row
    FIELDTERMINATOR = ',',
    CODEPAGE        = '65001'     -- UTF-8
);
GO

SELECT COUNT(*) AS raw_rows FROM raw_telco_churn;   -- expect 7043
GO

/* If BULK INSERT fails (file permission or path error):
   Right-click ChurnDB > Tasks > Import Flat File, choose the CSV, name the table raw_telco_churn,
   and on the "Modify Columns" page rename each column to the names above (no spaces)
   and set every column to nvarchar(100). Then continue with 02_data_cleaning.sql. */
