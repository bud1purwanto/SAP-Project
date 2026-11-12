# Excel analisa alias PRD 1 tahun terakhir: konversi alias -> material + simulasi tracing MIC
import json
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter
from openpyxl.worksheet.datavalidation import DataValidation
D='outputs/alias_recent_20261112/'
r1=json.load(open(D+'recent_alias_conversion.json')); r2=json.load(open(D+'recent_mic_tracing.json'))
r3=json.load(open(D+'recent_limit_compare.json')); src=json.load(open(D+'recent_alias_material_sample.json'))
cnt=dict(json.load(open(D+'recent_alias_counts.json')))
F='Arial'; HF=PatternFill('solid',fgColor='0B4F5C'); YEL=PatternFill('solid',fgColor='FFF2CC')
GRN=PatternFill('solid',fgColor='E6F3EC'); RED=PatternFill('solid',fgColor='FCEEE5')
th=Side(style='thin',color='C9D6DA'); B=Border(left=th,right=th,top=th,bottom=th)
ST={'NOCONV':'Tidak bisa dikonversi','DIFF':'Dikonversi ke material lain','MIXED':'Dikonversi (sebagian material sama)','SAME':'Material alias = material batch'}
wb=Workbook()
def head(ws,row,cols,widths):
    for i,(c,w) in enumerate(zip(cols,widths),1):
        x=ws.cell(row,i,c); x.font=Font(name=F,bold=True,color='FFFFFF'); x.fill=HF; x.border=B
        x.alignment=Alignment(wrap_text=True,vertical='center'); ws.column_dimensions[get_column_letter(i)].width=w
    ws.freeze_panes=ws.cell(row+1,1); 
def put(ws,r,vals,fill=None,fmt=None):
    for i,v in enumerate(vals,1):
        x=ws.cell(r,i,v); x.font=Font(name=F,size=10); x.border=B; x.alignment=Alignment(wrap_text=True,vertical='top')
        if fill: x.fill=fill
    if fmt:
        for col,f in fmt.items(): ws.cell(r,col).number_format=f
order=sorted(r1,key=lambda a:-cnt[a])
def matstr(a,o):
    ns=sum(len(b) for b in src[a].values())
    return ', '.join(f"{m} ({len(b)}/{ns})" for m,b in src[a].items()), ', '.join(o['batch_makt'][m] for m in src[a])
# --- sheet Konversi
w1=wb.active; w1.title='Konversi Alias'
head(w1,1,['Alias (ZZALIAS)','Jumlah batch (sampel 20%)','Status','Dikonversi lewat','Material alias','Deskripsi material alias','Material batch (contoh/8)','Deskripsi material batch'],[16,13,30,12,12,24,30,40])
r=2
for a in order:
    o=r1[a]; ms,mk=matstr(a,o)
    put(w1,r,[a,cnt[a],ST[o['status']],o.get('via',''),o.get('amat',''),o.get('amat_makt',''),ms,mk],fmt={2:'#,##0'}); r+=1
L1=r-1; w1.auto_filter.ref=f'A1:H{L1}'
# --- sheet Tracing MIC
def cat(a,v,lim):
    rows=v['rows']; n=len(rows); ok=sum(1 for x in rows if x[1]); bad=[x[0] for x in rows if not x[1]]
    notin=[x for x in rows if x[1] and x[3] is False]
    if n==0: return 'Mapping alias tidak bisa disimulasikan (material alias tanpa lot/plan)'
    if ok==0: return 'Material batch tanpa inspection plan'
    if bad and set(bad)<= {'SRFCUNTR'}: return 'MIC umum SRFCUNTR tidak ada di plan batch (perlu cocok deskripsi per level)'
    if bad and set(bad)<= {'SRFCUNTR','SLTR125','SLNT125'}: return 'MIC umum (SRFCUNTR/SLTR125/SLNT125) tidak ada di plan batch'
    if bad: return 'Penamaan properti beda (sisi/kode lain), perlu padanan dari QA'
    if lim: return 'MIC lengkap, tapi limit spec beda'
    if notin: return 'MIC ada di plan tapi tidak ada di lot batch'
    return 'Aman'
w2=wb.create_sheet('Tracing MIC')
head(w2,1,['Alias','Material alias','Material batch','Deskripsi material batch','MIC di mapping alias (simulasi)','MIC berhasil diterjemahkan','MIC gagal','Daftar MIC gagal','Lot Z04 batch ditemukan?','MIC hasil terjemah ada di lot','MIC tidak ada di lot','Jumlah limit beda','Kategori','Catatan functional/QA'],[12,11,11,28,12,12,9,34,11,11,26,10,40,30])
r=2
for k in sorted(r2,key=lambda k:-cnt[k.split('|')[0]]):
    v=r2[k]; a=k.split('|')[0]; am,bm=k.split('|')[1].split('->'); rows=v['rows']
    ok=sum(1 for x in rows if x[1]); bad=[x[0] for x in rows if not x[1]]
    notin=[f"{x[0]}→{x[1]}" for x in rows if x[1] and x[3] is False]
    lim=r3.get(k,[]); c=cat(a,v,lim)
    fill=GRN if c=='Aman' else (RED if ('beda' in c or 'tanpa' in c) else None)
    put(w2,r,[a,am,bm,r1[a]['batch_makt'].get(bm,''),len(rows),ok,f'=E{r}-F{r}',', '.join(bad),'Ya' if v['batch_lot'] else 'Tidak (contoh batch belum/tanpa lot)',
              sum(1 for x in rows if x[3]) if v['batch_lot'] else '-',', '.join(notin),len(lim),c,None])
    if fill: w2.cell(r,13).fill=fill
    w2.cell(r,14).fill=YEL; r+=1
L2=r-1; w2.auto_filter.ref=f'A1:N{L2}'
# --- Detail MIC
w3=wb.create_sheet('Detail MIC')
head(w3,1,['Alias','Material alias','Material batch','MIC mapping alias','Deskripsi','MIC material batch','Cara cocok','Ada di lot batch?'],[12,11,11,12,36,14,10,12])
r=2
for k,v in r2.items():
    a=k.split('|')[0]; am,bm=k.split('|')[1].split('->')
    for m,n,how,inl,hv in v['rows']:
        put(w3,r,[a,am,bm,m,v['desc'].get(m,''),n or '',how,'-' if inl is None else ('Ya' if inl else 'Tidak')],fill=RED if not n else None); r+=1
w3.auto_filter.ref=f'A1:H{r-1}'
# --- Limit beda
w4=wb.create_sheet('Limit Beda')
head(w4,1,['Alias','Material alias → batch','MIC alias','MIC batch','Properti','Lower alias','Upper alias','Lower batch','Upper batch'],[12,22,12,12,30,11,11,11,11])
r=2
for k,v in r3.items():
    for ma,mb,d,la,lb in v: put(w4,r,[k.split('|')[0],k.split('|')[1],ma,mb,d,la[0],la[1],lb[0],lb[1]]); r+=1
# --- Tidak terkonversi
w5=wb.create_sheet('Alias Tidak Terkonversi')
head(w5,1,['Alias','Jumlah batch (sampel 20%)','Material batch (contoh/8)','Deskripsi material batch','MAKT yang dicari','Alias ini apa? (nama dagang / customer / FTYPE / lainnya)','Material acuan yang benar (kalau ada)','Catatan functional'],[14,13,30,40,32,26,18,30])
r=2
for a in order:
    o=r1[a]
    if o['status']!='NOCONV': continue
    ms,mk=matstr(a,o); m0=o['batch_makt'][list(src[a])[0]]; pre=m0.rsplit(' ',1)[0]+' ' if ' ' in m0 else ''
    put(w5,r,[a,cnt[a],ms,mk,f'"{(pre+a).upper()}" tidak ditemukan',None,None,None],fmt={2:'#,##0'})
    for c in (6,7,8): w5.cell(r,c).fill=YEL
    r+=1
L5=r-1
dv=DataValidation(type='list',formula1='"Nama dagang,Nama customer,FTYPE,Salah input,Lainnya"',allow_blank=True); w5.add_data_validation(dv); dv.add(f'F2:F{L5}')
# --- Ringkasan
w0=wb.create_sheet('Ringkasan',0)
w0.column_dimensions['A'].width=58; w0.column_dimensions['B'].width=16; w0.column_dimensions['C'].width=16; w0.column_dimensions['D'].width=12
w0['A1']='Analisa alias PRD — batch dibuat 11 Nov 2025 s/d 12 Nov 2026'; w0['A1'].font=Font(name=F,bold=True,size=13)
w0['A2']='Read-only dari Production AIX, 12 Nov 2026. Tidak ada program dijalankan di PRD.'; w0['A2'].font=Font(name=F,italic=True,size=9)
head(w0,4,['A. Konversi alias → material','Jumlah alias','Jumlah batch (sampel)','Porsi'],[58,16,16,12])
w0.freeze_panes=None
stats=[ST['DIFF'],ST['MIXED'],ST['NOCONV'],ST['SAME']]
for i,s in enumerate(stats):
    rr=5+i
    put(w0,rr,[s,f"=COUNTIF('Konversi Alias'!C2:C{L1},A{rr})",f"=SUMIFS('Konversi Alias'!B2:B{L1},'Konversi Alias'!C2:C{L1},A{rr})",f"=IF($C$9=0,0,C{rr}/$C$9)"],fmt={3:'#,##0',4:'0.0%'})
put(w0,9,['Total (54 alias = 95% batch beralias di sampel)','=SUM(B5:B8)','=SUM(C5:C8)','=SUM(D5:D8)'],fmt={3:'#,##0',4:'0.0%'})
head(w0,11,['B. Simulasi tracing MIC (alias material → material batch)','Nilai','',''],[58,16,16,12])
kp=[('Pasangan alias material → material batch',f"=COUNTA('Tracing MIC'!A2:A{L2})"),
    ('Pasangan dengan semua MIC berhasil diterjemahkan',f"=COUNTIFS('Tracing MIC'!G2:G{L2},0,'Tracing MIC'!E2:E{L2},\">0\")"),
    ('Total MIC di mapping alias (simulasi)',f"=SUM('Tracing MIC'!E2:E{L2})"),
    ('MIC berhasil diterjemahkan',f"=SUM('Tracing MIC'!F2:F{L2})"),
    ('% MIC berhasil diterjemahkan','=IF(B14=0,0,B15/B14)'),
    ('Pasangan yang lot Z04 batch-nya ditemukan',f"=COUNTIF('Tracing MIC'!I2:I{L2},\"Ya\")"),
    ('MIC hasil terjemah yang ada di lot batch',f"=SUM('Tracing MIC'!J2:J{L2})"),
    ('Pasangan dengan limit spec beda',f"=COUNTIF('Tracing MIC'!L2:L{L2},\">0\")"),
    ('Pasangan kategori "Aman"',f"=COUNTIF('Tracing MIC'!M2:M{L2},\"Aman\")")]
for i,(t,f) in enumerate(kp):
    put(w0,12+i,[t,f,None,None]); 
w0['B16'].number_format='0.0%'
notes=['Metode:',
'1. Batas waktu: CUOBJ batch ≥ 000000000051282577 (batch dibuat 11 Nov 2025). Sampel sistematis 20% (1 dari tiap 5 jendela 20.000 CUOBJ) → 317.061 nilai ZZALIAS, 221 alias unik.',
'2. 54 alias teratas (95% batch) diambil 8 contoh batch per alias, tersebar merata, untuk tahu material batch-nya.',
'3. Konversi: ZZCODE (CAWNT-ATWTB = alias → kode → SR+kode+I), lalu MAKT "SLITT ROLL "+alias.',
'4. Tracing: mapping alias disimulasikan dari MIC lot Z04 terakhir material alias (PRD belum punya ZMAP_COA untuk material alias). MIC diterjemahkan ke material batch lewat inspection plan (EXACT → RULE → SUFFIX → DESC), lalu dicek ada di lot Z04 contoh batch.',
'Batasan: lot Z04 contoh batch tidak selalu ditemukan (batch baru/belum inspeksi atau lot di batch change-grade). Nilai JR tidak diuji (mengikuti trace program).',
'Kolom kuning = diisi functional/QA.']
for i,t in enumerate(notes):
    x=w0.cell(23+i,1,t); x.font=Font(name=F,size=10,bold=(i==0)); x.alignment=Alignment(wrap_text=True); w0.merge_cells(start_row=23+i,start_column=1,end_row=23+i,end_column=4); w0.row_dimensions[23+i].height=30 if i else 15
out='docs/Analisa_Alias_PRD_1Tahun.xlsx'; wb.save(out); print(out)
