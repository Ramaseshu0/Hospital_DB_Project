import pandas as pd
from sqlalchemy import create_engine, text
import os

# --- CONFIGURATION ---
# Note: Using port 5433 as per your setup
DB_URI = 'postgresql://admin:password123@127.0.0.1:5433/hospital_db'
CSV_PATH = 'data/healthcare_dataset.csv'
SCHEMA_PATH = 'sql/schema.sql'

def run_ingestion():
    print("--- Starting ROBUST Data Ingestion Pipeline ---")

    # 1. Connect
    try:
        engine = create_engine(DB_URI)
        conn = engine.connect()
        print("Connected to PostgreSQL.")
    except Exception as e:
        print(f"Connection Error: {e}")
        return

    # 2. Reset Schema
    print("Resetting Schema...")
    with open(SCHEMA_PATH, 'r') as f:
        # Split by command and execute individually
        commands = f.read().split(';')
        for cmd in commands:
            if cmd.strip():
                conn.execute(text(cmd))
        conn.commit()

    # 3. Read & Clean Data
    print(f"Reading CSV from {CSV_PATH}...")
    df = pd.read_csv(CSV_PATH)
    
    # Standardize Text Columns
    text_cols = ['Name', 'Gender', 'Medical Condition', 'Doctor', 
                 'Hospital', 'Insurance Provider', 'Admission Type', 
                 'Medication', 'Test Results', 'Blood Type']
    
    for col in text_cols:
        if col in df.columns:
            df[col] = df[col].astype(str).str.strip().str.title()
            
    # Fix Dates
    df['Date of Admission'] = pd.to_datetime(df['Date of Admission']).dt.date
    df['Discharge Date'] = pd.to_datetime(df['Discharge Date']).dt.date

    # 4. Load Dimensions
    print("Loading Dimensions...")

    # Load Doctors
    doctors = df[['Doctor']].drop_duplicates().reset_index(drop=True)
    doctors.columns = ['name']
    doctors.to_sql('doctors', engine, if_exists='append', index=False)
    print(f" -> Loaded {len(doctors)} Doctors")

    # Load Hospitals
    hospitals = df[['Hospital']].drop_duplicates().reset_index(drop=True)
    hospitals.columns = ['name']
    hospitals.to_sql('hospitals', engine, if_exists='append', index=False)
    print(f" -> Loaded {len(hospitals)} Hospitals")

    # Load Insurance
    insurance = df[['Insurance Provider']].drop_duplicates().reset_index(drop=True)
    insurance.columns = ['provider_name']
    insurance.to_sql('insuranceproviders', engine, if_exists='append', index=False)
    print(f" -> Loaded {len(insurance)} Insurance Providers")

    # Load Patients (Using Name+Age+Gender+BloodType as unique key)
    patients = df[['Name', 'Age', 'Gender', 'Blood Type']].drop_duplicates().reset_index(drop=True)
    patients.columns = ['name', 'age', 'gender', 'blood_type']
    patients.to_sql('patients', engine, if_exists='append', index=False)
    print(f" -> Loaded {len(patients)} Patients")

    # 5. Map Foreign Keys (The Crucial Step)
    print("Mapping Data IDs...")
    
    # Get IDs from DB
    doc_map = pd.read_sql("SELECT name, doctor_id FROM doctors", conn)
    hos_map = pd.read_sql("SELECT name, hospital_id FROM hospitals", conn)
    ins_map = pd.read_sql("SELECT provider_name, insurance_id FROM insuranceproviders", conn)
    pat_map = pd.read_sql("SELECT name, age, gender, blood_type, patient_id FROM patients", conn)

    # Merge IDs into main dataframe
    # We join carefully to ensure no rows are dropped
    df_merged = df.merge(doc_map, left_on='Doctor', right_on='name', how='left')
    df_merged = df_merged.merge(hos_map, left_on='Hospital', right_on='name', how='left')
    df_merged = df_merged.merge(ins_map, left_on='Insurance Provider', right_on='provider_name', how='left')
    
    # Strict join for patients on 4 columns
    df_merged = df_merged.merge(
        pat_map, 
        left_on=['Name', 'Age', 'Gender', 'Blood Type'], 
        right_on=['name', 'age', 'gender', 'blood_type'], 
        how='left'
    )

    # Check for missing IDs (Data Integrity Check)
    missing_pats = df_merged['patient_id'].isnull().sum()
    if missing_pats > 0:
        print(f"WARNING: {missing_pats} records failed to match a patient!")

    # Prepare Final Table
    admissions = df_merged[[
        'patient_id', 'doctor_id', 'hospital_id', 'insurance_id',
        'Date of Admission', 'Discharge Date', 'Admission Type', 
        'Medical Condition', 'Medication', 'Test Results', 
        'Room Number', 'Billing Amount'
    ]].copy()

    admissions.columns = [
        'patient_id', 'doctor_id', 'hospital_id', 'insurance_id',
        'admission_date', 'discharge_date', 'admission_type',
        'medical_condition', 'medication', 'test_results',
        'room_number', 'billing_amount'
    ]

    # Drop any rows that failed mapping (prevent DB crash)
    admissions = admissions.dropna(subset=['patient_id', 'doctor_id', 'hospital_id', 'insurance_id'])

    print(f"Loading {len(admissions)} Admissions...")
    admissions.to_sql('admissions', engine, if_exists='append', index=False)
    
    conn.commit()
    conn.close()
    print("--- Ingestion Complete! ---")

if __name__ == "__main__":
    run_ingestion()