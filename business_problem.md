# Business Problem

## Context
A telecom company has 7,043 customers in California. 1,869 of them (26.54%) have left. Each churned customer takes recurring revenue with them, and winning a new customer usually costs more than keeping an existing one.

## The problem
The retention team has no single view that shows **why** customers leave, **who** is likely to leave next, and **what** reducing churn is worth. Without that view, retention offers are spread across all customers instead of the groups that need them most.

**Cost of the problem:** about **$1.67M** in annual revenue lost to churned customers.

## Objectives
1. Measure churn overall and by customer segment.
2. Identify the main drivers of churn.
3. Flag active customers who are at high risk and rank them by value.
4. Estimate the savings from reducing churn.
5. Show where churn is concentrated geographically.

## Business questions the dashboard answers

| # | Question | Where answered |
|---|---|---|
| 1 | What is the overall churn rate and revenue lost? | Page 1 |
| 2 | Which contracts and tenure groups churn most? | Pages 1 and 2 |
| 3 | What reasons do customers give for leaving? | Page 2 |
| 4 | Which services and payment methods are linked to churn? | Page 2 |
| 5 | Which active customers should the team contact first? | Page 3 |
| 6 | How much is a 5%, 10%, or 20% reduction in churn worth? | Page 3 |
| 7 | Which cities have the most churn? | Page 4 |

## Users
- **Retention and customer success managers:** priority call list and segment views.
- **Marketing:** which offers to target (contract upgrades, onboarding).
- **Leadership:** KPIs, revenue impact, and what-if savings.

## Scope and data
- One snapshot of 7,043 customers (IBM Telco Customer Churn sample dataset). There is no date column, so the project does not show trends over time.
- All amounts are in US dollars.
- The churn score and customer lifetime value (CLTV) come from the source dataset. They were not modelled in this project.

## Success criteria
- Every number in the dashboard can be traced back to the cleaned dataset and reproduced with SQL.
- A retention manager can find the highest-value at-risk customers in under a minute.
