-- ============================================================
-- 03_star_schema_views.sql   (SQL Server / T-SQL)
-- Views for Power BI. The dashboard reads vw_customer_churn (one wide table).
-- The dimension views are optional: use them if you want to rebuild the model as a star schema.
-- ============================================================
USE ChurnDB;
GO

-- Main view used by Power BI (Home > Get Data > SQL Server/MySQL > vw_customer_churn)
CREATE OR ALTER VIEW vw_customer_churn AS
SELECT * FROM clean_customers;
GO

-- Optional dimension views
CREATE OR ALTER VIEW vw_dim_contract AS
SELECT DISTINCT Contract FROM clean_customers;
GO

CREATE OR ALTER VIEW vw_dim_payment_method AS
SELECT DISTINCT PaymentMethod FROM clean_customers;
GO

CREATE OR ALTER VIEW vw_dim_city AS
SELECT DISTINCT City, ZipCode, Latitude, Longitude FROM clean_customers;
GO

-- Active high-risk customers with a value-based priority tier (P1 = most valuable)
CREATE OR ALTER VIEW vw_high_risk_customers AS
SELECT CustomerID, City, Contract, TenureMonths, MonthlyCharges, ChurnScore, CLTV, AnnualRevenue,
       NTILE(4) OVER (ORDER BY CLTV DESC) AS PriorityTier
FROM clean_customers
WHERE AtRiskActive = 1;
GO
