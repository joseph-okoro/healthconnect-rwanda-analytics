-- ============================================================
-- HealthConnect Rwanda | Step 5: Power BI-ready tables (star schema) and CSV export
-- Run after steps 01-04 in pgAdmin: Query Tool > open this file > F5.
-- Output: CSV files in C:/HealthConnect_Data/PowerBI_Data/  (create that folder first; load the files into Power BI Desktop)
-- Needs the postgres user. Alternative: run a SELECT on a pbi table and click the Download icon in the Query Tool results.
--
-- Design notes
--   * Facts (billing, diagnoses, feedback, labs ...) point to up to 60,000 appointments, but the Appointments table
--     holds only 5,000. Every fact therefore carries a column  link_status  = 'Linked' / 'Not linked'.
--     'Linked'     : the appointment exists, so hospital, department, visit type, patient province and month are known.
--     'Not linked' : the appointment is missing, so those columns are empty (NULL).
--     Totals use every row. Hospital / department / province visuals use  link_status = 'Linked'  (visual filter).
--   * Department is analysed by NAME (10 types) because department IDs do not match the facility recorded on the appointment.
--   * Province = the patient's home province (no facility location exists in the data).
-- ============================================================
DROP SCHEMA IF EXISTS pbi CASCADE;
CREATE SCHEMA pbi;
SET search_path = pbi, hc, public;

-- Link table: one row per appointment with all descriptive columns
CREATE VIEW link AS
SELECT a.appointment_id, a.appointment_date, a.appointment_month, a.visit_type, a.facility_id, d.department_name,
       a.doctor_id, a.patient_id, g.province_name, g.district_name
FROM hc.appointments a
JOIN hc.departments d ON d.department_id = a.department_id
JOIN hc.v_patient_geo g ON g.patient_id = a.patient_id;

-- ---------- Dimensions ----------
CREATE TABLE dim_date AS
SELECT d::date AS date, EXTRACT(YEAR FROM d)::int AS year, EXTRACT(QUARTER FROM d)::int AS quarter_no,
       'Q' || EXTRACT(QUARTER FROM d)::int AS quarter, EXTRACT(MONTH FROM d)::int AS month_no,
       to_char(d, 'Mon') AS month_name, to_char(d, 'YYYY-MM') AS year_month, date_trunc('month', d)::date AS month_start,
       EXTRACT(ISODOW FROM d)::int AS weekday_no, trim(to_char(d, 'Day')) AS weekday_name,
       CASE WHEN d > DATE '2026-10-22' THEN 'After analysis date' ELSE 'Up to analysis date' END AS period_flag
FROM generate_series(DATE '2026-01-01', DATE '2026-12-31', INTERVAL '1 day') AS d;

CREATE TABLE dim_facility AS
SELECT f.facility_id,
       COALESCE(s.doctors,0) AS doctors, COALESCE(s.nurses,0) AS nurses, COALESCE(s.pharmacists,0) AS pharmacists,
       COALESCE(s.lab_scientists,0) AS lab_scientists, COALESCE(s.radiographers,0) AS radiographers,
       COALESCE(s.admin_staff,0) AS admin_staff, COALESCE(s.total_staff,0) AS total_staff,
       (SELECT COUNT(*) FROM hc.departments x WHERE x.facility_id = f.facility_id) AS departments,
       (SELECT COUNT(*) FROM hc.rooms r WHERE r.facility_id = f.facility_id) AS rooms,
       (SELECT COUNT(*) FROM hc.beds b JOIN hc.rooms r USING (room_id) WHERE r.facility_id = f.facility_id) AS beds,
       (SELECT COUNT(*) FROM hc.medical_equipment e WHERE e.facility_id = f.facility_id) AS equipment_items
FROM hc.health_facilities f
LEFT JOIN (SELECT facility_id,
                  COUNT(*) FILTER (WHERE role='Doctor') AS doctors, COUNT(*) FILTER (WHERE role='Nurse') AS nurses,
                  COUNT(*) FILTER (WHERE role='Pharmacist') AS pharmacists, COUNT(*) FILTER (WHERE role='Laboratory Scientist') AS lab_scientists,
                  COUNT(*) FILTER (WHERE role='Radiographer') AS radiographers, COUNT(*) FILTER (WHERE role='Administrative Staff') AS admin_staff,
                  COUNT(*) AS total_staff
           FROM hc.staff_all GROUP BY facility_id) s USING (facility_id);

CREATE TABLE dim_department AS
SELECT d.department_name,
       COUNT(DISTINCT d.department_id) AS department_units,
       (SELECT COUNT(*) FROM hc.rooms r JOIN hc.departments x USING (department_id) WHERE x.department_name = d.department_name) AS rooms,
       (SELECT COUNT(*) FROM hc.beds b JOIN hc.rooms r USING (room_id) JOIN hc.departments x USING (department_id) WHERE x.department_name = d.department_name) AS beds,
       (SELECT COUNT(*) FROM hc.medical_equipment e JOIN hc.departments x USING (department_id) WHERE x.department_name = d.department_name) AS equipment_items,
       (SELECT COUNT(*) FROM hc.staff_all s WHERE s.department_name = d.department_name) AS staff
FROM hc.departments d GROUP BY d.department_name;

CREATE TABLE dim_patient AS
SELECT patient_id, first_name, last_name, gender, date_of_birth, age, age_group,
       CASE WHEN age < 18 THEN 'Under 18' WHEN age < 35 THEN '18-34' WHEN age < 50 THEN '35-49' WHEN age < 65 THEN '50-64' ELSE '65+' END AS age_band,
       blood_group, insurance_id, chronic_condition, CASE WHEN has_chronic_condition THEN 'Yes' ELSE 'No' END AS has_chronic_condition, status, village_name, sector_name, district_name, province_name,
       (SELECT COUNT(*) FROM hc.appointments a WHERE a.patient_id = g.patient_id) AS appointments_count
FROM hc.v_patient_geo g;

CREATE TABLE dim_province AS
SELECT province_id, province_name FROM hc.provinces;

-- ---------- Facts ----------
CREATE TABLE fact_appointments AS
SELECT l.appointment_id, l.appointment_date AS date, l.visit_type, l.facility_id, l.department_name, l.doctor_id, l.patient_id,
       l.province_name, l.district_name,
       CASE WHEN adm.admission_id IS NOT NULL THEN 'Yes' ELSE 'No' END AS was_admitted, adm.length_of_stay_days,
       CASE WHEN ref.referral_id IS NOT NULL THEN 'Yes' ELSE 'No' END AS was_referred,
       CASE WHEN lab.cnt > 0 THEN 'Yes' ELSE 'No' END AS had_lab_test, CASE WHEN rx.cnt > 0 THEN 'Yes' ELSE 'No' END AS had_prescription,
       b.amount AS billed_amount, COALESCE(p.paid,0) AS paid_amount,
       fb.rating AS rating
FROM link l
LEFT JOIN hc.admissions adm USING (appointment_id)
LEFT JOIN (SELECT appointment_id, MIN(referral_id) AS referral_id FROM hc.referrals GROUP BY 1) ref USING (appointment_id)
LEFT JOIN (SELECT appointment_id, COUNT(*) AS cnt FROM hc.laboratory_tests GROUP BY 1) lab USING (appointment_id)
LEFT JOIN (SELECT appointment_id, COUNT(*) AS cnt FROM hc.prescriptions GROUP BY 1) rx USING (appointment_id)
LEFT JOIN hc.billing b USING (appointment_id)
LEFT JOIN (SELECT billing_id, SUM(amount_paid) AS paid FROM hc.payments GROUP BY 1) p USING (billing_id)
LEFT JOIN (SELECT appointment_id, MAX(rating) AS rating FROM hc.patient_feedback GROUP BY 1) fb USING (appointment_id);

CREATE TABLE fact_billing AS
SELECT v.billing_id, v.appointment_id, v.billed_amount, v.paid_amount, v.outstanding_amount, v.billing_status, v.payment_method,
       v.claim_provider, v.claim_amount, v.claim_status,
       CASE WHEN l.appointment_id IS NULL THEN 'Not linked' ELSE 'Linked' END AS link_status,
       l.appointment_date AS date, l.facility_id, l.department_name, l.visit_type, l.province_name, l.patient_id
FROM hc.v_billing_detail v LEFT JOIN link l USING (appointment_id);

CREATE TABLE fact_diagnoses AS
SELECT dg.diagnosis_id, dg.appointment_id, dg.diagnosis, dg.severity,
       CASE WHEN l.appointment_id IS NULL THEN 'Not linked' ELSE 'Linked' END AS link_status,
       l.appointment_date AS date, l.facility_id, l.department_name, l.visit_type, l.province_name, l.patient_id
FROM hc.diagnoses dg LEFT JOIN link l USING (appointment_id);

CREATE TABLE fact_feedback AS
SELECT f.feedback_id, f.appointment_id, f.rating, f.comment,
       CASE WHEN f.rating <= 2 THEN 'Poor (1-2)' WHEN f.rating = 3 THEN 'Average (3)' ELSE 'Excellent (4-5)' END AS rating_band,
       CASE WHEN l.appointment_id IS NULL THEN 'Not linked' ELSE 'Linked' END AS link_status,
       l.appointment_date AS date, l.facility_id, l.department_name, l.visit_type, l.province_name, l.patient_id
FROM hc.patient_feedback f LEFT JOIN link l USING (appointment_id);

CREATE TABLE fact_lab_tests AS
SELECT t.lab_id, t.appointment_id, t.test, t.result,
       CASE WHEN l.appointment_id IS NULL THEN 'Not linked' ELSE 'Linked' END AS link_status,
       l.appointment_date AS date, l.facility_id, l.department_name, l.province_name
FROM hc.laboratory_tests t LEFT JOIN link l USING (appointment_id);

CREATE TABLE fact_prescriptions AS
SELECT t.prescription_id, t.appointment_id, t.medication, t.dosage,
       CASE WHEN l.appointment_id IS NULL THEN 'Not linked' ELSE 'Linked' END AS link_status,
       l.appointment_date AS date, l.facility_id, l.department_name, l.province_name
FROM hc.prescriptions t LEFT JOIN link l USING (appointment_id);

CREATE TABLE fact_admissions AS
SELECT t.admission_id, t.appointment_id, t.length_of_stay_days,
       CASE WHEN l.appointment_id IS NULL THEN 'Not linked' ELSE 'Linked' END AS link_status,
       l.appointment_date AS date, l.facility_id, l.department_name, l.province_name, l.patient_id
FROM hc.admissions t LEFT JOIN link l USING (appointment_id);

CREATE TABLE fact_referrals AS
SELECT t.referral_id, t.appointment_id, t.referred_facility_id,
       CASE WHEN l.appointment_id IS NULL THEN 'Not linked' ELSE 'Linked' END AS link_status,
       l.appointment_date AS date, l.facility_id AS from_facility_id, l.department_name, l.province_name
FROM hc.referrals t LEFT JOIN link l USING (appointment_id);

CREATE TABLE fact_staff AS
SELECT staff_id, first_name, last_name, role, department_name, specialty, facility_id, years_experience, status FROM hc.staff_all;

CREATE TABLE fact_beds AS
SELECT b.bed_id, b.room_id, b.status AS bed_status, r.facility_id, d.department_name FROM hc.beds b
JOIN hc.rooms r USING (room_id) JOIN hc.departments d ON d.department_id = r.department_id;

CREATE TABLE fact_equipment AS
SELECT e.equipment_id, e.equipment_name, e.facility_id, d.department_name FROM hc.medical_equipment e JOIN hc.departments d USING (department_id);

CREATE TABLE fact_revenue_summary AS
SELECT month_start, to_char(month_start,'YYYY-MM') AS year_month, revenue, appointments FROM hc.revenue_summary;

CREATE TABLE data_quality_log AS SELECT * FROM hc.data_quality_log;

-- ---------- Export to CSV ----------
COPY pbi.dim_date TO 'C:/HealthConnect_Data/PowerBI_Data/dim_date.csv' CSV HEADER;
COPY pbi.dim_facility TO 'C:/HealthConnect_Data/PowerBI_Data/dim_facility.csv' CSV HEADER;
COPY pbi.dim_department TO 'C:/HealthConnect_Data/PowerBI_Data/dim_department.csv' CSV HEADER;
COPY pbi.dim_patient TO 'C:/HealthConnect_Data/PowerBI_Data/dim_patient.csv' CSV HEADER;
COPY pbi.dim_province TO 'C:/HealthConnect_Data/PowerBI_Data/dim_province.csv' CSV HEADER;
COPY pbi.fact_appointments TO 'C:/HealthConnect_Data/PowerBI_Data/fact_appointments.csv' CSV HEADER;
COPY pbi.fact_billing TO 'C:/HealthConnect_Data/PowerBI_Data/fact_billing.csv' CSV HEADER;
COPY pbi.fact_diagnoses TO 'C:/HealthConnect_Data/PowerBI_Data/fact_diagnoses.csv' CSV HEADER;
COPY pbi.fact_feedback TO 'C:/HealthConnect_Data/PowerBI_Data/fact_feedback.csv' CSV HEADER;
COPY pbi.fact_lab_tests TO 'C:/HealthConnect_Data/PowerBI_Data/fact_lab_tests.csv' CSV HEADER;
COPY pbi.fact_prescriptions TO 'C:/HealthConnect_Data/PowerBI_Data/fact_prescriptions.csv' CSV HEADER;
COPY pbi.fact_admissions TO 'C:/HealthConnect_Data/PowerBI_Data/fact_admissions.csv' CSV HEADER;
COPY pbi.fact_referrals TO 'C:/HealthConnect_Data/PowerBI_Data/fact_referrals.csv' CSV HEADER;
COPY pbi.fact_staff TO 'C:/HealthConnect_Data/PowerBI_Data/fact_staff.csv' CSV HEADER;
COPY pbi.fact_beds TO 'C:/HealthConnect_Data/PowerBI_Data/fact_beds.csv' CSV HEADER;
COPY pbi.fact_equipment TO 'C:/HealthConnect_Data/PowerBI_Data/fact_equipment.csv' CSV HEADER;
COPY pbi.fact_revenue_summary TO 'C:/HealthConnect_Data/PowerBI_Data/fact_revenue_summary.csv' CSV HEADER;
COPY pbi.data_quality_log TO 'C:/HealthConnect_Data/PowerBI_Data/data_quality_log.csv' CSV HEADER;
