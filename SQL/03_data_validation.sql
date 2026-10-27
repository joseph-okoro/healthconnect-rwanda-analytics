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
