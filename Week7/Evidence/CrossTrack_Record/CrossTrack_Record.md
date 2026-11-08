# HC-POD cross-track testing record (Week 7)

Collaborating track: **Project Management** (Manal El khalifi, Project Manager, HealthConnect pod)
Channel: Slack direct message. Screenshots in this folder: `01_request_from_manal.png` (her request); `02_my_reply_and_her_acknowledgement.png` (my reply and her answer).

| # | Field | Record |
|---|---|---|
| 1 | Track collaborated with | Project Management (her results come from the Data Science / ML model work) |
| 2 | Project dependency | The Project Manager checks model results against the project quality gates; Data Analytics supplies validated facts about the data the models learn from |
| 3 | Component / output being tested | Claims model result (accuracy 50.1%) and triage model result (emergency recall 9.7%, 32 of 330; gate 80%) against the cleaned HealthConnect Rwanda data from Week 6 |
| 4 | Information received | Claims accuracy 50.1% (about chance); triage emergency recall 9.7% (32 of 330) against an 80% gate |
| 5 | Information provided | (a) Claim status is 50.0% Approved / 50.0% Pending (21,008 vs 21,028 of 42,036) and does not change with insurer (49.3% to 50.9%), payment method (49.4% to 50.9%), claim amount quartile (49.7% to 50.4%) or visit type (49.0% to 51.4%); (b) 1,650 emergency appointments of 5,000 (33.0%), so a 20% test split gives 330 |
| 6 | Testing activity completed | Chi-square tests of claim approval by insurer, payment method and amount (tests F17); count check of the emergency test-set size (F18). Code: `Week7/Code/week7_finding_tests.py` |
| 7 | Issue or finding identified | A claims model has no signal to learn from these fields: accuracy near 50% is expected, not a model fault. The emergency test-set size is consistent with the data; the 9.7% recall itself cannot be assessed from the Analytics side |
| 8 | Refinement / action taken | Sent both results to the Project Manager with a request to confirm the claims target (Approved vs Pending) and how emergency cases were labelled |
| 9 | Retest result | **No numerical retest.** She replied on 2 Nov 2026 at 12:10 AM: "Thank you very much, I really appreciate it. I submitted last min." She did not report a changed result, target or label |
| 10 | What changed as a result | Nothing was reported as changed on her side. On mine, the two results were added to the test record (F17, F18) and the issue log (I-16). The result was used in her submission as far as she said, but I cannot confirm how |
| 11 | Evidence | Slack screenshots, `Week7/Code/week7_finding_tests.py`, `Week7/Evidence/finding_tests.csv` |
| 12 | How the activity improved the overall HealthConnect solution | The model results were checked against validated data facts: claims accuracy near chance has a data explanation, so effort can move from tuning the claims model to finding a better target or fields |

Status: request received, answered with evidence, and acknowledged. The full Test, Finding, Action, Retest chain is not complete because no retest result came back. This is recorded as it happened.
