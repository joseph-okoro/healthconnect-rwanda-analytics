# Week 8 cross-track final integration record (Data Analytics)

Written as it happened. Fields marked **[YOU]** are for you to fill in only if something real happens before you submit.

| # | Field | Record |
|---|---|---|
| 1 | Track collaborated with | Project Management (Manal El khalifi). Data Science is the next receiver of my findings |
| 2 | Dependency | PM checks model results against project gates; my validated data facts explain those results |
| 3 | Output received | Week 7: claims model accuracy 50.1%; triage emergency recall 9.7% (32 of 330) vs an 80% gate |
| 4 | Output provided | Week 7: claims split 50.0/50.0 and flat across insurer, payment method, amount and visit type; 1,650 emergency appointments (33.0%). Week 8: the final analytics package (KPIs, validated findings, limits) |
| 5 | Final integration activity | Rechecked all 11 final KPIs; prepared the findings handover for Data Science (message below). **[YOU]** add a line if Data Science or PM replies |
| 6 | What changed | On my side: the two model results were added to the test record (F17, F18) and issue log (I-16); recommendations were rewritten to match the evidence. On the PM side: nothing reported as changed |
| 7 | How the change improved the solution | It shows claims accuracy near 50% has a data reason, so effort should go to a better target or fields, not tuning. It also shows the dataset has no attendance field |
| 8 | Evidence | Slack screenshots in `Week7/Evidence/CrossTrack_Record/`; `Week7/Code/week7_finding_tests.py`; `Week8/Evidence/final_kpis.csv` |
| 9 | Contribution to the final presentation | Slide 9 (cross-track) and slide 5 (what is proven) of the Data Analytics section |

Not claimed: a retest result, or that Data Science used my findings. Neither has been confirmed.

## Optional handover message (send it, then wait for a real reply)
Hi, here are my final validated findings from Data Analytics for the HealthConnect model work:
1. Claims are 50.0% approved and 50.0% pending in every group I tested (insurer, payment method, amount, visit type), so the claims fields hold no signal to predict from.
2. 1,650 of 5,000 appointments (33%) are emergencies.
3. The dataset has no attendance or no-show field.
My final KPIs and the report are in the Week8 folder. If you use any of this in the model write-up, please tell me and I will add it to the integration record. Thank you.
