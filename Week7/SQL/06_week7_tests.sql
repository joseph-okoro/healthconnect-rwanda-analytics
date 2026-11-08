-- ============================================================
-- HealthConnect Rwanda | Week 7: SQL tests (run in pgAdmin Query Tool after the Week 6 database is restored)
-- Select one test at a time and press F5. Expected values are in the comment above each test.
-- These tests are independent of the Week 6 analysis queries: they recount from the base tables.
-- ============================================================

-- T-SQL-01 Row counts of the clean tables. Expected: patients 20000, appointments 5000, billing 60000, diagnoses 60000, feedback 21064
SELECT 'patients' AS tbl, COUNT(*) FROM hc.patients UNION ALL SELECT 'appointments', COUNT(*) FROM hc.appointments
UNION ALL SELECT 'billing', COUNT(*) FROM hc.billing UNION ALL SELECT 'diagnoses', COUNT(*) FROM hc.diagnoses UNION ALL SELECT 'patient_feedback', COUNT(*) FROM hc.patient_feedback;

-- T-SQL-02 Outstanding amount reconciles: billed - collected = outstanding. Expected: 9309401961 - 8389454556 = 919947405 (difference 0)
SELECT b.billed, p.collected, b.billed - p.collected AS billed_minus_collected, v.outstanding, (b.billed - p.collected) - v.outstanding AS difference
FROM (SELECT SUM(amount) billed FROM hc.billing) b, (SELECT SUM(amount_paid) collected FROM hc.payments) p, (SELECT SUM(outstanding_amount) outstanding FROM hc.v_billing_detail) v;

-- T-SQL-03 Duplicate keys. Expected: 0 rows returned
SELECT 'patients' AS tbl, patient_id, COUNT(*) FROM hc.patients GROUP BY patient_id HAVING COUNT(*) > 1
UNION ALL SELECT 'appointments', appointment_id, COUNT(*) FROM hc.appointments GROUP BY appointment_id HAVING COUNT(*) > 1
UNION ALL SELECT 'billing', billing_id, COUNT(*) FROM hc.billing GROUP BY billing_id HAVING COUNT(*) > 1;

-- T-SQL-04 Share of each fact table that links to a detailed appointment. Expected: billing 8.3%, diagnoses 8.3%, feedback 8.3%, admissions 11.7%
SELECT 'billing' AS tbl, COUNT(*) AS rows, SUM((a.appointment_id IS NOT NULL)::int) AS linked, ROUND(100.0*SUM((a.appointment_id IS NOT NULL)::int)/COUNT(*),1) AS pct_linked
FROM hc.billing x LEFT JOIN hc.appointments a USING (appointment_id)
UNION ALL SELECT 'diagnoses', COUNT(*), SUM((a.appointment_id IS NOT NULL)::int), ROUND(100.0*SUM((a.appointment_id IS NOT NULL)::int)/COUNT(*),1) FROM hc.diagnoses x LEFT JOIN hc.appointments a USING (appointment_id)
UNION ALL SELECT 'feedback', COUNT(*), SUM((a.appointment_id IS NOT NULL)::int), ROUND(100.0*SUM((a.appointment_id IS NOT NULL)::int)/COUNT(*),1) FROM hc.patient_feedback x LEFT JOIN hc.appointments a USING (appointment_id)
UNION ALL SELECT 'admissions', COUNT(*), SUM((a.appointment_id IS NOT NULL)::int), ROUND(100.0*SUM((a.appointment_id IS NOT NULL)::int)/COUNT(*),1) FROM hc.admissions x LEFT JOIN hc.appointments a USING (appointment_id);

-- T-SQL-05 Poor rating rate (Week 7 correction). Expected: 8518 poor ratings of 21064 = 40.4 (Week 6 had shown 40.5)
SELECT COUNT(*) AS ratings, SUM((rating <= 2)::int) AS poor, ROUND(100.0*SUM((rating <= 2)::int)/COUNT(*),1) AS poor_pct, ROUND(100.0*SUM((rating >= 4)::int)/COUNT(*),1) AS excellent_pct FROM hc.patient_feedback;

-- T-SQL-06 Rating vs comment contradictions. Expected: 6336 of 21064
SELECT SUM(((rating <= 2 AND comment IN ('Excellent','Good')) OR (rating >= 4 AND comment = 'Poor'))::int) AS contradictions, COUNT(*) AS ratings FROM hc.patient_feedback;

-- T-SQL-07 Bill status vs payment. Expected: 36052 of 60000 bills contradict
SELECT SUM(((billing_status = 'Paid' AND outstanding_amount > 0) OR (billing_status <> 'Paid' AND outstanding_amount = 0))::int) AS contradictions, COUNT(*) AS bills FROM hc.v_billing_detail;

-- T-SQL-08 Hospital ratings with 95% confidence range (refined measure logic). Expected: 20 hospitals, 72 to 102 ratings each; no hospital's range excludes 2.99
WITH r AS (
  SELECT a.facility_id, COUNT(*) AS n, AVG(f.rating)::numeric AS m, STDDEV_SAMP(f.rating)::numeric AS s
  FROM hc.patient_feedback f JOIN hc.appointments a USING (appointment_id) GROUP BY a.facility_id)
SELECT facility_id, n, ROUND(m,2) AS avg_rating, ROUND(m - 1.96*s/SQRT(n::numeric),2) AS ci_low, ROUND(m + 1.96*s/SQRT(n::numeric),2) AS ci_high,
       CASE WHEN m + 1.96*s/SQRT(n::numeric) < 2.99 THEN 'Below network' WHEN m - 1.96*s/SQRT(n::numeric) > 2.99 THEN 'Above network' ELSE 'Within normal range' END AS flag
FROM r ORDER BY avg_rating;

-- T-SQL-09 Records per hospital-department cell (small-sample check). Expected: median 25, minimum 13 appointments per cell
WITH c AS (SELECT a.facility_id, d.department_name, COUNT(*) n FROM hc.appointments a JOIN hc.departments d USING (department_id) GROUP BY 1,2)
SELECT COUNT(*) AS cells, MIN(n) AS min_n, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY n) AS median_n, SUM((n < 30)::int) AS cells_below_30 FROM c;

-- T-SQL-10 Future-dated appointments. Expected: 916 appointments after 2026-10-22; admission rate to date 11.3% (all rows 11.7%)
SELECT SUM((a.appointment_date > DATE '2026-10-22')::int) AS future_dated,
       ROUND(100.0*SUM((s.appointment_id IS NOT NULL)::int)/COUNT(*),1) AS admission_rate_all,
       ROUND(100.0*SUM(((s.appointment_id IS NOT NULL) AND a.appointment_date <= DATE '2026-10-22')::int)/SUM((a.appointment_date <= DATE '2026-10-22')::int),1) AS admission_rate_to_date
FROM hc.appointments a LEFT JOIN hc.admissions s USING (appointment_id);
