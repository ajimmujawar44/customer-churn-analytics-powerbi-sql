# DAX Measures

All measures are in a table called `_Measures`. The data model has a single table, `Customers` (the cleaned dataset, 7,043 rows), so there are no relationships to set up. Column names are explained in [`data/data_dictionary.md`](../data/data_dictionary.md).

**Why measures and not plain columns:** a measure recalculates with every slicer and chart click, so one `Churn Rate %` works on every page. Never use a summed column such as "Sum of ChurnFlag" for a rate.

## Check values

With no filters selected, every measure should show the value in the last column of the tables below. If it does not, fix the measure before building visuals.

---

## 1. Customer counts

| Measure | Format |
|---|---|
| Total Customers | Whole number, thousands separator |
| Churned Customers | Whole number, thousands separator |
| Retained Customers | Whole number, thousands separator |

```DAX
Total Customers = COUNTROWS(Customers)

Churned Customers =
CALCULATE([Total Customers], Customers[ChurnFlag] = 1)

Retained Customers = [Total Customers] - [Churned Customers]
```

| Measure | Expected |
|---|---|
| Total Customers | 7,043 |
| Churned Customers | 1,869 |
| Retained Customers | 5,174 |

`Churned Customers` changes the filter on `ChurnFlag` with `CALCULATE`, and keeps all other filters (contract, city, and so on).

---

## 2. Rates

| Measure | Format |
|---|---|
| Churn Rate % | Percentage, 2 decimals |
| Retention Rate % | Percentage, 2 decimals |
| Overall Churn Rate % | Percentage, 2 decimals |

```DAX
Churn Rate % =
DIVIDE([Churned Customers] + 0, [Total Customers])

Retention Rate % = 1 - [Churn Rate %]

Overall Churn Rate % =
CALCULATE([Churn Rate %], ALL(Customers))
```

| Measure | Expected |
|---|---|
| Churn Rate % | 26.54% |
| Retention Rate % | 73.46% |
| Overall Churn Rate % | 26.54% |

- `DIVIDE` returns blank instead of an error when the denominator is zero.
- `+ 0` turns a blank count into 0, so segments with no churn show **0.00%** and not an empty cell. This fixes the blank "Two year, 0-12 Months" cells in the matrix.
- `ALL(Customers)` removes every slicer and chart filter, so `Overall Churn Rate %` always shows the company-wide rate. Use it as the constant line on the bar charts, to show which groups are above or below average.

---

## 3. Revenue

| Measure | Format |
|---|---|
| Revenue Lost | Currency $, 0 decimals |
| Revenue at Risk | Currency $, 0 decimals |

```DAX
Revenue Lost =
CALCULATE(SUM(Customers[AnnualRevenue]), Customers[ChurnFlag] = 1)

Revenue at Risk =
CALCULATE(SUM(Customers[AnnualRevenue]), Customers[AtRiskActive] = 1)
```

| Measure | Expected |
|---|---|
| Revenue Lost | $1,669,570 |
| Revenue at Risk | $690,811 |

`AnnualRevenue` is `MonthlyCharges` × 12, so these are estimated annual revenue, in US dollars. `AtRiskActive` is 1 for customers who have not churned and have a churn score of 70 or more.

---

## 4. At-risk customers

| Measure | Format |
|---|---|
| At-Risk Customers | Whole number |
| At-Risk Avg CLTV | Currency $, 0 decimals |

```DAX
At-Risk Customers =
CALCULATE([Total Customers], Customers[AtRiskActive] = 1)

At-Risk Avg CLTV =
CALCULATE(AVERAGE(Customers[CLTV]), Customers[AtRiskActive] = 1)
```

| Measure | Expected |
|---|---|
| At-Risk Customers | 950 |
| At-Risk Avg CLTV | about $4,493 (4,492.5) |

---

## 5. Averages

| Measure | Format |
|---|---|
| Avg CLTV | Currency $, 0 decimals |
| Avg Monthly Charges | Currency $, 2 decimals |

```DAX
Avg CLTV = AVERAGE(Customers[CLTV])

Avg Monthly Charges = AVERAGE(Customers[MonthlyCharges])
```

| Measure | Expected |
|---|---|
| Avg CLTV | about $4,400 (4,400.3) |
| Avg Monthly Charges | $64.76 |

---

## 6. Geography

```DAX
Cities Covered = DISTINCTCOUNT(Customers[City])
```

| Measure | Expected |
|---|---|
| Cities Covered | 1,129 |

---

## 7. What-if: churn reduction savings

Create the parameter first: **Modeling → New parameter → Numeric range**.

| Setting | Value |
|---|---|
| Name | Churn Reduction |
| Minimum | 0 |
| Maximum | 0.20 |
| Increment | 0.01 |
| Default | 0.10 |
| Add slicer to this page | On |

Power BI creates a table named `Churn Reduction` with a column and a measure like the one below. The exact names depend on what you typed, so check them in the Data pane:

```DAX
Churn Reduction Value =
SELECTEDVALUE('Churn Reduction'[Churn Reduction], 0.1)
```

Then add:

```DAX
Potential Savings = [Revenue Lost] * [Churn Reduction Value]
```

Format the parameter column as a percentage so the slider shows 10% and not 0.10.

| Slider | Potential Savings |
|---|---|
| 5% | $83,479 |
| 10% (default) | $166,957 |
| 15% | $250,436 |
| 20% | $333,914 |

**Assumption:** reducing churn by X% recovers X% of the annual revenue currently lost. It is a planning estimate, not a forecast.

---

## Where each measure is used

| Page | Measures |
|---|---|
| 1. Executive Overview | Total Customers, Churned Customers, Churn Rate %, Revenue Lost, Revenue at Risk, Total Customers (risk tier and senior citizen charts), Retained Customers |
| 2. Why They Leave | Churned Customers (top reasons, decomposition tree), Churn Rate % (payment method, tech support, internet service, matrix), Overall Churn Rate % (reference line) |
| 3. Action Plan | At-Risk Customers, Revenue at Risk, Revenue Lost, At-Risk Avg CLTV, Potential Savings, Churn Reduction Value |
| 4. Geographic View | Total Customers, Churned Customers, Churn Rate %, Cities Covered |

## Filter context test

Select **Month-to-month** in a contract chart or slicer. The measures should read:

| Measure | Expected |
|---|---|
| Total Customers | 3,875 |
| Churned Customers | 1,655 |
| Churn Rate % | 42.71% |
| At-Risk Customers | 415 |

`Overall Churn Rate %` should still read 26.54%, because it ignores filters.

## Notes

- Delete any leftover `Column1` in `_Measures`. It comes from the Enter Data step and is not used.
- Set **Don't summarize** on numeric columns shown in tables, such as `CLTV`, `ChurnScore`, `MonthlyCharges`, and `TenureMonths`, so they display row by row.
- Every measure here matches the SQL results in `sql/04_churn_analysis_queries.sql` and `sql/05_customer_segmentation_risk_tiers.sql`.
