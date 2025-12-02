# Hospital Management System (OLTP & OLAP)
**Course:** EAS 550 Data Management Systems  
**Phase:** 1 & 2 Completed

## 📌 Project Overview
This project implements a normalized relational database (OLTP) for a **Hospital Management System**. It manages patient admissions, doctor assignments, hospital resources, and insurance billing. [cite_start]The system is designed to handle transactional data integrity (3NF) and supports advanced analytical querying for business insights[cite: 4, 24].

### Key Features
* **3NF Normalized Schema:** Eliminates redundancy by separating Patients, Doctors, Hospitals, and Admissions.
* **Automated ETL Pipeline:** A Python script cleans raw CSV data and populates the PostgreSQL database.
* **Security:** Role-Based Access Control (RBAC) with distinct Admin and Analyst roles.
* **Analytics:** Complex SQL queries for revenue analysis and patient trends.
* **Performance Tuning:** Indexed optimization for high-frequency queries.

---

## 🚀 Setup & Installation

### Prerequisites
* **Docker Desktop** (must be running)
* **Python 3.9+**
* **Git**

### 1. Clone the Repository
```bash
git clone [https://github.com/Ramaseshu0E/Hospital_DB_Project.git](https://github.com/Ramaseshu0/Hospital_DB_Project.git)
cd Hospital_DB_Project
```
2. Start the Database (Docker)
We use Docker Compose to spin up a PostgreSQL 15 container and Adminer (a web-based DB viewer).

```Bash

docker-compose up -d
Database Port: 5433 (Mapped to avoid conflicts with local Postgres)
```
Adminer UI: http://localhost:8080/

3. Install Python Dependencies
```Bash

pip install -r requirements.txt
```
🛠️ Phase 1: Database Implementation (OLTP)
Data Ingestion (ETL)
The src/ingest_data.py script handles data cleaning (fixing text case, date formatting) and loads it into the database.

Bash

python src/ingest_data.py
Expected Output: --- Ingestion Complete! ---

Accessing the Database
You can view the data via the Adminer web interface:

Go to: http://localhost:8080/

System: PostgreSQL

Server: db

Username: admin

Password: password123

Database: hospital_db

ER Diagram
The Entity-Relationship Diagram (ERD) is available in the ERD.md file (rendered via Mermaid.js).

📊 Phase 2: Analytics & Performance
Advanced Queries
Three complex analytical queries (Window functions, CTEs, Joins) are provided in sql/phase2_analytics.sql.

Query 1: Doctor Revenue Ranking.

Query 2: High-Cost Condition Analysis.

Query 3: Monthly Admission Trends.

Performance Tuning
We optimized query performance by implementing B-Tree indexes on high-traffic columns.


Report: See Performance_Report.md for the detailed "Before vs. After" analysis using EXPLAIN ANALYZE.


📂 Project Structure
Plaintext

Hospital_DB_Project/
├── data/
│   └── healthcare_dataset.csv    # Raw source data
├── sql/
│   ├── schema.sql                # DDL: Table definitions (3NF)
│   ├── security.sql              # RBAC: Role creation
│   └── phase2_analytics.sql      # Phase 2: Complex Queries & Indexing
├── src/
│   └── ingest_data.py            # Python ETL Script
├── docker-compose.yml            # Container orchestration
├── requirements.txt              # Python libraries
├── Performance_Report.md         # Phase 2 Tuning results
├── ERD.md                        # Entity-Relationship Diagram
└── README.md                     # Project documentation
