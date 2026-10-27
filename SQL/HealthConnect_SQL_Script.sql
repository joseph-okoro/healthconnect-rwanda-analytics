-- HealthConnect Rwanda | Combined SQL script (steps 01 to 04), for pgAdmin Query Tool. Set the data folder path in step 01 first.

-- ======================= 01_create_staging_and_load.sql =======================
-- ============================================================
-- HealthConnect Rwanda | Step 1: staging tables and raw data load
-- HOW TO RUN (pgAdmin): 1) copy the project's Data folder to C:\HealthConnect_Data   (so C:\HealthConnect_Data\HC_Patients.csv exists)
--   2) right-click the database > Query Tool > open this file > press F5 (Execute).
--   Log in as the postgres user (COPY reads files on the computer running PostgreSQL).
--   If your folder is elsewhere, use Find/Replace (Ctrl+H) to change  C:/HealthConnect_Data/  to your own path (use forward slashes).
--   If you get 'Permission denied', move the folder to a public place such as C:/Users/Public/HealthConnect_Data/, or use the pgAdmin Import/Export Data tool on each staging table.
-- Every staging column is TEXT so that nothing is lost or changed on the way in.
-- ============================================================

CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.stg_administrative_staff CASCADE;
CREATE TABLE staging.stg_administrative_staff (staffid TEXT, firstname TEXT, lastname TEXT, role TEXT, department TEXT, specialty TEXT, facilityid TEXT, departmentid TEXT, yearsexperience TEXT, status TEXT);
COPY staging.stg_administrative_staff FROM 'C:/HealthConnect_Data/HC_Administrative_Staff.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_admissions CASCADE;
CREATE TABLE staging.stg_admissions (admissionid TEXT, appointmentid TEXT, lengthofstaydays TEXT);
COPY staging.stg_admissions FROM 'C:/HealthConnect_Data/HC_Admissions.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_appointments CASCADE;
CREATE TABLE staging.stg_appointments (appointmentid TEXT, patientid TEXT, doctorid TEXT, facilityid TEXT, departmentid TEXT, date TEXT, visittype TEXT);
COPY staging.stg_appointments FROM 'C:/HealthConnect_Data/HC_Appointments.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_beds CASCADE;
CREATE TABLE staging.stg_beds (bedid TEXT, roomid TEXT, status TEXT);
COPY staging.stg_beds FROM 'C:/HealthConnect_Data/HC_Beds.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_billing CASCADE;
CREATE TABLE staging.stg_billing (billingid TEXT, appointmentid TEXT, amount TEXT, status TEXT);
COPY staging.stg_billing FROM 'C:/HealthConnect_Data/HC_Billing.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_countries CASCADE;
CREATE TABLE staging.stg_countries (countryid TEXT, countryname TEXT, iso2 TEXT, iso3 TEXT, currency TEXT, region TEXT);
COPY staging.stg_countries FROM 'C:/HealthConnect_Data/HC_Countries.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_departments CASCADE;
CREATE TABLE staging.stg_departments (departmentid TEXT, departmentname TEXT, facilityid TEXT);
COPY staging.stg_departments FROM 'C:/HealthConnect_Data/HC_Departments.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_diagnoses CASCADE;
CREATE TABLE staging.stg_diagnoses (diagnosisid TEXT, appointmentid TEXT, diagnosis TEXT, severity TEXT);
COPY staging.stg_diagnoses FROM 'C:/HealthConnect_Data/HC_Diagnoses.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_districts CASCADE;
CREATE TABLE staging.stg_districts (districtid TEXT, districtname TEXT, provinceid TEXT);
COPY staging.stg_districts FROM 'C:/HealthConnect_Data/HC_Districts.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_doctor CASCADE;
CREATE TABLE staging.stg_doctor (staffid TEXT, firstname TEXT, lastname TEXT, role TEXT, department TEXT, specialty TEXT, facilityid TEXT, departmentid TEXT, yearsexperience TEXT, status TEXT);
COPY staging.stg_doctor FROM 'C:/HealthConnect_Data/HC_Doctor.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_insurance_claims CASCADE;
CREATE TABLE staging.stg_insurance_claims (claimid TEXT, billingid TEXT, provider TEXT, claimamount TEXT, status TEXT);
COPY staging.stg_insurance_claims FROM 'C:/HealthConnect_Data/HC_Insurance_Claims.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_laboratory_scientist CASCADE;
CREATE TABLE staging.stg_laboratory_scientist (staffid TEXT, firstname TEXT, lastname TEXT, role TEXT, department TEXT, specialty TEXT, facilityid TEXT, departmentid TEXT, yearsexperience TEXT, status TEXT);
COPY staging.stg_laboratory_scientist FROM 'C:/HealthConnect_Data/HC_Laboratory_Scientist.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_laboratory_tests CASCADE;
CREATE TABLE staging.stg_laboratory_tests (labid TEXT, appointmentid TEXT, test TEXT, result TEXT);
COPY staging.stg_laboratory_tests FROM 'C:/HealthConnect_Data/HC_Laboratory_Tests.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_medical_equipment CASCADE;
CREATE TABLE staging.stg_medical_equipment (equipmentid TEXT, equipmentname TEXT, departmentid TEXT, facilityid TEXT);
COPY staging.stg_medical_equipment FROM 'C:/HealthConnect_Data/HC_Medical_Equipment.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_medical_specialties CASCADE;
CREATE TABLE staging.stg_medical_specialties (specialtyid TEXT, specialty TEXT, departmentid TEXT);
COPY staging.stg_medical_specialties FROM 'C:/HealthConnect_Data/HC_Medical_Specialties.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_nurse CASCADE;
CREATE TABLE staging.stg_nurse (staffid TEXT, firstname TEXT, lastname TEXT, role TEXT, department TEXT, specialty TEXT, facilityid TEXT, departmentid TEXT, yearsexperience TEXT, status TEXT);
COPY staging.stg_nurse FROM 'C:/HealthConnect_Data/HC_Nurse.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_ownership_types CASCADE;
CREATE TABLE staging.stg_ownership_types (ownershipid TEXT, ownership TEXT);
COPY staging.stg_ownership_types FROM 'C:/HealthConnect_Data/HC_Ownership_Types.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_patient_feedback CASCADE;
CREATE TABLE staging.stg_patient_feedback (feedbackid TEXT, appointmentid TEXT, rating TEXT, comment TEXT);
COPY staging.stg_patient_feedback FROM 'C:/HealthConnect_Data/HC_Patient_Feedback.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_patients CASCADE;
CREATE TABLE staging.stg_patients (patientid TEXT, firstname TEXT, lastname TEXT, gender TEXT, dateofbirth TEXT, age TEXT, maritalstatus TEXT, occupation TEXT, education TEXT, villageid TEXT, insuranceid TEXT, bloodgroup TEXT, heightcm TEXT, weightkg TEXT, chroniccondition TEXT, phone TEXT, emergencycontact TEXT, status TEXT, bmi TEXT);
COPY staging.stg_patients FROM 'C:/HealthConnect_Data/HC_Patients.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_payments CASCADE;
CREATE TABLE staging.stg_payments (paymentid TEXT, billingid TEXT, amountpaid TEXT, method TEXT);
COPY staging.stg_payments FROM 'C:/HealthConnect_Data/HC_Payments.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_pharmacist CASCADE;
CREATE TABLE staging.stg_pharmacist (staffid TEXT, firstname TEXT, lastname TEXT, role TEXT, department TEXT, specialty TEXT, facilityid TEXT, departmentid TEXT, yearsexperience TEXT, status TEXT);
COPY staging.stg_pharmacist FROM 'C:/HealthConnect_Data/HC_Pharmacist.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_prescriptions CASCADE;
CREATE TABLE staging.stg_prescriptions (prescriptionid TEXT, appointmentid TEXT, medication TEXT, dosage TEXT);
COPY staging.stg_prescriptions FROM 'C:/HealthConnect_Data/HC_Prescriptions.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_provinces CASCADE;
CREATE TABLE staging.stg_provinces (provinceid TEXT, provincename TEXT, countryid TEXT);
COPY staging.stg_provinces FROM 'C:/HealthConnect_Data/HC_Provinces.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_radiographer CASCADE;
CREATE TABLE staging.stg_radiographer (staffid TEXT, firstname TEXT, lastname TEXT, role TEXT, department TEXT, specialty TEXT, facilityid TEXT, departmentid TEXT, yearsexperience TEXT, status TEXT);
COPY staging.stg_radiographer FROM 'C:/HealthConnect_Data/HC_Radiographer.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_referrals CASCADE;
CREATE TABLE staging.stg_referrals (referralid TEXT, appointmentid TEXT, referredfacilityid TEXT);
COPY staging.stg_referrals FROM 'C:/HealthConnect_Data/HC_Referrals.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_revenue_summary CASCADE;
CREATE TABLE staging.stg_revenue_summary (month TEXT, revenue TEXT, appointments TEXT);
COPY staging.stg_revenue_summary FROM 'C:/HealthConnect_Data/HC_Revenue_Summary.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_rooms CASCADE;
CREATE TABLE staging.stg_rooms (roomid TEXT, departmentid TEXT, facilityid TEXT, roomname TEXT);
COPY staging.stg_rooms FROM 'C:/HealthConnect_Data/HC_Rooms.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_sectors CASCADE;
CREATE TABLE staging.stg_sectors (sectorid TEXT, sectorname TEXT, districtid TEXT);
COPY staging.stg_sectors FROM 'C:/HealthConnect_Data/HC_Sectors.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_services CASCADE;
CREATE TABLE staging.stg_services (serviceid TEXT, servicename TEXT, departmentid TEXT);
COPY staging.stg_services FROM 'C:/HealthConnect_Data/HC_Services.csv' WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS staging.stg_villages CASCADE;
CREATE TABLE staging.stg_villages (villageid TEXT, villagename TEXT, sectorid TEXT);
COPY staging.stg_villages FROM 'C:/HealthConnect_Data/HC_Villages.csv' WITH (FORMAT csv, HEADER true);

-- ======================= 02_clean_and_build.sql =======================
-- ============================================================
-- HealthConnect Rwanda | Step 2: clean the staging data and build the final tables
-- Run after 01_create_staging_and_load.sql
--   pgAdmin: Query Tool > open this file > F5.
--
-- What this script does
--   * trims text, converts dates and numbers to proper types
--   * adds primary keys, foreign keys and CHECK rules where the data allows
--   * adds helper columns (age group, chronic-disease flag, valid-phone flag, etc.)
--   * creates views that join the tables the way the business questions need
--
-- Important data notes (also described in the README and the report)
--   * There is no Health Facilities list in the data, so a facility is known only by its ID (HF001-HF020).
--   * Billing, Diagnoses, Feedback and the other clinical tables point to up to 60,000 appointments,
--     but the Appointments table holds only 5,000. These links are NOT enforced as foreign keys.
--     Hospital / department / province results therefore use the 5,000 appointments that can be matched.
--   * Phone numbers arrived in scientific notation (e.g. 2.50788E+11) and cannot be repaired.
-- ============================================================

DROP SCHEMA IF EXISTS hc CASCADE;
CREATE SCHEMA hc;
SET search_path = hc, public;

-- ------------------------------------------------------------
-- 1. Geography
-- ------------------------------------------------------------
CREATE TABLE countries AS
SELECT trim(countryid) AS country_id, trim(countryname) AS country_name, trim(iso2) AS iso2,
       trim(iso3) AS iso3, trim(currency) AS currency, trim(region) AS region
FROM staging.stg_countries;
ALTER TABLE countries ADD PRIMARY KEY (country_id);

CREATE TABLE provinces AS
SELECT trim(provinceid) AS province_id, trim(provincename) AS province_name, trim(countryid) AS country_id
FROM staging.stg_provinces;
ALTER TABLE provinces ADD PRIMARY KEY (province_id);
ALTER TABLE provinces ADD FOREIGN KEY (country_id) REFERENCES countries(country_id);

CREATE TABLE districts AS
SELECT trim(districtid) AS district_id, trim(districtname) AS district_name, trim(provinceid) AS province_id
FROM staging.stg_districts;
ALTER TABLE districts ADD PRIMARY KEY (district_id);
ALTER TABLE districts ADD FOREIGN KEY (province_id) REFERENCES provinces(province_id);

CREATE TABLE sectors AS
SELECT trim(sectorid) AS sector_id, trim(sectorname) AS sector_name, trim(districtid) AS district_id
FROM staging.stg_sectors;
ALTER TABLE sectors ADD PRIMARY KEY (sector_id);
ALTER TABLE sectors ADD FOREIGN KEY (district_id) REFERENCES districts(district_id);

CREATE TABLE villages AS
SELECT trim(villageid) AS village_id, trim(villagename) AS village_name, trim(sectorid) AS sector_id
FROM staging.stg_villages;
ALTER TABLE villages ADD PRIMARY KEY (village_id);
ALTER TABLE villages ADD FOREIGN KEY (sector_id) REFERENCES sectors(sector_id);

CREATE TABLE ownership_types AS
SELECT trim(ownershipid) AS ownership_id, trim(ownership) AS ownership_type FROM staging.stg_ownership_types;
ALTER TABLE ownership_types ADD PRIMARY KEY (ownership_id);

-- ------------------------------------------------------------
-- 2. Facilities, departments and hospital resources
-- ------------------------------------------------------------
-- No facility master list was supplied, so the facility table is built from the IDs used in Departments.
CREATE TABLE health_facilities AS
SELECT DISTINCT trim(facilityid) AS facility_id FROM staging.stg_departments;
ALTER TABLE health_facilities ADD PRIMARY KEY (facility_id);

CREATE TABLE departments AS
SELECT trim(departmentid) AS department_id, trim(departmentname) AS department_name, trim(facilityid) AS facility_id
FROM staging.stg_departments;
ALTER TABLE departments ADD PRIMARY KEY (department_id);
ALTER TABLE departments ADD FOREIGN KEY (facility_id) REFERENCES health_facilities(facility_id);

CREATE TABLE medical_specialties AS
SELECT trim(specialtyid) AS specialty_id, trim(specialty) AS specialty, trim(departmentid) AS department_id
FROM staging.stg_medical_specialties;
ALTER TABLE medical_specialties ADD PRIMARY KEY (specialty_id);
ALTER TABLE medical_specialties ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);

CREATE TABLE services AS
SELECT trim(serviceid) AS service_id, trim(servicename) AS service_name, trim(departmentid) AS department_id
FROM staging.stg_services;
ALTER TABLE services ADD PRIMARY KEY (service_id);
ALTER TABLE services ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);

CREATE TABLE medical_equipment AS
SELECT trim(equipmentid) AS equipment_id, trim(equipmentname) AS equipment_name,
       trim(departmentid) AS department_id, trim(facilityid) AS facility_id
FROM staging.stg_medical_equipment;
ALTER TABLE medical_equipment ADD PRIMARY KEY (equipment_id);
ALTER TABLE medical_equipment ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE medical_equipment ADD FOREIGN KEY (facility_id) REFERENCES health_facilities(facility_id);

CREATE TABLE rooms AS
SELECT trim(roomid) AS room_id, trim(departmentid) AS department_id, trim(facilityid) AS facility_id, trim(roomname) AS room_name
FROM staging.stg_rooms;
ALTER TABLE rooms ADD PRIMARY KEY (room_id);
ALTER TABLE rooms ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE rooms ADD FOREIGN KEY (facility_id) REFERENCES health_facilities(facility_id);

CREATE TABLE beds AS
SELECT trim(bedid) AS bed_id, trim(roomid) AS room_id, trim(status) AS status FROM staging.stg_beds;
ALTER TABLE beds ADD PRIMARY KEY (bed_id);
ALTER TABLE beds ADD FOREIGN KEY (room_id) REFERENCES rooms(room_id);

-- ------------------------------------------------------------
-- 3. Staff (one table per role, plus a combined view)
-- ------------------------------------------------------------
-- the six staff files share the same layout, so one loop builds all six clean tables
DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT * FROM (VALUES
      ('doctors','stg_doctor'), ('nurses','stg_nurse'), ('pharmacists','stg_pharmacist'),
      ('laboratory_scientists','stg_laboratory_scientist'), ('radiographers','stg_radiographer'),
      ('administrative_staff','stg_administrative_staff')) AS t(clean_name, stg_name)
  LOOP
    EXECUTE format($f$
      CREATE TABLE hc.%I AS
      SELECT trim(staffid) AS staff_id, trim(firstname) AS first_name, trim(lastname) AS last_name,
             trim(role) AS role, trim(department) AS department_name, trim(specialty) AS specialty,
             trim(facilityid) AS facility_id, trim(departmentid) AS department_id,
             yearsexperience::int AS years_experience, trim(status) AS status
      FROM staging.%I $f$, r.clean_name, r.stg_name);
    EXECUTE format('ALTER TABLE hc.%I ADD PRIMARY KEY (staff_id)', r.clean_name);
    EXECUTE format('ALTER TABLE hc.%I ADD FOREIGN KEY (facility_id) REFERENCES hc.health_facilities(facility_id)', r.clean_name);
    EXECUTE format('ALTER TABLE hc.%I ADD FOREIGN KEY (department_id) REFERENCES hc.departments(department_id)', r.clean_name);
    EXECUTE format('ALTER TABLE hc.%I ADD CONSTRAINT chk_%s_exp CHECK (years_experience BETWEEN 0 AND 60)', r.clean_name, r.clean_name);
  END LOOP;
END $$;

CREATE VIEW staff_all AS
SELECT * FROM doctors UNION ALL SELECT * FROM nurses UNION ALL SELECT * FROM pharmacists
UNION ALL SELECT * FROM laboratory_scientists UNION ALL SELECT * FROM radiographers
UNION ALL SELECT * FROM administrative_staff;

-- ------------------------------------------------------------
-- 4. Patients
-- ------------------------------------------------------------
CREATE TABLE patients AS
SELECT trim(patientid)                          AS patient_id,
       trim(firstname)                          AS first_name,
       trim(lastname)                           AS last_name,
       trim(gender)                             AS gender,
       to_date(trim(dateofbirth), 'MM/DD/YYYY') AS date_of_birth,
       age::int                                 AS age,
       CASE WHEN age::int < 18 THEN '0-17'
            WHEN age::int < 35 THEN '18-34'
            WHEN age::int < 50 THEN '35-49'
            WHEN age::int < 65 THEN '50-64'
            ELSE '65+' END                      AS age_group,
       trim(maritalstatus)                      AS marital_status,
       trim(occupation)                         AS occupation,
       trim(education)                          AS education,
       trim(villageid)                          AS village_id,
       trim(insuranceid)                        AS insurance_id,
       trim(bloodgroup)                         AS blood_group,
       heightcm::int                            AS height_cm,
       weightkg::int                            AS weight_kg,
       bmi::numeric(4,1)                        AS bmi,
       trim(chroniccondition)                   AS chronic_condition,
       (trim(chroniccondition) <> 'None')       AS has_chronic_condition,
       trim(phone)                              AS phone_raw,
       (trim(phone) !~* 'E')                    AS phone_valid,   -- FALSE = corrupted scientific notation
       trim(emergencycontact)                   AS emergency_contact,
       trim(status)                             AS status
FROM staging.stg_patients;
ALTER TABLE patients ADD PRIMARY KEY (patient_id);
ALTER TABLE patients ADD FOREIGN KEY (village_id) REFERENCES villages(village_id);
ALTER TABLE patients ADD CONSTRAINT chk_gender CHECK (gender IN ('Male','Female'));
ALTER TABLE patients ADD CONSTRAINT chk_age CHECK (age BETWEEN 0 AND 120);

-- ------------------------------------------------------------
-- 5. Clinical transactions
-- ------------------------------------------------------------
CREATE TABLE appointments AS
SELECT trim(appointmentid) AS appointment_id, trim(patientid) AS patient_id, trim(doctorid) AS doctor_id,
       trim(facilityid) AS facility_id, trim(departmentid) AS department_id,
       "date"::date AS appointment_date, date_trunc('month', "date"::date)::date AS appointment_month,
       trim(visittype) AS visit_type
FROM staging.stg_appointments;
ALTER TABLE appointments ADD PRIMARY KEY (appointment_id);
ALTER TABLE appointments ADD FOREIGN KEY (patient_id) REFERENCES patients(patient_id);
ALTER TABLE appointments ADD FOREIGN KEY (doctor_id) REFERENCES doctors(staff_id);
ALTER TABLE appointments ADD FOREIGN KEY (facility_id) REFERENCES health_facilities(facility_id);
ALTER TABLE appointments ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE appointments ADD CONSTRAINT chk_visit CHECK (visit_type IN ('Consultation','Emergency','Follow-up'));

CREATE TABLE diagnoses AS
SELECT trim(diagnosisid) AS diagnosis_id, trim(appointmentid) AS appointment_id, trim(diagnosis) AS diagnosis, trim(severity) AS severity
FROM staging.stg_diagnoses;
ALTER TABLE diagnoses ADD PRIMARY KEY (diagnosis_id);
ALTER TABLE diagnoses ADD CONSTRAINT chk_sev CHECK (severity IN ('Mild','Moderate','Severe'));

CREATE TABLE laboratory_tests AS
SELECT trim(labid) AS lab_id, trim(appointmentid) AS appointment_id, trim(test) AS test, trim(result) AS result
FROM staging.stg_laboratory_tests;
ALTER TABLE laboratory_tests ADD PRIMARY KEY (lab_id);

CREATE TABLE prescriptions AS
SELECT trim(prescriptionid) AS prescription_id, trim(appointmentid) AS appointment_id, trim(medication) AS medication, trim(dosage) AS dosage
FROM staging.stg_prescriptions;
ALTER TABLE prescriptions ADD PRIMARY KEY (prescription_id);

CREATE TABLE admissions AS
SELECT trim(admissionid) AS admission_id, trim(appointmentid) AS appointment_id, lengthofstaydays::int AS length_of_stay_days
FROM staging.stg_admissions;
ALTER TABLE admissions ADD PRIMARY KEY (admission_id);
ALTER TABLE admissions ADD CONSTRAINT chk_los CHECK (length_of_stay_days > 0);

CREATE TABLE referrals AS
SELECT trim(referralid) AS referral_id, trim(appointmentid) AS appointment_id, trim(referredfacilityid) AS referred_facility_id
FROM staging.stg_referrals;
ALTER TABLE referrals ADD PRIMARY KEY (referral_id);
ALTER TABLE referrals ADD FOREIGN KEY (referred_facility_id) REFERENCES health_facilities(facility_id);

-- ------------------------------------------------------------
-- 6. Finance and patient experience
-- ------------------------------------------------------------
CREATE TABLE billing AS
SELECT trim(billingid) AS billing_id, trim(appointmentid) AS appointment_id, amount::numeric(12,0) AS amount, trim(status) AS status
FROM staging.stg_billing;
ALTER TABLE billing ADD PRIMARY KEY (billing_id);
ALTER TABLE billing ADD CONSTRAINT chk_amount CHECK (amount > 0);
ALTER TABLE billing ADD CONSTRAINT chk_bstatus CHECK (status IN ('Paid','Partially Paid','Pending'));

CREATE TABLE payments AS
SELECT trim(paymentid) AS payment_id, trim(billingid) AS billing_id, amountpaid::numeric(12,0) AS amount_paid, trim(method) AS method
FROM staging.stg_payments;
ALTER TABLE payments ADD PRIMARY KEY (payment_id);
ALTER TABLE payments ADD FOREIGN KEY (billing_id) REFERENCES billing(billing_id);

CREATE TABLE insurance_claims AS
SELECT trim(claimid) AS claim_id, trim(billingid) AS billing_id, trim(provider) AS provider,
       claimamount::numeric(12,2) AS claim_amount, trim(status) AS status
FROM staging.stg_insurance_claims;
ALTER TABLE insurance_claims ADD PRIMARY KEY (claim_id);
ALTER TABLE insurance_claims ADD FOREIGN KEY (billing_id) REFERENCES billing(billing_id);

CREATE TABLE patient_feedback AS
SELECT trim(feedbackid) AS feedback_id, trim(appointmentid) AS appointment_id, rating::int AS rating, trim(comment) AS comment
FROM staging.stg_patient_feedback;
ALTER TABLE patient_feedback ADD PRIMARY KEY (feedback_id);
ALTER TABLE patient_feedback ADD CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5);

CREATE TABLE revenue_summary AS
SELECT to_date(trim(month) || '-01', 'YYYY-MM-DD') AS month_start, revenue::bigint AS revenue, appointments::int AS appointments
FROM staging.stg_revenue_summary;
ALTER TABLE revenue_summary ADD PRIMARY KEY (month_start);

-- ------------------------------------------------------------
-- 7. Indexes for the join columns used most often
-- ------------------------------------------------------------
CREATE INDEX ix_diag_appt   ON diagnoses(appointment_id);
CREATE INDEX ix_lab_appt    ON laboratory_tests(appointment_id);
CREATE INDEX ix_rx_appt     ON prescriptions(appointment_id);
CREATE INDEX ix_adm_appt    ON admissions(appointment_id);
CREATE INDEX ix_ref_appt    ON referrals(appointment_id);
CREATE INDEX ix_bill_appt   ON billing(appointment_id);
CREATE INDEX ix_fb_appt     ON patient_feedback(appointment_id);
CREATE INDEX ix_pay_bill    ON payments(billing_id);
CREATE INDEX ix_claim_bill  ON insurance_claims(billing_id);
CREATE INDEX ix_appt_pat    ON appointments(patient_id);
CREATE INDEX ix_appt_fac    ON appointments(facility_id);

-- ------------------------------------------------------------
-- 8. Views used by the analysis and by Power BI
-- ------------------------------------------------------------
-- Where a patient lives: Patient -> Village -> Sector -> District -> Province
CREATE VIEW v_patient_geo AS
SELECT p.*, v.village_name, s.sector_name, d.district_id, d.district_name, pr.province_id, pr.province_name
FROM patients p
JOIN villages v   ON v.village_id = p.village_id
JOIN sectors s    ON s.sector_id = v.sector_id
JOIN districts d  ON d.district_id = s.district_id
JOIN provinces pr ON pr.province_id = d.province_id;

-- One row per appointment with everything that can be known about it
CREATE VIEW v_appointment_detail AS
SELECT a.appointment_id, a.appointment_date, a.appointment_month, a.visit_type,
       a.facility_id, a.department_id, dep.department_name,
       a.doctor_id, doc.specialty AS doctor_specialty,
       a.patient_id, g.gender, g.age, g.age_group, g.province_name, g.district_name,
       b.billing_id, b.amount AS billed_amount, b.status AS billing_status,
       COALESCE(pay.amount_paid, 0) AS paid_amount
FROM appointments a
JOIN departments dep   ON dep.department_id = a.department_id
JOIN doctors doc       ON doc.staff_id = a.doctor_id
JOIN v_patient_geo g   ON g.patient_id = a.patient_id
LEFT JOIN billing b    ON b.appointment_id = a.appointment_id
LEFT JOIN (SELECT billing_id, SUM(amount_paid) AS amount_paid FROM payments GROUP BY billing_id) pay
       ON pay.billing_id = b.billing_id;

-- Billing joined to its payments, claims and (where it exists) its appointment
CREATE VIEW v_billing_detail AS
SELECT b.billing_id, b.appointment_id, b.amount AS billed_amount, b.status AS billing_status,
       COALESCE(pay.amount_paid, 0) AS paid_amount, pay.method AS payment_method,
       b.amount - COALESCE(pay.amount_paid, 0) AS outstanding_amount,
       c.provider AS claim_provider, c.claim_amount, c.status AS claim_status
FROM billing b
LEFT JOIN payments pay ON pay.billing_id = b.billing_id
LEFT JOIN insurance_claims c ON c.billing_id = b.billing_id;

-- Staff counts by role and facility
CREATE VIEW v_staff_by_facility AS
SELECT facility_id, role, COUNT(*) AS staff_count, ROUND(AVG(years_experience), 1) AS avg_years_experience
FROM staff_all GROUP BY facility_id, role;

ANALYZE;

-- ======================= 03_data_validation.sql =======================
-- ============================================================
-- HealthConnect Rwanda | Step 3: data validation
-- Run after 02_clean_and_build.sql
--   pgAdmin: Query Tool > open this file > F5.
-- Every check writes one row to hc.data_quality_log: what was checked, how many records, how many problems.
-- Look at the result at the end:  SELECT * FROM hc.data_quality_log ORDER BY check_no;
-- ============================================================
SET search_path = hc, public;

DROP TABLE IF EXISTS data_quality_log;
CREATE TABLE data_quality_log (
    check_no        serial PRIMARY KEY,
    category        text,
    check_name      text,
    records_checked bigint,
    issues_found    bigint,
    result          text,       -- PASS / ISSUE
    action_taken    text
);

-- helper: log a check
CREATE OR REPLACE FUNCTION log_check(p_cat text, p_name text, p_checked bigint, p_issues bigint, p_action text)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO hc.data_quality_log(category, check_name, records_checked, issues_found, result, action_taken)
  VALUES (p_cat, p_name, p_checked, p_issues, CASE WHEN p_issues = 0 THEN 'PASS' ELSE 'ISSUE' END, p_action);
$$;

-- ------------------------------------------------------------
-- A. Duplicate IDs (primary keys are enforced, so these also prove the keys are unique)
-- ------------------------------------------------------------
SELECT log_check('Duplicates', 'Duplicate PatientID',          (SELECT COUNT(*) FROM patients),     (SELECT COUNT(*) - COUNT(DISTINCT patient_id)     FROM patients),     'None needed');
SELECT log_check('Duplicates', 'Duplicate AppointmentID',      (SELECT COUNT(*) FROM appointments), (SELECT COUNT(*) - COUNT(DISTINCT appointment_id) FROM appointments), 'None needed');
SELECT log_check('Duplicates', 'Duplicate BillingID',          (SELECT COUNT(*) FROM billing),      (SELECT COUNT(*) - COUNT(DISTINCT billing_id)     FROM billing),      'None needed');
SELECT log_check('Duplicates', 'Duplicate DiagnosisID',        (SELECT COUNT(*) FROM diagnoses),    (SELECT COUNT(*) - COUNT(DISTINCT diagnosis_id)   FROM diagnoses),    'None needed');
SELECT log_check('Duplicates', 'Duplicate staff IDs (all roles)', (SELECT COUNT(*) FROM staff_all), (SELECT COUNT(*) - COUNT(DISTINCT staff_id) FROM staff_all),            'None needed');
SELECT log_check('Duplicates', 'Appointment billed more than once', (SELECT COUNT(*) FROM billing),
       (SELECT COUNT(*) - COUNT(DISTINCT appointment_id) FROM billing), 'None needed');
SELECT log_check('Duplicates', 'Appointment with more than one feedback record', (SELECT COUNT(*) FROM patient_feedback),
       (SELECT COUNT(*) - COUNT(DISTINCT appointment_id) FROM patient_feedback), 'None needed');

-- ------------------------------------------------------------
-- B. Missing values
-- ------------------------------------------------------------
SELECT log_check('Missing values', 'Patients with missing gender, date of birth, village or blood group', (SELECT COUNT(*) FROM patients),
       (SELECT COUNT(*) FROM patients WHERE gender IS NULL OR date_of_birth IS NULL OR village_id IS NULL OR blood_group IS NULL), 'None needed');
SELECT log_check('Missing values', 'Appointments with missing patient, doctor, facility, department or date', (SELECT COUNT(*) FROM appointments),
       (SELECT COUNT(*) FROM appointments WHERE patient_id IS NULL OR doctor_id IS NULL OR facility_id IS NULL OR department_id IS NULL OR appointment_date IS NULL), 'None needed');
SELECT log_check('Missing values', 'Billing rows with missing amount or status', (SELECT COUNT(*) FROM billing),
       (SELECT COUNT(*) FROM billing WHERE amount IS NULL OR status IS NULL), 'None needed');
SELECT log_check('Missing values', 'Patients stored as "None" for chronic condition (a valid category, not a gap)', (SELECT COUNT(*) FROM patients),
       0, 'Kept as category "None"; flag has_chronic_condition added');

-- ------------------------------------------------------------
-- C. Invalid values
-- ------------------------------------------------------------
SELECT log_check('Invalid values', 'Impossible ages (below 0 or above 120)', (SELECT COUNT(*) FROM patients),
       (SELECT COUNT(*) FROM patients WHERE age < 0 OR age > 120), 'None needed');
SELECT log_check('Invalid values', 'Age does not agree with date of birth (more than 1 year apart, counted at 1 Jan 2026)', (SELECT COUNT(*) FROM patients),
       (SELECT COUNT(*) FROM patients WHERE ABS(age - EXTRACT(YEAR FROM age(DATE '2026-01-01', date_of_birth))) > 1), 'Age field kept as supplied');
SELECT log_check('Invalid values', 'Date of birth in the future', (SELECT COUNT(*) FROM patients),
       (SELECT COUNT(*) FROM patients WHERE date_of_birth > CURRENT_DATE), 'None needed');
SELECT log_check('Invalid values', 'Impossible height/weight/BMI', (SELECT COUNT(*) FROM patients),
       (SELECT COUNT(*) FROM patients WHERE height_cm NOT BETWEEN 100 AND 230 OR weight_kg NOT BETWEEN 2 AND 300 OR bmi NOT BETWEEN 8 AND 80), 'None needed');
SELECT log_check('Invalid values', 'Invalid billing amounts (zero or negative)', (SELECT COUNT(*) FROM billing),
       (SELECT COUNT(*) FROM billing WHERE amount <= 0), 'None needed');
SELECT log_check('Invalid values', 'Payments larger than the bill', (SELECT COUNT(*) FROM payments),
       (SELECT COUNT(*) FROM payments p JOIN billing b USING (billing_id) WHERE p.amount_paid > b.amount), 'None needed');
SELECT log_check('Invalid values', 'Insurance claims larger than the bill', (SELECT COUNT(*) FROM insurance_claims),
       (SELECT COUNT(*) FROM insurance_claims c JOIN billing b USING (billing_id) WHERE c.claim_amount > b.amount), 'None needed');
SELECT log_check('Invalid values', 'Ratings outside 1-5', (SELECT COUNT(*) FROM patient_feedback),
       (SELECT COUNT(*) FROM patient_feedback WHERE rating NOT BETWEEN 1 AND 5), 'None needed');
SELECT log_check('Invalid values', 'Length of stay of zero or less', (SELECT COUNT(*) FROM admissions),
       (SELECT COUNT(*) FROM admissions WHERE length_of_stay_days <= 0), 'None needed');
SELECT log_check('Invalid values', 'Staff with impossible years of experience', (SELECT COUNT(*) FROM staff_all),
       (SELECT COUNT(*) FROM staff_all WHERE years_experience NOT BETWEEN 0 AND 60), 'None needed');
SELECT log_check('Invalid values', 'Appointments dated in the future (after 22 Oct 2026, the date of this analysis)', (SELECT COUNT(*) FROM appointments),
       (SELECT COUNT(*) FROM appointments WHERE appointment_date > DATE '2026-10-22'), 'Kept as supplied and flagged; trends are shown by month and the future months are labelled');
SELECT log_check('Invalid values', 'Revenue Summary months dated after 22 Oct 2026', (SELECT COUNT(*) FROM revenue_summary),
       (SELECT COUNT(*) FROM revenue_summary WHERE month_start > DATE '2026-10-22'), 'Kept as supplied and flagged');

-- ------------------------------------------------------------
-- D. Foreign keys / relationships
-- ------------------------------------------------------------
SELECT log_check('Relationships', 'Invalid FacilityID in appointments', (SELECT COUNT(*) FROM appointments),
       (SELECT COUNT(*) FROM appointments a LEFT JOIN health_facilities f USING (facility_id) WHERE f.facility_id IS NULL), 'None needed');
SELECT log_check('Relationships', 'Invalid DepartmentID in appointments', (SELECT COUNT(*) FROM appointments),
       (SELECT COUNT(*) FROM appointments a LEFT JOIN departments d USING (department_id) WHERE d.department_id IS NULL), 'None needed');
SELECT log_check('Relationships', 'Appointments whose patient does not exist', (SELECT COUNT(*) FROM appointments),
       (SELECT COUNT(*) FROM appointments a LEFT JOIN patients p USING (patient_id) WHERE p.patient_id IS NULL), 'None needed');
SELECT log_check('Relationships', 'Appointments whose doctor does not exist', (SELECT COUNT(*) FROM appointments),
       (SELECT COUNT(*) FROM appointments a LEFT JOIN doctors d ON d.staff_id = a.doctor_id WHERE d.staff_id IS NULL), 'None needed');
SELECT log_check('Relationships', 'Patients whose village does not exist', (SELECT COUNT(*) FROM patients),
       (SELECT COUNT(*) FROM patients p LEFT JOIN villages v USING (village_id) WHERE v.village_id IS NULL), 'None needed');
SELECT log_check('Relationships', 'Payments or claims without a bill', (SELECT COUNT(*) FROM payments) + (SELECT COUNT(*) FROM insurance_claims),
       (SELECT COUNT(*) FROM payments p LEFT JOIN billing b USING (billing_id) WHERE b.billing_id IS NULL)
     + (SELECT COUNT(*) FROM insurance_claims c LEFT JOIN billing b USING (billing_id) WHERE b.billing_id IS NULL), 'None needed');
SELECT log_check('Relationships', 'Bills without a payment', (SELECT COUNT(*) FROM billing),
       (SELECT COUNT(*) FROM billing b LEFT JOIN payments p USING (billing_id) WHERE p.billing_id IS NULL), 'None needed');

-- appointment-level tables that point to appointments missing from the Appointments table
SELECT log_check('Relationships', 'Diagnoses pointing to an appointment missing from Appointments', (SELECT COUNT(*) FROM diagnoses),
       (SELECT COUNT(*) FROM diagnoses d LEFT JOIN appointments a USING (appointment_id) WHERE a.appointment_id IS NULL),
       'Not removed. Totals use all rows; hospital/department/province results use the 5,000 matched appointments');
SELECT log_check('Relationships', 'Billing pointing to an appointment missing from Appointments', (SELECT COUNT(*) FROM billing),
       (SELECT COUNT(*) FROM billing b LEFT JOIN appointments a USING (appointment_id) WHERE a.appointment_id IS NULL),
       'Not removed. Totals use all bills; revenue by hospital/department/province uses the 5,000 matched appointments');
SELECT log_check('Relationships', 'Feedback pointing to an appointment missing from Appointments', (SELECT COUNT(*) FROM patient_feedback),
       (SELECT COUNT(*) FROM patient_feedback f LEFT JOIN appointments a USING (appointment_id) WHERE a.appointment_id IS NULL),
       'Not removed. Overall rating uses all rows; ratings by hospital/department use the matched rows');
SELECT log_check('Relationships', 'Laboratory tests pointing to a missing appointment', (SELECT COUNT(*) FROM laboratory_tests),
       (SELECT COUNT(*) FROM laboratory_tests l LEFT JOIN appointments a USING (appointment_id) WHERE a.appointment_id IS NULL), 'Not removed; same treatment as above');
SELECT log_check('Relationships', 'Prescriptions pointing to a missing appointment', (SELECT COUNT(*) FROM prescriptions),
       (SELECT COUNT(*) FROM prescriptions r LEFT JOIN appointments a USING (appointment_id) WHERE a.appointment_id IS NULL), 'Not removed; same treatment as above');
SELECT log_check('Relationships', 'Admissions pointing to a missing appointment', (SELECT COUNT(*) FROM admissions),
       (SELECT COUNT(*) FROM admissions r LEFT JOIN appointments a USING (appointment_id) WHERE a.appointment_id IS NULL), 'Not removed; same treatment as above');
SELECT log_check('Relationships', 'Referrals pointing to a missing appointment', (SELECT COUNT(*) FROM referrals),
       (SELECT COUNT(*) FROM referrals r LEFT JOIN appointments a USING (appointment_id) WHERE a.appointment_id IS NULL), 'Not removed; same treatment as above');

-- ------------------------------------------------------------
-- E. Consistency between related fields
-- ------------------------------------------------------------
SELECT log_check('Consistency', 'Appointments where the department belongs to a different facility than the one recorded', (SELECT COUNT(*) FROM appointments),
       (SELECT COUNT(*) FROM appointments a JOIN departments d USING (department_id) WHERE d.facility_id <> a.facility_id),
       'Facility taken from the appointment row; department compared by NAME (10 types) not by ID');
SELECT log_check('Consistency', 'Staff whose department belongs to a different facility than the one recorded', (SELECT COUNT(*) FROM staff_all),
       (SELECT COUNT(*) FROM staff_all s JOIN departments d USING (department_id) WHERE d.facility_id <> s.facility_id),
       'Facility taken from the staff row; department compared by NAME');
SELECT log_check('Consistency', 'Staff whose department NAME does not match their DepartmentID', (SELECT COUNT(*) FROM staff_all),
       (SELECT COUNT(*) FROM staff_all s JOIN departments d USING (department_id) WHERE d.department_name <> s.department_name), 'None needed');
SELECT log_check('Consistency', 'Bill status disagrees with payment: marked Pending/Partially Paid but fully paid, or Paid but not fully paid', (SELECT COUNT(*) FROM billing),
       (SELECT COUNT(*) FROM billing b JOIN payments p USING (billing_id)
        WHERE (b.status = 'Paid' AND p.amount_paid < b.amount) OR (b.status <> 'Paid' AND p.amount_paid >= b.amount)),
       'Outstanding amount is calculated from payments (bill minus paid), not from the status label');
SELECT log_check('Consistency', 'Feedback rating does not match comment (rating 1-2 with comment Excellent/Good, or rating 4-5 with Poor)', (SELECT COUNT(*) FROM patient_feedback),
       (SELECT COUNT(*) FROM patient_feedback WHERE (rating <= 2 AND comment IN ('Excellent','Good')) OR (rating >= 4 AND comment = 'Poor')),
       'Rating is used for satisfaction; the comment is reported separately as a category');
SELECT log_check('Consistency', 'Bed status other than Available (all beds show Available, so occupancy cannot come from this field)', (SELECT COUNT(*) FROM beds),
       (SELECT COUNT(*) FROM beds WHERE status = 'Available'), 'Bed utilisation estimated from admissions (bed-days used / bed-days available)');
SELECT log_check('Consistency', 'Revenue Summary total vs total of the Billing table (difference in RWF)', (SELECT COUNT(*) FROM revenue_summary),
       ABS((SELECT SUM(revenue) FROM revenue_summary) - (SELECT SUM(amount) FROM billing))::bigint,
       'Both reported. Billing is used for totals; Revenue Summary is used for the month-by-month trend only');
SELECT log_check('Consistency', 'Revenue Summary appointment total vs number of billed appointments (difference)', (SELECT COUNT(*) FROM revenue_summary),
       ABS((SELECT SUM(appointments) FROM revenue_summary) - (SELECT COUNT(*) FROM billing))::bigint, 'Both reported');

-- ------------------------------------------------------------
-- F. Phone numbers
-- ------------------------------------------------------------
SELECT log_check('Phone numbers', 'Phone numbers stored in scientific notation (digits lost, cannot be repaired)', (SELECT COUNT(*) FROM patients),
       (SELECT COUNT(*) FROM patients WHERE NOT phone_valid), 'Raw value kept in phone_raw; flag phone_valid = FALSE. Not used for patient identification');
SELECT log_check('Phone numbers', 'Distinct phone values across 20,000 patients', 20000, 20000 - (SELECT COUNT(DISTINCT phone_raw) FROM patients),
       'Duplicate-phone result (SQL task 9) is reported but is not meaningful');

-- ------------------------------------------------------------
-- G. Referral sanity
-- ------------------------------------------------------------
SELECT log_check('Consistency', 'Referrals sent to the same facility the appointment took place in (matched rows only)', (SELECT COUNT(*) FROM referrals r JOIN appointments a USING (appointment_id)),
       (SELECT COUNT(*) FROM referrals r JOIN appointments a USING (appointment_id) WHERE r.referred_facility_id = a.facility_id), 'Reported only');

SELECT check_no, category, check_name, records_checked, issues_found, result FROM data_quality_log ORDER BY check_no;

-- ======================= 04_business_analysis_40_queries.sql =======================
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
