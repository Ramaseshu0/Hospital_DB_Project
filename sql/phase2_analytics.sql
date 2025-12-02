-- Optimization: Index on Medical Condition
CREATE INDEX idx_medical_condition ON Admissions(medical_condition);

-- 1. Doctor Revenue Ranking (Window Function)
-- Business Question: Who are the top revenue-generating doctors, and how do they rank compared to others?

SELECT 
    d.name AS doctor_name,
    COUNT(a.admission_id) AS total_admissions,
    SUM(a.billing_amount) AS total_revenue,
    RANK() OVER (ORDER BY SUM(a.billing_amount) DESC) AS revenue_rank
FROM Admissions a
JOIN Doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.name
ORDER BY total_revenue DESC
LIMIT 10;


-- 2. High-Cost Outliers vs. Condition Average (CTE & Joins)
--Business Question: Identify patients whose billing amount is significantly higher (> 1.2x) than the average cost for their specific medical condition.

WITH ConditionStats AS (
    SELECT 
        medical_condition, 
        AVG(billing_amount) as avg_cost
    FROM Admissions
    GROUP BY medical_condition
)
SELECT 
    p.name AS patient_name,
    a.medical_condition,
    a.billing_amount,
    ROUND(cs.avg_cost, 2) AS condition_avg_cost,
    ROUND(a.billing_amount - cs.avg_cost, 2) AS excess_amount
FROM Admissions a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN ConditionStats cs ON a.medical_condition = cs.medical_condition
WHERE a.billing_amount > (cs.avg_cost * 1.2) -- Patients paying 20% more than average
ORDER BY excess_amount DESC
LIMIT 10;

-- 3. Monthly Admission Trends
-- Business Question: What is the busiest month for the hospital based on admission counts?

SELECT 
    TO_CHAR(admission_date, 'YYYY-MM') AS admission_month,
    h.name AS hospital_name,
    COUNT(*) AS admission_count,
    SUM(billing_amount) AS monthly_revenue
FROM Admissions a
JOIN Hospitals h ON a.hospital_id = h.hospital_id
GROUP BY 1, 2
ORDER BY admission_month DESC, admission_count DESC;


