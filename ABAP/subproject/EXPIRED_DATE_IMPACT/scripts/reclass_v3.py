"""Koreksi kelompok di sheet Daftar Program (file versi terbaru dari user), urutkan ulang, dan sesuaikan teks terkait.
Pakai: python reclass_v3.py <input.xlsx> <output.xlsx>
"""
import sys
from copy import copy
from openpyxl import load_workbook
from openpyxl.styles import Font, PatternFill

inp, out = sys.argv[1:3]
wb = load_workbook(inp)
ws = wb['Daftar Program']
H, FIRST = 3, 4
last = FIRST
while ws.cell(last + 1, 3).value:
    last += 1

PROD = 'Label mencetak tanggal/bulan produksi (MANUF.DATE), bukan Expired Date. ZZEXPIREDLIVE dibaca tapi nilainya tidak dipakai. Terdampak hanya kalau bulan produksi di label ikut digeser.'
FIX = {  # program: (kelompok, tampil sebagai, catatan)
    'ZLABELROL_A131': ('K', 'Bulan produksi (YYYY.MM), bukan expired', PROD),
    'ZLABELROL_A136': ('K', 'MANUF.DATE (YYYY.MM), bukan expired', PROD + ' Lihat Contoh 4 di sheet Label & Cetak.'),
    'ZLABELROL_A138': ('K', 'Bulan produksi (YYYY.MM), bukan expired', PROD),
    'ZLABELROL_A139': ('K', 'Bulan produksi (YYYY.MM), bukan expired', PROD),
    'ZMMR_LABELROL_PM': ('K', 'Tanggal produksi (DD/MM/YYYY), bukan expired', 'Label PMI/Sampoerna: field ZZEX diisi tanggal produksi (komentar "Add Expired Date" tapi isinya V_POSTDATE). ZZEXPIREDLIVE dibaca tapi tidak dipakai.'),
    'ZMMR_LABELHU_KTNG': ('K', 'Umur simpan dikirim ke template label', 'Expired Date tidak dihitung di ABAP; nilai umur simpan (VLIVE) dan tanggal produksi dikirim ke template label KT&G. Perlu cek template.'),
    'ZLABEL_A211': ('F', '-', 'Kode perhitungan expired sudah dinonaktifkan (dikomentari). ZZEXPIREDLIVE dibaca tapi tidak dipakai.'),
    'ZPPR_PENDING_ORDER_ALF': ('F', '-', 'Pending Order Report. ZZEXPIREDLIVE hanya ada di daftar nama karakteristik (F_SET_ATNAM, tuning baca ATINN); nilainya tidak dipakai, tidak ada kolom expired.'),
    'ZPPR_PENDING_ORDER_SCHLINE': ('F', '-', 'Pending Order per schedule line. Sama dengan ZPP005N: ZZEXPIREDLIVE hanya di daftar nama karakteristik, nilainya tidak dipakai.'),
    'ZSDI_UP_QUOT': ('F', '-', 'Upload quotation: ZZEXPIREDLIVE justru dibuang dari entri variant table ZZCODE (DELETE ... WHERE VTCHARACT = ZZEXPIREDLIVE).'),
    'ZSDI_UP_QUOT_TTA': ('F', '-', 'Sama dengan ZSD101: ZZEXPIREDLIVE dibuang dari entri variant table.'),
    'ZSDI_UP_QUOT_TTE': ('F', '-', 'Sama dengan ZSD101: ZZEXPIREDLIVE dibuang dari entri variant table.'),
    'ZMMI_GRN_SUBCON_TTE': ('F', '-', 'Hanya deklarasi field ZZEXPIREDLIVE, tidak pernah diisi atau ditampilkan.'),
    'ZHU_LABEL_GENT': ('F', '-', 'Field EDATE (Used Before) hanya dideklarasi, tidak pernah dihitung.'),
    'ZMMR_LABELROL_MODIFIED_KTNG': ('F', '-', 'Kolom "Live" dan "Expired Date" ada di ALV tapi tidak pernah diisi (selalu kosong).'),
    'ZMAP_COA_BATCH': ('D', 'Mapping kolom "Expired Date" Batch List COA', 'Hanya mapping kolom untuk Batch List COA; nilai dihitung di ZQMI_COA.'),
}
# nama kelompok mengikuti yang sudah ada di file (user mengganti nama A)
names, stat = {}, {}
for r in range(FIRST, last + 1):
    g = ws.cell(r, 2).value
    names.setdefault(g[0], g)
    stat.setdefault(g[0], ws.cell(r, 12).value)
names.setdefault('K', 'K. Perlu cek manual'); stat.setdefault('K', 'Perlu cek')
stat['K'] = 'Perlu cek: tidak menghitung Expired Date di SAP'

rows = []
for r in range(FIRST, last + 1):
    cells = []
    for c in range(1, 16):
        x = ws.cell(r, c)
        cells.append({'v': x.value, 'font': copy(x.font), 'fill': copy(x.fill), 'border': copy(x.border),
                      'al': copy(x.alignment), 'nf': x.number_format, 'hl': copy(x.hyperlink) if x.hyperlink else None})
    prog = cells[2]['v']
    g = cells[1]['v'][0]
    if prog in FIX:
        ng, tampil, note = FIX[prog]
        g = ng
        cells[1]['v'] = names[g]
        cells[6]['v'] = tampil
        cells[11]['v'] = stat[g]
        cells[13]['v'] = note
        if g in 'KF' and cells[8]['v'] == 'Label & Cetak' and prog not in ('ZLABELROL_A136',):
            cells[8]['v'] = '-'; cells[8]['hl'] = None
    rows.append((g, prog, cells, ws.row_dimensions[r].height))
order = 'ABCSDKEF'
rows.sort(key=lambda x: (order.index(x[0]), x[1]))

FILL = {'A': 'E2EFDA', 'B': 'E2EFDA', 'C': 'E2EFDA', 'S': 'D9E2F3', 'D': 'D9E2F3', 'K': 'FFF2CC'}
for i, (g, prog, cells, h) in enumerate(rows):
    r = FIRST + i
    for c, d in enumerate(cells, 1):
        x = ws.cell(r, c)
        x.value = d['v']
        x.font, x.border, x.alignment, x.number_format = d['font'], d['border'], d['al'], d['nf']
        x.fill = PatternFill('solid', fgColor=FILL[g]) if g in FILL else PatternFill(fill_type=None)
        x.hyperlink = d['hl']
    ws.cell(r, 1).value = i + 1
    j = ws.cell(r, 10)
    base = copy(ws.cell(r, 11).font)
    if g in 'ABC' and j.value == 'Tidak':
        j.font = Font(name=base.name, size=base.size, bold=True, color='C00000')
    else:
        j.font = base
    if h:
        ws.row_dimensions[r].height = h
note_row = last + 2
v = ws.cell(note_row, 1).value or ''
ws.cell(note_row, 1).value = v.replace('Hijau = terdampak (43 program di Ringkasan).', 'Hijau = terdampak (lihat Ringkasan langkah 3).').replace(
    'Kuning = perlu cek manual.', 'Kuning = perlu cek manual (antara lain label yang mencetak tanggal produksi, bukan expired).')

# Ringkasan: teks daftar program langkah 3b
rs = wb['Ringkasan']
for row in rs.iter_rows(min_row=18, max_row=30):
    for x in row:
        if isinstance(x.value, str) and x.value.startswith('Tidak memanggil FM, menghitung tanggal produksi sendiri'):
            x.value = 'Tidak memanggil FM, menghitung tanggal produksi sendiri: ZQM001P, ZEQM001P, ZBMBC2, barrier TTE (ZEQM041), label HU ZHU021, ZHU023, ZHU025.'

# Label & Cetak: koreksi baris A131/A136/A138/A139 dan KT&G
lc = wb['Label & Cetak']
for r in range(5, 22):
    p = str(lc.cell(r, 3).value)
    if p.startswith('ZLABELROL_A131'):
        lc.cell(r, 4).value = 'VUSED = V_POSTDATE (bulan produksi). ZZEXPIREDLIVE dibaca tapi tidak dipakai.'
        lc.cell(r, 5).value = 'Mencetak MANUF.DATE / bulan produksi, bukan Expired Date. Terdampak hanya kalau bulan produksi ikut digeser.'
    if p == 'ZMMR_LABELHU_KTNG':
        lc.cell(r, 4).value = 'ITAB-VLIVE = umur simpan; expired tidak dihitung di ABAP'
        lc.cell(r, 5).value = 'Umur simpan dan tanggal produksi dikirim ke template label KT&G. Perlu cek template.'
wb.save(out)
from collections import Counter
print(Counter(x[0] for x in rows))
