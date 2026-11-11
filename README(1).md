# SQL scripts

Run the scripts in numeric order. Table and view names below are the ones the Power BI model expects.

| Script | What it does |
|---|---|
| `01_create_database_and_tables.sql` | Creates the database and loads the raw file into `raw_telco_churn`. Keep this table untouched |
| `02_data_cleaning.sql` | Checks duplicates and blanks, fixes `Total Charges` (11 blanks, tenure 0, set to 0), fills `Churn Reason`, drops constant columns, renames columns, adds `TenureBand`, `AnnualRevenue`, `RiskTier`, `MonthlyChargeBand`, `AtRiskActive`. Output table: `clean_customers` |
| `03_star_schema_views.sql` | Creates the view `vw_customer_churn` that Power BI reads, plus optional dimension views |
| `04_churn_analysis_queries.sql` | Churn rate by contract, tenure, payment method, internet service, tech support, and senior citizen. Top churn reasons (CTE with RANK). City summary |
| `05_customer_segmentation_risk_tiers.sql` | Risk tiers with NTILE or CASE, the high-risk active customer list, revenue at risk by contract |

## Check your output against these numbers

| Check | Expected |
|---|---|
| Rows in `clean_customers` | 7,043 |
| Churned customers | 1,869 (26.54%) |
| Revenue lost (sum of `AnnualRevenue` where churned) | $1,669,570 |
| Blank `Total Charges` fixed | 11 |
| Churn by contract | Month-to-month 42.71%, one year 11.27%, two year 2.83% |
| Churn by tenure band | 47.44%, 28.71%, 20.39%, 9.51% |
| Top 3 churn reasons | 192, 189, 162 |
| Active customers with `AtRiskActive = 1` | 950, with $690,811 annual revenue |
| Active customers by risk tier | High 950, Medium 2,545, Low 1,679 |

Matching these numbers means the SQL, the Python check (`scripts/clean_data.py`), and the Power BI dashboard all agree.

## Notes
- Keep a comment at the top of each script saying what it does and which database you used (MySQL or SQL Server).
- Never overwrite `raw_telco_churn`. Build every later table from it.
