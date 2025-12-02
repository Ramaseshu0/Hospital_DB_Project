-- schema.sql
-- Phase 1: DDL (Data Definition Language)

-- 1. Create Independent Tables (Dimensions)
CREATE TABLE IF NOT EXISTS Patients (
    patient_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    age INTEGER,
    gender TEXT,
    blood_type TEXT
);

CREATE TABLE IF NOT EXISTS Doctors (
    doctor_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Hospitals (
    hospital_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS InsuranceProviders (
    insurance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    provider_name TEXT NOT NULL UNIQUE
);

-- 2. Create the Main Transactional Table (Fact Table)
CREATE TABLE IF NOT EXISTS Admissions (
    admission_id INTEGER PRIMARY KEY AUTOINCREMENT,
    patient_id INTEGER,
    doctor_id INTEGER,
    hospital_id INTEGER,
    insurance_id INTEGER,
    
    admission_date DATE,
    discharge_date DATE,
    admission_type TEXT,
    medical_condition TEXT,
    medication TEXT,
    test_results TEXT,
    room_number INTEGER,
    billing_amount REAL,
    
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id),
    FOREIGN KEY (hospital_id) REFERENCES Hospitals(hospital_id),
    FOREIGN KEY (insurance_id) REFERENCES InsuranceProviders(insurance_id)
);