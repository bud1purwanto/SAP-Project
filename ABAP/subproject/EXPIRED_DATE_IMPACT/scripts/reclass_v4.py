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

UNUSED = 'Tidak punya T-code, tidak dipanggil program lain, dan tidak terdaftar di ZMAP_LABEL (PROG_ROLL), jadi tidak pernah jalan.'
FIX = {
    'ZLABELROL_A133': ('E', '-', UNUSED),
    'ZMMR_LABELROL_NONSAP': ('E', '-', UNUSED),
}
# kolom D (T-code / pemicu) dan E (nama) yang dikoreksi: label tidak punya T-code sendiri
TC = {
    'ZLABELROL_A132': 'Label type A132', 'ZLABELROL_A400': 'Label type A400', 'ZLABELROL_A401': 'Label type A401',
    'ZLABELROL_A131': 'Label type A131', 'ZLABELROL_A136': 'Label type A136', 'ZLABELROL_A138': 'Label type A138', 'ZLABELROL_A139': 'Label type A139',
    'ZLABELROL_A133': '-', 'ZMMR_LABELROL_NONSAP': '-',
    'ZMMR_LABELROL_DOCX': 'Label type A153-A157, A159, B101, C109, D128, E127, E128, E133',
    'ZMMR_LABELROL_WINDOWS': 'Label type A010-A013, A161, CP18',
    'ZMMR_LABELROL_INCHI': 'Label type A134, A137, A142, A145, A300, A301, A304, A305, J129',
    'ZMMR_LABELROL_STANDAR': 'Label type lain (default)',
    'ZMMR_LABELROL_PM': 'Label type K110-K160 (PMI)',
    'ZMMR_LABELROL_TYB': 'ZTYB03, ZTYB03A, ZTYB03B (Report Label Toyobo)',
    'ZLABELHU_A146': 'Label type A146 (HU)', 'ZLABELHU_A400': 'Label type A400 (HU)', 'ZLABELHU_A401': 'Label type A401 (HU)',
    'ZMMR_LABELHU_WINDOWS': 'Label type A010-A013, A161, CP18 (HU)', 'ZMMR_LABELHU_KTNG': 'Label type A158, A164, A173 (HU)',
    'ZQMI_BARRIER_PASS_FAIL': 'Dipanggil dari ZEQM041, ZEQM044, ZBMBC',
    'ZQMI_BARRIER_NCR_UPLOAD': 'Dipanggil dari ZEQM041',
    'ZMMR_RETURN_PALLET': 'ZAMM062K, ZEMM062, ZMM062_TS, ZMM062_WKA; juga dari menu ZMM062',
    'ZMMR_RETURN_PALLET_W_CYCLE': 'Dipanggil dari menu ZMM062',
}
NAMA = {
    'ZQMI_BARRIER_PASS_FAIL': 'Barrier pass/fail TTE (dari NCR Approval Barrier Inspection / Report Barrier TTE)',
    'ZQMI_BARRIER_NCR_UPLOAD': 'Barrier NCR upload TTE (dari NCR Approval Barrier Inspection)',
    'ZMMR_RETURN_PALLET': 'Returnable Pallet History Report',
    'ZMMR_RETURN_PALLET_W_CYCLE': 'Returnable Pallet History (cycle)',
}
LBL = 'Label roll (tercetak otomatis saat produksi / cetak ulang)'
# nama kelompok mengikuti yang sudah ada di file (user mengganti nama A)
names, stat = {}, {}
for r in range(FIRST, last + 1):
    g = ws.cell(r, 2).value
    names.setdefault(g[0], g)
    stat.setdefault(g[0], ws.cell(r, 12).value)
names.setdefault('K', 'K. Perlu cek manual'); stat.setdefault('K', 'Perlu cek')

rows = []
for r in range(FIRST, last + 1):
    cells = []
    for c in range(1, 16):
        x = ws.cell(r, c)
        cells.append({'v': x.value, 'font': copy(x.font), 'fill': copy(x.fill), 'border': copy(x.border),
                      'al': copy(x.alignment), 'nf': x.number_format, 'hl': copy(x.hyperlink) if x.hyperlink else None})
    prog = cells[2]['v']
    g = cells[1]['v'][0]
    if prog in TC:
        cells[3]['v'] = TC[prog]
    if prog in NAMA:
        cells[4]['v'] = NAMA[prog]
    if cells[4]['v'] == 'Label roll (cetak produksi / reprint)':
        cells[4]['v'] = LBL
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
i = v.find('*ZPP001 dkk.')
j = v.find('Interface OLAP')
if i >= 0 and j > i:
    v = v[:i] + ('Label roll tidak punya T-code sendiri: dicetak oleh ZMMR_LABELROL sesuai label type batch (tabel ZMAP_LABEL). '
                 'ZMMR_LABELROL dipanggil otomatis dari transaksi seperti slitting ZPP001/ZPP001N/ZPP001L, ZAPP001, ZEPP001, ZTYB001/ZTYB02, '
                 'change grade ZQM016/ZEQM016, dan cetak ulang ZLABEL. Label type TTA (TA02-TA07) dan TTE (TE02) tidak mencetak Expired Date. ') + v[j:]
ws.cell(note_row, 1).value = v
ws.row_dimensions[note_row].height = 42

rs = wb['Ringkasan']
REP = {
    'Report: ZBMBC, ZBMBC2, ZSD012N, ZSD024, ZSD024A, ZQM001P, ZMM062, COA ZQM002/ZQM003. Label: ZPP001/N/L, ZPP006, ZPP018, ZPP021, ZQM016, ZLABEL, ZLABEL90/91, ZHU020-025.':
        'Report: ZBMBC, ZBMBC2, ZSD012N, ZSD024, ZSD024A, ZQM001P, ZMM062, COA ZQM002/ZQM003. Label roll (sesuai label type) dan label HU ZHU020-ZHU025; cetak ulang ZLABEL, ZLABEL90, ZLABEL91.',
    'Report: ZAMM062K + report umum (ZBMBC, ZSD012N, COA). Label: ZAPP001.':
        'Report: ZAMM062K + report umum (ZBMBC, ZSD012N, COA). Label type TTA (TA02-TA07) tidak mencetak Expired Date.',
    'Report: ZEQM001P, ZSD024TTE, ZEMM062, ZEQM041/ZEQM044 + report umum. Label: ZEPP001, ZEQM016.':
        'Report: ZEQM001P, ZSD024TTE, ZEMM062, barrier ZEQM041/ZEQM044 + report umum. Label type TTE (TE02) tidak mencetak Expired Date.',
    'ZTYB10, label ZTYB001/02, ZTYB03.': 'Report ZTYB10; label Toyobo lewat ZTYB03 (Report Label Toyobo).',
}
for row in rs.iter_rows(min_row=40, max_row=52):
    for x in row:
        if x.value in REP:
            x.value = REP[x.value]

lc = wb['Label & Cetak']
for r in range(5, 22):
    if str(lc.cell(r, 3).value).startswith('ZLABELROL_A132 / A133'):
        lc.cell(r, 2).value = 'A132, A400, A401'
        lc.cell(r, 3).value = 'ZLABELROL_A132 / A400 / A401'
    if lc.cell(r, 3).value == 'ZMMR_LABELROL_NONSAP':
        lc.cell(r, 5).value = 'Tidak dipakai: tanpa T-code, tidak dipanggil, tidak ada di ZMAP_LABEL.'
wb.save(out)
from collections import Counter
print(Counter(x[0] for x in rows))
