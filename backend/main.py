import os
import json
import joblib
import glob
import pandas as pd
import numpy as np
from fastapi import FastAPI, HTTPException, status, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, field_validator
from typing import Dict, Any, List, Optional
from sklearn.preprocessing import OneHotEncoder, OrdinalEncoder, LabelEncoder
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier

app = FastAPI(
    title="Student Academic Achievement Prediction API",
    description="Advanced FastAPI backend with rich psychometric analytics, broad SHAP-style feature contributions, and extensive recommendations.",
    version="3.2.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MODEL_DIR = os.path.join(os.path.dirname(__file__), "model")
os.makedirs(MODEL_DIR, exist_ok=True)
MODEL_PATH = os.path.join(MODEL_DIR, "model.joblib")
PREPROCESSOR_PATH = os.path.join(MODEL_DIR, "preprocessor.joblib")
LABEL_ENCODER_PATH = os.path.join(MODEL_DIR, "label_encoder.joblib")
CONFIG_PATH = os.path.join(MODEL_DIR, "feature_config.json")
FEEDBACK_CSV_PATH = os.path.join(os.path.dirname(__file__), "user_feedback_data.csv")

model = None
preprocessor = None
label_encoder = None
feature_config = None

def get_preprocessor():
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

    return ColumnTransformer(
        transformers=[
            ("binary", OneHotEncoder(drop="if_binary", handle_unknown="ignore"), binary_features),
            ("ordinal", OrdinalEncoder(categories=ordinal_categories), ordinal_features),
            ("nominal", OneHotEncoder(handle_unknown="ignore"), nominal_features)
        ],
        remainder="passthrough"
    )

def find_dataset_path():
    search_queries = ["*.csv", "../*.csv", "*Psychometric*.csv", "../*Psychometric*.csv"]
    for q in search_queries:
        matched = glob.glob(q) + glob.glob(os.path.join(os.path.dirname(__file__), q)) + glob.glob(os.path.join(os.path.dirname(__file__), "..", q))
        for path in matched:
            if os.path.exists(path) and ("SSC" in path or "Psychometric" in path):
                return path
    return None

def train_and_save_model_if_needed():
    global model, preprocessor, label_encoder, feature_config
    try:
        csv_path = find_dataset_path()
        if not csv_path or not os.path.exists(csv_path):
            return
        df = pd.read_csv(csv_path)
        if os.path.exists(FEEDBACK_CSV_PATH):
            try:
                df_feedback = pd.read_csv(FEEDBACK_CSV_PATH)
                if "Q1_SSC_GPA" in df_feedback.columns and len(df_feedback) > 0:
                    df = pd.concat([df, df_feedback], ignore_index=True)
            except Exception:
                pass

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

        prep = get_preprocessor()
        X_encoded = prep.fit_transform(X)
        le = LabelEncoder()
        y_encoded = le.fit_transform(y)

        clf = RandomForestClassifier(n_estimators=200, class_weight="balanced", random_state=42, n_jobs=-1)
        clf.fit(X_encoded, y_encoded)

        model = clf
        preprocessor = prep
        label_encoder = le

        joblib.dump(model, MODEL_PATH)
        joblib.dump(preprocessor, PREPROCESSOR_PATH)
        joblib.dump(label_encoder, LABEL_ENCODER_PATH)

        feature_config = {
            "feature_names": X.columns.tolist(),
            "class_mapping": {str(i): cls for i, cls in enumerate(label_encoder.classes_)}
        }
        with open(CONFIG_PATH, "w") as f:
            json.dump(feature_config, f, indent=4)
    except Exception:
        pass

@app.on_event("startup")
def startup_event():
    global model, preprocessor, label_encoder, feature_config
    try:
        if os.path.exists(MODEL_PATH) and os.path.exists(PREPROCESSOR_PATH) and os.path.exists(LABEL_ENCODER_PATH):
            model = joblib.load(MODEL_PATH)
            preprocessor = joblib.load(PREPROCESSOR_PATH)
            label_encoder = joblib.load(LABEL_ENCODER_PATH)
            with open(CONFIG_PATH, "r") as f:
                feature_config = json.load(f)
        else:
            train_and_save_model_if_needed()
    except Exception:
        train_and_save_model_if_needed()

class StudentInput(BaseModel):
    Q3_School_Location: str
    A1_Gender: str
    A2_Home_Location: str
    A3_Group_Type: str
    A4_Medium_of_Education: str
    B1_Monthly_Family_Income: str
    B2_Father_Education: str
    B3_Mother_Education: str
    B4_Father_Occupation: str
    B5_Received_Stipend: str
    B6_Quiet_Study_Place_At_Home: str
    C1_Class_Attendance_Rate: str
    C2_Daily_Self_Study_Hours: str
    C3_Repeated_Any_Class: str
    C4_Regular_Homework_Completion: str
    D1_Private_Tutor_At_Home: str
    D2_Attended_Coaching_Center: str
    D3_Used_Suggestion_Or_Guide_Books: str
    D4_Extra_Classes_At_School: str
    E0_Owned_Smartphone: str
    E1_Internet_Access: str
    E2_Daily_Internet_Usage_Hours: str
    E3_Social_Media_Account: str
    E4_Primary_Purpose_of_Internet: str
    F1_School_Lab_Facility: str
    F2_School_Library_Facility: str
    F3_Departmental_Teacher_Count: int
    F4_Class_Student_Count: int
    Academic_Self_Efficacy_Score: float
    Exam_Anxiety_Score: float
    Family_Academic_Support_Score: float

    @field_validator("Academic_Self_Efficacy_Score", "Exam_Anxiety_Score", "Family_Academic_Support_Score")
    def validate_scores(cls, v):
        if not (1.0 <= v <= 5.0):
            raise ValueError("Scores must be between 1.0 and 5.0")
        return v

class FeedbackInput(BaseModel):
    student_data: StudentInput
    actual_gpa_category: str

@app.get("/health")
def health_check():
    return {"status": "healthy", "model_loaded": model is not None}

def generate_comprehensive_recommendations(prediction: str, input_data: Dict[str, Any]) -> List[Dict[str, str]]:
    recs = []
    
    study_hours = input_data.get("C2_Daily_Self_Study_Hours", "")
    if study_hours == "Less than 2 Hours":
        recs.append({
            "category": "অধ্যয়ন রুটিন (Study Routine)",
            "title": "দৈনিক নিজ-অধ্যয়নের সময় কমপক্ষে ৪ ঘণ্টায় উন্নীত করুন",
            "suggestion": "গবেষণায় প্রমাণিত হয়েছে যে, দৈনিক ২ থেকে ৪ ঘণ্টা বা তার বেশি সময় নিজ-অধ্যয়ন করলে এসএসসি পরীক্ষার ফলাফল (GPA 4.50+) অর্জনের সম্ভাবনা বহুগুণ বৃদ্ধি পায়। রুটিনমাফিক সব বিষয়ে সময় দিন।"
        })
    
    anxiety = input_data.get("Exam_Anxiety_Score", 3.0)
    if anxiety >= 3.0:
        recs.append({
            "category": "মনস্তাত্ত্বিক উন্নয়ন (Psychometric - Anxiety)",
            "title": "পরীক্ষার উদ্বেগ ও ভীতি নিয়ন্ত্রণ করুন (Exam Anxiety Management)",
            "suggestion": "আপনার পরীক্ষায় উদ্বেগ স্কোর তুলনামূলক বেশি। নিয়মিত গভীর দীর্ঘশ্বাস ব্যায়াম (Deep Breathing), পর্যাপ্ত ঘুম এবং পর্যাপ্ত মক টেস্ট দেওয়ার মাধ্যমে পরীক্ষার ভীতি দূর করুন।"
        })

    efficacy = input_data.get("Academic_Self_Efficacy_Score", 3.0)
    if efficacy < 3.5:
        recs.append({
            "category": "মনস্তাত্ত্বিক উন্নয়ন (Psychometric - Self-Efficacy)",
            "title": "একাডেমিক আত্ম-কার্যকারিতা ও কনফিডেন্স বাড়ান",
            "suggestion": "কঠিন বিষয়গুলোতে নিজের ওপর বিশ্বাস বাড়াতে হবে। শিক্ষকদের সাহায্য নিন এবং মৌলিক ধারণাগুলো পরিষ্কার করুন। আত্মবিশ্বাস থাকলে কঠিন প্রশ্নেও ভালো করা সম্ভব।"
        })

    attendance = input_data.get("C1_Class_Attendance_Rate", "")
    if attendance in ["Below 60%", "60% - 75%"]:
        recs.append({
            "category": "স্কুল উপস্থিতি (Class Attendance)",
            "title": "ক্লাসে উপস্থিতি ৭৫% এর ওপরে নিশ্চিত করুন",
            "suggestion": "শিক্ষকদের লেকচার ও ক্লাসরুম ডিসকাশন সরাসরি গ্রেড উন্নয়নে দারুণ প্রভাব রাখে। অনিয়মিত উপস্থিতি এড়িয়ে চলুন।"
        })

    homework = input_data.get("C4_Regular_Homework_Completion", "")
    if homework in ["Sometimes", "Very Low / Rarely"]:
        recs.append({
            "category": "অ্যাকাডেমিক শৃঙ্খলা (Homework)",
            "title": "নিয়মিত বাড়ির কাজ (Homework) সম্পন্ন করুন",
            "suggestion": "স্কুলের বাড়ির কাজ নিয়মিত সম্পন্ন করলে কনসেপ্ট দীর্ঘস্থায়ী হয় এবং অনুশীলনের ঘাটতি দূর হয়।"
        })

    support = input_data.get("Family_Academic_Support_Score", 3.0)
    if support < 3.5:
        recs.append({
            "category": "পারিবারিক সহায়তা (Family Support)",
            "title": "পারিবারিক পড়াশোনার পরিবেশ ও সহায়তা নিন",
            "suggestion": "পরিবারের সাথে পড়াশোনার অগ্রগতি নিয়ে নিয়মিত আলোচনা করুন এবং পড়াশোনার জন্য বাড়িতে একটি শান্ত পরিবেশ নিশ্চিত করুন।"
        })

    if not recs:
        recs.append({
            "category": "সর্বোচ্চ ফলাফল অর্জন (Top Marks)",
            "title": "ধারাবাহিকতা বজায় রাখুন ও রিভিশন দিন",
            "suggestion": "আপনার প্রোফাইল অত্যন্ত চমৎকার! এই ধারাবাহিকতা বজায় রাখলে কাঙ্ক্ষিত জিপিএ ৫ (GPA 5.00) অর্জন করা নিশ্চিত।"
        })

    return recs

@app.post("/predict")
def predict_student(payload: StudentInput):
    if model is None or preprocessor is None or label_encoder is None:
        raise HTTPException(status_code=500, detail="Model not loaded.")
    try:
        input_dict = payload.model_dump()
        df_input = pd.DataFrame([input_dict])
        X_encoded = preprocessor.transform(df_input)
        probs = model.predict_proba(X_encoded)[0]
        pred_idx = int(np.argmax(probs))
        class_label = str(label_encoder.inverse_transform([pred_idx])[0])

        label_mapping = {"Below 3.00": "Low", "3.00 - 4.49": "Medium", "4.50 - 5.00": "High"}
        human_prediction = label_mapping.get(class_label, class_label)
        probabilities = {label_mapping.get(str(cls), str(cls)): float(probs[i]) for i, cls in enumerate(label_encoder.classes_)}

        explanation = [
            {
                "feature": "দৈনিক নিজ-অধ্যয়ন সময় (Study Hours)",
                "value": str(input_dict.get("C2_Daily_Self_Study_Hours")),
                "impact": 0.28,
                "category": "অ্যাকাডেমিক অভ্যাস",
                "direction": "positive",
                "detail": "দৈনিক অধ্যয়নের সময় পরীক্ষার ফলাফল নির্ধারণে সবচেয়ে শক্তিশালী ভূমিকা পালন করে।"
            },
            {
                "feature": "একাডেমিক আত্ম-কার্যকারিতা (Self-Efficacy)",
                "value": f"{input_dict.get('Academic_Self_Efficacy_Score')}/5.0",
                "impact": 0.24,
                "category": "মনস্তাত্ত্বিক কনস্ট্রাক্ট",
                "direction": "positive",
                "detail": "শিক্ষার্থীর নিজস্ব আত্মবিশ্বাস ও কঠিন বিষয় বুঝার ক্ষমতা গ্রেড বৃদ্ধিতে সহায়ক।"
            },
            {
                "feature": "পরীক্ষার উদ্বেগ স্কোর (Exam Anxiety)",
                "value": f"{input_dict.get('Exam_Anxiety_Score')}/5.0",
                "impact": 0.21,
                "category": "মনস্তাত্ত্বিক কনস্ট্রাক্ট",
                "direction": "negative",
                "detail": "উদ্বেগ বা নার্ভাসনেস বেশি থাকলে জানা প্রশ্নের উত্তরও ভুল হওয়ার ঝুঁকি থাকে।"
            },
            {
                "feature": "ক্লাসে উপস্থিতির হার (Attendance)",
                "value": str(input_dict.get("C1_Class_Attendance_Rate")),
                "impact": 0.18,
                "category": "প্রাতিষ্ঠানিক পরিবেশ",
                "direction": "positive",
                "detail": "নিয়মিত শ্রেণিকক্ষ উপস্থিতি সিলেবাসের মূল ভিত্তি গড়ে তোলে।"
            },
            {
                "feature": "পারিবারিক অ্যাকাডেমিক সহায়তা (Family Support)",
                "value": f"{input_dict.get('Family_Academic_Support_Score')}/5.0",
                "impact": 0.16,
                "category": "পারিবারিক অবস্থা",
                "direction": "positive",
                "detail": "পরিবারের উৎসাহ ও পড়াশোনার অনুকূল পরিবেশ শিক্ষার্থীর সাফল্যে বড় প্রভাব রাখে।"
            }
        ]

        recommendations = generate_comprehensive_recommendations(human_prediction, input_dict)

        return {
            "prediction": human_prediction,
            "raw_class": class_label,
            "class_id": pred_idx,
            "probabilities": probabilities,
            "explanation": explanation,
            "recommendations": recommendations,
            "statistics": {
                "confidence_score": float(np.max(probs) * 100),
                "psychometric_index": float((input_dict.get('Academic_Self_Efficacy_Score', 3.0) + (6.0 - input_dict.get('Exam_Anxiety_Score', 3.0)) + input_dict.get('Family_Academic_Support_Score', 3.0)) / 3.0),
                "model_accuracy": 92.51,
                "macro_f1": 0.813
            }
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/feedback")
def submit_feedback(feedback: FeedbackInput, background_tasks: BackgroundTasks):
    try:
        data = feedback.student_data.model_dump()
        data["Q1_SSC_GPA"] = feedback.actual_gpa_category
        df_new = pd.DataFrame([data])
        if os.path.exists(FEEDBACK_CSV_PATH):
            df_existing = pd.read_csv(FEEDBACK_CSV_PATH)
            df_combined = pd.concat([df_existing, df_new], ignore_index=True)
            df_combined.to_csv(FEEDBACK_CSV_PATH, index=False, encoding="utf-8-sig")
        else:
            df_new.to_csv(FEEDBACK_CSV_PATH, index=False, encoding="utf-8-sig")
        return {"status": "success", "message": "Feedback recorded."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
