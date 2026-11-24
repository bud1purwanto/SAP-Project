"""Bangun Excel impact analysis Expired Date (fokus: Expired Date yang tampil di SAP).
Jalankan: <venv>/bin/python build_excel.py
"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from openpyxl import Workbook
from openpyxl.drawing.image import Image as XLImage
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHOT = os.path.join(BASE, 'outputs', 'screenshots_20261124')
OUT = os.path.join(BASE, 'outputs', 'Impact_Expired_Date_ABAP_20261124.xlsx')

F = 'Arial'
NAVY = '1F3864'
fill_head = PatternFill('solid', fgColor=NAVY)
fill_sub = PatternFill('solid', fgColor='D9E2F3')
fill_note = PatternFill('solid', fgColor='FFF2CC')
fill_ok = PatternFill('solid', fgColor='E2EFDA')
thin = Side(style='thin', color='A6A6A6')
box = Border(left=thin, right=thin, top=thin, bottom=thin)
wrap = Alignment(wrap_text=True, vertical='top')


def title(ws, text, sub=None):
    ws['A1'] = text
    ws['A1'].font = Font(name=F, size=14, bold=True, color=NAVY)
    if sub:
        ws['A2'] = sub
        ws['A2'].font = Font(name=F, size=10, italic=True, color='595959')


def table(ws, row, headers, rows, widths=None):
    for c, h in enumerate(headers, 1):
        cell = ws.cell(row=row, column=c, value=h)
        cell.font = Font(name=F, bold=True, color='FFFFFF')
        cell.fill = fill_head
        cell.alignment = Alignment(wrap_text=True, vertical='center')
        cell.border = box
    for r, vals in enumerate(rows, row + 1):
        for c, v in enumerate(vals, 1):
            cell = ws.cell(row=r, column=c, value=v)
            cell.font = Font(name=F, size=10)
            cell.alignment = wrap
            cell.border = box
    if widths:
        for i, w in enumerate(widths, 1):
            ws.column_dimensions[get_column_letter(i)].width = w
    ws.freeze_panes = ws.cell(row=row + 1, column=1)
    return row + len(rows) + 1


def text(ws, cell, value, bold=False, size=10, fill=None, color='000000'):
    ws[cell] = value
    ws[cell].font = Font(name=F, bold=bold, size=size, color=color)
    ws[cell].alignment = Alignment(wrap_text=(size < 12), vertical='top')
    if fill:
        ws[cell].fill = fill


wb = Workbook()

# ---------------------------------------------------------------- Ringkasan
import datetime as _dt
import json
import math
from scan_class import GROUPS, GNAME, GSTAT, aggregate, classify

center = Alignment(wrap_text=True, vertical='center')
fill_lbl = PatternFill('solid', fgColor='F2F2F2')
WC = 66  # lebar kolom C (karakter), dipakai untuk taksir tinggi baris

ws = wb.active
ws.title = 'Ringkasan'
title(ws, 'Impact Analysis ABAP - Perubahan Perhitungan Expired Date Roll')
ws.merge_cells('A1:C1')
ws.row_dimensions[1].height = 24
for col, w in (('A', 40), ('B', 26), ('C', WC)):
    ws.column_dimensions[col].width = w


def section(r, label):
    ws[f'A{r}'] = label
    ws[f'A{r}'].font = Font(name=F, size=12, bold=True, color=NAVY)
    for col in 'ABC':
        ws[f'{col}{r}'].border = Border(bottom=Side(style='medium', color=NAVY))
    ws.row_dimensions[r].height = 22
    return r + 1


def cell(ref, value, bold=False, fill=None, color='000000', fmt=None, align=center):
    ws[ref] = value
    ws[ref].font = Font(name=F, size=10, bold=bold, color=color)
    ws[ref].alignment = align
    ws[ref].border = box
    if fill:
        ws[ref].fill = fill
    if fmt:
        ws[ref].number_format = fmt


def height(r, txt, width):
    lines = sum(max(1, math.ceil(len(p) / (width * 1.05))) for p in str(txt).split('\n'))
    ws.row_dimensions[r].height = max(18, 14 * lines + 4)


def kv(r, k, v, merge=True):
    """Baris label (A) + isi (B:C) dengan border dan rata tengah vertikal."""
    cell(f'A{r}', k, bold=True, fill=fill_lbl)
    cell(f'B{r}', v)
    if merge:
        ws[f'C{r}'].border = box
        ws.merge_cells(f'B{r}:C{r}')
    height(r, v, 18 + WC if merge else 18)
    return r + 1


def header(r, cols):
    for col, h in zip('ABC', cols):
        cell(f'{col}{r}', h, bold=True, fill=fill_head, color='FFFFFF')
    ws.row_dimensions[r].height = 20
    return r + 1


r = section(3, '1. Rumus Expired Date di SAP saat ini')
cell(f'A{r}', 'Expired Date = Production Date + ZZEXPIREDLIVE (hari)', bold=True, fill=fill_note)
ws.merge_cells(f'A{r}:C{r}')
ws.row_dimensions[r].height = 22
r += 1
for k, v in [
    ('Production Date', 'Tanggal GR 101 hasil produksi (yang tidak di-reverse). Kalau tidak ada GR, pakai tanggal batch dibuat. Diambil lewat FM Z_GET_PRODUCTION_DATE.'),
    ('Umur simpan', 'Karakteristik batch "Expired Life" (ZZEXPIREDLIVE), dalam hari. Umumnya 180 (Trias) atau 365 (TTA/TTE).'),
    ('Disimpan di SAP?', 'Tidak. Setiap report/label menghitung ulang sendiri dengan rumus di atas.'),
    ('Format tampil', 'Label: bulan-tahun (YYYY.MM). Report: tanggal penuh (DD.MM.YYYY).'),
]:
    r = kv(r, k, v)

r = section(r + 1, '2. Contoh nyata di SAP (DO 0085006287, plant 2000)')
r = header(r, ['Item', 'Nilai', 'Keterangan'])
ex = r
rows = [
    ('HU / Batch', '6000036531 / 0000407486', 'Material SRAANI, customer UPM Raflatac', None),
    ('Production Date (GR 101)', _dt.date(2026, 11, 23), 'Data DEV', 'DD.MM.YYYY'),
    ('Umur simpan (hari)', 180, 'Data DEV', '0'),
    ('Expired Date sekarang', f'=B{ex+1}+B{ex+2}', 'Production Date + umur simpan. Sama di ZBMBC, ZBMBC2, ZSD012N, ZSD024, ZQM001P (lihat sheet SS-...).', 'DD.MM.YYYY'),
    ('Bulan dasar usulan', f'=IF(DAY(B{ex+1})>=15,DATE(YEAR(B{ex+1}),MONTH(B{ex+1})+1,1),DATE(YEAR(B{ex+1}),MONTH(B{ex+1}),1))', 'Usulan: produksi tanggal >= 15 pakai bulan berikutnya', 'MMM YYYY'),
    ('Best used usulan (+6 bulan)', f'=DATE(YEAR(B{ex+4}),MONTH(B{ex+4})+6,1)', 'Usulan Pak Roby: bulan dasar + 6 bulan', 'MMM YYYY'),
]
for k, v, note, fmt in rows:
    is_input = not (isinstance(v, str) and v.startswith('='))
    key = k.startswith('Expired') or k.startswith('Best')
    cell(f'A{r}', k, bold=True, fill=fill_lbl)
    cell(f'B{r}', v, bold=key, fill=fill_note if key else None, color='0000FF' if is_input else '000000', fmt=fmt,
         align=Alignment(horizontal='center', vertical='center'))
    cell(f'C{r}', note)
    height(r, note, WC)
    r += 1
# --- 3. Cakupan scan (alur saring: dari semua source sampai program terdampak)
r = section(r + 1, '3. Cakupan scan: dari semua source sampai program terdampak')
r = header(r, ['Langkah', 'Jumlah', 'Keterangan'])
HS = "'Daftar Program'"
s0 = r
steps = [
    ('1. Source dibaca', '=4725+770', '4.725 source Z/Y (report, include, function group, class, user exit, dll.) + 770 include Smart Form. Semua dibaca isinya, bukan hanya where-used.', False),
    ('2. Program yang menyebut kata kunci', f"=COUNTA({HS}!C5:C300)", 'Kata kunci: ZZEXPIREDLIVE, Z_GET_PRODUCTION_DATE, EXPIR, BEST USE/USED BEFORE, VFDAT/HSDAT. Dihitung per program (include digabung ke programnya). Rincian per kelompok di bagian 4.', False),
    ('3. Program terdampak', f'=COUNTIFS({HS}!B5:B300,"A*")+COUNTIFS({HS}!B5:B300,"B*")+COUNTIFS({HS}!B5:B300,"C*")', 'Program aktif yang menghitung dan menampilkan Expired Date: report (A), label roll (B), label HU/pallet (C).', True),
    ('    a. ketemu juga lewat where-used FM', f'=B{s0+2}-B{s0+4}', 'Memanggil FM Z_GET_PRODUCTION_DATE, jadi muncul juga di where-used list.', False),
    ('    b. hanya ketemu lewat scan full-text', f'=COUNTIFS({HS}!B5:B300,"A*",{HS}!J5:J300,"Tidak")+COUNTIFS({HS}!B5:B300,"B*",{HS}!J5:J300,"Tidak")+COUNTIFS({HS}!B5:B300,"C*",{HS}!J5:J300,"Tidak")', 'Tidak memanggil FM, menghitung tanggal produksi sendiri: ZQM001P, ZEQM001P, ZBMBC2, ZHU021, ZHU023, ZHU025, barrier TTE, ZMMR_LABELHU_KTNG, ZLABEL_A211.', False),
]
for k, v, note, key in steps:
    sub = k.startswith('    ')
    cell(f'A{r}', k, bold=not sub, fill=fill_lbl)
    cell(f'B{r}', v, bold=key, fmt='#,##0', fill=fill_note if key else None,
         align=Alignment(horizontal='center', vertical='center'))
    cell(f'C{r}', note)
    height(r, note, WC)
    r += 1
ws[f'A{r}'] = 'Kesimpulan: where-used saja kurang. Langkah 3b adalah program yang terlewat kalau hanya pakai where-used.'
ws[f'A{r}'].font = Font(name=F, size=9, italic=True, color='595959')
ws.merge_cells(f'A{r}:C{r}')

# --- 4. Hasil per kelompok: 3 blok dengan subtotal, total = langkah 2
r = section(r + 2, '4. Rincian 128 program dari langkah 2')
r = header(r, ['Kelompok', 'Program', 'Keterangan'])
ctr = Alignment(horizontal='center', vertical='center')
BLOCKS = [
    ('Terdampak (= langkah 3)', 'ABC', fill_ok, 'Menampilkan Expired Date, perlu diubah'),
    ('Terkait, tidak menampilkan Expired Date', 'SD', fill_sub, 'Sumber tanggal produksi / umur simpan; jadi titik ubah kalau aturan dibuat terpusat'),
    ('Tidak dihitung', 'KEF', None, 'Perlu cek manual, salinan/uji/lama, atau kata "expir" dalam arti lain'),
]
sub_rows = []
for bname, codes, bfill, bnote in BLOCKS:
    first = r + 1
    for code in codes:
        name = GNAME[code]
        cell(f'A{r+1}', '    ' + name, fill=fill_lbl)
        cell(f'B{r+1}', f'=COUNTIFS({HS}!B5:B300,"{code}*")', align=ctr)
        cell(f'C{r+1}', '')
        r += 1
    # baris subtotal di atas anggotanya
    sr = first - 1
    cell(f'A{sr}', bname, bold=True, fill=bfill or fill_lbl)
    cell(f'B{sr}', f'=SUM(B{first}:B{r})', bold=True, fill=bfill, align=ctr)
    cell(f'C{sr}', bnote, fill=bfill)
    sub_rows.append(sr)
    r += 1
cell(f'A{r}', 'Total (= langkah 2)', bold=True, fill=fill_head, color='FFFFFF')
cell(f'B{r}', '=' + '+'.join(f'B{x}' for x in sub_rows), bold=True, fill=fill_head, color='FFFFFF', align=ctr)
cell(f'C{r}', '', fill=fill_head)
r += 1

# --- 5. Perbandingan per company
r = section(r + 1, '5. Perbandingan per company code')
r = header(r, ['Company / plant', 'Umur simpan mayoritas', 'T-code yang menampilkan Expired Date'])
for k, v, note in [
    ('9999 Trias Sentosa (1000 Waru, 2000 Krian)', '180 hari', 'Report: ZBMBC, ZBMBC2, ZSD012N, ZSD024, ZSD024A, ZQM001P, ZMM062, COA ZQM002/ZQM003. Label: ZPP001/N/L, ZPP006, ZPP018, ZPP021, ZQM016, ZLABEL, ZLABEL90/91, ZHU020-025.'),
    ('9701 TTA (TTA2)', '365 hari', 'Report: ZAMM062K + report umum (ZBMBC, ZSD012N, COA). Label: ZAPP001.'),
    ('6500 TTE (TTE)', '365 hari', 'Report: ZEQM001P, ZSD024TTE, ZEMM062, ZEQM041/ZEQM044 + report umum. Label: ZEPP001, ZEQM016.'),
    ('9800 UNS (UNS1/UNS2)', '365 hari', 'Tidak ada T-code khusus; memakai report umum.'),
    ('Toyobo (label TYB)', '-', 'ZTYB10, label ZTYB001/02, ZTYB03.'),
]:
    cell(f'A{r}', k, bold=True, fill=fill_lbl)
    cell(f'B{r}', v, align=Alignment(horizontal='center', vertical='center'))
    cell(f'C{r}', note)
    height(r, note, WC)
    r += 1
ws[f'A{r}'] = 'Rumus sama di semua company. Bedanya di nilai umur simpan dan T-code khusus TTE. Detail jumlah batch: sheet "Umur Simpan per Plant".'
ws[f'A{r}'].font = Font(name=F, size=9, italic=True, color='595959')
ws.merge_cells(f'A{r}:C{r}')

# --- 6. Ringkasan dampak
r = section(r + 2, '6. Ringkasan dampak')
for k, v in [
    ('Report / monitor', f'=COUNTIFS({HS}!B5:B300,"A*")&" program report/monitor/COA (kelompok A). 7 T-code sudah diverifikasi dengan screenshot: ZBMBC, ZBMBC2, ZSD012N, ZSD024, ZSD024TTE, ZQM001P, ZEQM001P. COA ZQM002 hanya layar awal (Batch List butuh Excel Windows)."'),
    ('Label roll & pallet', f'=(COUNTIFS({HS}!B5:B300,"B*")+COUNTIFS({HS}!B5:B300,"C*"))&" program label (kelompok B "&COUNTIFS({HS}!B5:B300,"B*")&" + C "&COUNTIFS({HS}!B5:B300,"C*")&") menghitung Expired Date sendiri-sendiri. Contoh dan preview: sheet Label & Cetak."'),
    ('Interface', 'ZSD012N dan ZSD024 mengirim Expired Date ke tabel SQL OLAP (XZSD012N, XZSD024).'),
    ('Kalau hanya label diubah', 'Label menunjukkan Juni 2027, tetapi semua report tetap 22.05.2027 (contoh DO 0085006287).'),
    ('Kalau semua diselaraskan', 'Disarankan satu FM pusat "Expired Date" lalu semua report/label memanggil FM itu, supaya hasilnya sama di semua tempat.'),
]:
    r = kv(r, k, v)

r = section(r + 1, 'Isi workbook')
for k, v in [
    ('Daftar Program', 'Semua program hasil scan: T-code, tempat Expired Date tampil, contoh hasil, link screenshot, kelompok dampak, dan apakah ketemu lewat where-used.'),
    ('SS-...', 'Satu sheet per report: layar seleksi + hasil, kolom Expired Date diberi kotak merah.'),
    ('Label & Cetak', 'Program label/COA yang menghitung Expired Date, plus contoh preview label asli SAP dengan bagian terdampak di-highlight.'),
    ('Umur Simpan per Plant', 'Sebaran nilai umur simpan per company/plant (data DEV).'),
    ('Pertanyaan Meeting', 'Hal yang perlu diputuskan bersama user.'),
]:
    r = kv(r, k, v)
merged_b = {mr.min_row for mr in ws.merged_cells.ranges if mr.min_col == 2 and mr.max_col == 3}
for row in range(4, ws.max_row + 1):
    a, b, c = (ws.cell(row=row, column=i).value for i in (1, 2, 3))
    if not (ws.cell(row=row, column=1).border.left and ws.cell(row=row, column=1).border.left.style):
        continue  # judul section / catatan
    def n(v, w):
        if v is None or not isinstance(v, str):
            return 1
        if v.startswith('='):
            v = 'x' * int(len(v) * 0.6)
        return sum(max(1, math.ceil(len(p) / (w * 1.1))) for p in v.split('\n'))
    lines = max(n(a, 40), n(b, 26 + WC) if row in merged_b else n(b, 26), n(c, WC))
    ws.row_dimensions[row].height = 15 * lines + 6
    for i in (1, 2, 3):
        al = ws.cell(row=row, column=i).alignment
        if al.horizontal != 'center':
            ws.cell(row=row, column=i).alignment = Alignment(wrap_text=True, vertical='center', indent=1)
ws.sheet_view.zoomScale = 100

# ---------------------------------------------------------------- Daftar Program (gabungan titik + hasil scan)
SHEET = 'Daftar Program'
ws = wb.create_sheet(SHEET)
title(ws, 'Daftar program: di mana Expired Date tampil di SAP (hasil scan full-text DEV)',
      'Satu baris per program. Include digabung ke program induk. Filter kolom Kelompok / Status untuk menyaring.')
LBL = 'Best used / expired di label (YYYY.MM)'
# program: (T-code tampil, nama di SAP, company/plant, tampil sebagai, contoh hasil DEV, sheet screenshot)
INFO = {
    'ZBAP_STOCK_BY_CHAR1': ('ZBMBC', 'Report Stock Overview with Characteristic', 'Semua', 'Kolom "Expired Date" (juga feed WMS)', '22.05.2027 (batch 0000407486)', 'SS-ZBMBC'),
    'ZCOPY_ZBMBC': ('ZBMBC_2', 'Salinan ZBMBC', 'Semua', 'Kolom "Expired Date"', '', ''),
    'ZTBAP_STOCK_BY_CHAR1': ('ZTBMBC', 'Salinan ZBMBC', 'Semua', 'Kolom "Expired Date"', '', ''),
    'ZRM07MLBS': ('ZBMBC2', 'Display Warehouse Stocks of Material', 'Semua', 'Kolom "Expired Date"', '22.05.2027', 'SS-ZBMBC2'),
    'ZBAP_READY_REPORT': ('ZSD012N', 'Ready Report for HU in Production and Warehouse', 'Semua', 'Kolom "Expired Date"; mode OLAP kirim ke SQL XZSD012N', '22.05.2027 (HU 6000036531)', 'SS-ZSD012N'),
    'ZHUR_ROLL_LIST_BY_DEL': ('ZSD024, ZSD024TTE', 'Delivery Order Monitor (Trias / TTE)', 'Trias 9999, TTE 6500', 'Kolom "Expired Date"; mode OLAP kirim ke SQL XZSD024', '22.05.2027 (DO 0085006287, 6 roll). TTE: lihat sheet SS-ZSD024TTE', 'SS-ZSD024'),
    'ZHUR_ROLL_LIST_BY_DEL_GG': ('ZSD024A', 'Delivery Order Monitor (varian)', 'Trias', 'Kolom expired', '', ''),
    'ZQMI_PACKING_STATUS': ('ZQM001P', 'QC Status for Packing (Daftar Pengepakan)', 'Trias', 'Kolom "Expiry Date". Tanggal dasar: GR 101/102 terakhir tanpa cek reversal', '22.05.2027 (HU 6000036531)', 'SS-ZQM001P'),
    'ZQMI_PACKING_STATUS_TTE': ('ZEQM001P', 'QC Status for Packing TTE', 'TTE', 'Kolom "Expiry Date" (sama dengan ZQM001P)', '18.11.2027 (HU 9000005321, umur 365)', 'SS-ZEQM001P'),
    'ZMMR_RETURN_PALLET': ('ZMM062, ZAMM062K, ZEMM062, ZMM062_TS, ZMM062_WKA', 'Return Pallet', 'Trias, TTA, TTE', 'Field expired date', '', ''),
    'ZMMR_RETURN_PALLET_W_CYCLE': (None, 'Return Pallet (cycle)', 'Trias', 'Field expired date', '', ''),
    'ZMM_TYBROL_TO_BATCH': ('ZTYB10', 'Toyobo Roll to Batch', 'Toyobo', 'Kolom tanggal (GR + umur simpan)', '', ''),
    'ZQMI_BARRIER_PASS_FAIL': ('ZEQM041 (dan dari ZBMBC)', 'Barrier pass/fail', 'TTE', 'Expired date', '', ''),
    'ZQMI_BARRIER_NCR_UPLOAD': ('ZEQM044', 'Barrier NCR upload', 'TTE', 'Expired date', '', ''),
    'ZQMI_COA': ('ZQM002, ZQM003', 'Print COA', 'Semua', 'Expired date per batch di lampiran Batch List COA (Excel)', 'Batch List hanya bisa dibuka di SAP GUI Windows', 'SS-ZQM002'),
    'ZHUR_LABELPACK': ('Output HU V6 Z001 / Z002', 'Label pallet / packing', 'Semua', 'Expired / used before di label pallet', '', 'Label & Cetak'),
    'ZHU_LABEL': ('ZHU023', 'Label HU', 'Semua', '"Used Before" MM/YYYY', '', 'Label & Cetak'),
    'ZHU_LABEL_GG01': ('ZHU021', 'Label HU GG', 'Semua', '"Used Before" MM/YYYY', '', 'Label & Cetak'),
    'ZHU_LABEL_KTNG': ('ZHU025', 'Label HU KT&G', 'Semua', '"Used Before" MM/YYYY', '', 'Label & Cetak'),
    'ZHU_LABEL_PMI': ('ZHU020', 'Label HU PMI', 'Semua', '"Used Before" MM/YYYY', '', 'Label & Cetak'),
    'ZLABELROL_CHANGE_90': ('ZLABEL90', 'Ganti label roll', 'Semua', LBL, '', 'Label & Cetak'),
    'ZMMR_CHANGE_LABELROL_WIN': ('ZLABEL91', 'Ganti label roll (Windows)', 'Semua', LBL, '', 'Label & Cetak'),
    'LZTRIASU01': ('-', 'FM Z_GET_PRODUCTION_DATE', 'Semua', 'Sumber Production Date untuk hampir semua program', '', ''),
}
DISP = 'Via ZMMR_LABELROL (ZPP001 dkk.*)'
HUDISP = 'Via ZMAP_LABEL-PROG_HU (label HU per label type)'
recs = aggregate(json.load(open(os.path.join(BASE, 'outputs', 'summary.json'))))
order = {g[0]: i for i, g in enumerate(GROUPS)}
rows = []
for rec in recs:
    g, note = classify(rec)
    rows.append((order[g], rec['prog'], g, rec, note))
rows.sort(key=lambda x: (x[0], x[1]))
hdr = ['No', 'Kelompok', 'Program', 'T-code', 'Nama di SAP', 'Company / Plant', 'Tampil sebagai', 'Contoh hasil (DEV)',
       'Screenshot', 'Panggil FM tgl produksi (where-used)', 'Pakai ZZEXPIREDLIVE', 'Status', 'Contoh baris rumus', 'Catatan', 'Include / objek cocok']
data = []
for i, (_, prog, g, rec, note) in enumerate(rows, 1):
    tc, nama, comp, tampil, contoh, ss = INFO.get(prog, (None, '', '', '', '', ''))
    tcodes = ', '.join(sorted(rec['tcodes']))
    if tc is None or tc == '':
        tc = tcodes or '-'
    if g == 'B':
        tampil = tampil or LBL
        nama = nama or 'Label roll (cetak produksi / reprint)'
        ss = ss or 'Label & Cetak'
        comp = comp or 'Semua'
        if tc == '-':
            tc = DISP
    if g == 'C':
        tampil = tampil or 'Expired / used before di label HU'
        nama = nama or 'Label HU / pallet'
        ss = ss or 'Label & Cetak'
        comp = comp or 'Semua'
        if tc == '-':
            tc = HUDISP
    objs = [o for o in rec['objs'] if o != prog]
    data.append((i, GNAME[g], prog, tc, nama or '-', comp or '-', tampil or '-', contoh or '-', ss or '-',
                 'Ya' if 'FM_PRODDATE' in rec['hits'] else 'Tidak',
                 'Ya' if 'ZZEXPIREDLIVE' in rec['hits'] else 'Tidak',
                 GSTAT[g], rec['formula'][0][:90] if rec['formula'] else '', note, ', '.join(objs)))
end = table(ws, 4, hdr, data, [5, 26, 28, 28, 30, 14, 32, 28, 14, 13, 12, 18, 44, 36, 30])
fills = {'A': fill_ok, 'B': fill_ok, 'C': fill_ok, 'S': fill_sub, 'D': fill_sub, 'K': fill_note}
NC = len(hdr)
for rr in range(5, end):
    g = ws.cell(row=rr, column=2).value[0]
    if g in fills:
        for cc in range(1, NC + 1):
            ws.cell(row=rr, column=cc).fill = fills[g]
    if g in 'ABC' and ws.cell(row=rr, column=10).value == 'Tidak':
        ws.cell(row=rr, column=10).font = Font(name=F, size=10, bold=True, color='C00000')
    c = ws.cell(row=rr, column=9)
    if c.value and c.value != '-':
        c.hyperlink = f"#'{c.value}'!A1"
        c.font = Font(name=F, size=10, color='0563C1', underline='single', bold=c.value.startswith('SS-'))
ws.freeze_panes = 'D5'
ws.auto_filter.ref = f'A4:{get_column_letter(NC)}{end-1}'
ws.row_dimensions[4].height = 42
text(ws, f'A{end+1}', 'Hijau = terdampak (43 program di Ringkasan). Biru = terkait, tidak menampilkan Expired Date. Kuning = perlu cek manual. Link SS-... tebal = sudah diverifikasi di SAP GUI DEV dengan screenshot. '
     'Merah "Tidak" di kolom J = program terdampak yang tidak ketemu kalau hanya pakai where-used FM. '
     '*ZPP001 dkk. = ZPP001/N/L, ZAPP001 (TTA), ZEPP001 (TTE), ZTYB001/02, ZIC006, ZPP006, ZPP018, ZPP021, ZPP029R, ZQM016/ZEQM016, ZLABEL (reprint). '
     'Interface OLAP: ZSD012N dan ZSD024 mode OLAP menulis Expired Date ke tabel SQL XZSD012N dan XZSD024.', size=9, color='595959')
ws.merge_cells(f'A{end+1}:{get_column_letter(NC)}{end+1}')
ws.row_dimensions[end + 1].height = 28

# ---------------------------------------------------------------- Screenshot sheets
shots = [
    ('SS-ZBMBC', 'ZBMBC - Report Stock Overview with Characteristic',
     'Seleksi: Material SRAANI, Plant 2000, Batch 0000407486. Hasil: Expired Date 22.05.2027 = Production Date 23.11.2026 + 180 hari.',
     ['zbmbc_sel.png', 'zbmbc_r1.png']),
    ('SS-ZBMBC2', 'ZBMBC2 - Display Warehouse Stocks of Material',
     'Seleksi: Material SRAANI, Plant 2000, Batch 0000407486. Hasil: Expired Date 22.05.2027, Production Date 23.11.2026.',
     ['zbmbc2_r2.png']),
    ('SS-ZSD012N', 'ZSD012N - Ready Report for HU in Production and Warehouse',
     'Seleksi: Plant 2000, Sloc 2813, Material SRAANI, Batch 0000407486, tampil di Screen. Hasil: Expired Date 22.05.2027.',
     ['zsd012n_sel.png', 'zsd012n_r2.png']),
    ('SS-ZSD024', 'ZSD024 - Delivery Order Monitor',
     'Seleksi: Company Code 9999, DO 0085006287. Hasil: 6 roll, semua Expired Date 22.05.2027.',
     ['zsd024_sel.png', 'zsd024_res.png']),
    ('SS-ZSD024TTE', 'ZSD024TTE - Delivery Order Monitor (TTE)',
     'Seleksi: Company Code 6500 (TTE), Created Date 01.01.2026-24.11.2026. Kolom Expired Date tampil untuk DO TTE.',
     ['zsd024tte_res.png']),
    ('SS-ZQM001P', 'ZQM001P - QC Status for Packing (Daftar Pengepakan)',
     'Seleksi: HU 6000036531, Plant 2000, QA OK. Hasil: Expiry Date 22.05.2027 untuk 3 roll di HU.',
     ['zqm001p_sel.png', 'zqm001p_r1.png']),
    ('SS-ZEQM001P', 'ZEQM001P - QC Status for Packing TTE',
     'Seleksi: HU 9000005321, Plant TTE. Hasil: Expiry Date 18.11.2027 = Production Date 18.11.2026 + 365 hari.',
     ['zeqm001p_sel.png', 'zeqm001p_r1.png']),
    ('SS-ZQM002', 'ZQM002 - Print COA',
     'DO 0085006287. Layar COA tidak menampilkan expired date; expired date ada di lampiran "Batch List" (Excel). Batch List tidak bisa dibuka di SAP GUI Java server (butuh Excel Windows), jadi tidak ada screenshot isi Batch List.',
     ['zqm002_res.png', 'zqm002_pd.png']),
]
for name, ttl, cap, files in shots:
    ws = wb.create_sheet(name)
    title(ws, ttl)
    text(ws, 'A3', cap, fill=fill_note)
    ws.merge_cells('A3:N3')
    ws.row_dimensions[3].height = 32
    ws['A4'] = 'Kotak merah = kolom Expired Date. Sumber: SAP DEV AIX (TRD 130), 24.11.2026.'
    ws['A4'].font = Font(name=F, size=9, italic=True, color='595959')
    ws['P1'] = '<< Kembali ke daftar'
    ws['P1'].hyperlink = "#'Daftar Program'!A1"
    ws['P1'].font = Font(name=F, size=10, color='0563C1', underline='single')
    row = 6
    for fn in files:
        img = XLImage(os.path.join(SHOT, fn))
        img.width, img.height = 1080, 675
        ws.add_image(img, f'A{row}')
        row += 36

# ---------------------------------------------------------------- Label & Cetak
ws = wb.create_sheet('Label & Cetak')
title(ws, 'Program label & cetak yang menghitung Expired Date',
      'Tidak dijalankan di SAP GUI karena akan mencetak. Baris kode diambil dari source DEV (read-only).')
hdr = ['Dipakai untuk', 'Label type / pemicu', 'Program', 'Baris kode (DEV)', 'Catatan']
data = [
    ('Label roll standar', 'Default semua label type', 'ZMMR_LABELROL_STANDAR', 'L1646: V_EXPDATE = V_POSTDATE + V_LIVE.', 'Juga aturan khusus label CKI D121: bulan x 30 dari ZMAP_LABEL'),
    ('Label roll Inchi', '-', 'ZMMR_LABELROL_INCHI', 'L395: V_EXPDATE = V_POSTDATE + V_LIVE.', ''),
    ('Label roll DOCX', 'A153-A157, A159, B101, C109, D128, E127, E128, E133', 'ZMMR_LABELROL_DOCX', 'L495: V_EXPDATE = V_POSTDATE + ITAB-VLIVE.', ''),
    ('Label roll Windows', 'A010-A013, A161, CP18', 'ZMMR_LABELROL_WINDOWS', 'L343: V_EXPDATE = V_POSTDATE + ITAB-VLIVE.', ''),
    ('Label roll per type', 'A132, A133, A400, A401', 'ZLABELROL_A132 / A133 / A400 / A401', 'V_EXPDATE = V_POSTDATE + V_LIVE.', ''),
    ('Label roll per type', 'A131, A136, A138, A139', 'ZLABELROL_A131 / A136 / A138 / A139', 'Kirim umur simpan ke layout', 'Perlu cek layout label'),
    ('Label roll Toyobo', 'ZTYB03 / 03A / 03B', 'ZMMR_LABELROL_TYB', 'L552: V_EXPDATE = V_POSTDATE + V_LIVE.', ''),
    ('Label roll Non-SAP', '-', 'ZMMR_LABELROL_NONSAP', 'L353: V_EXPDATE = V_POSTDATE + ITAB-VLIVE.', ''),
    ('Ganti label', 'ZLABEL90', 'ZLABELROL_CHANGE_90', 'L763: V_EXPDATE = V_POSTDATE + V_LIVE.', 'Aturan D121 juga ada'),
    ('Ganti label', 'ZLABEL91', 'ZMMR_CHANGE_LABELROL_WIN', 'L442: V_EXPDATE = V_POSTDATE + ITAB-VLIVE.', ''),
    ('Label pallet / packing', 'Output HU V6 Z001 / Z002', 'ZHUR_LABELPACK', 'L1712: V_EXPDATE = V_POSTDATE + V_LIVE.', 'Aturan D121 juga ada'),
    ('Label HU per type', 'A146, A400, A401', 'ZLABELHU_A146 / A400 / A401', 'V_EXPDATE = V_POSTDATE + V_LIVE.', ''),
    ('Label HU Windows', 'A010-A013, A161, CP18', 'ZMMR_LABELHU_WINDOWS', 'L330: V_EXPDATE = V_POSTDATE + ITAB-VLIVE.', ''),
    ('Label HU KT&G', 'A158, A164, A173', 'ZMMR_LABELHU_KTNG', 'Kirim umur simpan ke layout', 'Perlu cek layout label'),
    ('Label HU', 'ZHU020 / ZHU021 / ZHU023 / ZHU025', 'ZHU_LABEL_PMI / _GG01 / ZHU_LABEL / _KTNG', 'EDATE = PDATE + VLIVE', '"Used Before" MM/YYYY'),
    ('COA', 'ZQM002 / ZQM003', 'ZQMI_COA', 'L4360: LV_EXPD = LV_PDATE + LV_DAYS.', 'Expired date di Batch List COA'),
    ('Sumber Production Date', 'Dipakai hampir semua program', 'FM Z_GET_PRODUCTION_DATE', 'GR 101/102 non-reversal, fallback MCH1-ERSDA', 'Titik paling tepat untuk aturan baru'),
]
table(ws, 4, hdr, data, [24, 34, 38, 44, 36])
text(ws, 'A23', 'Tidak terdampak: label TTA/TTE (ZMMR_LABELROL_TTA/_TTE), label Toyobo lama, label jumbo roll (ZMMR_LABELJR): tidak mencetak expired date.', size=9, color='595959')
ws.merge_cells('A23:E23')

# ---------------------------------------------------------------- Umur simpan
ws = wb.create_sheet('Umur Simpan per Plant')
title(ws, 'Sebaran umur simpan (hari) per company / plant', 'Jumlah batch di SAP DEV per nilai umur simpan. PRD bisa berbeda.')
hdr = ['Company', 'Plant', '60', '90', '120', '180', '270', '360', '365', 'Total batch', '% 180 hari', '% 365 hari']
vals = [
    ('9999 PT Trias Sentosa', '1000 Waru', 907, 0, 1633, 202153, 3, 306, 1962),
    ('9999 PT Trias Sentosa', '2000 Krian', 735, 8, 3147, 181170, 0, 3285, 41359),
    ('9701 PT Trias Toyobo Astria (TTA)', 'TTA2', 0, 0, 0, 3334, 0, 0, 4170),
    ('6500 PT Toyobo Trias Ecosyar (TTE)', 'TTE', 0, 0, 0, 3517, 0, 0, 9268),
    ('9702 PT TTE (inactive)', 'TTE2', 0, 0, 0, 18, 0, 0, 3),
    ('9800 PT Unggul Niaga Sentosa', 'UNS2', 0, 0, 0, 9, 0, 0, 30),
]
table(ws, 4, hdr, [list(v) for v in vals], [34, 14, 9, 9, 9, 11, 9, 9, 11, 13, 12, 12])
for i in range(len(vals)):
    rr = 5 + i
    for cc in range(3, 10):
        ws.cell(row=rr, column=cc).number_format = '#,##0;-#,##0;-'
        ws.cell(row=rr, column=cc).font = Font(name=F, size=10, color='0000FF')
    ws.cell(row=rr, column=10, value=f'=SUM(C{rr}:I{rr})').number_format = '#,##0'
    ws.cell(row=rr, column=11, value=f'=IF(J{rr}=0,0,F{rr}/J{rr})').number_format = '0.0%'
    ws.cell(row=rr, column=12, value=f'=IF(J{rr}=0,0,I{rr}/J{rr})').number_format = '0.0%'
    for cc in (10, 11, 12):
        ws.cell(row=rr, column=cc).font = Font(name=F, size=10)
        ws.cell(row=rr, column=cc).border = box
text(ws, 'A12', 'Angka biru = hasil hitung data batch SAP DEV (AUSP class 023 x MCH1 x MCHA), 24.11.2026. Satu batch bisa tercatat di lebih dari satu plant.', size=9, color='595959')
ws.merge_cells('A12:L12')
text(ws, 'A13', 'Catatan: usulan "+6 bulan" setara 180 hari (mayoritas Trias). Di TTA dan TTE mayoritas 365 hari, jadi perlu diputuskan apakah aturan baru berlaku juga di sana.', size=10, fill=fill_note)
ws.merge_cells('A13:L13')
ws.row_dimensions[13].height = 30

# ---------------------------------------------------------------- Pertanyaan
ws = wb.create_sheet('Pertanyaan Meeting')
title(ws, 'Hal yang perlu diputuskan sebelum perubahan', 'Bahan diskusi meeting dengan user')
hdr = ['No', 'Pertanyaan', 'Kenapa penting', 'Keputusan (diisi saat meeting)']
data = [
    (1, 'Customer "kritis" (STT dll.) ditentukan dari apa: customer, type film, label type, atau konfigurasi SO?', 'Saat label dicetak di produksi, sistem perlu tahu roll ini ikut aturan baru atau tidak.', ''),
    (2, 'Company/plant mana yang ikut: Trias saja, atau juga TTA, TTE, UNS?', 'TTA/TTE mayoritas umur simpan 365 hari dan punya T-code sendiri (ZEQM001P, ZSD024TTE).', ''),
    (3, 'Expired Date di report (tanggal penuh) jatuh di tanggal berapa: awal bulan, akhir bulan, atau tanggal produksi?', 'Label hanya tampil bulan, tapi ZBMBC/ZSD024/ZQM001P menampilkan tanggal penuh untuk monitoring stok expired.', ''),
    (4, 'Umur simpan tetap dalam hari (180/365) atau diganti bulan (6/12)? Bagaimana nilai 60/90/120/270/360?', 'Aturan baru berbasis bulan, data sekarang berbasis hari.', ''),
    (5, 'Batas tanggal 15 dihitung dari tanggal GR 101 atau tanggal konfirmasi produksi?', 'Production Date di SAP sekarang = tanggal GR 101.', ''),
    (6, 'Berlaku mulai kapan? Apakah batch lama ikut berubah di report?', 'Expired Date tidak disimpan; kalau rumus diubah, roll lama yang sudah berlabel ikut berubah di report.', ''),
    (7, 'Opsi perubahan: hanya label, atau label + semua report?', 'Hanya label = label dan report beda bulan (contoh Juni vs 22 Mei).', ''),
    (8, 'Koordinasi OLAP (Mas Cahya) untuk tabel XZSD012N dan XZSD024.', 'Kolom expired date ikut terkirim ke OLAP.', ''),
]
end = table(ws, 4, hdr, data, [5, 60, 55, 40])
for rr in range(5, end):
    ws.cell(row=rr, column=4).fill = PatternFill('solid', fgColor='FFFF00')
    ws.row_dimensions[rr].height = 45
text(ws, f'A{end+1}', 'Kolom kuning diisi saat meeting.', size=9, color='595959')

for s in wb.worksheets:
    s.sheet_view.showGridLines = False
wb.save(OUT)
print(OUT)
