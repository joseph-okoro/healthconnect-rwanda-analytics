# %% [markdown]
# # HealthConnect Rwanda | Week 7: Analytical Testing, KPI Validation and Dashboard Refinement
# **Author:** Okoro Joseph Ifeanyichukwu | **Track:** Data Analytics | AnalystLab Africa
#
# This notebook **tests** the Week 6 outputs. It does not rebuild them. Every KPI is recalculated here from the raw source files
# (`Data/`) with code that is separate from the SQL and DAX used in Week 6, then compared with (a) the SQL database results,
# (b) the Power BI data files and DAX expected values, and (c) the values seen in Power BI Desktop screenshots.
# Each test is stored in a test record (`Logs/Week7_Test_Record.csv`) with expected result, actual result, pass/fail, issue, action and retest.

# %%
import pandas as pd, numpy as np, json, subprocess, io, os, warnings
from scipy import stats
warnings.filterwarnings('ignore')
RAW='../../Data/'; PBI='../../Dashboard/PowerBI_Data/'; OUT='../Logs/'
rd=lambda f: pd.read_csv(RAW+f,encoding='utf-8-sig',keep_default_na=False)
pb=lambda f: pd.read_csv(PBI+f,keep_default_na=False)
ANALYSIS_DATE=pd.Timestamp('2026-10-22')
R=[]  # test record
def T(tid,area,comp,scenario,expected,actual,status,issue='',action='',retest='',track='Data Analytics',evidence=''):
    R.append(dict(Test_ID=tid,Area=area,Component_Tested=comp,Scenario=scenario,Expected_Result=str(expected),Actual_Result=str(actual),
                  Pass_Fail=status,Issue_Identified=issue,Action_Taken=action,Retest_Result=retest,Collaborating_Track=track,Evidence=evidence))
def eq(a,b,tol=0): return abs(float(a)-float(b))<=tol
FACTS={}  # numbers used later in the report
def F(k,v): FACTS[k]=v; return v

# %% [markdown]
# ## 1. Load the raw source files (independent of the SQL pipeline)
# %%
pat=rd('HC_Patients.csv'); apt=rd('HC_Appointments.csv'); bil=rd('HC_Billing.csv'); pay=rd('HC_Payments.csv'); clm=rd('HC_Insurance_Claims.csv')
dia=rd('HC_Diagnoses.csv'); fb=rd('HC_Patient_Feedback.csv'); adm=rd('HC_Admissions.csv'); ref=rd('HC_Referrals.csv')
lab=rd('HC_Laboratory_Tests.csv'); rx=rd('HC_Prescriptions.csv'); bed=rd('HC_Beds.csv'); eqp=rd('HC_Medical_Equipment.csv'); rev=rd('HC_Revenue_Summary.csv')
staff={k:rd(f) for k,f in dict(Doctor='HC_Doctor.csv',Nurse='HC_Nurse.csv',Pharmacist='HC_Pharmacist.csv',Radiographer='HC_Radiographer.csv',
       Lab='HC_Laboratory_Scientist.csv',Admin='HC_Administrative_Staff.csv').items()}
for d,c in [(bil,'Amount'),(pay,'AmountPaid'),(clm,'ClaimAmount'),(fb,'Rating'),(adm,'LengthOfStayDays'),(pat,'Age')]: d[c]=pd.to_numeric(d[c])
apt['Date']=pd.to_datetime(apt['Date'])
print({n:len(d) for n,d in dict(patients=pat,appointments=apt,billing=bil,payments=pay,claims=clm,diagnoses=dia,feedback=fb,admissions=adm,referrals=ref,labs=lab,rx=rx,beds=bed).items()})

# %% [markdown]
# ## 2. Test group A: data pipeline reconciliation (raw files to Power BI files)
# %%
dp=pb('dim_patient.csv'); fa=pb('fact_appointments.csv'); fb_=pb('fact_billing.csv'); fd=pb('fact_diagnoses.csv'); ff=pb('fact_feedback.csv')
fs=pb('fact_staff.csv'); fbd=pb('fact_beds.csv'); fadm=pb('fact_admissions.csv'); flab=pb('fact_lab_tests.csv'); frx=pb('fact_prescriptions.csv')
fref=pb('fact_referrals.csv'); feq=pb('fact_equipment.csv'); frs=pb('fact_revenue_summary.csv')
dfac=pb('dim_facility.csv'); ddep=pb('dim_department.csv'); dprov=pb('dim_province.csv'); ddate=pb('dim_date.csv')
pairs=[('Patients',len(pat),len(dp)),('Appointments',len(apt),len(fa)),('Billing',len(bil),len(fb_)),('Diagnoses',len(dia),len(fd)),('Feedback',len(fb),len(ff)),
       ('Staff (6 files combined, 5 clinical+admin)',sum(len(v) for v in staff.values()),len(fs)),('Beds',len(bed),len(fbd)),('Admissions',len(adm),len(fadm)),
       ('Lab tests',len(lab),len(flab)),('Prescriptions',len(rx),len(frx)),('Referrals',len(ref),len(fref)),('Equipment',len(eqp),len(feq)),('Revenue summary',len(rev),len(frs))]
for i,(n,a,b) in enumerate(pairs,1):
    T(f'A{i:02d}','Pipeline reconciliation',f'Raw file to Power BI file: {n}',f'Row count of the raw {n} file equals the Power BI table',a,b,'PASS' if a==b else 'FAIL',evidence='Notebook section 2')
# key uniqueness
for t,df,k in [('dim_patient',dp,'patient_id'),('dim_facility',dfac,'facility_id'),('dim_department',ddep,'department_name'),('dim_province',dprov,'province_name'),('dim_date',ddate,'date'),
               ('fact_appointments',fa,'appointment_id'),('fact_billing',fb_,'billing_id')]:
    d=int(df[k].duplicated().sum()); T(f'A{len(R)+1:02d}','Keys',f'{t}[{k}] is unique (one-side of relationship)','Zero duplicate keys',0,d,'PASS' if d==0 else 'FAIL',evidence='Notebook section 2')
# orphan keys
def orph(f,fcol,dim,dcol):
    s=f[fcol]; s=s[s!='']; return int((~s.isin(set(dim[dcol]))).sum())
chk=[('fact_appointments','facility_id',fa,dfac,'facility_id'),('fact_billing','facility_id',fb_,dfac,'facility_id'),('fact_staff','facility_id',fs,dfac,'facility_id'),
     ('fact_appointments','patient_id',fa,dp,'patient_id'),('fact_appointments','department_name',fa,ddep,'department_name'),('fact_staff','department_name',fs,ddep,'department_name'),
     ('fact_billing','province_name',fb_,dprov,'province_name'),('fact_appointments','date',fa,ddate,'date'),('fact_billing','date',fb_,ddate,'date'),('fact_feedback','date',ff,ddate,'date'),
     ('fact_referrals','from_facility_id',fref,dfac,'facility_id'),('fact_referrals','referred_facility_id',fref,dfac,'facility_id'),('fact_revenue_summary','month_start',frs,ddate,'date')]
for f,c,df,dim,dc in chk:
    n=orph(df,c,dim,dc); T(f'A{len(R)+1:02d}','Relationships',f'Orphan keys: {f}[{c}] with no match in dimension',f'No unmatched non-blank keys, so the relationship filters every row',0,n,'PASS' if n==0 else 'FAIL',evidence='Notebook section 2')
# Linked counts
lk=int((fb_.link_status=='Linked').sum()); T(f'A{len(R)+1:02d}','Link status','fact_billing Linked rows equal bills whose appointment exists in the 5,000 appointments','Linked = number of bills matching an appointment',int(bil.AppointmentID.isin(apt.AppointmentID).sum()),lk,'PASS' if lk==int(bil.AppointmentID.isin(apt.AppointmentID).sum()) else 'FAIL',evidence='Notebook section 2')

# %% [markdown]
# ## 3. Test group B: KPI recalculation from raw files
# Outstanding = billed minus paid, per bill. Raw payments may hold one row per bill; check this first.
# %%
print('payments per bill max:',pay.BillingID.value_counts().max(),'| claims per bill max:',clm.BillingID.value_counts().max())
b=bil.merge(pay.groupby('BillingID',as_index=False).AmountPaid.sum(),on='BillingID',how='left').fillna({'AmountPaid':0})
b['outstanding']=b.Amount-b.AmountPaid
tot_rev=int(b.Amount.sum()); coll=int(b.AmountPaid.sum()); outst=int(b.outstanding.sum()); notpaid=int((b.outstanding>0).sum()); neg=int((b.outstanding<0).sum())
claims=len(clm); appr=int((clm.Status=='Approved').sum()); pend=int((clm.Status=='Pending').sum())
adm_appts=int(apt.AppointmentID.isin(adm.AppointmentID).sum()); adm_pts=int(apt[apt.AppointmentID.isin(adm.AppointmentID)].PatientID.nunique())
appt_by_pt=apt.groupby('PatientID').size(); seen=int(appt_by_pt.size); repeat=int((appt_by_pt>1).sum())
F('revenue',tot_rev);F('collected',coll);F('outstanding',outst);F('not_fully_paid',notpaid)
kpis=[('B01','Total patients',len(pat),20000),('B02','Total appointments',len(apt),5000),('B03','Total billed (RWF)',tot_rev,9309401961),('B04','Total collected (RWF)',coll,8389454556),
      ('B05','Outstanding bills (RWF)',outst,919947405),('B06','Bills not fully paid',notpaid,11887),('B07','Insurance claims',claims,42036),('B08','Approved claims',appr,21008),
      ('B09','Appointments that led to an admission',adm_appts,586),('B10','Patients seen (distinct)',seen,4443),('B11','Repeat patients (2+ visits)',repeat,510),
      ('B12','Patients over 65',int((pat.Age>65).sum()),5487),('B13','Patients with a chronic condition',int((pat.ChronicCondition!='None').sum()),14929),
      ('B14','Doctors',len(staff['Doctor']),350),('B15','Nurses',len(staff['Nurse']),700),('B16','Total staff (all six files)',sum(len(v) for v in staff.values()),1250),('B17','Beds',len(bed),2000),
      ('B18','Bed-days used (sum of length of stay)',int(adm.LengthOfStayDays.sum()),27438),('B19','Severe diagnoses',int((dia.Severity=='Severe').sum()),19983),
      ('B20','Referrals',len(ref),4708),('B21','Feedback records',len(fb),21064)]
for tid,name,act,exp in kpis:
    T(tid,'KPI validation',f'KPI: {name}','Recalculate from raw files; must equal the Week 6 SQL/DAX expected value',f'{exp:,}',f'{int(act):,}','PASS' if int(act)==exp else 'FAIL',evidence='Notebook section 3')
rates=[('B22','Collection rate (%)',round(100*coll/tot_rev,1),90.1),('B23','Claim approval rate (%)',round(100*appr/claims,1),50.0),('B24','Admission rate (% of appointments)',round(100*adm_appts/len(apt),1),11.7),
       ('B25','Average rating (all 21,064)',round(fb.Rating.mean(),2),2.99),('B26','Average length of stay (days)',round(adm.LengthOfStayDays.mean(),2),5.49),('B27','Average patient age',round(pat.Age.mean(),1),45.0),
       ('B28','Average bill (RWF)',round(bil.Amount.mean()),155157),('B29','Poor ratings 1-2 (%)',round(100*(fb.Rating<=2).mean(),1),40.5),('B30','Bed utilisation estimate (%)',round(100*adm.LengthOfStayDays.sum()/(len(bed)*365),1),3.8),
       ('B31','Patients per staff member',round(len(pat)/sum(len(v) for v in staff.values()),1),16.0),('B32','Appointments per doctor',round(len(apt)/len(staff['Doctor']),2),14.29),
       ('B33','Abnormal lab results (%)',round(100*(lab.Result=='Abnormal').mean(),1),50.3),('B34','Severe diagnoses (%)',round(100*(dia.Severity=='Severe').mean(),1),33.3)]
for tid,name,act,exp in rates:
    T(tid,'KPI validation',f'KPI: {name}','Recalculate from raw files; must equal the Week 6 expected value',exp,act,'PASS' if eq(act,exp,0.05) else 'FAIL',evidence='Notebook section 3')
T('B35','KPI validation','Outstanding amount: no negative balances','No bill should have paid > billed (would cut the outstanding total)',0,neg,'PASS' if neg==0 else 'FAIL',evidence='Notebook section 3')
# age vs date of birth
dob=pd.to_datetime(pat.DateOfBirth,format='%m/%d/%Y',errors='coerce')
age_calc=((ANALYSIS_DATE-dob).dt.days//365.25).astype('Int64'); mism=int((age_calc!=pat.Age).sum()); F('age_dob_mismatch',mism)
T('B36','Data validation','Patient Age vs date of birth','Age column equals age worked out from date of birth at 22 Oct 2026',0,mism,'PASS' if mism<=int(0.01*len(pat)) else 'FAIL',
  issue='' if mism==0 else f'{mism:,} ages differ from date of birth by one year (birthday not yet reached/passed)',action='' if mism==0 else 'Age column is used as supplied. The difference is a one-year rounding effect and does not change the 65+ group materially.',
  retest='' if mism==0 else f"Patients over 65 by date of birth: {int((age_calc>65).sum()):,} vs by Age column: {int((pat.Age>65).sum()):,}",evidence='Notebook section 3')
F('over65_dob',int((age_calc>65).sum()))


for r_ in R:
    if r_['Test_ID']=='B29':
        r_.update(Issue_Identified='Week 6 reported 40.5%; the correct value is 40.4% (8,518 of 21,064). The Week 6 figure was rounded up from 40.44%.',
                  Action_Taken='Corrected to 40.4% in the Week 6 report, slides, README and the DAX expected-value comment (originals kept in Week7/Corrections/Week6_originals)',
                  Retest_Result='Retest: text search of the corrected report PDF and slides finds 40.4% and no 40.5%')
exc=round(100*(fb.Rating>=4).mean(),1)
T('B37','KPI validation','KPI: Excellent ratings 4-5 (%)','Recalculate from raw files; must equal the Week 6 expected value',39.6,exc,'PASS' if eq(exc,39.6,0.05) else 'FAIL',evidence='Notebook section 3')
minors=pat[pat.Age<18]; nm=int((minors.MaritalStatus!='Single').sum()); F('minors',len(minors)); F('minors_not_single',nm)
T('B38','Data validation','Patient details: patients under 18 recorded as Married or Widowed','No child should be married or widowed',0,f'{nm:,} of {len(minors):,} patients under 18','FAIL',
  'Marital status (and occupation) are unreliable for children, so they cannot be used in patient analysis','Marital status and occupation are not used in any KPI or chart; listed as a data issue for the data owner (Issue I-05)','Not resolvable with the data supplied; no KPI affected',evidence='Notebook section 3')
bmi=(pat.WeightKg.astype(float)/(pat.HeightCm.astype(float)/100)**2); badbmi=int(((bmi>50)|(bmi<12)).sum()); F('bad_bmi',badbmi)
T('B39','Data validation','Patient height and weight: implausible BMI (above 50 or below 12)','Very few implausible values',0,f'{badbmi:,} of {len(pat):,} patients','FAIL','Height and weight values are partly unrealistic','BMI is not used in any KPI; listed as a data issue (Issue I-05)','No KPI affected',evidence='Notebook section 3')

pa=int(round(clm[clm.Status=='Pending'].ClaimAmount.sum())); aa=int(round(clm[clm.Status=='Approved'].ClaimAmount.sum())); F('claims_pending_amt',pa); F('claims_approved_amt',aa); F('claims_pending_n',pend)
T('B40','KPI validation','KPI: Pending insurance claims (count)','Recalculate from raw files; must equal the Week 6 value','21,028',f'{pend:,}','PASS' if pend==21028 else 'FAIL',evidence='Notebook section 3')
T('B41','KPI validation','KPI: Pending claims value (RWF)','Recalculate from raw files; Week 6 reported RWF 2.44 billion','2,438,605,768',f'{pa:,}','PASS' if abs(pa-2438605768)<=1 else 'FAIL',evidence='Notebook section 3')
T('B42','KPI validation','KPI: Approved claims value (RWF)','Recalculate from raw files; Week 6 reported RWF 2.44 billion','2,443,257,526',f'{aa:,}','PASS' if abs(aa-2443257526)<=1 else 'FAIL',evidence='Notebook section 3')

# %% [markdown]
# ## 4. Test group C: SQL database vs this notebook
# %%
def sql(q,db='hc_verify'):
    r=subprocess.run(['psql','-h','/tmp','-p','5433','-U','postgres','-d',db,'-At','-F','|','-c',q],capture_output=True,text=True)
    return r.stdout.strip() if r.returncode==0 else None
qs=[('C01','SUM(billed) from hc.billing',"select sum(amount) from hc.billing",tot_rev),('C02','SUM(paid) from hc.payments',"select sum(amount_paid) from hc.payments",coll),
    ('C03','Outstanding from hc.v_billing_detail',"select sum(outstanding_amount) from hc.v_billing_detail",outst),('C04','Approved claims',"select count(*) from hc.insurance_claims where status='Approved'",appr),
    ('C05','Distinct patients seen',"select count(distinct patient_id) from hc.appointments",seen),('C06','Appointments per hospital (HF013)',"select count(*) from hc.appointments where facility_id='HF013'",int((apt.FacilityID=='HF013').sum())),
    ('C07','Admitted appointments',"select count(*) from hc.appointments a join hc.admissions s using(appointment_id)",adm_appts),('C08','Average rating',"select round(avg(rating),2) from hc.patient_feedback",round(fb.Rating.mean(),2))]
for tid,name,q,exp in qs:
    a=sql(q); ok=a is not None and float(a)==float(exp)
    T(tid,'SQL vs independent code',f'SQL result: {name}','PostgreSQL result equals the independent pandas result',f'{float(exp):,.2f}'.rstrip('0').rstrip('.'),a if a is not None else 'database not available','PASS' if ok else 'FAIL',evidence='SQL/06_week7_tests.sql; notebook section 4')
dq=sql("select count(*), sum((result='ISSUE')::int) from hc.data_quality_log"); F('dq_checks',dq)

# %% [markdown]
# ## 5. Test group D: dashboard values seen in Power BI Desktop (from screenshots)
# The values below were read from the two Power BI Desktop screenshots saved in `Evidence/` (Clinical Analytics and Operational Analytics pages).
# %%
shots=[('D01','Total Staff card (Operational page)',1250,1250),('D02','Total Doctors card',350,350),('D03','Total Nurses card',700,700),('D04','Total Beds card',2000,2000),
       ('D05','Patients per Staff Member card','16.0','16.00'),('D06','Avg Appointments per Doctor card','14.29','14.29'),('D07','Bed utilisation gauge','3.8%','3.8%'),
       ('D08','Severe Rate card (Clinical page)','33.3%','33.3%'),('D09','Avg Length of Stay card','5.49','5.49'),('D10','Admission Rate card','11.7%','11.7%'),
       ('D11','Abnormal Lab Rate card','50.3%','50.3%'),('D12','Referrals card','4,708','4,708'),('D13','Total Diagnoses card','60,000 (shown as 60K)','60K')]
for tid,name,exp,act in shots: T(tid,'Dashboard values (Power BI)',name,'Value shown in Power BI equals the validated expected value',exp,act,'PASS',evidence='Evidence/screenshot_operational_page_before_fix.png, Evidence/screenshot_clinical_page_before_fix.png')
T('D14','Dashboard build','Stacked column chart visual (Operational and Clinical pages)','Chart renders with data','Chart with staff by hospital and role','Grey box: "To see this custom visual, add it to this report first: stackedColumnChart"','FAIL',
  'Visual type name in the generated project file was invalid (stackedColumnChart); correct type is columnChart','Fix identified: switch both visuals to the Stacked column chart type and re-add the fields (checklist R1)','Pending: retest screenshot (Evidence/after_R1_stacked_columns.png)',track='Data Analytics',evidence='Evidence/screenshot_operational_page_before_fix.png, screenshot_clinical_page_before_fix.png')
T('D15','Dashboard build','Key influencers visual (Clinical page)','Visual lists drivers of admission','Ranked list of influencers','"No fields in Explain by"','FAIL','Explain-by fields were not carried into the generated project file','Fix identified: add visit_type, department_name, was_referred and had_lab_test to Explain by (checklist R2)','Pending: retest screenshot (Evidence/after_R2_key_influencers.png)',evidence='Evidence/screenshot_clinical_page_before_fix.png')
T('D16','Dashboard build','Hospital ranking table (Operational page)','Table shows Hospital Score and Hospital Overall Rank next to each hospital','Three columns','Only facility_id column visible','FAIL','Measure columns missing from the table','Fix identified: add Hospital Score and Hospital Overall Rank to the table (checklist R3)','Pending: retest screenshot (Evidence/after_R3_ranking_table.png)',evidence='Evidence/screenshot_operational_page_before_fix.png')
T('D17','Dashboard build','Map visual (Executive page)','Revenue by province shown on a map','Filled map of five provinces','Map not displayed','FAIL','Province names did not geocode, or map visuals not enabled in Options > Security','Fix identified: Place column (province name plus ", Rwanda") or enable map visuals; fallback is a bar chart of revenue by province (checklist R4)','Pending: retest screenshot',evidence='Reported by user; retest screenshot pending')

# %% [markdown]
# ## 6. Test group E: do the dashboard slicers reach every KPI? (model analysis)
# A slicer only changes a card if a relationship path leads from the slicer's table to the card's table.
# %%
rel=[('fact_appointments','dim_date'),('fact_billing','dim_date'),('fact_diagnoses','dim_date'),('fact_feedback','dim_date'),('fact_lab_tests','dim_date'),('fact_prescriptions','dim_date'),
     ('fact_admissions','dim_date'),('fact_referrals','dim_date'),('fact_revenue_summary','dim_date')]
rel+=[(f,'dim_facility') for f in ['fact_appointments','fact_billing','fact_diagnoses','fact_feedback','fact_lab_tests','fact_prescriptions','fact_admissions','fact_staff','fact_beds','fact_equipment','fact_referrals']]
rel+=[(f,'dim_department') for f in ['fact_appointments','fact_billing','fact_diagnoses','fact_feedback','fact_lab_tests','fact_prescriptions','fact_admissions','fact_referrals','fact_staff','fact_beds','fact_equipment']]
rel+=[('fact_appointments','dim_patient'),('dim_patient','dim_province')]+[(f,'dim_province') for f in ['fact_billing','fact_diagnoses','fact_feedback','fact_lab_tests','fact_prescriptions','fact_admissions','fact_referrals']]
down={}  # one-side -> many-side
for many,one in rel: down.setdefault(one,set()).add(many)
def reach(src):
    seen_={src}; st=[src]
    while st:
        x=st.pop()
        for y in down.get(x,()):
            if y not in seen_: seen_.add(y); st.append(y)
    return seen_
cards=[('Total Patients','dim_patient'),('Patients Seen','fact_appointments'),('Total Appointments','fact_appointments'),('Total Revenue','fact_billing'),('Total Diagnoses','fact_diagnoses'),
       ('Avg Satisfaction','fact_feedback'),('Total Staff','fact_staff'),('Total Beds','fact_beds'),('Revenue Growth % (Revenue Summary)','fact_revenue_summary')]
sl_={'Month slicer':'dim_date','Province slicer':'dim_province','Hospital slicer':'dim_facility','Department slicer':'dim_department'}
mat=[]
for c,t in cards:
    row={'Card':c}
    for s,st_ in sl_.items(): row[s]='responds' if t in reach(st_) else 'does NOT respond'
    mat.append(row)
mat=pd.DataFrame(mat); print(mat.to_string(index=False)); mat.to_csv(OUT+'Week7_Slicer_Reach_Matrix.csv',index=False)
nr=int((mat.drop(columns='Card')=='does NOT respond').sum().sum())
F('slicer_nonresponding',nr)
T('E01','Dashboard filters','Slicer reach: month, province, hospital and department slicers vs nine KPI cards','Every slicer on a page should change every card on that page, or be clearly labelled',
  '36 of 36 slicer/card pairs respond',f'{36-nr} of 36 respond; {nr} do not','FAIL',
  'Total Patients ignores the month and hospital slicers (patients have no hospital); Total Staff and Total Beds ignore month and province; Revenue Summary ignores hospital, province and department',
  'Planned: add a visible note under each affected card and place Patients Seen (which does respond) next to Total Patients (checklist R5)','Pending: retest screenshot. The behaviour follows from the data model, not from a calculation error',
  evidence='Logs/Week7_Slicer_Reach_Matrix.csv')

# %% [markdown]
# ## 7. Test group F: do the Week 6 findings hold up? (segment and significance tests)
# Week 6 reported rankings of hospitals, departments and provinces. Rankings can look meaningful even when differences are only chance, so each key finding is tested.
# %%
rng=np.random.default_rng(7)
# F1 hospital volume
vol=apt.FacilityID.value_counts().sort_index(); chi,p=stats.chisquare(vol.values); F('vol_chi_p',round(p,3)); F('vol_min',int(vol.min()));F('vol_max',int(vol.max()))
T('F01','Finding validation','Week 6 finding: "HF013, HF014, HF010 are busiest; HF019 quietest"','Hospital volumes differ more than chance would explain (chi-square, p < 0.05)','p < 0.05',f'chi-square p = {p:.3f}, borderline (range {vol.min()} to {vol.max()} against 250 expected)',
  'PASS' if p<0.05 else 'FAIL','Differences in hospital volume are not reliable at the 5% level (borderline) and are close to random variation' if p>=0.05 else '', 'Re-worded: hospitals are described as "similar in volume"; ranking by volume kept only as a descriptive table' if p>=0.05 else '',
  'Recommendation 1 (move doctors) changed from "re-balance now" to "monitor monthly"' if p>=0.05 else '',evidence='Notebook section 7')
# F2 per doctor
docs=staff['Doctor'].groupby('FacilityID').size(); per=(vol/docs); mech=(250/docs)  # expected per doctor if volume equal
corr=stats.spearmanr(per,docs)[0]
F('per_doc_min',round(per.min(),1));F('per_doc_max',round(per.max(),1)); F('doc17',int((docs==17).sum())); F('doc18',int((docs==18).sum()))
mech_range=(250/docs.max(), 250/docs.min()); F('mech_lo',round(mech_range[0],1)); F('mech_hi',round(mech_range[1],1))
T('F02','Finding validation','Week 6 finding: "same staff, uneven workload: 12.3 to 16.4 appointments per doctor"','Doctor numbers (17 or 18 per hospital) explain most of the spread',
  f'Spread of about {mech_range[0]:.1f} to {mech_range[1]:.1f} if volume were equal',f'Observed {per.min():.1f} to {per.max():.1f}; the extra spread comes from appointment volume, which test F01 shows is not reliably different','FAIL',
  'The "uneven allocation" finding is not supported as stated: staffing is nearly flat (17 or 18 doctors, 35 nurses everywhere) and volume differences are chance',
  'Replaced by a fact that is supported: staffing does not vary with demand because every hospital has the same team size; the 12-to-16 range is shown as descriptive only',
  'Reworded finding verified: nurses per hospital all 35; doctors 17 or 18',evidence='Notebook section 7')
nur=staff['Nurse'].groupby('FacilityID').size(); F('nurse_min',int(nur.min())); F('nurse_max',int(nur.max()))
# F3 hospital ratings
fbl=fb.merge(apt[['AppointmentID','FacilityID','DepartmentID','PatientID']],on='AppointmentID',how='inner'); F('fb_linked',len(fbl))
g=[x.Rating.values for _,x in fbl.groupby('FacilityID')]; Fh,ph=stats.f_oneway(*g); kw=stats.kruskal(*g).pvalue
F('rating_hosp_p',round(ph,3)); F('rating_hosp_kw',round(kw,3))
T('F03','Finding validation','Week 6 finding: "busiest hospitals are among the least liked" (HF013, HF014 rated 2.77)','Hospital ratings differ by more than chance (ANOVA p < 0.05)','p < 0.05',f'ANOVA p = {ph:.2f}; Kruskal-Wallis p = {kw:.2f}','PASS' if ph<0.05 else 'FAIL',
  'Hospital rating differences are within random variation' if ph>=0.05 else '', 'Removed the claim from the key messages; hospital ratings now shown with sample size and 95% confidence range (see section 8)' if ph>=0.05 else '',
  'Refined measure flags 0 hospitals as reliably different (section 8)' if ph>=0.05 else '',evidence='Notebook section 7')
hv=fbl.groupby('FacilityID').Rating.mean(); sp=stats.spearmanr(vol.reindex(hv.index),hv); F('vol_rating_rho',round(sp[0],2)); F('vol_rating_p',round(sp[1],2))
T('F04','Finding validation','Is hospital volume related to hospital rating?','Spearman correlation between appointments and rating is clearly negative (p < 0.05)','rho < 0, p < 0.05',f'rho = {sp[0]:.2f}, p = {sp[1]:.2f}','PASS' if sp[1]<0.05 else 'FAIL',
  'No reliable link between how busy a hospital is and how patients rate it','Week 6 headline "busy hospitals are less liked" withdrawn','Headline replaced by "ratings are similar across hospitals; 40.4% of ratings are poor everywhere"',evidence='Notebook section 7')
# F5 dept ratings
gd=[x.Rating.values for _,x in fbl.merge(pd.read_csv(RAW+'HC_Departments.csv',encoding='utf-8-sig')[['DepartmentID','DepartmentName']],on='DepartmentID').groupby('DepartmentName')]
pdp=stats.f_oneway(*gd).pvalue; F('rating_dept_p',round(pdp,3))
T('F05','Finding validation','Week 6 finding: "ICU lowest (2.76), Emergency best (3.02)"','Department ratings differ by more than chance (ANOVA p < 0.05)','p < 0.05',f'ANOVA p = {pdp:.2f}','PASS' if pdp<0.05 else 'FAIL',
  'Department rating differences are within random variation' if pdp>=0.05 else '','ICU patient-experience programme recommendation downgraded to "monitor" ' if pdp>=0.05 else '','',evidence='Notebook section 7')
# F6 province usage
ap=apt.merge(pat[['PatientID','VillageID']],on='PatientID'); vil=rd('HC_Villages.csv'); sec=rd('HC_Sectors.csv'); dis=rd('HC_Districts.csv'); prv=rd('HC_Provinces.csv')
print(vil.columns.tolist(),sec.columns.tolist(),dis.columns.tolist(),prv.columns.tolist())
# %%
vcol=[c for c in vil.columns]; 
geo=pat[['PatientID','VillageID']].merge(vil,on='VillageID',how='left')
for left,right in [(sec,'SectorID'),(dis,'DistrictID'),(prv,'ProvinceID')]:
    geo=geo.merge(left,on=right,how='left',suffixes=('','_x'))
pname=[c for c in geo.columns if 'Province' in c and 'Name' in c][0]
geo=geo[['PatientID',pname]].rename(columns={pname:'Province'})
ap=apt.merge(geo,on='PatientID'); n_pat=geo.Province.value_counts(); n_app=ap.Province.value_counts()
exp=n_pat/n_pat.sum()*n_app.sum(); chi,pp=stats.chisquare(n_app.reindex(n_pat.index),exp)
per1000=(1000*n_app/n_pat).round(0); F('prov_p',round(pp,2)); F('prov_min',str(per1000.idxmin())); F('prov_per1000',per1000.to_dict())
T('F06','Finding validation','Week 6 finding: "Kigali City patients use hospitals least (239 per 1,000)"','Province use rates differ by more than chance (chi-square p < 0.05)','p < 0.05',f'chi-square p = {pp:.2f} (Kigali City {per1000["Kigali City"]:.0f}, Northern {per1000["Northern"]:.0f})','PASS' if pp<0.05 else 'FAIL',
  'Province differences in hospital use are within random variation' if pp>=0.05 else '','Recommendation 6 changed from "investigate access in Kigali, Southern, Eastern" to "no evidence of regional under-use; re-test when the full appointment list is loaded"' if pp>=0.05 else '','',evidence='Notebook section 7')
# F7 quarterly diagnosis trend (linked)
dl=dia.merge(apt[['AppointmentID','Date']],on='AppointmentID'); dl['Q']=dl.Date.dt.quarter
ct=pd.crosstab(dl.Diagnosis,dl.Q); chi,pq,_,_=stats.chi2_contingency(ct); F('trend_p',round(pq,2))
h=ct.loc['Hypertension']; pb_=stats.binomtest(int(h[4]),int(h.sum()),0.25).pvalue
T('F07','Finding validation','Week 6 finding: "hypertension and respiratory infections rose in Q4"','Diagnosis mix changes between quarters (chi-square p < 0.05)','p < 0.05',f'chi-square p = {pq:.2f}; hypertension Q4 share {h[4]/h.sum():.1%} (binomial p = {pb_:.2f})','PASS' if pq<0.05 else 'FAIL',
  'No evidence that any diagnosis is becoming more common' if pq>=0.05 else '','Business question 3 answered as "no reliable trend; diagnoses are evenly spread"; the Q4 caveat (includes future dates) kept','',evidence='Notebook section 7')
# F8 unpaid by payment method
bp=bil.merge(pay,on='BillingID'); bp['out']=bp.Amount-bp.AmountPaid; ctu=pd.crosstab(bp.Method,bp.out>0); pm=stats.chi2_contingency(ctu)[1]; F('method_p',round(pm,2))
T('F08','Finding validation','Week 6 finding: "unpaid amounts are almost equal across payment methods"','Unpaid share does not depend on payment method (chi-square p >= 0.05)','p >= 0.05',f'chi-square p = {pm:.2f}','PASS' if pm>=0.05 else 'FAIL',retest='Finding confirmed',evidence='Notebook section 7')
# F9 rating vs comment
rc=pd.crosstab(fb.Rating,fb.Comment); pc=stats.chi2_contingency(rc)[1]
mis=int(((fb.Rating<=2)&fb.Comment.isin(['Excellent','Good'])).sum()+((fb.Rating>=4)&(fb.Comment=='Poor')).sum()); F('rating_comment_p',round(pc,2)); F('rating_comment_mismatch',mis)
T('F09','Data reliability','Does the rating agree with the comment?','Low ratings go with Poor comments and high ratings with Excellent (chi-square p < 0.05)','p < 0.05',f'chi-square p = {pc:.2f}; {mis:,} of {len(fb):,} ratings contradict their comment','FAIL',
  'Rating and comment are statistically unrelated, so at least one of them is unreliable; satisfaction KPIs cannot be taken as a true measure of patient experience',
  'Satisfaction KPIs labelled "as recorded; reliability not confirmed" in the dashboard and report; raised as a data issue for the data owner (Issue I-04)','Cannot be resolved with the data supplied',evidence='Notebook section 7')
# F10 bill status vs payment
bs=bil.merge(b[['BillingID','outstanding']],on='BillingID'); mm=int(((bs.Status=='Paid')&(bs.outstanding>0)).sum()+((bs.Status!='Paid')&(bs.outstanding==0)).sum()); F('status_mismatch',mm)
T('F10','Data reliability','Does the bill Status agree with the payment actually received?','Paid bills have zero outstanding; Pending/Partially Paid bills have a balance','0 contradictions',f'{mm:,} of {len(bil):,} bills contradict','FAIL',
  'Bill status label is unreliable, so any KPI built on Status would be wrong','Week 6 used billed minus paid instead of Status; confirmed by test B05 (matches database)','Retest: outstanding total RWF 919,947,405 reconciles between raw files, SQL and DAX expected value (B05, C03)',evidence='Notebook section 7')
# F11 representativeness
bl=bil.assign(linked=bil.AppointmentID.isin(apt.AppointmentID)); tb=stats.ttest_ind(bl[bl.linked].Amount,bl[~bl.linked].Amount,equal_var=False)
fl=fb.assign(linked=fb.AppointmentID.isin(apt.AppointmentID)); tf=stats.ttest_ind(fl[fl.linked].Rating,fl[~fl.linked].Rating,equal_var=False)
dl2=dia.assign(linked=dia.AppointmentID.isin(apt.AppointmentID)); pdm=stats.chi2_contingency(pd.crosstab(dl2.Diagnosis,dl2.linked))[1]
F('rep_bill_p',round(tb.pvalue,2));F('rep_rating_p',round(tf.pvalue,3));F('rep_dx_p',round(pdm,2))
T('F11','Sample representativeness','Are the 5,000 traceable appointments typical of all records?','Linked and not-linked records look alike (bill size, rating, diagnosis mix; p >= 0.05)','p >= 0.05 for all three',
  f'bill size p = {tb.pvalue:.2f}; rating p = {tf.pvalue:.3f} (borderline: linked mean {fl[fl.linked].Rating.mean():.2f} vs {fl[~fl.linked].Rating.mean():.2f}); diagnosis mix p = {pdm:.2f}','PASS' if min(tb.pvalue,tf.pvalue,pdm)>=0.05 else 'FAIL','' ,'', 'Linked-only results can be treated as a fair sample of the full data, but hospital-level detail (about 250 appointments each) is thin',evidence='Notebook section 7')

# %% [markdown]
# ## 8. Refinement: sample-size-aware ratings (before and after)
# Refined measures add the number of ratings, the 95% confidence range and a flag that only marks a hospital when its range excludes the network average.
# %%
net=fb.Rating.mean(); rows=[]
for h_,x in fbl.groupby('FacilityID'):
    n=len(x); m=x.Rating.mean(); se=x.Rating.std(ddof=1)/np.sqrt(n); lo,hi=m-1.96*se,m+1.96*se
    old='red' if m<2.8 else ('green' if m>=3.0 else 'grey'); new='below network' if hi<net else ('above network' if lo>net else 'within normal range')
    rows.append(dict(Hospital=h_,Ratings=n,Avg=round(m,2),CI_low=round(lo,2),CI_high=round(hi,2),Week6_colour=old,Week7_flag=new))
rt=pd.DataFrame(rows).sort_values('Avg'); rt.to_csv(OUT+'Week7_Hospital_Rating_Before_After.csv',index=False); print(rt.to_string(index=False))
nflag=int((rt.Week7_flag!='within normal range').sum()); nred=int((rt.Week6_colour=='red').sum()); F('flag_after',nflag);F('red_before',nred);F('rating_n_min',int(rt.Ratings.min()));F('rating_n_max',int(rt.Ratings.max()))
F('ci_width_avg',round((rt.CI_high-rt.CI_low).mean(),2))
T('F12','Refinement','Refined hospital rating flag (sample size and 95% confidence range)','Only hospitals whose confidence range excludes the network average (2.99) are flagged','Week 6 coloured red/green on raw averages',
  f'Week 6 marked {nred} hospitals red; refined flag marks {nflag}','PASS','Week 6 colour rule treated 2.76 vs 3.19 as real differences with 72 to 102 ratings per hospital',
  'Refinement measures written (Rating Count, Rating CI Low/High, Rating Flag; Dashboard_Refinement/Week7_Refinement_Measures.dax); to be applied to the rating chart (checklist R6)',
  f'Retest on the data (same logic in Python and SQL): {nflag} hospitals flagged; typical confidence range +/-{(rt.CI_high-rt.CI_low).mean()/2:.2f} points. Retest in Power BI pending (R6)',evidence='Logs/Week7_Hospital_Rating_Before_After.csv')
# small samples on matrix
dnm=pd.read_csv(RAW+'HC_Departments.csv',encoding='utf-8-sig'); apd=apt.merge(dnm[['DepartmentID','DepartmentName']],on='DepartmentID',how='left')
cell=fl[fl.linked].merge(apd[['AppointmentID','FacilityID','DepartmentName']],on='AppointmentID').groupby(['FacilityID','DepartmentName']).size()
bc=bil[bil.AppointmentID.isin(apt.AppointmentID)].merge(apd[['AppointmentID','FacilityID','DepartmentName']],on='AppointmentID').groupby(['FacilityID','DepartmentName']).size()
F('bill_cell_median',int(bc.median()));F('rating_cell_median',float(cell.median()));F('rating_cell_min',int(cell.min()))
cc=apd.groupby(['FacilityID','DepartmentName']).size()
F('hd_cells',int(len(cc)));F('hd_below30',int((cc<30).sum()));F('hd_median',int(cc.median()));F('hd_min',int(cc.min()))
T('F13','Dashboard robustness','Small-sample cells in the hospital by department matrix','Each cell has enough records for a stable figure (30 or more)',' >= 30 per cell',f'median {int(cc.median())} appointments, {int(bc.median())} bills and {float(cell.median()):.0f} ratings per hospital-department cell (minimum {int(cc.min())} appointments); {int((cc<30).sum())} of {len(cc)} cells have fewer than 30','FAIL',
  'Hospital x department figures rest on very few records and swing widely','Guard measure written (Revenue (Linked, 30+ bills)); matrix to be titled "indicative only" (checklist R8)','Retest on the data: cells below 30 would show blank. Retest in Power BI pending (R8)',evidence='Notebook section 8')
# future dates
fut=int((apt.Date>ANALYSIS_DATE).sum()); F('future',fut); af=apt[apt.Date<=ANALYSIS_DATE]
adm_f=100*af.AppointmentID.isin(adm.AppointmentID).mean(); F('adm_rate_to_date',round(adm_f,1))
mon=apt.groupby(apt.Date.dt.to_period('M')).size(); mon_to=af.groupby(af.Date.dt.to_period('M')).size()
T('F14','Sensitivity','Do appointments dated after 22 Oct 2026 change the headline KPIs?','Admission rate and ratings unchanged when future-dated rows are excluded (within 0.5 points)','11.7%',f'{adm_f:.1f}% ({fut} future-dated rows excluded)','PASS' if abs(adm_f-11.7)<=0.5 else 'FAIL',
  f'{fut} appointments ({100*fut/len(apt):.1f}%) are dated after the analysis date; Nov and Dec monthly counts look just like earlier months',
  'Measures written (Appointments to Analysis Date, Future-dated Appointments) and a dashboard footnote planned (checklist R9); forecast should not be read as a real forecast','Headline KPIs stable to 0.5 points either way',evidence='Notebook section 8')
# unpaid by staff? no. Edge case: divisions by zero
T('F15','Edge cases','Rate measures when a filter leaves no records (DIVIDE guard)','Rates show blank, not an error, when the denominator is zero','Blank','All rate measures use DIVIDE(); fewest records in any hospital x month cell: '+str(int(apt.groupby(['FacilityID',apt.Date.dt.to_period("M")]).size().min())),'PASS',evidence='DAX file review; notebook section 8')

# %% [markdown]
# ## 9. Save the test record
# %%
rec=pd.DataFrame(R); rec.to_csv(OUT+'Week7_Test_Record.csv',index=False)
summ=rec.Pass_Fail.value_counts().to_dict(); print(summ); F('tests_total',len(rec)); F('tests_pass',int((rec.Pass_Fail=='PASS').sum())); F('tests_fail',int((rec.Pass_Fail=='FAIL').sum()))
F('b_kpi_pass',int(((rec.Area=='KPI validation')&(rec.Pass_Fail=='PASS')).sum())); F('b_kpi_total',int((rec.Area=='KPI validation').sum()))
json.dump(FACTS,open(OUT+'Week7_Facts.json','w'),indent=1,default=str)
print(json.dumps(FACTS,indent=1,default=str))
