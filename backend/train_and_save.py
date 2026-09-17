import pandas as pd
import numpy as np
import joblib
import json
from sklearn.preprocessing import OneHotEncoder, OrdinalEncoder, LabelEncoder
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import StackingClassifier, ExtraTreesClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from xgboost import XGBClassifier
from lightgbm import LGBMClassifier

print("="*70)
print("TRAINING STACKING ENSEMBLE RESEARCH MODEL")
print("="*70)

# 1. Load dataset
df = pd.read_csv("SSC_Phase2_Psychometric_Validated_Checkpoint.csv")

# 2. Drop leakage & identifiers
leakage_candidates = [
    "GPA_5", "GPA_%", "Appeared", "Passed", "Pass rate",
    "Appeared_numeric", "Passed_numeric", "Pass rate_numeric", "GPA_%_numeric",
    "Calculated_pass_rate", "Pass_rate_difference", "Calculated_GPA5_percentage",
    "Calculated_pass_rate_check", "Pass_rate_difference_check", "Target_numeric"
]
drop_cols = list(set(leakage_candidates + ["ID", "EIIN", "Q2_Secondary_School_Name"]))
df_model = df.drop(columns=drop_cols, errors="ignore")

raw_psych_items = [
    "G1_Understand_Difficult_Subjects", "G2_Confidence_In_Core_Concepts", "G3_Master_School_Skills",
    "G4_Perform_Better_Than_Peers", "G5_Confidence_In_Exam_Questions", "G6_Nervous_Forget_Concepts",
    "G7_Anxious_Insomnia_Before_Exam", "G8_Anxious_Under_Pressure_Despite_Studying", "G9_Peaceful_During_Exam",
    "G10_Parents_Encouraged_Hard_Work", "G11_Family_Interested_In_Progress", "G12_Parents_Provided_Study_Materials",
    "G13_Family_Discussed_School_Progress", "G1_Understand_Difficult_Subjects_score", "G2_Confidence_In_Core_Concepts_score",
    "G3_Master_School_Skills_score", "G4_Perform_Better_Than_Peers_score", "G5_Confidence_In_Exam_Questions_score",
    "G6_Nervous_Forget_Concepts_score", "G7_Anxious_Insomnia_Before_Exam_score", "G8_Anxious_Under_Pressure_Despite_Studying_score",
    "G9_Peaceful_During_Exam_score", "G10_Parents_Encouraged_Hard_Work_score", "G11_Family_Interested_In_Progress_score",
    "G12_Parents_Provided_Study_Materials_score", "G13_Family_Discussed_School_Progress_score", "G9_Peaceful_During_Exam_reverse"
]
df_model = df_model.drop(columns=raw_psych_items, errors="ignore")

df_model["B1_Monthly_Family_Income"] = df_model["B1_Monthly_Family_Income"].replace({"15,000 - 40,000 Taka": "15000 - 40000 TK"})
df_model["E2_Daily_Internet_Usage_Hours"] = df_model["E2_Daily_Internet_Usage_Hours"].replace({"Less than 2 hours": "Less than 2 Hours"})
df_model["E4_Primary_Purpose_of_Internet"] = df_model["E4_Primary_Purpose_of_Internet"].replace({"Never_USe": "Never_Use"})

X = df_model.drop(columns=["Q1_SSC_GPA"])
y = df_model["Q1_SSC_GPA"]

binary_features = [
    "B5_Received_Stipend", "B6_Quiet_Study_Place_At_Home", "C3_Repeated_Any_Class",
    "D1_Private_Tutor_At_Home", "D2_Attended_Coaching_Center", "D3_Used_Suggestion_Or_Guide_Books",
    "D4_Extra_Classes_At_School", "E0_Owned_Smartphone", "E1_Internet_Access",
    "E3_Social_Media_Account", "F1_School_Lab_Facility", "F2_School_Library_Facility"
]

ordinal_features = [
    "B1_Monthly_Family_Income", "B2_Father_Education", "B3_Mother_Education",
    "C1_Class_Attendance_Rate", "C2_Daily_Self_Study_Hours", "C4_Regular_Homework_Completion"
]

nominal_features = [
    "Q3_School_Location", "A1_Gender", "A2_Home_Location", "A3_Group_Type",
    "A4_Medium_of_Education", "B4_Father_Occupation", "E2_Daily_Internet_Usage_Hours",
    "E4_Primary_Purpose_of_Internet"
]

ordinal_categories = [
    ["Below 15000 TK", "15000 - 40000 TK", "Above 40000 TK"],
    ["No Institutional Education", "Primary", "Secondary (SSC or Below)", "Higher Secondary (HSC) or Above"],
    ["No Institutional Education", "Primary", "Secondary (SSC or Below)", "Higher Secondary (HSC) or Above"],
    ["Below 60%", "60% - 75%", "75% or Above"],
    ["Less than 2 Hours", "2 - 4 Hours", "More than 4 Hours"],
    ["Very Low / Rarely", "Sometimes", "Always"]
]

preprocessor = ColumnTransformer(
    transformers=[
        ("binary", OneHotEncoder(drop="if_binary", handle_unknown="ignore"), binary_features),
        ("ordinal", OrdinalEncoder(categories=ordinal_categories), ordinal_features),
        ("nominal", OneHotEncoder(handle_unknown="ignore"), nominal_features)
    ],
    remainder="passthrough"
)

X_encoded = preprocessor.fit_transform(X)

label_encoder = LabelEncoder()
y_encoded = label_encoder.fit_transform(y)

# 3. Define Stacking Ensemble: XGBoost + LightGBM + Extra Trees + SVM
base_estimators = [
    ("xgboost", XGBClassifier(objective="multi:softprob", num_class=3, eval_metric="mlogloss", n_estimators=200, learning_rate=0.05, max_depth=4, random_state=42)),
    ("lightgbm", LGBMClassifier(n_estimators=200, learning_rate=0.05, max_depth=4, random_state=42, verbose=-1)),
    ("extratrees", ExtraTreesClassifier(n_estimators=200, random_state=42, n_jobs=-1)),
    ("svm", SVC(kernel="rbf", C=1.0, probability=True, random_state=42))
]

meta_learner = LogisticRegression(max_iter=2000, class_weight="balanced", random_state=42)

stacking_model = StackingClassifier(
    estimators=base_estimators,
    final_estimator=meta_learner,
    cv=5,
    stack_method="predict_proba",
    n_jobs=-1
)

print("Training Stacking Classifier...")
stacking_model.fit(X_encoded, y_encoded)
print("Training completed successfully.")

# 4. Save artifacts
joblib.dump(stacking_model, "backend/model/model.joblib")
joblib.dump(preprocessor, "backend/model/preprocessor.joblib")
joblib.dump(label_encoder, "backend/model/label_encoder.joblib")

feature_config = {
    "feature_names": X.columns.tolist(),
    "binary_features": binary_features,
    "ordinal_features": ordinal_features,
    "nominal_features": nominal_features,
    "numerical_features": ["F3_Departmental_Teacher_Count", "F4_Class_Student_Count", "Academic_Self_Efficacy_Score", "Exam_Anxiety_Score", "Family_Academic_Support_Score"],
    "class_mapping": {str(i): cls for i, cls in enumerate(label_encoder.classes_)}
}

with open("backend/model/feature_config.json", "w") as f:
    json.dump(feature_config, f, indent=4)

print("="*70)
print("STACKING MODEL & ARTIFACTS SAVED SUCCESSFULLY TO backend/model/")
print("="*70)
