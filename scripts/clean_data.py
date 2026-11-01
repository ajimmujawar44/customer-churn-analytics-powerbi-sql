"""
Reproduce the cleaned Telco churn dataset from the raw IBM file.

Input : data/raw/Telco_customer_churn.xlsx
Output: data/cleaned/telco_churn_cleaned.csv

Run from the repository root:
    python scripts/clean_data.py

The same cleaning rules are implemented in SQL (sql/02_data_cleaning.sql).
This script is an independent check: both routes should give identical results.
"""
from pathlib import Path

import numpy as np
import pandas as pd

RAW = Path("data/raw/Telco_customer_churn.xlsx")
OUT = Path("data/cleaned/telco_churn_cleaned.csv")

RENAME = {
    "Zip Code": "ZipCode", "Senior Citizen": "SeniorCitizen", "Tenure Months": "TenureMonths",
    "Phone Service": "PhoneService", "Multiple Lines": "MultipleLines",
    "Internet Service": "InternetService", "Online Security": "OnlineSecurity",
    "Online Backup": "OnlineBackup", "Device Protection": "DeviceProtection",
    "Tech Support": "TechSupport", "Streaming TV": "StreamingTV",
    "Streaming Movies": "StreamingMovies", "Paperless Billing": "PaperlessBilling",
    "Payment Method": "PaymentMethod", "Monthly Charges": "MonthlyCharges",
    "Total Charges": "TotalCharges", "Churn Label": "ChurnLabel", "Churn Value": "ChurnFlag",
    "Churn Score": "ChurnScore", "Churn Reason": "ChurnReason",
}
DROP = ["Count", "Country", "State", "Lat Long"]   # constant or duplicated columns


def clean(raw: pd.DataFrame) -> pd.DataFrame:
    df = raw.copy()

    # 1. Total Charges: blank strings -> 0 (all have Tenure Months = 0, i.e. not yet billed)
    blank = df["Total Charges"].astype(str).str.strip().eq("")
    df["Total Charges"] = pd.to_numeric(df["Total Charges"].replace(r"^\s*$", np.nan, regex=True))
    assert (df.loc[df["Total Charges"].isna(), "Tenure Months"] == 0).all()
    df["Total Charges"] = df["Total Charges"].fillna(0.0)
    print(f"Blank Total Charges fixed: {int(blank.sum())}")

    # 2. Churn Reason is empty only for customers who stayed
    df["Churn Reason"] = df["Churn Reason"].fillna("Not Churned")

    # 3. Trim text columns
    for col in df.columns:
        if col != "Total Charges" and pd.api.types.is_string_dtype(df[col]):
            df[col] = df[col].astype(str).str.strip()

    # 4. Drop constant / redundant columns, then rename
    df = df.drop(columns=DROP).rename(columns=RENAME)

    # 5. Derived columns
    bins = [-1, 12, 24, 48, 10**6]
    df["TenureBand"] = pd.cut(df.TenureMonths, bins,
                              labels=["0-12 Months", "13-24 Months", "25-48 Months", "49+ Months"]).astype(str)
    df["TenureBandSort"] = pd.cut(df.TenureMonths, bins, labels=[1, 2, 3, 4]).astype(int)
    df["AnnualRevenue"] = (df.MonthlyCharges * 12).round(2)
    df["RiskTier"] = np.select([df.ChurnScore >= 70, df.ChurnScore >= 40],
                               ["High Risk", "Medium Risk"], "Low Risk")
    df["MonthlyChargeBand"] = pd.cut(df.MonthlyCharges, [0, 35, 70, 100, 1000],
                                     labels=["Low (<=35)", "Medium (35-70)", "High (70-100)",
                                             "Premium (>100)"]).astype(str)
    df["AtRiskActive"] = ((df.ChurnFlag == 0) & (df.ChurnScore >= 70)).astype(int)

    # 6. Validation
    assert df.CustomerID.is_unique, "Duplicate CustomerID"
    assert df.isna().sum().sum() == 0, "Missing values remain"
    assert ((df.ChurnLabel == "Yes").astype(int) == df.ChurnFlag).all(), "Churn label mismatch"
    return df


def main() -> None:
    raw = pd.read_excel(RAW)
    df = clean(raw)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUT, index=False, encoding="utf-8")

    churned = int(df.ChurnFlag.sum())
    print(f"Rows: {len(df):,} | Columns: {df.shape[1]}")
    print(f"Churned: {churned:,} ({churned / len(df):.2%})")
    print(f"Annual revenue lost: ${df.loc[df.ChurnFlag == 1, 'AnnualRevenue'].sum():,.0f}")
    print(f"At-risk active customers: {int(df.AtRiskActive.sum()):,} "
          f"(${df.loc[df.AtRiskActive == 1, 'AnnualRevenue'].sum():,.0f} annual revenue)")
    print(f"Saved: {OUT}")


if __name__ == "__main__":
    main()
