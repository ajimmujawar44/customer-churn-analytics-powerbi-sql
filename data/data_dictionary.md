# Data Dictionary

**File:** `data/cleaned/telco_churn_cleaned.csv`
**Rows:** 7,043 (one row per customer) | **Columns:** 35 | **Source:** IBM Telco Customer Churn sample dataset (via Kaggle)
**Currency:** US dollars | **Region:** California | **Missing values after cleaning:** 0

The dataset is a single snapshot with no date column. `Source` below shows whether a column comes from the original file or was added during cleaning.

## Columns

### Customer and location

| # | Column | Type | Description | Values / range | Source |
|---|---|---|---|---|---|
| 1 | `CustomerID` | Text | Unique customer identifier (primary key) | 7,043 unique values, for example 3668-QPYBK | Original |
| 2 | `City` | Text | City where the customer lives | 1,129 cities | Original |
| 3 | `ZipCode` | Text | Zip code. Treat as text, never sum it | 1,652 unique, 90001 to 96161 | Original |
| 4 | `Latitude` | Decimal | Latitude of the zip code location | 32.555828 to 41.962127 | Original |
| 5 | `Longitude` | Decimal | Longitude of the zip code location | -124.301372 to -114.192901 | Original |

### Demographics

| # | Column | Type | Description | Values / range | Source |
|---|---|---|---|---|---|
| 6 | `Gender` | Text | Customer gender | Female, Male | Original |
| 7 | `SeniorCitizen` | Text | Whether the customer is a senior citizen | Yes, No | Original |
| 8 | `Partner` | Text | Whether the customer has a partner | Yes, No | Original |
| 9 | `Dependents` | Text | Whether the customer has dependents | Yes, No | Original |

### Account and services

| # | Column | Type | Description | Values / range | Source |
|---|---|---|---|---|---|
| 10 | `TenureMonths` | Whole number | Months the customer has been with the company | 0 to 72 | Original |
| 11 | `PhoneService` | Text | Has phone service | Yes, No | Original |
| 12 | `MultipleLines` | Text | Has more than one phone line | Yes, No, No phone service | Original |
| 13 | `InternetService` | Text | Type of internet service | DSL, Fiber optic, No | Original |
| 14 | `OnlineSecurity` | Text | Has the online security add-on | Yes, No, No internet service | Original |
| 15 | `OnlineBackup` | Text | Has the online backup add-on | Yes, No, No internet service | Original |
| 16 | `DeviceProtection` | Text | Has device protection | Yes, No, No internet service | Original |
| 17 | `TechSupport` | Text | Has the tech support add-on | Yes, No, No internet service | Original |
| 18 | `StreamingTV` | Text | Uses internet streaming TV | Yes, No, No internet service | Original |
| 19 | `StreamingMovies` | Text | Uses internet streaming movies | Yes, No, No internet service | Original |
| 20 | `Contract` | Text | Contract type | Month-to-month, One year, Two year | Original |
| 21 | `PaperlessBilling` | Text | Receives paperless bills | Yes, No | Original |
| 22 | `PaymentMethod` | Text | How the customer pays | Electronic check, Mailed check, Bank transfer (automatic), Credit card (automatic) | Original |

### Charges

| # | Column | Type | Description | Values / range | Source |
|---|---|---|---|---|---|
| 23 | `MonthlyCharges` | Decimal | Amount charged each month, in USD | 18.25 to 118.75 | Original |
| 24 | `TotalCharges` | Decimal | Total billed over the customer's lifetime, in USD. Set to 0 for the 11 customers with 0 months of tenure (they were blank in the raw file) | 0 to 8,684.80 | Original (cleaned) |

### Churn

| # | Column | Type | Description | Values / range | Source |
|---|---|---|---|---|---|
| 25 | `ChurnLabel` | Text | Whether the customer left | Yes, No | Original |
| 26 | `ChurnFlag` | Whole number | Numeric version of `ChurnLabel`. Use it for counting and averages | 1 = churned (1,869), 0 = stayed (5,174) | Original (renamed from Churn Value) |
| 27 | `ChurnScore` | Whole number | Churn risk score provided in the source data (higher means more likely to churn). It was not calculated in this project | 5 to 100 | Original |
| 28 | `CLTV` | Whole number | Customer lifetime value provided in the source data, used to rank customers by value | 2,003 to 6,500 | Original |
| 29 | `ChurnReason` | Text | Reason given for leaving. `Not Churned` for customers who stayed | 20 reasons plus Not Churned. Top: Attitude of support person (192), Competitor offered higher download speeds (189), Competitor offered more data (162) | Original (blanks filled) |

### Added during cleaning

| # | Column | Type | Description | Logic | Values |
|---|---|---|---|---|---|
| 30 | `TenureBand` | Text | Tenure group | `TenureMonths` 0-12, 13-24, 25-48, 49 and above | 0-12 Months, 13-24 Months, 25-48 Months, 49+ Months |
| 31 | `TenureBandSort` | Whole number | Sort order for `TenureBand` (use Sort by column in Power BI) | 1 to 4 in the order above | 1, 2, 3, 4 |
| 32 | `AnnualRevenue` | Decimal | Estimated yearly revenue from the customer, in USD | `MonthlyCharges` × 12 | 219 to 1,425 |
| 33 | `RiskTier` | Text | Risk group from `ChurnScore` | 70 or more = High Risk, 40 to 69 = Medium Risk, below 40 = Low Risk | High Risk, Medium Risk, Low Risk |
| 34 | `MonthlyChargeBand` | Text | Price group | 35 or less = Low, over 35 to 70 = Medium, over 70 to 100 = High, over 100 = Premium | Low (<=35), Medium (35-70), High (70-100), Premium (>100) |
| 35 | `AtRiskActive` | Whole number | Flags active customers with a high churn score | 1 if `ChurnFlag` = 0 and `ChurnScore` >= 70, otherwise 0 | 1 = at risk (950 customers), 0 = other |

## Columns removed from the raw file

| Raw column | Reason |
|---|---|
| `Count` | Always 1 |
| `Country` | Always United States |
| `State` | Always California |
| `Lat Long` | Duplicate of `Latitude` and `Longitude` |

## Renamed columns (raw name to cleaned name)

`Zip Code` → `ZipCode`, `Senior Citizen` → `SeniorCitizen`, `Tenure Months` → `TenureMonths`, `Phone Service` → `PhoneService`, `Multiple Lines` → `MultipleLines`, `Internet Service` → `InternetService`, `Online Security` → `OnlineSecurity`, `Online Backup` → `OnlineBackup`, `Device Protection` → `DeviceProtection`, `Tech Support` → `TechSupport`, `Streaming TV` → `StreamingTV`, `Streaming Movies` → `StreamingMovies`, `Paperless Billing` → `PaperlessBilling`, `Payment Method` → `PaymentMethod`, `Monthly Charges` → `MonthlyCharges`, `Total Charges` → `TotalCharges`, `Churn Label` → `ChurnLabel`, `Churn Value` → `ChurnFlag`, `Churn Score` → `ChurnScore`, `Churn Reason` → `ChurnReason`.

## Notes
- **"No internet service" and "No phone service"** are kept as separate values. These customers do not have the service at all, which is different from having it and answering "No".
- **Currency:** all amounts are in US dollars.
- **Map locations** are zip-code coordinates, so many customers share the same point.
- **Risk tier cut-offs** (70 and 40) and the **price bands** are my own choices, not part of the source data.
- Source terms: check the original publisher's terms before reusing the data.
