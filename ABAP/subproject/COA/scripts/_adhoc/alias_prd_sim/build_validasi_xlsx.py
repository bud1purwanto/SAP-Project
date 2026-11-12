# Excel validasi functional: alias PRD yang tidak bisa dikonversi ke material
import json
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter
from openpyxl.worksheet.datavalidation import DataValidation
d=json.load(open('outputs/alias_live_20261112/prd_sim_alias_conversion.json'))
src=json.load(open('outputs/alias_mapping_20261111/prd_alias_to_material_sample.json'))
cnt=dict(json.load(open('outputs/alias_mapping_20261111/prd_alias_counts_sample50k.json')))
F='Arial'; hdr=PatternFill('solid',fgColor='0B4F5C'); inp=PatternFill('solid',fgColor='FFF2CC')
thin=Side(style='thin',color='C9D6DA'); B=Border(left=thin,right=thin,top=thin,bottom=thin)
st={'NOCONV':'Tidak bisa dikonversi','DIFF':'Dikonversi ke material lain','SAME':'Material alias = material batch'}
wb=Workbook()
def head(ws,row,cols,widths):
    for i,(c,w) in enumerate(zip(cols,widths),1):
        x=ws.cell(row,i,c); x.font=Font(name=F,bold=True,color='FFFFFF'); x.fill=hdr
        x.alignment=Alignment(wrap_text=True,vertical='center'); x.border=B
        ws.column_dimensions[get_column_letter(i)].width=w
def cell(ws,r,i,v,fill=None):
    x=ws.cell(r,i,v); x.font=Font(name=F,size=10); x.border=B; x.alignment=Alignment(wrap_text=True,vertical='top')
    if fill: x.fill=fill
    return x
order=sorted(d.items(),key=lambda kv:-cnt.get(kv[0],0))
# Ringkasan
w3=wb.active; w3.title='Ringkasan'
# Detail NOCONV
ws=wb.create_sheet('Alias Tidak Terkonversi')
ws['A1']='Alias PRD yang tidak bisa dikonversi ke material (untuk validasi functional)'; ws['A1'].font=Font(name=F,bold=True,size=13)
ws['A2']='Sumber: Production AIX, read-only, 12 Nov 2026. Sampel 50.000 nilai ZZALIAS (AUSP ATINN 0000000844); 45 alias teratas dianalisis, 8 contoh batch per alias. Kolom kuning (J–L) diisi functional.'
ws['A2'].font=Font(name=F,italic=True,size=9); ws.merge_cells('A2:L2')
head(ws,4,['No','Alias (ZZALIAS)','Jumlah batch di sampel 50k','Material batch','Deskripsi material (MAKT)','Contoh batch','Cek 1: ZZCODE (CAWNT-ATWTB = alias)','Cek 2: MAKT yang dicari','Hasil',
  'Alias ini apa? (nama dagang / customer / FTYPE / lainnya)','Material acuan yang benar (kalau ada)','Catatan functional'],[5,18,12,12,26,30,20,32,16,26,18,30])
r=5;n=0
for a,o in order:
    if o['status']!='NOCONV': continue
    mats=list(src[a]); m0=o['batch_makt'][mats[0]]; pre=m0.rsplit(' ',1)[0]+' ' if ' ' in m0 else ''; n+=1
    vals=[n,a,cnt.get(a,0),', '.join(mats),', '.join(o['batch_makt'][m] for m in mats),', '.join(src[a][mats[0]][:3]),
          'Tidak ditemukan',f'"{(pre+a).upper()}" tidak ditemukan','Tidak terkonversi']
    for i,v in enumerate(vals,1): cell(ws,r,i,v)
    for i in (10,11,12): cell(ws,r,i,None,inp)
    ws.cell(r,3).number_format='#,##0'; r+=1
last=r-1
ws.cell(r,2,'Total').font=Font(name=F,bold=True)
x=ws.cell(r,3,f'=SUM(C5:C{last})'); x.font=Font(name=F,bold=True); x.number_format='#,##0'
dv=DataValidation(type='list',formula1='"Nama dagang,Nama customer,FTYPE,Salah input,Lainnya"',allow_blank=True)
ws.add_data_validation(dv); dv.add(f'J5:J{last}')
ws.freeze_panes='C5'; ws.auto_filter.ref=f'A4:L{last}'
# Semua alias
w2=wb.create_sheet('Semua Alias')
head(w2,1,['Alias','Jumlah batch di sampel 50k','Status','Dikonversi lewat','Material alias','Deskripsi material alias','Material batch','Deskripsi material batch'],[18,12,28,14,14,26,16,32])
r=2
for a,o in order:
    mats=list(src[a])
    for i,v in enumerate([a,cnt.get(a,0),st[o['status']],o.get('via',''),o.get('amat',''),o.get('amat_makt',''),', '.join(mats),', '.join(o['batch_makt'][m] for m in mats)],1): cell(w2,r,i,v)
    w2.cell(r,2).number_format='#,##0'; r+=1
l2=r-1; w2.freeze_panes='A2'; w2.auto_filter.ref=f'A1:H{l2}'
# Ringkasan isi
w3['A1']='Ringkasan konversi alias → material (PRD)'; w3['A1'].font=Font(name=F,bold=True,size=13)
head(w3,3,['Status','Jumlah alias','Jumlah batch (sampel)','Porsi batch'],[34,14,22,14])
for i,s in enumerate(st.values()):
    rr=4+i
    cell(w3,rr,1,s); cell(w3,rr,2,f"=COUNTIF('Semua Alias'!C2:C{l2},A{rr})")
    cell(w3,rr,3,f"=SUMIFS('Semua Alias'!B2:B{l2},'Semua Alias'!C2:C{l2},A{rr})")
    cell(w3,rr,4,f"=IF($C$7=0,0,C{rr}/$C$7)")
for c,v in zip('ABCD',['Total','=SUM(B4:B6)','=SUM(C4:C6)','=SUM(D4:D6)']): x=cell(w3,7,'ABCD'.index(c)+1,v); x.font=Font(name=F,size=10,bold=True)
for rr in range(4,8): w3.cell(rr,3).number_format='#,##0'; w3.cell(rr,4).number_format='0.0%'
notes=['Cara cek konversi (sama dengan logic yang diuji di DEV):',
 '1. ZZCODE: cari teks nilai ZZCODE (CAWNT-ATWTB) = alias → kode → material SR + kode + I (cek MARA).',
 '2. Kalau gagal: cari MAKT = awalan deskripsi material batch + alias, contoh "SLITT ROLL KTM-12".',
 'Batasan: hanya 45 dari 131 alias unik di sampel; 8 contoh batch per alias, jadi material lain di bawah alias yang sama bisa belum terlihat.',
 'Jumlah batch = jumlah kemunculan alias di sampel 50.000 nilai ZZALIAS, bukan total seluruh PRD.',
 'Yang perlu dikonfirmasi functional: sheet "Alias Tidak Terkonversi", kolom kuning J–L.']
for i,t in enumerate(notes): x=w3.cell(10+i,1,t); x.font=Font(name=F,size=10,bold=(i==0))
out='docs/Validasi_Alias_PRD_Tidak_Terkonversi.xlsx'; wb.save(out); print(out,n,'alias tidak terkonversi')
