# Explain it simply (for you, so you can answer questions)

**What is SQL / PostgreSQL here?** The place where the 27 data files live, so I can ask questions like "how much was billed?".
**What is Power BI?** The tool that turns those answers into charts and cards. DAX is the formula language inside it (like Excel formulas).
**What is a KPI?** One important number, like "90.1% of bills collected".
**What is a p-value?** A test for "could this just be luck?". Below 0.05 means probably not luck. Above 0.05 means I can't prove it, so I don't claim it.
**Why did you remove 5 findings?** Their p-values were 0.22 to 0.91. They looked like patterns but could be chance.
**Why 40.4% and not 40.5%?** 8,518 poor ratings out of 21,064 is 40.44%, which rounds to 40.4%. The first report rounded wrong.
**Why no no-show results?** The data has no column that says attended, cancelled or no-show. I can't invent it.
**Why only 5,000 appointments for hospital results?** Only 5,000 appointments have details. The 60,000 bills and diagnoses mostly can't be matched to an appointment (about 8%).
**Why are claims 50% pending for everyone?** The pending share is the same for every insurer, amount and payment method. So the cause is the process, not one insurer.
**What did Manal send and what did you send?** She sent the claims model (about 50% accuracy) and triage model (9.7% emergency recall vs an 80% goal). I sent back: claims are 50/50 and flat; 1,650 of 5,000 appointments (33%) are emergencies.
**What is not finished?** Saving the Power BI file (.pbix) and exporting its PDF. Only you can do this in Power BI Desktop.
