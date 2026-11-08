# Week 7 dashboard refinement checklist (Data Analytics)

Each item comes from a test in `Logs/Week7_Test_Record.csv`. Do the item in Power BI Desktop, then take a screenshot into `Evidence/` named as shown. Tick when done.

| # | Page | Change | Why (test) | Screenshot name | Done |
|---|---|---|---|---|---|
| R1 | Operational and Clinical | Make the stacked column charts show data: select the broken visual, pick the **Stacked column chart** icon, re-add the fields | D14 | `after_R1_stacked_columns.png` | [ ] |
| R2 | Clinical | Key influencers: put `visit_type`, `department_name`, `was_referred`, `had_lab_test` in **Explain by** | D15 | `after_R2_key_influencers.png` | [ ] |
| R3 | Operational | Hospital ranking table: add `Hospital Score` and `Hospital Overall Rank` | D16 | `after_R3_ranking_table.png` | [ ] |
| R4 | Executive | Map: add the `Place` column fix or use the bar-chart fallback | D17 | `after_R4_map.png` | [ ] |
| R5 | Executive, Patients, Operational | Add a small text note under cards that ignore a slicer: "Total Patients is not affected by the hospital or month slicers", "Total Staff and Beds are not affected by the month or province slicers" | E01 | `after_R5_card_notes.png` | [ ] |
| R6 | Patient Experience | Paste `Week7_Refinement_Measures.dax`. Change the hospital rating bar chart: colour by `Rating Colour (Refined)`; add `Rating CI Low`, `Rating CI High` and `Rating Count (Linked)` to the tooltip | F03, F12 | `after_R6_rating_chart.png` | [ ] |
| R7 | Patient Experience | Add a text box using the `Rating Data Note` measure under the rating cards | F09 | `after_R7_rating_note.png` | [ ] |
| R8 | Financial and Executive | Hospital x department matrix: use `Revenue (Linked, 30+ bills)` instead of `Revenue (Linked)`; rename the title to "Revenue by hospital and department (indicative only)" | F13 | `after_R8_matrix.png` | [ ] |
| R9 | Executive | Add a card `Future-dated Appointments` and a footnote "Appointments after 22 Oct 2026 are included; do not read the forecast as a real forecast" | F14 | `after_R9_future_note.png` | [ ] |
| R10 | All | Check every card against the expected values in `Dashboard/HealthConnect_DAX_Measures.txt`; the Poor Rating Rate card should now show **40.4%** | B29 | `after_R10_cards.png` | [ ] |
