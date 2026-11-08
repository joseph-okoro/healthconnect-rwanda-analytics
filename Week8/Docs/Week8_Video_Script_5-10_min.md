# Week 8 video script (about 7 minutes)

Read it in your own voice. Short sentences. Slides: `Presentation/HealthConnect_Week8_Analytics_Section_Slides.pptx`.
Tip: record on Zoom or Google Meet (share screen + camera on), say it twice if you stumble, upload and paste the link in the form.

## 1. Introduction (about 45 seconds) | slides 1-2
"Hello, my name is Okoro Joseph Ifeanyichukwu. I am in the Data Analytics track, in the HealthConnect pod.
HealthConnect is a project to help a clinic reduce missed appointments and give patients better support.
The problem is that clinics lose money and patient trust, and they need data to see where."

## 2. My track contribution (about 2.5 minutes) | slides 3-6
"My job was to turn the data into clear numbers, tested findings and actions.
In Week 5 I practised. In Week 6 I loaded 27 datasets into PostgreSQL, cleaned them, wrote SQL questions and built a Power BI dashboard.
The main results: the hospitals billed 9.31 billion Rwandan francs and collected 90.1 percent.
About 920 million is still unpaid.
Half of the 42,036 insurance claims are still pending, and that is true for every insurer, so the process needs a review.
The average patient rating is 2.99 out of 5, and 40.4 percent of ratings are poor.
The tools I used were SQL, Power BI, Python and Excel."

## 3. Cross-track collaboration (about 1.5 minutes) | slide 9
"In Week 7 I worked with Project Management. Manal, our project manager, sent me the results of the claims model and the triage model.
I checked them against my data and sent back two facts:
claims are split 50/50 between approved and pending, and that does not change with insurer, payment method or amount,
and about one third of appointments are emergencies.
This explains why a claims model gets about 50 percent accuracy: the data gives it nothing to learn from.
Manal thanked me. I did not get a retest result back, so I will not claim one.
For the final integration I am passing my validated findings to Data Science."

## 4. Testing, refinement and outcome (about 1.5 minutes) | slides 5, 7
"In Week 7 I ran 120 tests. 102 passed. I fixed one wrong number: poor ratings are 40.4 percent, not 40.5.
I also tested my five Week 6 findings, like 'the busiest hospitals are the least liked'.
The tests said these could just be chance, so I removed them. I would rather be correct than impressive.
In Week 8 I rechecked all 11 final KPIs and they all match.
One limit: the data has no field for attendance, so I could not measure no-shows.
Appointments are the same every day and every month, even on weekends."

## 5. Overall HealthConnect solution (about 1 minute) | slide 8
"My numbers feed the other tracks: Data Science reads them against the model, and Project Management uses them for decisions.
My recommendations are: record attendance for every appointment, chase unpaid bills, review the claims process,
staff evenly including weekends, and fix the feedback form.
That way HealthConnect recovers money now and can finally measure missed appointments."

## 6. Closing (about 45 seconds) | slide 10
"The key takeaway: HealthConnect can recover money now, and it must record attendance to fix missed appointments.
I learned to check numbers twice, to test before I claim, and to say what the data cannot do.
In a future version I would want the full appointment list and an attendance field.
Thank you."

---
## If someone asks "did you do this yourself?"
Say the truth: you used an AI assistant to help build the database, dashboard and report, and you reviewed the outputs. The simple explainer file (`Week8_Explain_It_Simply.md`) is there to help you explain each part in your own words.
