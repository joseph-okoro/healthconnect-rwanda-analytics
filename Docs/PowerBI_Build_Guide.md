# Power BI Build Guide: HealthConnect Rwanda Dashboard

Goal: build `HealthConnect_Analytics.pbix` (6 pages) and export the Executive Dashboard PDF.
Time needed: about 3 to 4 hours. Do the steps in order. Everything you need is in `Dashboard/PowerBI_Data/` (18 CSV files) and `Dashboard/HealthConnect_DAX_Measures.txt`.

Colours used everywhere (so the report looks like one design):
Teal `#0F6E6E` (main) · Dark navy `#12263F` (titles) · Amber `#F2A900` (highlight) · Red `#C62828` (bad) · Green `#2E7D32` (good) · Light grey background `#F4F6F8`.
Font: Segoe UI. Titles 16 pt bold, labels 10 pt.

---

## Part 1. Load and clean the data (Power Query)  ·  15 marks "cleaning, integration, validation"

1. Open Power BI Desktop > **Get data > Text/CSV**. Load all 18 files from `PowerBI_Data`. In the Navigator window choose **Transform Data**.
2. For each table, in Power Query:
   - **Use First Row as Headers** (already done for CSV).
   - Set data types: `date`, `month_start`, `date_of_birth` = **Date**; `billed_amount`, `paid_amount`, `outstanding_amount`, `claim_amount`, `rating`, `age`, `length_of_stay_days`, `years_experience`, counts = **Whole number**; everything else = **Text**.
   - **Transform > Trim** and **Clean** on text columns (names, facility_id, department_name).
   - **Remove Duplicates** on each ID column (`patient_id`, `billing_id`, ...).
3. Rename the queries to the table names (they already match the file names, drop the `.csv`).
4. Add a **validation** query: select `data_quality_log` and keep it as a table. It shows the 48 checks from the SQL work. Put it on the last page ("Data Quality") or leave it in the model as evidence.
5. Right-click each query > keep **Enable load** ticked. Click **Close & Apply**.

(Cleaning was already done in PostgreSQL. This step documents that cleaning also happens in Power Query, as the brief asks.)

## Part 2. Model (Model view)  ·  star schema

1. **dim_date**: select the table > Table tools > **Mark as date table** > column `date`.
   Select `month_name` > Column tools > **Sort by column** > `month_no`. Do the same for `year_month` (sort by `month_start`) and `weekday_name` (sort by `weekday_no`).
2. Create the relationships exactly as listed in section 0 of `HealthConnect_DAX_Measures.txt` (dimension on the "one" side, fact on the "many" side, single direction).
   For `fact_referrals`: connect `dim_facility[facility_id]` to `from_facility_id` (active) and to `referred_facility_id` (then double-click the line and untick **Make this relationship active**).
3. Create a new table for measures: **Home > Enter data**, name it `_Measures`, click Load. Then paste every measure from the DAX file (**Modeling > New measure**). Delete the empty "Column1".
4. Create hierarchies (right-click the field > **New hierarchy**):
   - `dim_date`: year > quarter > month_name > date
   - `dim_patient`: province_name > district_name > sector_name > village_name
5. Check your numbers: put the measures on cards and compare with the "expect" values in the DAX file. Total Patients 20,000 · Total Appointments 5,000 · Total Revenue 9,309,401,961 · Outstanding 919,947,405 · Avg Satisfaction 2.99 · Admission Rate 11.7% · Claim Approval Rate 50.0%.
6. **Hide** the key columns from Report view (right-click > Hide in report view): all `*_id` columns, `link_status`, `appointment_id`.

## Part 3. Pages

Page size: **16:9** (View > Page view > Fit to page). Set page background `#F4F6F8` (Format page > Canvas background, transparency 0).
Add to every page: a title text box on the top left, a **Back** / **Home** button (Insert > Buttons > Navigator > Page navigator, place it once, then copy).

Create a **Navigation bar**: Insert > Buttons > **Navigator > Page navigator**. Put it in a strip on the left side of every page.

### Page 1: Executive Overview
Title (dynamic): fx on a text box title > field `Title - Executive`.
- 6 **KPI cards**: Total Patients, Total Appointments, Total Revenue, Collection Rate, Avg Satisfaction, Admission Rate.
- **Line chart**: X = `dim_date[year_month]`, Y = Total Appointments. Turn on **Analytics > Forecast** (forecast length 3 points, confidence 95%). Title: "Appointments per month and 3-month forecast".
- **Clustered bar**: hospital (`dim_facility[facility_id]`) vs Total Appointments, sorted high to low. Title: "Busiest hospitals".
- **Map** (Filled map): Location = `dim_province[province_name]` (set data category to State/Province, and add ", Rwanda" in a helper column if the map does not place it: Add column `Place = [province_name] & ", Rwanda"`), Colour = Revenue (Linked).
- **Slicers**: `dim_date[year_month]` (dropdown), `dim_province[province_name]` (tiles), `dim_facility[facility_id]` (dropdown).
- **Smart narrative** (Insert > Smart narrative) on a card with a short sentence. Optional.
- **Conditional formatting**: in the bar chart colour bars by Rating Colour (Format > Bars > Colours > fx > Field value).

### Page 2: Patient Analytics
- Cards: Total Patients, Patients Seen, Average Patient Age, Patients Over 65, Chronic Rate, Repeat Patients (2+ visits).
- **Age pyramid**: clustered bar, Axis = `age_band`, Values = `Male Patients (pyramid)` and `Female Patients`. Overlap bars 100%. Axis label hide.
- **Donut**: gender split (Total Patients by `gender`).
- **Column chart**: patients by `province_name` (Total Patients).
- **Matrix**: rows = `province_name` > `district_name` (hierarchy, use the drill arrows), columns = `gender`, values = Total Patients. Turn on **conditional formatting > Background colour > Gradient** on the values.
- **Treemap**: `chronic_condition` by Total Patients (filter out "None").
- Slicers: `age_group`, `gender`, `insurance_id` is not useful. Use `status` and `blood_group`.
- **Decomposition tree** (Visualizations > Decomposition tree): Analyze = Total Patients; Explain by = `province_name`, `gender`, `age_band`, `chronic_condition`.

### Page 3: Clinical Analytics
- Cards: Total Diagnoses, Severe Rate, Avg Length of Stay, Admission Rate, Abnormal Lab Rate, Referrals.
- **Bar**: top diagnoses (`fact_diagnoses[diagnosis]`, Total Diagnoses). Use Total (all rows).
- **Stacked column**: severity by diagnosis.
- **Line**: diagnoses per quarter by `diagnosis` (Linked rows only: add a visual filter `link_status = Linked`).
- **Bar**: admission rate by department (`dim_department[department_name]`, Admission Rate).
- **Column**: most requested lab tests (`fact_lab_tests[test]`, Lab Tests).
- **Bar**: most prescribed medications (`fact_prescriptions[medication]`, Prescriptions).
- **Key influencers** (Visualizations > Key influencers): Analyze = `fact_appointments[was_admitted]` = Yes; Explain by = `visit_type`, `department_name`, `province_name`, `was_referred`, `had_lab_test`.
- Create a **Drill-through page** (see Part 4) for a single diagnosis.

### Page 4: Financial Analytics
- Cards: Total Revenue, Collected Amount, Outstanding Bills, Collection Rate, Claim Approval Rate, Average Billing Amount.
- **Column + line**: Monthly Revenue (Summary) by `year_month`; line = Revenue Growth %. (Use the Revenue Summary only for the month trend, as noted in the DAX file.)
- **Bar**: revenue by hospital, **Revenue (Linked)**.
- **Bar**: revenue by department, Revenue (Linked). **Donut**: revenue by `visit_type`.
- **Clustered bar**: insurer (`fact_billing[claim_provider]`) vs Claimed Amount and Claim Approval Rate.
- **Donut**: payment methods (Total Bills by `payment_method`).
- **Matrix**: hospital × department, values = Revenue (Linked), conditional formatting (data bars).
- Time intelligence: add a card with **Appointments YTD** and a table with **Revenue Growth %**.
- Slicers: `year_month`, `claim_provider`, `payment_method`.

### Page 5: Operational Analytics
- Cards: Total Staff, Total Doctors, Total Nurses, Total Beds, Patients per Staff Member, Avg Appointments per Doctor.
- **Stacked column**: staff by hospital and `role` (use `fact_staff`, count of `staff_id`).
- **Clustered column**: appointments per doctor by hospital (Total Appointments ÷ doctors).
- **Bar**: beds by department. **Bar**: equipment items by department.
- **Gauge**: Bed Utilization Rate (target 80%; the actual is 3.8%).
- **Table**: Hospital Score and Hospital Overall Rank (from the DAX file) with conditional formatting. Title: "Hospitals that may need expansion".
- **Bookmarks** (Part 4): toggle between "Volume view" and "Staffing view".

### Page 6: Patient Experience
- Cards: Feedback Count, Avg Satisfaction, Poor Rating Rate, Excellent Rating Rate.
- **Column**: rating distribution (`rating` 1 to 5, Feedback Count).
- **Bar**: Avg Rating (Linked) by hospital, colour = Rating Colour; sorted high to low.
- **Bar**: Avg Rating (Linked) by department.
- **Line**: Avg Satisfaction by month. **Funnel** or donut: `rating_band`.
- **Tooltip page** (Part 4) showing the hospital's ratings.
- Slicers: hospital, department, `rating_band`.

## Part 4. The special features the brief requires

| Feature | How to do it |
|---|---|
| **KPI cards** | Insert > Card (or "Card (new)"); Format > Callout value font 28 pt. |
| **Slicers** | Insert > Slicer. Sync across pages: View > Sync slicers. |
| **Drill-through** | Add a page named "Hospital Detail". Drag `dim_facility[facility_id]` into **Drill through** wells. Add cards (appointments, revenue linked, rating) and a table. Right-click any hospital on other pages > Drill through > Hospital Detail. |
| **Bookmarks** | View > Bookmarks. Set the page in one state (e.g. chart A visible), Add bookmark "Volume". Change (hide chart A, show chart B using the Selection pane) and add bookmark "Staffing". Insert two buttons and set Action > Bookmark. |
| **Tooltips** | New page > Format page > Page information > **Allow use as tooltip** on. Page size > Type > Tooltip. Add a small card and a bar chart. On a visual: Format > General > Tooltips > Type = Report page > select the page. |
| **Hierarchies** | Part 2 step 4. Use the hierarchy on a matrix/column chart and click the "drill down" arrows. |
| **Conditional formatting** | Matrix cell values > Background colour > Gradient; bars > Colour > Field value (Rating Colour, Collection Colour). |
| **Maps** | Filled map on Page 1 (province). |
| **Matrix** | Pages 2 and 4. |
| **DAX measures** | `_Measures` table (section 1 to 9 of the DAX file). |
| **Time intelligence** | `Appointments YTD`, `Appointments Last Month`, `Appointment Growth %`, `Revenue Growth %` (uses `DATEADD` and `TOTALYTD`). |
| **Dynamic titles** | Select a visual > Format > General > Title > Text > **fx** > Field value > choose `Title - Revenue` etc. |
| **Decomposition tree** | Page 2. |
| **Key influencers** | Page 3. |
| **Forecasting** | Page 1: select the line chart > Analytics pane > Forecast > On. |

## Part 5. Check, save, export

1. Click through every slicer and make sure the cards react. Hospital / department / province visuals must show no "(Blank)" bar. If you see one, you used a total measure instead of a "(Linked)" measure.
2. Add a text box on page 1 footer: "Hospital, department and province figures use the 5,000 appointments that have full details (see README)." This is the honest limitation note.
3. **File > Save as** `Dashboard/HealthConnect_Analytics.pbix`.
4. **Executive Dashboard PDF**: go to Page 1 (Executive Overview). **File > Export > Export to PDF** (choose "Current page" only if you want one page; for all six pages export the full report and save it as `Dashboard/HealthConnect_Executive_Dashboard.pdf`).
5. Screenshots for the report: on each page press **Win + Shift + S**, select the page, save in `Images/` as `page1_executive.png` ... `page6_experience.png`.
6. Tell me the file names, and I will place them into the report and the slides (or follow the placeholders marked `[Insert screenshot]`).

## If something looks wrong
- Card shows 5,000 where you expect 20,000: you used a patient measure on a visual filtered by hospital. Patients have no hospital link, so clear the hospital slicer.
- Whole numbers show many decimals: select the measure > Measure tools > format, decimal places 0.
- Map does not show provinces: use a **Shape map** instead, or show the provinces as a bar chart and keep the map as optional.
