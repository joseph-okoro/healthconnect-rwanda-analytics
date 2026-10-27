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
