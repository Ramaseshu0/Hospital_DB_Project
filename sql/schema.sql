-- Phase 1: Database Schema (Fixed)

DROP TABLE IF EXISTS Admissions CASCADE;
DROP TABLE IF EXISTS Patients CASCADE;
DROP TABLE IF EXISTS Doctors CASCADE;
DROP TABLE IF EXISTS Hospitals CASCADE;
DROP TABLE IF EXISTS InsuranceProviders CASCADE;

-- 1. Dimension Tables
CREATE TABLE Patients (
    patient_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INTEGER CHECK (age >= 0),
    gender VARCHAR(20),
    blood_type VARCHAR(5),
    -- Fixed: Included blood_type in unique constraint to allow similar patients
    UNIQUE(name, age, gender, blood_type) 
);

CREATE TABLE Doctors (
    doctor_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Hospitals (
    hospital_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE InsuranceProviders (
    insurance_id SERIAL PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL UNIQUE
);

-- 2. Fact Table
CREATE TABLE Admissions (
    admission_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    doctor_id INTEGER NOT NULL,
    hospital_id INTEGER NOT NULL,
    insurance_id INTEGER NOT NULL,
    
    admission_date DATE NOT NULL,
    discharge_date DATE NOT NULL,
    admission_type VARCHAR(50),
    medical_condition VARCHAR(100),
    medication VARCHAR(100),
    test_results VARCHAR(50),
    room_number INTEGER,
    billing_amount DECIMAL(10, 2),
    
    CONSTRAINT fk_patient FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    CONSTRAINT fk_doctor FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id),
    CONSTRAINT fk_hospital FOREIGN KEY (hospital_id) REFERENCES Hospitals(hospital_id),
    CONSTRAINT fk_insurance FOREIGN KEY (insurance_id) REFERENCES InsuranceProviders(insurance_id),
    CONSTRAINT check_dates CHECK (discharge_date >= admission_date)
);