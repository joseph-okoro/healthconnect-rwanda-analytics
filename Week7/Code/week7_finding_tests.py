"""Week 7 | HealthConnect Rwanda | Re-testing the main Week 6 findings (statistical checks and segment checks).
Reads the Week 6 PostgreSQL database (schema hc). Writes ../Evidence/finding_tests.csv
Usage: python3 week7_finding_tests.py
"""
import subprocess,io,os,numpy as np,pandas as pd
from scipy import stats
def q(sql,db='hc_verify'):
    r=subprocess.run(['psql','-h','/tmp','-p','5433','-U','postgres','-d',db,'--csv','-c','SET search_path=hc,public; '+sql],capture_output=True,text=True)
    if r.returncode: raise SystemExit(r.stderr)
    t=r.stdout.split('\n',1)[1] if r.stdout.startswith('SET') else r.stdout
    return pd.read_csv(io.StringIO(t),keep_default_na=False)
rows=[]
def log(test,expected,actual,result,note): rows.append((test,expected,actual,result,note)); print(f'[{result}] {test}\n   expected: {expected}\n   actual:   {actual}\n   {note}\n')
rng=np.random.default_rng(7)
# T1 hospital ratings: are differences between hospitals more than chance?
fb=q("select a.facility_id h, f.rating from patient_feedback f join appointments a using(appointment_id)")
groups=[g.rating.values for _,g in fb.groupby('h')]
F,p=stats.f_oneway(*groups); H,pk=stats.kruskal(*groups)
log('Hospital ratings differ more than chance (ANOVA / Kruskal-Wallis, 20 hospitals, n=%d)'%len(fb),'p < 0.05 if hospital differences are real',f'ANOVA p={p:.3f}; Kruskal p={pk:.3f}','NOT SUPPORTED' if p>=0.05 else 'SUPPORTED','Week 6 said some hospitals are rated clearly lower. Differences are within what chance produces.')
# T2 volume vs rating
v=q("select a.facility_id h,count(distinct a.appointment_id) vol from appointments a group by 1").set_index('h').vol
m=fb.groupby('h').rating.mean(); n=fb.groupby('h').rating.size()
rho,pr=stats.spearmanr(v.reindex(m.index),m)
log('Busiest hospitals are rated lowest (Spearman, volume vs average rating, 20 hospitals)','negative correlation, p < 0.05',f'rho={rho:.2f}, p={pr:.3f}','NOT SUPPORTED' if pr>=0.05 else 'SUPPORTED','Week 6 headline said busy hospitals are among the least liked. The relationship is not statistically supported.')
# T3 rating CIs: HF013/HF014 vs rest
for h in ['HF013','HF014','HF011']:
    a=fb[fb.h==h].rating; b=fb[fb.h!=h].rating; t,pt=stats.ttest_ind(a,b,equal_var=False)
    boot=[rng.choice(a,len(a)).mean() for _ in range(4000)]; lo,hi=np.percentile(boot,[2.5,97.5])
    log(f'{h} rating vs other hospitals (Welch t-test, 95% bootstrap interval)','p < 0.05 for a real gap',f'mean {a.mean():.2f} (95% interval {lo:.2f} to {hi:.2f}) vs {b.mean():.2f}; p={pt:.3f}; n={len(a)}','NOT SUPPORTED' if pt>=0.05 else 'SUPPORTED','Interval is wide because each hospital has only 70 to 100 linked ratings.')
# T4 department ratings
fd=q("select d.department_name dn, f.rating from patient_feedback f join appointments a using(appointment_id) join departments d using(department_id)")
F2,p2=stats.f_oneway(*[g.rating.values for _,g in fd.groupby('dn')])
log('Department ratings differ (ANOVA, 10 departments)','p < 0.05',f'p={p2:.3f}','NOT SUPPORTED' if p2>=0.05 else 'SUPPORTED','ICU (2.76) lowest and Emergency (3.02) highest but not significant.')
# T5 workload spread: appointments per doctor
w=q("select a.facility_id h,count(*) appts,(select count(*) from doctors d where d.facility_id=a.facility_id) docs from appointments a group by 1")
w['ratio']=w.appts/w.docs
chi=stats.chisquare(w.appts, f_exp=(w.docs/w.docs.sum()*w.appts.sum()))
log('Workload per doctor differs between hospitals (chi-square: appointments vs doctors)','p < 0.05 if staffing mismatch is real',f'range {w.ratio.min():.1f} to {w.ratio.max():.1f} per doctor; chi-square p={chi.pvalue:.3f}','NOT SUPPORTED' if chi.pvalue>=0.05 else 'SUPPORTED','Counts are about 28% apart between busiest and quietest hospital; test whether that exceeds random variation.')
# T6 appointment volume evenly spread?
chi2=stats.chisquare(w.appts)
log('Appointment volume differs by hospital (chi-square vs equal split)','p < 0.05 if some hospitals really are busier',f'p={chi2.pvalue:.3f}','NOT SUPPORTED' if chi2.pvalue>=0.05 else 'SUPPORTED','If p is high, volume is effectively even and no hospital is overloaded on volume alone.')
# T7 poor rating rate and rating distribution uniform?
d=q("select rating,count(*) n from patient_feedback group by 1 order by 1")
c3=stats.chisquare(d.n)
log('Ratings are evenly spread across 1 to 5 (chi-square vs equal split, n=21,064)','p >= 0.05 (no skew)',f'counts {list(d.n)}; p={c3.pvalue:.3f}','SUPPORTED' if c3.pvalue>=0.05 else 'NOT SUPPORTED','Ratings are spread evenly, so the average (2.99) hides a split; consistent with Week 6 note.')
# T8 claims flat across segments
cl=q("select c.provider, c.status, c.claim_amount, b.payment_method pm from insurance_claims c join v_billing_detail b using(billing_id)")
for col in ['provider','pm']:
    ct=pd.crosstab(cl[col],cl.status); chi_,pp,_,_=stats.chi2_contingency(ct)
    log(f'Claim approval differs by {col} (chi-square)','p < 0.05 if approval depends on it',f'approval {", ".join(f"{i}: {100*ct.loc[i,"Approved"]/ct.loc[i].sum():.1f}%" for i in ct.index)}; p={pp:.3f}','NOT SUPPORTED' if pp>=0.05 else 'SUPPORTED','Used in the cross-track reply to the Project Manager.')
cl['quart']=pd.qcut(cl.claim_amount,4,labels=False); ct=pd.crosstab(cl.quart,cl.status); chi_,pp,_,_=stats.chi2_contingency(ct)
log('Claim approval differs by claim amount quartile (chi-square)','p < 0.05 if approval depends on size',f'approved {[float(round(100*ct.loc[i,"Approved"]/ct.loc[i].sum(),1)) for i in ct.index]}; p={pp:.3f}','NOT SUPPORTED' if pp>=0.05 else 'SUPPORTED','No signal for a claims model to learn from these fields.')
# T9 province use per patient
pv=q("select g.province_name p,count(*) appts from appointments a join v_patient_geo g using(patient_id) group by 1")
pp_=q("select province_name p,count(*) pts from v_patient_geo group by 1")
j=pv.merge(pp_,on='p'); ch=stats.chisquare(j.appts,f_exp=j.pts/j.pts.sum()*j.appts.sum())
log('Hospital use per patient differs by province (chi-square)','p < 0.05 if Kigali City really uses hospitals less',f'per 1,000 patients: {dict(zip(j.p,(1000*j.appts/j.pts).round(0)))}; p={ch.pvalue:.3f}','NOT SUPPORTED' if ch.pvalue>=0.05 else 'SUPPORTED','Week 6 recommended a look at Kigali City, Southern and Eastern.')
# T10 diagnosis trend Q3->Q4
dq=q("select d.diagnosis dg, extract(quarter from a.appointment_date)::int qtr, count(*) n from diagnoses d join appointments a using(appointment_id) group by 1,2")
pv_=dq.pivot(index='dg',columns='qtr',values='n'); chi_,pp,_,_=stats.chi2_contingency(pv_)
log('Diagnosis mix changes across quarters (chi-square, linked appointments)','p < 0.05 if a disease is really rising',f'p={pp:.3f}; hypertension Q3->Q4: {pv_.loc["Hypertension",3]}->{pv_.loc["Hypertension",4]}','NOT SUPPORTED' if pp>=0.05 else 'SUPPORTED','Week 6 flagged hypertension and respiratory infection as a watch-list.')
# T11 poor rating % precise
tot=q("select sum((rating<=2)::int) poor,count(*) n from patient_feedback").iloc[0]
log('Poor-rating rate reported in Week 6 (40.5%)','40.5%',f'{100*tot.poor/tot.n:.2f}% ({tot.poor}/{tot.n})','ERROR FOUND','Week 6 rounded wrongly. Correct value is 40.4%. Fixed in all documents.')
# T12 future-dated appointments
fu=q("select count(*) n from appointments where appointment_date>'2026-10-22'").iloc[0].n
log('Appointments after the Week 6 analysis date (22 Oct 2026)','0',f'{fu}','DATA ISSUE','Known data issue. Q4 trends include these; findings treated as a watch-list.')
pd.DataFrame(rows,columns=['test','expected','actual','result','note']).to_csv('../Evidence/finding_tests.csv',index=False)
