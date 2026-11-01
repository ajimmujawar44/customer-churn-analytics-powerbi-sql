-- ============================================================
-- 05_customer_segmentation_risk_tiers.sql   (works unchanged on SQL Server and MySQL 8.0+)
-- Risk tiers, the at-risk call list, revenue at risk, and what-if savings (Page 3 of the dashboard).
-- Risk tiers: High Risk = churn score 70+, Medium = 40-69, Low = below 40 (my cut-offs, not from the source data).
-- ============================================================
-- If you use SQL Server run:  USE ChurnDB;     If you use MySQL run:  USE churn_db;

-- Q1. Active customers by risk tier                  -- High 950 | Medium 2545 | Low 1679   (total 5174)
SELECT RiskTier, COUNT(*) AS active_customers,
       ROUND(SUM(AnnualRevenue), 0) AS annual_revenue
FROM clean_customers
WHERE ChurnFlag = 0
GROUP BY RiskTier
ORDER BY active_customers;

-- Q2. Does the score separate churners? Churned customers by tier   -- High 1609 | Medium 260 | Low 0
SELECT RiskTier, COUNT(*) AS customers, SUM(ChurnFlag) AS churned
FROM clean_customers
GROUP BY RiskTier
ORDER BY churned DESC;

-- Q3. Revenue at risk by contract (active customers with score 70+)
--     Month-to-month 415 customers / 308821 | Two year 306 / 218021 | One year 229 / 163969   (total 950 / 690811)
SELECT Contract, COUNT(*) AS at_risk_customers,
       ROUND(SUM(AnnualRevenue), 0) AS annual_revenue_at_risk
FROM clean_customers
WHERE AtRiskActive = 1
GROUP BY Contract
ORDER BY annual_revenue_at_risk DESC;

-- Q4. Priority call list: top 20 at-risk customers by lifetime value (ROW_NUMBER)
--     Top row: 7622-FWGEW, Costa Mesa, Two year, CLTV 6500
WITH ranked AS (
    SELECT CustomerID, City, Contract, TenureMonths, MonthlyCharges, ChurnScore, CLTV,
           ROW_NUMBER() OVER (ORDER BY CLTV DESC, CustomerID) AS priority_rank
    FROM clean_customers
    WHERE AtRiskActive = 1
)
SELECT priority_rank, CustomerID, City, Contract, TenureMonths, MonthlyCharges, ChurnScore, CLTV
FROM ranked
WHERE priority_rank <= 20
ORDER BY priority_rank;

-- Q5. Value tiers inside the at-risk group with NTILE (P1 = top 25% by lifetime value)
WITH tiered AS (
    SELECT CustomerID, CLTV, AnnualRevenue,
           NTILE(4) OVER (ORDER BY CLTV DESC) AS priority_tier
    FROM clean_customers
    WHERE AtRiskActive = 1
)
SELECT priority_tier, COUNT(*) AS customers,
       ROUND(AVG(CLTV), 0) AS avg_cltv,
       ROUND(SUM(AnnualRevenue), 0) AS annual_revenue_at_risk
FROM tiered
GROUP BY priority_tier
ORDER BY priority_tier;

-- Q6. What-if: revenue recovered if churn falls by 5 / 10 / 15 / 20 percent
--     83479 | 166957 | 250436 | 333914   (same as the Potential Savings card)
WITH lost AS (
    SELECT SUM(AnnualRevenue) AS annual_revenue_lost
    FROM clean_customers
    WHERE ChurnFlag = 1
), scenarios AS (
    SELECT 0.05 AS reduction UNION ALL SELECT 0.10 UNION ALL SELECT 0.15 UNION ALL SELECT 0.20
)
SELECT ROUND(reduction * 100, 0) AS churn_reduction_pct,
       ROUND(annual_revenue_lost * reduction, 0) AS revenue_recovered
FROM lost CROSS JOIN scenarios
ORDER BY reduction;
