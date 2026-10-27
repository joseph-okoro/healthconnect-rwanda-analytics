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
