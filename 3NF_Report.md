# Database Design Justification (3NF)

## 1. Entities & Normalization
We designed the schema to satisfy **Third Normal Form (3NF)** to eliminate redundancy and update anomalies.

* **1NF (Atomic Values):** All columns in the original dataset (e.g., 'Medication', 'Test Results') contain single values per record. No repeating groups were found.
* **2NF (Partial Dependencies):** The primary key for the main table is `admission_id`. Attributes like `Doctor`, `Hospital`, and `Insurance Provider` depend only on the primary key, not part of it. However, in the raw CSV, 'Doctor' implies a specific name, but that name repeats. We extracted `Doctors`, `Hospitals`, and `InsuranceProviders` into their own tables.
* **3NF (Transitive Dependencies):** In the raw data, knowing the 'Doctor' might imply the 'Hospital' if doctors only worked at one hospital (though in this dataset, they might float). Regardless, storing the text string "Blue Cross" 500 times is redundant. We moved these to lookup tables.
    * **Patients:** Separated to ensure patient demographics (Age, Blood Type) are stored once per patient, not repeated for every admission.
    * **Admissions:** Contains only foreign keys and transaction-specific data (Dates, Billing, Test Results).

## 2. Constraints
* **Primary Keys:** Added `SERIAL` IDs for every table to ensure unique identification.
* **Foreign Keys:** Enforced referential integrity between Admissions and Dimension tables.
* **Data Integrity:** * `CHECK (discharge_date >= admission_date)` ensures logical consistency.
    * `UNIQUE` constraints on Names prevents duplicate entries in dimension tables.