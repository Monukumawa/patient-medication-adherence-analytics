"""
Patient Medication Adherence - Drop-off Prediction (Random Forest)
Run from the repo root:  python Python/adherence_prediction.py
"""
import pandas as pd
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (accuracy_score, precision_score, recall_score,
                             f1_score, confusion_matrix)

# 1. Load data
df = pd.read_csv("Dataset/adherence_flat.csv")
print(f"Rows: {len(df)} | Drop-off rate: {df['dropped_off'].mean():.1%}")

# 2. Feature engineering (IDs and dates are not used as features)
features = ["drug_name", "drug_class", "channel", "days_supply_per_fill",
            "total_fills", "age", "gender", "region_patient", "insurance_type",
            "has_comorbidity", "age_band", "specialty", "region_doctor",
            "years_practicing"]
X = df[features].copy()
for col in X.select_dtypes(exclude="number").columns:
    X[col] = LabelEncoder().fit_transform(X[col])
y = df["dropped_off"]

# 3. Train / test split (80/20)
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42)

# 4. Random Forest
model = RandomForestClassifier(n_estimators=100, max_depth=8, random_state=42)
model.fit(X_train, y_train)
pred = model.predict(X_test)

# 5. Evaluation
print(f"Accuracy : {accuracy_score(y_test, pred):.1%}")
print(f"Precision: {precision_score(y_test, pred):.1%}")
print(f"Recall   : {recall_score(y_test, pred):.1%}")
print(f"F1 Score : {f1_score(y_test, pred):.1%}")
print("Confusion matrix [[TN FP] [FN TP]]:\n", confusion_matrix(y_test, pred))

# 6. Feature importance
imp = (pd.Series(model.feature_importances_ * 100, index=features)
         .sort_values(ascending=False).round(1))
print("\nFeature importance (%):\n", imp)

# 7. Export predictions for Power BI
out = X_test.copy()
out["Actual_Dropoff"] = y_test.values
out["Predicted_Dropoff"] = pred
out.to_csv("Python/patient_predictions_new.csv", index=False)
print("\nSaved Python/patient_predictions_new.csv")
