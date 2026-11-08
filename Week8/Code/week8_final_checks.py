"""Week 8 | HealthConnect Rwanda | Final KPI confirmation and appointment-pattern checks.
Reads the Week 6 PostgreSQL database (schema hc). Writes ../Evidence/final_kpis.csv, appointment_patterns.csv and 3 charts.
Usage: python3 week8_final_checks.py
"""
import subprocess,io,os,pandas as pd,numpy as np
from scipy import stats
import matplotlib; matplotlib.use('Agg'); import matplotlib.pyplot as plt
OUT=os.path.join(os.path.dirname(__file__),'..','Evidence')
def q(sql,db='hc_verify'):
    r=subprocess.run(['psql','-h','/tmp','-p','5433','-U','postgres','-d',db,'--csv','-c','SET search_path=hc,public; '+sql],capture_output=True,text=True)
    if r.returncode: raise SystemExit(r.stderr)
    t=r.stdout.split('\n',1)[1] if r.stdout.startswith('SET') else r.stdout
    return pd.read_csv(io.StringIO(t),keep_default_na=False)
# ---- 1. Final KPIs: recalculate and compare with the Week 7 confirmed value
b=q("select sum(billed_amount) b, sum(paid_amount) p from v_billing_detail").iloc[0]
kp=[('Registered patients',20000,int(q("select count(*) n from patients").n[0])),
('Appointments with full details',5000,int(q("select count(*) n from appointments").n[0])),
('Patients seen',4443,int(q("select count(distinct patient_id) n from appointments").n[0])),
('Total billed (RWF)',9309401961,int(b.b)),('Collected (RWF)',8389454556,int(b.p)),('Unpaid (RWF)',919947405,int(b.b-b.p)),
('Insurance claims',42036,int(q("select count(*) n from insurance_claims").n[0])),
('Diagnoses',60000,int(q("select count(*) n from diagnoses").n[0])),
('Feedback records',21064,int(q("select count(*) n from patient_feedback").n[0]))]
k=pd.DataFrame(kp,columns=['KPI','Week7_confirmed','Week8_recalculated']); k['Match']=np.where(k.Week7_confirmed==k.Week8_recalculated,'Yes','CHECK')
pr=q("select round(100.0*sum(case when rating<=2 then 1 else 0 end)/count(*),1) v, round(avg(rating),2) a from patient_feedback").iloc[0]
k.loc[len(k)]=['Poor ratings (%)',40.4,float(pr.v),'Yes' if abs(pr.v-40.4)<0.05 else 'CHECK']
k.loc[len(k)]=['Average rating',2.99,float(pr.a),'Yes' if abs(pr.a-2.99)<0.005 else 'CHECK']
k.to_csv(f'{OUT}/final_kpis.csv',index=False); print(k.to_string())
# ---- 2. Appointment patterns (the closest thing to attendance patterns in this dataset)
a=q("select appointment_date d, visit_type v, department_name dep, extract(isodow from appointment_date) wd from v_appointment_detail")
rows=[]
for name,ser in [('Weekday',a.wd),('Visit type',a.v),('Department',a.dep)]:
    c=ser.value_counts().sort_index(); chi,p=stats.chisquare(c)
    rows.append((name,int(c.min()),int(c.max()),round(p,3),'Differences could be chance' if p>0.05 else 'Real difference'))
a['m']=pd.to_datetime(a.d).dt.to_period('M'); c=a.m.value_counts().sort_index(); chi,p=stats.chisquare(c)
rows.append(('Month',int(c.min()),int(c.max()),round(p,3),'Differences could be chance' if p>0.05 else 'Real difference'))
pt=pd.DataFrame(rows,columns=['Pattern','Smallest_group','Largest_group','p_value','Meaning']); pt.to_csv(f'{OUT}/appointment_patterns.csv',index=False); print(pt.to_string())
# ---- 3. Charts
T='#0F6E6E'; N='#12263F'; G='#BFC8D0'
def style(ax): 
    for s in ['top','right']: ax.spines[s].set_visible(False)
wd=a.wd.value_counts().sort_index(); fig,ax=plt.subplots(figsize=(6,3.2)); ax.bar(['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],wd.values,color=T); style(ax)
for i,v in enumerate(wd.values): ax.text(i,v+8,str(v),ha='center',fontsize=9)
ax.set_title('Appointments by day of week: no busy day',fontsize=11,color=N,loc='left'); ax.set_ylim(0,850); plt.tight_layout(); plt.savefig(f'{OUT}/chart_weekday.png',dpi=200); plt.close()
mo=a.m.value_counts().sort_index(); fig,ax=plt.subplots(figsize=(6,3.2)); ax.bar([str(x)[-2:] for x in mo.index],mo.values,color=T); style(ax)
ax.set_title('Appointments by month (2026): flat all year',fontsize=11,color=N,loc='left'); ax.set_xlabel('Month'); ax.set_ylim(0,520); plt.tight_layout(); plt.savefig(f'{OUT}/chart_month.png',dpi=200); plt.close()
fig,ax=plt.subplots(figsize=(6,3.2)); lab=['Collected','Unpaid']; val=[b.p/1e9,(b.b-b.p)/1e9]; ax.barh(lab[::-1],val[::-1],color=['#C62828',T]); style(ax)
for i,v in enumerate(val[::-1]): ax.text(v+0.1,i,f'RWF {v:.2f} B',va='center',fontsize=10)
ax.set_xlim(0,10.5); ax.set_title('Of RWF 9.31 B billed, RWF 0.92 B is unpaid (9.9%)',fontsize=11,color=N,loc='left'); plt.tight_layout(); plt.savefig(f'{OUT}/chart_unpaid.png',dpi=200); plt.close()
