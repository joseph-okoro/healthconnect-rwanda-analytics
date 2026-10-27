-- ============================================================
-- HealthConnect Rwanda | Step 4: the 40 business questions
-- Run after steps 01-03.   pgAdmin: Query Tool > open this file; select ONE query (Q01 to Q40) with the mouse and press F5 to see its result.
-- (or open in pgAdmin and run one query at a time with F5 after selecting it)
--
-- Reading guide
--   "ALL"     = uses every row of the table (e.g. 60,000 diagnoses, 60,000 bills)
--   "MATCHED" = uses only the 5,000 appointments that have full details (hospital, department, doctor, patient, date).
--               Billing, diagnoses, feedback, labs, prescriptions, admissions and referrals point to up to 60,000
--               appointments, so only some of their rows can be linked to a hospital/department/province.
--   Hospital = FacilityID (HF001-HF020). No hospital names exist in the data.
--   Province = the patient's home province (Patient > Village > Sector > District > Province).
--   Currency = Rwandan francs (RWF).
-- ============================================================
SET search_path = hc, public;

-- ################ PATIENT ANALYSIS ################

-- Q01. Retrieve all registered patients.  (ALL: 20,000 rows; phone numbers are left out because they are corrupted)
SELECT patient_id, first_name, last_name, gender, date_of_birth, age, age_group, marital_status, occupation,
       education, village_id, insurance_id, blood_group, chronic_condition, status
FROM patients
ORDER BY patient_id;

-- Q02. Count patients by gender.  (ALL)
SELECT gender, COUNT(*) AS patients, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM patients GROUP BY gender ORDER BY patients DESC;

-- Q03. Count patients by province.  (ALL)
SELECT province_name, COUNT(*) AS patients, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM v_patient_geo GROUP BY province_name ORDER BY patients DESC;

-- Q04. Identify patients above 65 years.  (ALL)
SELECT patient_id, first_name, last_name, gender, age, chronic_condition, village_name, province_name
FROM v_patient_geo WHERE age > 65 ORDER BY age DESC, patient_id;

-- Q05. Find patients with chronic diseases, and how many have each disease.  (ALL)
SELECT chronic_condition, COUNT(*) AS patients, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM patients WHERE has_chronic_condition
GROUP BY chronic_condition ORDER BY patients DESC;

-- Q06. Retrieve patients covered by insurance.  (ALL) Every patient has an insurance scheme ID, so the result is all 20,000.
SELECT insurance_id, COUNT(*) AS covered_patients, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM patients WHERE insurance_id IS NOT NULL AND insurance_id <> ''
GROUP BY insurance_id ORDER BY insurance_id;

-- Q07. Count patients by blood group.  (ALL)
SELECT blood_group, COUNT(*) AS patients, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM patients GROUP BY blood_group ORDER BY patients DESC;

-- Q08. List the youngest and the oldest patients.  (ALL)
(SELECT 'Youngest' AS group_name, patient_id, first_name, last_name, gender, date_of_birth, age
 FROM patients WHERE date_of_birth = (SELECT MAX(date_of_birth) FROM patients) ORDER BY patient_id)
UNION ALL
(SELECT 'Oldest', patient_id, first_name, last_name, gender, date_of_birth, age
 FROM patients WHERE date_of_birth = (SELECT MIN(date_of_birth) FROM patients) ORDER BY patient_id);

-- Q09. Identify duplicate phone numbers.  (ALL) NOTE: phones were saved in scientific notation, so only 10 different values remain.
--      Every patient therefore appears as a "duplicate"; the result shows the data problem, not real duplicate people.
SELECT phone_raw, COUNT(*) AS patients_sharing_value
FROM patients GROUP BY phone_raw HAVING COUNT(*) > 1 ORDER BY patients_sharing_value DESC;

-- Q10. Calculate average patient age.  (ALL)
SELECT ROUND(AVG(age), 1) AS average_age, MIN(age) AS youngest_age, MAX(age) AS oldest_age,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY age) AS median_age
FROM patients;

-- ################ APPOINTMENT ANALYSIS ################
-- (The Appointments table has 5,000 rows, so all of this section is MATCHED.)

-- Q11. Count appointments by month.
SELECT to_char(appointment_month, 'YYYY-MM') AS month, COUNT(*) AS appointments,
       ROUND(100.0 * (COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY appointment_month)) / NULLIF(LAG(COUNT(*)) OVER (ORDER BY appointment_month), 0), 1) AS growth_pct
FROM appointments GROUP BY appointment_month ORDER BY appointment_month;

-- Q12. Identify the busiest hospitals.
SELECT facility_id AS hospital, COUNT(*) AS appointments, RANK() OVER (ORDER BY COUNT(*) DESC) AS busiest_rank
FROM appointments GROUP BY facility_id ORDER BY appointments DESC, hospital LIMIT 10;

-- Q13. Find the busiest departments.
SELECT d.department_name, COUNT(*) AS appointments, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM appointments a JOIN departments d USING (department_id)
GROUP BY d.department_name ORDER BY appointments DESC;

-- Q14. Find doctors with the highest workload.
SELECT a.doctor_id, doc.first_name || ' ' || doc.last_name AS doctor, doc.specialty, doc.facility_id AS doctor_hospital,
       COUNT(*) AS appointments
FROM appointments a JOIN doctors doc ON doc.staff_id = a.doctor_id
GROUP BY a.doctor_id, doctor, doc.specialty, doc.facility_id
ORDER BY appointments DESC, a.doctor_id LIMIT 10;

-- Q15. Identify referral patterns.  Part A uses ALL 4,708 referrals; Part B uses the MATCHED ones.
--      Part A: where patients are referred to
SELECT referred_facility_id AS referred_to_hospital, COUNT(*) AS referrals, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM referrals GROUP BY referred_facility_id ORDER BY referrals DESC LIMIT 10;
--      Part B: which hospitals send the most patients away
SELECT a.facility_id AS referred_from_hospital, COUNT(*) AS referrals_sent
FROM referrals r JOIN appointments a USING (appointment_id)
GROUP BY a.facility_id ORDER BY referrals_sent DESC LIMIT 10;

-- Q16. Count emergency appointments.
SELECT visit_type, COUNT(*) AS appointments, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM appointments GROUP BY visit_type ORDER BY appointments DESC;

-- Q17. Calculate average appointments per doctor.
SELECT COUNT(*) AS appointments, (SELECT COUNT(*) FROM doctors) AS doctors_on_staff,
       COUNT(DISTINCT doctor_id) AS doctors_with_appointments,
       ROUND(1.0 * COUNT(*) / (SELECT COUNT(*) FROM doctors), 2) AS avg_per_doctor_on_staff,
       ROUND(1.0 * COUNT(*) / COUNT(DISTINCT doctor_id), 2) AS avg_per_busy_doctor
FROM appointments;

-- Q18. Retrieve appointments by province (the patient's home province).
SELECT g.province_name, COUNT(*) AS appointments, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM appointments a JOIN v_patient_geo g USING (patient_id)
GROUP BY g.province_name ORDER BY appointments DESC;

-- Q19. Identify facilities with the highest patient volume (different patients seen).
SELECT facility_id AS hospital, COUNT(DISTINCT patient_id) AS different_patients, COUNT(*) AS appointments
FROM appointments GROUP BY facility_id ORDER BY different_patients DESC, hospital LIMIT 10;

-- Q20. Find peak consultation periods: by month, then by day of the week.
SELECT to_char(appointment_month, 'YYYY-MM') AS month, COUNT(*) AS consultations
FROM appointments WHERE visit_type = 'Consultation' GROUP BY appointment_month ORDER BY consultations DESC LIMIT 5;
SELECT to_char(appointment_date, 'Day') AS weekday, EXTRACT(ISODOW FROM appointment_date) AS day_no, COUNT(*) AS consultations
FROM appointments WHERE visit_type = 'Consultation' GROUP BY weekday, day_no ORDER BY day_no;

-- ################ CLINICAL ANALYSIS ################

-- Q21. Top diagnoses.  (ALL 60,000)
SELECT diagnosis, COUNT(*) AS cases, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM diagnoses GROUP BY diagnosis ORDER BY cases DESC LIMIT 20;

-- Q22. Most requested laboratory tests.  (ALL 5,000)
SELECT test, COUNT(*) AS requests, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM laboratory_tests GROUP BY test ORDER BY requests DESC;

-- Q23. Most prescribed medications.  (ALL 5,000)
SELECT medication, COUNT(*) AS prescriptions, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM prescriptions GROUP BY medication ORDER BY prescriptions DESC;

-- Q24. Average admission duration.  (ALL 5,000) plus the spread of stays.
SELECT ROUND(AVG(length_of_stay_days), 2) AS avg_days, MIN(length_of_stay_days) AS shortest, MAX(length_of_stay_days) AS longest,
       SUM(length_of_stay_days) AS total_bed_days, COUNT(*) AS admissions
FROM admissions;
SELECT CASE WHEN length_of_stay_days <= 3 THEN '1-3 days' WHEN length_of_stay_days <= 7 THEN '4-7 days' ELSE '8-10 days' END AS stay_length,
       COUNT(*) AS admissions
FROM admissions GROUP BY 1 ORDER BY 1;

-- Q25. Disease severity distribution.  (ALL 60,000)
SELECT severity, COUNT(*) AS cases, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM diagnoses GROUP BY severity ORDER BY cases DESC;

-- Q26. Laboratory test utilisation: requests and how many results were abnormal.  (ALL 5,000)
SELECT test, COUNT(*) AS requests, SUM((result = 'Abnormal')::int) AS abnormal_results,
       ROUND(100.0 * SUM((result = 'Abnormal')::int) / COUNT(*), 1) AS abnormal_pct
FROM laboratory_tests GROUP BY test ORDER BY requests DESC;

-- Q27. Prescription trends by month.  (MATCHED: prescriptions that can be dated through their appointment)
SELECT to_char(a.appointment_month, 'YYYY-MM') AS month, COUNT(*) AS prescriptions
FROM prescriptions rx JOIN appointments a USING (appointment_id)
GROUP BY a.appointment_month ORDER BY a.appointment_month;

-- Q28. Referral destinations.  (ALL 4,708)
SELECT referred_facility_id AS destination_hospital, COUNT(*) AS referrals
FROM referrals GROUP BY referred_facility_id ORDER BY referrals DESC;

-- Q29. Admission rate by diagnosis.  (MATCHED: admitted appointments / all appointments with that diagnosis, within the 5,000)
SELECT dg.diagnosis, COUNT(*) AS appointments, COUNT(adm.admission_id) AS admitted,
       ROUND(100.0 * COUNT(adm.admission_id) / COUNT(*), 1) AS admission_rate_pct
FROM appointments a
JOIN diagnoses dg USING (appointment_id)
LEFT JOIN admissions adm USING (appointment_id)
GROUP BY dg.diagnosis ORDER BY admission_rate_pct DESC;

-- Q30. Clinical workload by department.  (MATCHED)
SELECT d.department_name,
       COUNT(DISTINCT a.appointment_id) AS appointments,
       COUNT(DISTINCT lab.lab_id)       AS lab_tests,
       COUNT(DISTINCT rx.prescription_id) AS prescriptions,
       COUNT(DISTINCT adm.admission_id) AS admissions,
       COUNT(DISTINCT ref.referral_id)  AS referrals
FROM appointments a
JOIN departments d USING (department_id)
LEFT JOIN laboratory_tests lab USING (appointment_id)
LEFT JOIN prescriptions rx     USING (appointment_id)
LEFT JOIN admissions adm       USING (appointment_id)
LEFT JOIN referrals ref        USING (appointment_id)
GROUP BY d.department_name ORDER BY appointments DESC;

-- ################ FINANCIAL ANALYSIS ################
-- "Revenue" = amount billed. "Collected" = amount paid. "Outstanding" = billed minus paid.

-- Q31. Revenue by facility.  (MATCHED: bills that belong to the 5,000 detailed appointments)
SELECT facility_id AS hospital, COUNT(*) AS billed_appointments, SUM(billed_amount) AS revenue_rwf,
       SUM(paid_amount) AS collected_rwf, ROUND(100.0 * SUM(paid_amount) / SUM(billed_amount), 1) AS collected_pct
FROM v_appointment_detail GROUP BY facility_id ORDER BY revenue_rwf DESC;

-- Q32. Revenue by department.  (MATCHED)
SELECT department_name, COUNT(*) AS billed_appointments, SUM(billed_amount) AS revenue_rwf, ROUND(AVG(billed_amount)) AS avg_bill_rwf
FROM v_appointment_detail GROUP BY department_name ORDER BY revenue_rwf DESC;

-- Q33. Revenue by service.  (MATCHED) The data has no service on a bill, so the type of visit is used as the service line.
SELECT visit_type AS service_line, COUNT(*) AS billed_appointments, SUM(billed_amount) AS revenue_rwf,
       ROUND(100.0 * SUM(billed_amount) / SUM(SUM(billed_amount)) OVER (), 1) AS pct_of_revenue
FROM v_appointment_detail GROUP BY visit_type ORDER BY revenue_rwf DESC;

-- Q34. Insurance claims by provider.  (ALL 42,036 claims)
SELECT provider, COUNT(*) AS claims, SUM(claim_amount)::bigint AS claimed_rwf,
       SUM((status = 'Approved')::int) AS approved_claims,
       ROUND(100.0 * SUM((status = 'Approved')::int) / COUNT(*), 1) AS approval_rate_pct,
       SUM(CASE WHEN status = 'Approved' THEN claim_amount ELSE 0 END)::bigint AS approved_rwf
FROM insurance_claims GROUP BY provider ORDER BY claimed_rwf DESC;

-- Q35. Outstanding payments.  (ALL 60,000 bills) Outstanding is worked out from the payments, because the bill status label is unreliable.
SELECT SUM(billed_amount) AS billed_rwf, SUM(paid_amount) AS collected_rwf, SUM(outstanding_amount) AS outstanding_rwf,
       ROUND(100.0 * SUM(outstanding_amount) / SUM(billed_amount), 1) AS outstanding_pct,
       SUM((outstanding_amount > 0)::int) AS bills_not_fully_paid
FROM v_billing_detail;
SELECT billing_status, COUNT(*) AS bills, SUM(billed_amount) AS billed_rwf, SUM(outstanding_amount) AS outstanding_rwf
FROM v_billing_detail GROUP BY billing_status ORDER BY outstanding_rwf DESC;

-- Q36. Average billing amount.  (ALL)
SELECT ROUND(AVG(amount)) AS avg_bill_rwf, MIN(amount) AS smallest_bill, MAX(amount) AS largest_bill,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount) AS median_bill, COUNT(*) AS bills
FROM billing;

-- Q37. Monthly revenue trend with month-on-month growth.  (Revenue Summary table)
SELECT to_char(month_start, 'YYYY-MM') AS month, revenue AS revenue_rwf, appointments,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month_start)) / LAG(revenue) OVER (ORDER BY month_start), 1) AS growth_pct
FROM revenue_summary ORDER BY month_start;

-- Q38. Payment methods.  (ALL 60,000 payments)
SELECT method, COUNT(*) AS payments, SUM(amount_paid) AS collected_rwf,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_payments
FROM payments GROUP BY method ORDER BY payments DESC;

-- Q39. Top revenue-generating hospitals.  (MATCHED) Top 10.
SELECT facility_id AS hospital, SUM(billed_amount) AS revenue_rwf, COUNT(*) AS billed_appointments,
       RANK() OVER (ORDER BY SUM(billed_amount) DESC) AS revenue_rank
FROM v_appointment_detail GROUP BY facility_id ORDER BY revenue_rank LIMIT 10;

-- Q40. Financial performance ranking of hospitals.  (MATCHED) Ranks revenue, collection rate and average bill, then averages the ranks.
WITH f AS (
  SELECT facility_id AS hospital, SUM(billed_amount) AS revenue, 100.0 * SUM(paid_amount) / SUM(billed_amount) AS collection_pct,
         AVG(billed_amount) AS avg_bill
  FROM v_appointment_detail GROUP BY facility_id)
SELECT hospital, revenue, ROUND(collection_pct, 1) AS collection_pct, ROUND(avg_bill) AS avg_bill,
       RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
       RANK() OVER (ORDER BY collection_pct DESC) AS collection_rank,
       RANK() OVER (ORDER BY avg_bill DESC) AS avg_bill_rank,
       ROUND((RANK() OVER (ORDER BY revenue DESC) + RANK() OVER (ORDER BY collection_pct DESC) + RANK() OVER (ORDER BY avg_bill DESC)) / 3.0, 1) AS average_rank
FROM f ORDER BY average_rank, hospital;
