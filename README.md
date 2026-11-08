# HealthConnect Rwanda: Healthcare Operations and Performance Analytics

**AnalystLab Africa | Week 6 | Track 1: Data Analytics | Batch E**
**Author:** Okoro Joseph Ifeanyichukwu

An end-to-end analysis of HealthConnect Rwanda's 20 hospitals: 27 raw datasets cleaned and checked in PostgreSQL, analysed with 40 SQL questions, and presented in a six-page Power BI dashboard with an executive report and presentation.

## Headline findings (2026, amounts in RWF)
- **Staffing does not follow demand.** Every hospital has 35 nurses and 17 to 18 doctors, but workload ranges from 12.3 to 16.4 appointments per doctor.
- **The busiest hospitals are among the least liked.** HF013 and HF014 are the two busiest and rate 2.77 out of 5 (network average 2.99). 40.4% of ratings are 1 or 2 stars.
- **RWF 919.9 million (9.9%) of the RWF 9.31 billion billed is unpaid**, and **50% of insurance claims (RWF 2.44 billion) are still pending.**
- **Expansion means doctors, not beds.** Estimated bed use is only 3.8%.
- **Kigali City patients use hospitals least** (239 appointments per 1,000 patients vs 260 in Northern).

## What is in this folder
| Folder / file | Contents |
|---|---|
| `Data/` | 30 original CSV files (27 datasets; the clinical workbook is split into its sheets) |
| `SQL/01_create_staging_and_load.sql` | Creates the `staging` schema (all text) and loads every CSV |
| `SQL/02_clean_and_build.sql` | Cleans and types the data, adds keys and relationships, builds the `hc` schema and helper views |
| `SQL/03_data_validation.sql` | 48 data-quality checks written to `hc.data_quality_log` |
| `SQL/04_business_analysis_40_queries.sql` | The 40 SQL questions (Q01 to Q40) |
| `SQL/05_powerbi_export.sql` | Builds the star-schema tables in the `pbi` schema and exports them to `Dashboard/PowerBI_Data/` |
| `SQL/HealthConnect_SQL_Script.sql` | Scripts 01 to 04 combined in one file |
| `Database/` | PostgreSQL backup for pgAdmin: `HealthConnect_DB.backup` (Restore) and `HealthConnect_DB_backup.sql` (Query Tool) |
| `Dashboard/PowerBI_Data/` | 18 Power BI-ready CSV files (dimensions, facts, data quality log) |
| `Dashboard/HealthConnect_DAX_Measures.txt` | More than 100 DAX measures with expected values to check against |
| `Dashboard/PowerBI_Project/` | Power BI project (`HealthConnect_Analytics.pbip`): data model, relationships, 107 measures and 8 pages. Open it in Power BI Desktop (see `HOW_TO_OPEN.txt`) |
| `Dashboard/HealthConnect_All_Measures_DAXQuery.dax` | All measures in one script for DAX query view |
| `Dashboard/HealthConnect_Analytics.pbix` | The saved Power BI dashboard (save from the project after opening it) |
| `Dashboard/HealthConnect_Executive_Dashboard.pdf` | Executive dashboard exported from Power BI (File > Export > Export to PDF) |
| `Docs/PowerBI_Build_Guide.md` | Step-by-step guide to build the dashboard |
| `Report/HealthConnect_Business_Insights_Report.pdf` | 5-page plain-language report answering the 10 business questions |
| `Presentation/` | 14-slide executive presentation (PPTX and PDF) |
| `Images/` | Charts used in the report and dashboard screenshots |
| `References/` | The assignment brief |

## How to run the SQL (pgAdmin)
**Option 1: restore the finished database (fastest)**
1. In pgAdmin, right-click **Databases > Create > Database**, name it `healthconnect`.
2. Right-click `healthconnect` > **Restore...**, choose `Database/HealthConnect_DB.backup` (format: Custom or tar), click **Restore**.
   (If pgAdmin reports a version error, use the plain file below: right-click `healthconnect` > **Query Tool** > open `Database/HealthConnect_DB_backup.sql` > press F5.)

**Option 2: rebuild from the raw data**
1. Create a database called `healthconnect` and copy the project's `Data` folder to `C:\HealthConnect_Data` (so `C:\HealthConnect_Data\HC_Patients.csv` exists).
2. Right-click `healthconnect` > **Query Tool**, open each script and press **F5**, in this order:
   `01_create_staging_and_load.sql`, `02_clean_and_build.sql`, `03_data_validation.sql`, `04_business_analysis_40_queries.sql` (select one query at a time), `05_powerbi_export.sql` (optional: creates the Power BI files in `C:\HealthConnect_Data\PowerBI_Data`, create that folder first).
   `HealthConnect_SQL_Script.sql` has steps 01 to 04 in one file.
3. Scripts load files with `COPY`, so log in as the `postgres` user. If your data folder is elsewhere, use Find/Replace (Ctrl+H) to change `C:/HealthConnect_Data/` to your path. If you see "permission denied", put the folder in `C:/Users/Public/` or use pgAdmin's Import/Export Data tool.

## Data model (Power BI)
Star schema. Dimensions: `dim_date`, `dim_facility`, `dim_department`, `dim_patient`, `dim_province`. Facts: appointments, billing, diagnoses, feedback, lab tests, prescriptions, admissions, referrals, staff, beds, equipment, revenue summary. Relationships and measures are listed in `Dashboard/HealthConnect_DAX_Measures.txt`. Each fact record carries a `link_status` ("Linked" or "Not linked", see below).

## Data cleaning and validation
- Text trimmed, dates and numbers typed, keys and foreign keys added, duplicate checks run on every ID.
- 48 checks logged in `hc.data_quality_log` (29 passed, 19 raise an issue). Issues are described and handled in the log, not hidden.
- Cleaning is also documented as Power Query steps in `Docs/PowerBI_Build_Guide.md` (Part 1).

## Assumptions
- **Revenue** = billed amount. **Collected** = amount paid. **Outstanding** = billed minus paid (the bill status label is unreliable: 36,052 of 60,000 contradict the payments).
- **Hospital** = facility ID (HF001 to HF020); there are no names, types or locations in the data.
- **Province** = the patient's home province (Patient > Village > Sector > District > Province), not the hospital's location.
- **Department** is compared by name (10 types) because department IDs do not match the facility on the appointment.
- **Service line** = visit type (Consultation, Follow-up, Emergency), because bills carry no service.
- **Bed utilisation** is estimated: bed-days used (sum of stays) / (2,000 beds x 365 days).
- **Currency:** Rwandan francs (RWF).
- **Analysis date:** 22 October 2026.

## Limitations
1. **Only 5,000 appointments have full details**, but bills (60,000), diagnoses (60,000), feedback (21,064), referrals (4,708) and others point to appointment IDs up to APT060000. About 8% link. Totals use every record; hospital, department and province results use the linked records and are labelled "(Linked)".
2. **Facility master data is missing** (names, type, ownership, location), so no hospital-type, ownership or map-by-hospital analysis.
3. **916 appointments are dated after 22 October 2026.** Kept and labelled.
4. **No cancellation or no-show field**, so cancellation rate cannot be measured. **All beds are "Available"**, so occupancy is estimated.
5. **Revenue Summary (RWF 1.13 billion) does not match Billing (RWF 9.31 billion).** Billing is used for totals; the Summary only for the month trend.
6. **Phone numbers are corrupted** (scientific notation) and are not used.

## KPI checks (database vs DAX)
Total Patients 20,000 · Total Appointments 5,000 · Total Revenue 9,309,401,961 · Outstanding 919,947,405 · Collection Rate 90.1% · Admission Rate 11.7% · Claim Approval Rate 50.0% · Avg Rating 2.99.

## Tools
PostgreSQL 16, pgAdmin, Power BI Desktop, DAX, Power Query, Python (analysis checks, report charts).

---

# Week 7: Analytical Testing, KPI Validation and Dashboard Refinement

Week 7 tests the Week 6 work above. It does **not** repeat it. Everything is in the `Week7/` folder (Week 6 files stay as they were, except for the corrections below).

## What was done
- **120 logged tests** (`Week7/Logs/Week7_Test_Record.csv`): raw files vs Power BI files, 39 KPIs recalculated from the raw CSVs with separate code, PostgreSQL vs independent code, dashboard values seen in Power BI Desktop, slicer reach, and a check of whether each key Week 6 finding could be chance. 102 passed, 18 found an issue.
- **One wrong figure corrected:** the poor-rating rate is **40.4%** (8,518 of 21,064), not 40.5%. Fixed in the Week 6 report, slides, README and DAX note; the originals are kept in `Week7/Corrections/Week6_originals/`.
- **Findings withdrawn or reworded** because the differences are small enough to be chance: "busiest hospitals are least liked", "ICU worst", "Kigali City uses hospitals least", "hypertension rising". Updated recommendations are in the Week 7 report.
- **Dashboard refined** (Power BI project version 2): four faulty visuals fixed, hospitals are flagged only when the gap is clearly not chance, a minimum-sample guard on the hospital x department matrix, notes on cards that ignore a slicer, and 12 new measures (119 in total).
- **Cross-track test with Project Management** (`Week7/Evidence/CrossTrack_Record/`): claims and triage model results compared with facts from the cleaned data. The retest outcome is recorded when the Project Manager replies.

## Week 7 folder
| Path | Contents |
|---|---|
| `Week7/Report/HealthConnect_Week7_Analytics_Testing_and_Refinement_Report.pdf` | Main Week 7 deliverable |
| `Week7/Report/HealthConnect_Week7_Project_Summary.pdf` | One-page project summary |
| `Week7/Logs/` | Test record (120 tests), integration and issue log, decision log, risk and dependency register, slicer reach matrix, hospital rating before/after |
| `Week7/Code/` | `week7_kpi_validation.py`, `week7_finding_tests.py` (reproducible tests) |
| `Week7/Notebook/` | Testing notebook (`.ipynb` and `.py`) with an HTML copy in `Week7/Evidence/` |
| `Week7/SQL/06_week7_tests.sql` | SQL tests to run in the pgAdmin Query Tool |
| `Week7/Dashboard_Refinement/` | Refinement checklist (R1 to R10) and the 12 refinement measures |
| `Week7/Evidence/` | Charts, before-fix screenshots, KPI and finding test results, cross-track record |
| `Week7/Corrections/Week6_originals/` | Week 6 files as submitted, before the 40.4% correction |
| `Dashboard/PowerBI_Project_v2/` | Updated Power BI project (version 1 is `Dashboard/PowerBI_Project/`) |
| `Dashboard/HealthConnect_All_Measures_DAXQuery_v2.dax` | All 119 measures for DAX query view |

## How to re-run the tests
1. Restore the database in pgAdmin (see "How to run the SQL" above).
2. KPI test: `python3 Week7/Code/week7_kpi_validation.py` (reads `Data/`; no database needed).
3. Finding tests: `python3 Week7/Code/week7_finding_tests.py` (reads the database; edit the connection at the top if your port is not 5433).
4. SQL tests: open `Week7/SQL/06_week7_tests.sql` in the Query Tool and run one test at a time.

## What changed between Week 6 and Week 7
| Item | Week 6 | Week 7 |
|---|---|---|
| Poor-rating rate | 40.5% | 40.4% |
| Hospital rating colours | 4 red, 3 green | 0 flagged (all within normal range) |
| Recommendation on moving doctors | Re-balance now | Monitor monthly and re-test |
| Regional (Kigali City) recommendation | Investigate access | Withdrawn: no evidence (p = 0.32) |
| Patient-experience programme | Run for busiest hospitals and ICU | Fix the rating data first (6,336 ratings contradict comments) |
| Dashboard | Version 1 | Version 2 (visual fixes, refined measures, notes) |

## Remaining issues before Week 8
1. **Dataset scope (critical):** the data has no attendance or no-show field, so the project question about missed appointments cannot be answered. Confirm the intended dataset with the programme.
2. Only 5,000 of 60,000 appointments have hospital detail; request the full list.
3. Rating data reliability; Revenue Summary vs billing mismatch.
4. Retest the dashboard fixes in Power BI Desktop and add the after screenshots.
5. Re-run test F17 if the claims target changes.

---
## Week 8: Final Analytics and Decision Support Package

**What this is:** the final step of my HealthConnect Rwanda analytics work (Weeks 5 to 8).

| Item | File |
|---|---|
| Final report (4 pages) | `Week8/Report/HealthConnect_Week8_Final_Analytics_and_Decision_Support_Report.pdf` |
| Slides (10) with speaker notes | `Week8/Presentation/HealthConnect_Week8_Analytics_Section_Slides.pptx` and `.pdf` |
| Final KPI check (11 KPIs, all match) | `Week8/Evidence/final_kpis.csv` |
| Appointment pattern tests | `Week8/Evidence/appointment_patterns.csv` |
| Code | `Week8/Code/week8_final_checks.py` |
| Cross-track record | `Week8/Docs/Week8_Cross_Track_Final_Integration_Record.md` |
| Video script | `Week8/Docs/Week8_Video_Script_5-10_min.md` |

**Main results:** RWF 9.31 B billed, 90.1% collected, RWF 919.9 M unpaid; half of 42,036 claims pending (same for every insurer); average rating 2.99; appointments are flat across days and months.
**Recommendations:** record attendance; chase unpaid bills; review the claims process; staff evenly including weekends; fix the feedback form.
**Limits:** no attendance or no-show field; only 5,000 of 60,000 appointments link to a hospital; hospitals are codes only; ratings and comments disagree; the final `.pbix` is saved separately from Power BI Desktop.
**How to rerun:** restore `Database/HealthConnect_DB.backup` into PostgreSQL, then `python3 Week8/Code/week8_final_checks.py`.
**AI use:** I used an AI assistant to help build and check this work and reviewed the results.
