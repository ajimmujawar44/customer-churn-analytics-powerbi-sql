-- ============================================================
-- 04_churn_analysis_queries.sql   (works unchanged on SQL Server and MySQL 8.0+)
-- Answers the business questions behind Pages 1, 2 and 4 of the dashboard.
-- Expected results are in the comments so you can check your work.
-- ============================================================
-- If you use SQL Server run:  USE ChurnDB;     If you use MySQL run:  USE churn_db;

-- Q1. Headline KPIs                                  -- 7043 | 1869 | 26.54 | 1669570 (annual revenue lost)
SELECT COUNT(*)                                        AS total_customers,
       SUM(ChurnFlag)                                  AS churned_customers,
       ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2)     AS churn_rate_pct,
       ROUND(SUM(CASE WHEN ChurnFlag = 1 THEN AnnualRevenue ELSE 0 END), 0) AS annual_revenue_lost
FROM clean_customers;

-- Q2. Churn by contract                              -- Month-to-month 42.71 | One year 11.27 | Two year 2.83
SELECT Contract, COUNT(*) AS customers, SUM(ChurnFlag) AS churned,
       ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct
FROM clean_customers
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- Q3. Churn by tenure band                           -- 47.44 | 28.71 | 20.39 | 9.51
SELECT TenureBand, COUNT(*) AS customers, SUM(ChurnFlag) AS churned,
       ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct
FROM clean_customers
GROUP BY TenureBand, TenureBandSort
ORDER BY TenureBandSort;

-- Q4. Churn by payment method                        -- Electronic check 45.29 | Mailed 19.11 | Bank transfer 16.71 | Credit card 15.24
SELECT PaymentMethod, COUNT(*) AS customers, SUM(ChurnFlag) AS churned,
       ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct
FROM clean_customers
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;

-- Q5. Churn by internet service                      -- Fiber optic 41.89 | DSL 18.96 | No 7.40
SELECT InternetService, COUNT(*) AS customers, SUM(ChurnFlag) AS churned,
       ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct
FROM clean_customers
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;

-- Q6. Churn by tech support                          -- No 41.64 | Yes 15.17 | No internet service 7.40
SELECT TechSupport, COUNT(*) AS customers, SUM(ChurnFlag) AS churned,
       ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct
FROM clean_customers
GROUP BY TechSupport
ORDER BY churn_rate_pct DESC;

-- Q7. Churn by senior citizen                        -- Yes 41.68 | No 23.61
SELECT SeniorCitizen, COUNT(*) AS customers, SUM(ChurnFlag) AS churned,
       ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 2) AS churn_rate_pct
FROM clean_customers
GROUP BY SeniorCitizen
ORDER BY churn_rate_pct DESC;

-- Q8. Contract x tenure matrix (same as the matrix on Page 2)
--     Month-to-month: 51.35 | 37.72 | 32.92 | 26.02      Two year: 0.00 | 0.00 | 2.19 | 3.33
SELECT Contract,
       ROUND(100.0 * AVG(CASE WHEN TenureBand = '0-12 Months'  THEN ChurnFlag * 1.0 END), 2) AS m_0_12,
       ROUND(100.0 * AVG(CASE WHEN TenureBand = '13-24 Months' THEN ChurnFlag * 1.0 END), 2) AS m_13_24,
       ROUND(100.0 * AVG(CASE WHEN TenureBand = '25-48 Months' THEN ChurnFlag * 1.0 END), 2) AS m_25_48,
       ROUND(100.0 * AVG(CASE WHEN TenureBand = '49+ Months'   THEN ChurnFlag * 1.0 END), 2) AS m_49_plus
FROM clean_customers
GROUP BY Contract;

-- Q9. Top 10 churn reasons (CTE + RANK)              -- 192 | 189 | 162 at the top
WITH reasons AS (
    SELECT ChurnReason, COUNT(*) AS churned_customers
    FROM clean_customers
    WHERE ChurnFlag = 1
    GROUP BY ChurnReason
), ranked AS (
    SELECT ChurnReason, churned_customers,
           RANK() OVER (ORDER BY churned_customers DESC) AS rnk
    FROM reasons
)
SELECT rnk, ChurnReason, churned_customers
FROM ranked
WHERE rnk <= 10
ORDER BY rnk;

-- Q10. Top 10 cities by churned customers            -- Los Angeles 90 | San Diego 50 | San Francisco 31 | San Jose 29 | Sacramento 26
WITH city_churn AS (
    SELECT City, COUNT(*) AS customers, SUM(ChurnFlag) AS churned,
           ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 1) AS churn_rate_pct
    FROM clean_customers
    GROUP BY City
), ranked AS (
    SELECT City, customers, churned, churn_rate_pct,
           ROW_NUMBER() OVER (ORDER BY churned DESC, City) AS rn
    FROM city_churn
)
SELECT rn, City, customers, churned, churn_rate_pct
FROM ranked
WHERE rn <= 10
ORDER BY rn;

-- Q11. City scorecard: cities with 30+ customers, highest churn rate first
--      San Diego 33.3 (150) | Glendale 32.5 (40) | Pasadena 30.0 (30) | San Francisco 29.8 (104) | Los Angeles 29.5 (305)
SELECT City, COUNT(*) AS customers, SUM(ChurnFlag) AS churned,
       ROUND(100.0 * SUM(ChurnFlag) / COUNT(*), 1) AS churn_rate_pct
FROM clean_customers
GROUP BY City
HAVING COUNT(*) >= 30
ORDER BY churn_rate_pct DESC, City;
