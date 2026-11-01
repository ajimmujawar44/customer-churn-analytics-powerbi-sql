-- ============================================================
-- 02_data_cleaning.sql   (SQL Server / T-SQL)
-- Builds clean_customers from raw_telco_churn. The raw table is never changed.
-- Fixes: blank Total Charges (11 rows, tenure 0 -> 0), empty Churn Reason -> 'Not Churned',
--        constant columns dropped (Count, Country, State, LatLong), text trimmed, types set.
-- Adds : TenureBand, TenureBandSort, AnnualRevenue, RiskTier, MonthlyChargeBand, AtRiskActive
-- ============================================================
USE ChurnDB;
GO

-- ---------- 1. Data quality checks on the RAW table ----------
SELECT COUNT(*)                         AS raw_rows,                         -- expect 7043
       COUNT(DISTINCT CustomerID)       AS distinct_customers                -- expect 7043 (no duplicates)
FROM raw_telco_churn;

SELECT COUNT(*) AS blank_total_charges                                       -- expect 11
FROM raw_telco_churn
WHERE LTRIM(RTRIM(TotalCharges)) = '';

SELECT DISTINCT TenureMonths                                                 -- expect only 0
FROM raw_telco_churn
WHERE LTRIM(RTRIM(TotalCharges)) = '';

SELECT COUNT(*) AS label_mismatch                                            -- expect 0
FROM raw_telco_churn
WHERE (ChurnLabel = 'Yes' AND ChurnFlag <> '1') OR (ChurnLabel = 'No' AND ChurnFlag <> '0');
GO

-- ---------- 2. Build the cleaned table ----------
DROP TABLE IF EXISTS clean_customers;
GO

WITH typed AS (
    SELECT
        LTRIM(RTRIM(CustomerID)) AS CustomerID,
        LTRIM(RTRIM(City)) AS City,
        LTRIM(RTRIM(ZipCode)) AS ZipCode,
        CAST(Latitude AS DECIMAL(9,6)) AS Latitude,
        CAST(Longitude AS DECIMAL(9,6)) AS Longitude,
        LTRIM(RTRIM(Gender)) AS Gender,
        LTRIM(RTRIM(SeniorCitizen)) AS SeniorCitizen,
        LTRIM(RTRIM(Partner)) AS Partner,
        LTRIM(RTRIM(Dependents)) AS Dependents,
        CAST(TenureMonths AS INT) AS TenureMonths,
        LTRIM(RTRIM(PhoneService)) AS PhoneService,
        LTRIM(RTRIM(MultipleLines)) AS MultipleLines,
        LTRIM(RTRIM(InternetService)) AS InternetService,
        LTRIM(RTRIM(OnlineSecurity)) AS OnlineSecurity,
        LTRIM(RTRIM(OnlineBackup)) AS OnlineBackup,
        LTRIM(RTRIM(DeviceProtection)) AS DeviceProtection,
        LTRIM(RTRIM(TechSupport)) AS TechSupport,
        LTRIM(RTRIM(StreamingTV)) AS StreamingTV,
        LTRIM(RTRIM(StreamingMovies)) AS StreamingMovies,
        LTRIM(RTRIM(Contract)) AS Contract,
        LTRIM(RTRIM(PaperlessBilling)) AS PaperlessBilling,
        LTRIM(RTRIM(PaymentMethod)) AS PaymentMethod,
        CAST(MonthlyCharges AS DECIMAL(10,2)) AS MonthlyCharges,
        COALESCE(TRY_CAST(NULLIF(LTRIM(RTRIM(TotalCharges)),'') AS DECIMAL(10,2)), 0) AS TotalCharges,
        LTRIM(RTRIM(ChurnLabel)) AS ChurnLabel,
        CAST(ChurnFlag AS INT) AS ChurnFlag,
        CAST(ChurnScore AS INT) AS ChurnScore,
        CAST(CLTV AS INT) AS CLTV,
        COALESCE(NULLIF(LTRIM(RTRIM(ChurnReason)),''),'Not Churned') AS ChurnReason
    FROM raw_telco_churn
)
SELECT
    CustomerID, City, ZipCode, Latitude, Longitude, Gender, SeniorCitizen, Partner, Dependents,
    TenureMonths, PhoneService, MultipleLines, InternetService, OnlineSecurity, OnlineBackup,
    DeviceProtection, TechSupport, StreamingTV, StreamingMovies, Contract, PaperlessBilling,
    PaymentMethod, MonthlyCharges, TotalCharges, ChurnLabel, ChurnFlag, ChurnScore, CLTV, ChurnReason,
    CASE WHEN TenureMonths <= 12 THEN '0-12 Months'
         WHEN TenureMonths <= 24 THEN '13-24 Months'
         WHEN TenureMonths <= 48 THEN '25-48 Months'
         ELSE '49+ Months' END                         AS TenureBand,
    CASE WHEN TenureMonths <= 12 THEN 1
         WHEN TenureMonths <= 24 THEN 2
         WHEN TenureMonths <= 48 THEN 3
         ELSE 4 END                                    AS TenureBandSort,
    ROUND(MonthlyCharges * 12, 2)                       AS AnnualRevenue,
    CASE WHEN ChurnScore >= 70 THEN 'High Risk'
         WHEN ChurnScore >= 40 THEN 'Medium Risk'
         ELSE 'Low Risk' END                           AS RiskTier,
    CASE WHEN MonthlyCharges <= 35  THEN 'Low (<=35)'
         WHEN MonthlyCharges <= 70  THEN 'Medium (35-70)'
         WHEN MonthlyCharges <= 100 THEN 'High (70-100)'
         ELSE 'Premium (>100)' END                     AS MonthlyChargeBand,
    CASE WHEN ChurnFlag = 0 AND ChurnScore >= 70 THEN 1 ELSE 0 END AS AtRiskActive
INTO clean_customers
FROM typed;
GO

-- ---------- 3. Checks on the CLEAN table ----------
SELECT COUNT(*)                                   AS clean_rows,             -- expect 7043
       SUM(ChurnFlag)                             AS churned,                -- expect 1869
       ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct,        -- expect 26.54
       SUM(AtRiskActive)                          AS at_risk_active          -- expect 950
FROM clean_customers;

SELECT COUNT(*) AS rows_with_null_values                                     -- expect 0
FROM clean_customers
WHERE CustomerID IS NULL OR TotalCharges IS NULL OR ChurnReason IS NULL OR ChurnScore IS NULL;
