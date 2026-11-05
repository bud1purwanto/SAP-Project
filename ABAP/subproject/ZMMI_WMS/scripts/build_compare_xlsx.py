"""Rapikan Compare_ZBMBC.xlsx (ZBMBC awal vs ZBMBC WMS vs ZMMI_WMS) untuk presentasi.

Pemakaian: python build_compare_xlsx.py <Compare_ZBMBC.xlsx asli> <folder media> <screenshot ZMMI_WMS.png> <out.xlsx>
<folder media> = isi xl/media hasil unzip file asli (image1..4.png).
"""
import datetime as dt
import os
import sys

from openpyxl import Workbook, load_workbook
from openpyxl.cell import WriteOnlyCell
from openpyxl.drawing.image import Image as XImage
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side

SRC, MEDIA, ZMMI_PNG, OUT = sys.argv[1:5]

NAVY = '1F3864'
F = 'Arial'
fnt = Font(name=F, size=10)
fnt_b = Font(name=F, size=10, bold=True)
fnt_h = Font(name=F, size=10, bold=True, color='FFFFFF')
fnt_title = Font(name=F, size=16, bold=True, color=NAVY)
fnt_sub = Font(name=F, size=10, italic=True, color='595959')
fnt_sec = Font(name=F, size=12, bold=True, color=NAVY)
fnt_note = Font(name=F, size=9, italic=True, color='595959')
fill_h = PatternFill('solid', fgColor=NAVY)
fill_grp = PatternFill('solid', fgColor='D9E1F2')
fill_tot = PatternFill('solid', fgColor='F2F2F2')
fill_new = PatternFill('solid', fgColor='E2EFDA')
thin = Side(style='thin', color='BFBFBF')
box = Border(left=thin, right=thin, top=thin, bottom=thin)
wrap = Alignment(wrap_text=True, vertical='center')
vmid = Alignment(vertical='center')
center = Alignment(horizontal='center', vertical='center', wrap_text=True)

wb = Workbook(write_only=True)


def C(ws, v, font=fnt, fill=None, fmt=None, align=None, border=True):
    c = WriteOnlyCell(ws, value=v)
    c.font = font
    if fill:
        c.fill = fill
    if fmt:
        c.number_format = fmt
    c.alignment = align or vmid
    if border:
        c.border = box
    return c


# =====================================================================
# Sheet 1 — Ringkasan
# =====================================================================
ws = wb.create_sheet('Ringkasan')
for col, w in zip('ABCDEFGHIJKL', [30, 32, 13, 10, 12, 18, 16, 13, 12, 14, 14, 52]):
    ws.column_dimensions[col].width = w
ws.sheet_view.showGridLines = False
ws.page_setup.orientation = 'landscape'
ws.page_setup.paperSize = '9'  # A4
ws.sheet_properties.pageSetUpPr.fitToPage = True
ws.page_setup.fitToWidth = 1
ws.page_setup.fitToHeight = 0

rows = []          # list of lists (cells) — ditulis berurutan
R = lambda *cells: rows.append(list(cells))   # noqa: E731
blank = lambda: rows.append([])               # noqa: E731

R(C(ws, 'Perbandingan Performa ZBMBC vs ZMMI_WMS (Feed WMS Gudang FGS)', fnt_title, border=False))
R(C(ws, 'Sistem DEV (TRD) · Diukur dengan Runtime Analysis (SAT) · ZBMBC dijalankan dengan Material SR*, Plant 1000',
    fnt_sub, border=False))
blank()

# ---- 1. Ringkasan runtime (baris 4..)
R(C(ws, '1. Ringkasan Runtime', fnt_sec, border=False))
hdr = ['Versi', 'Program / Mode', 'Tanggal SAT', 'Jam', 'User', 'Jumlah Pemanggilan', 'Runtime (µs)',
       'Runtime (detik)', 'Runtime (menit)', 'Lebih cepat vs ZBMBC awal', 'Status', 'Keterangan']
R(*[C(ws, h, fnt_h, fill_h, align=center) for h in hdr])          # baris 5
runs = [
    ('ZBMBC awal', 'ZBAP_STOCK_BY_CHAR1 — Screen', dt.date(2026, 10, 28), '14:14:10', 'TRSTDEV', 2962485,
     372247962, 'Baseline', 'Membaca seluruh stok SR* Plant 1000 (71.290 batch); SELECT per baris.', None),
    ('ZBMBC WMS (run 1)', 'ZBAP_STOCK_BY_CHAR1 — Execution Type WMS', dt.date(2026, 10, 28), '15:52:09', 'TRST-BUDI',
     1315534, 94395661, 'Tidak dilanjutkan',
     'Runtime = Gross "Perform GT_DATA" (net per kategori tidak terlihat di screenshot).', None),
    ('ZBMBC WMS (run 2)', 'ZBAP_STOCK_BY_CHAR1 — Execution Type WMS', dt.date(2026, 10, 28), '16:40:35', 'TRST-BUDI',
     1315537, 137048531, 'Tidak dilanjutkan', 'Runtime = Gross "Perform GT_DATA".', None),
    ('ZMMI_WMS', 'ZMMI_WMS — program baru (berbasis HU)', dt.date(2026, 11, 5), '10:21:37', 'TRST-BUDI', 27832,
     1287776, 'Program baru', 'Hanya HU sesuai Created On; mass select (FOR ALL ENTRIES) di awal.', fill_new),
]
first = 6
for i, (v, prog, d, t, u, n, us, st, ket, fl) in enumerate(runs):
    r = first + i
    R(C(ws, v, fnt_b, fl), C(ws, prog, fnt, fl, align=wrap), C(ws, d, fnt, fl, 'dd.mm.yyyy'), C(ws, t, fnt, fl),
      C(ws, u, fnt, fl), C(ws, n, fnt, fl, '#,##0'), C(ws, us, fnt, fl, '#,##0'),
      C(ws, '=G%d/1000000' % r, fnt, fl, '#,##0.00'), C(ws, '=G%d/60000000' % r, fnt, fl, '#,##0.000'),
      C(ws, '=$G$%d/G%d' % (first, r), fnt_b, fl, '#,##0.0"x"'), C(ws, st, fnt_b, fl),
      C(ws, ket, fnt, fl, align=wrap))
R(C(ws, 'Sumber: screenshot SAT (SE30 / SAT) di sheet "Screenshot SAT". Runtime = Net total Runtime Measurement, '
    'kecuali ZBMBC WMS (Gross Perform GT_DATA).', fnt_note, border=False))
blank()

# ---- 2. Profil SAT per kategori
sec2 = len(rows) + 1
R(C(ws, '2. Profil SAT per Kategori', fnt_sec, border=False))
grp = ['', 'ZBMBC awal', '', '', '', 'ZBMBC WMS (run 1)', 'ZMMI_WMS', '', '', '']
R(*[C(ws, g, fnt_b, fill_grp) for g in grp])
hdr2 = ['Kategori Aktivitas (Profile)', 'Jumlah Pemanggilan', 'Net (µs)', 'Net (menit)', 'Beban %',
        'Jumlah Pemanggilan', 'Jumlah Pemanggilan', 'Net (µs)', 'Net (detik)', 'Beban %']
R(*[C(ws, h, fnt_h, fill_h, align=center) for h in hdr2])
cats = [
    ('Data Accesses External (Akses DB)', 1427435, 207240000, 577977, 2027, 554046),
    ('Internal Processing Blocks (Rutin/Metode)', 308497, 116140000, 368440, 20078, 200556),
    ('Data Accesses Internal (Manipulasi Tabel Internal)', 1142970, 41350000, 286836, 1103, 232583),
    ('Miscellaneous (Lain-lain)', 82532, 7420000, 81407, 4317, 24650),
    ('External Processing Blocks', 744, 60000, 712, 26, 271115),
    ('Load / Generate', 306, 37000, 161, 280, 4826),
    ('Runtime Analysis (Beban Alat SAT)', 1, 900, 1, 1, 0),
]
c0 = len(rows) + 1
cN = c0 + len(cats) - 1
tot = cN + 1
for i, (k, n1, us1, n2, n3, us3) in enumerate(cats):
    r = c0 + i
    R(C(ws, k, fnt, align=wrap), C(ws, n1, fnt, None, '#,##0'), C(ws, us1, fnt, None, '#,##0'),
      C(ws, '=C%d/60000000' % r, fnt, None, '#,##0.00'), C(ws, '=C%d/C$%d' % (r, tot), fnt, None, '0.00%'),
      C(ws, n2, fnt, None, '#,##0'), C(ws, n3, fnt, None, '#,##0'), C(ws, us3, fnt, None, '#,##0'),
      C(ws, '=H%d/1000000' % r, fnt, None, '#,##0.000'), C(ws, '=H%d/H$%d' % (r, tot), fnt, None, '0.00%'))
R(C(ws, 'Total', fnt_b, fill_tot),
  *[C(ws, '=SUM(%s%d:%s%d)' % (col, c0, col, cN), fnt_b, fill_tot, fm)
    for col, fm in [('B', '#,##0'), ('C', '#,##0'), ('D', '#,##0.00'), ('E', '0.00%'), ('F', '#,##0'),
                    ('G', '#,##0'), ('H', '#,##0'), ('I', '#,##0.000'), ('J', '0.00%')]])
R(C(ws, 'Catatan: Net ZBMBC awal per kategori dibulatkan (kolom Net terpotong di screenshot); total tepat '
    '372.247.962 µs. Net ZBMBC WMS per kategori tidak terlihat di screenshot.', fnt_note, border=False))
blank()

# ---- 3. Akses DB teratas
R(C(ws, '3. Akses DB Teratas (Hit List SAT)', fnt_sec, border=False))
hdr3 = ['Versi', 'Statement / Event', 'Hits', 'Net (µs)', 'Net (detik)', 'Net % (SAT)']
R(*[C(ws, h, fnt_h, fill_h, align=center) for h in hdr3])
hits = [
    ('ZBMBC awal', 'DB: Fetch AUSP', 71290, 107320359, 0.2884),
    ('ZBMBC awal', 'DB: Fetch MCH1', 71290, 102236233, 0.2747),
    ('ZBMBC awal', 'DB: Fetch VEPO', 142580, 22920119, 0.0616),
    ('ZBMBC awal', 'DB: Fetch MSEG', 71290, 21107660, 0.0567),
    ('ZBMBC awal', 'DB: Fetch LQUA', 71290, 10023369, 0.0269),
    ('ZBMBC WMS (run 1)', 'DB: Fetch AUSP', 1398, 18934577, 0.2003),
    ('ZBMBC WMS (run 1)', 'DB: Fetch VEPO', 142592, 16506860, 0.1746),
    ('ZBMBC WMS (run 1)', 'DB: Fetch VBPA', 40917, 4890690, 0.0517),
    ('ZBMBC WMS (run 1)', 'DB: Fetch VEPO', 45095, 4590462, 0.0486),
    ('ZBMBC WMS (run 1)', 'DB: Fetch VEKP', 26277, 3033331, 0.0321),
    ('ZMMI_WMS', 'DB: Fetch AUSP', 29, 115743, 0.0899),
    ('ZMMI_WMS', 'DB: Fetch MSKA', 56, 107858, 0.0838),
    ('ZMMI_WMS', 'DB: Fetch MCHB', 56, 104945, 0.0815),
    ('ZMMI_WMS', 'DB: Fetch VEPO', 594, 104862, 0.0814),
    ('ZMMI_WMS', 'DB: Fetch LQUA', 29, 28535, 0.0222),
]
h0 = len(rows) + 1
for i, (v, s, n, us, pct) in enumerate(hits):
    r = h0 + i
    fl = fill_new if v == 'ZMMI_WMS' else None
    R(C(ws, v, fnt_b if i % 5 == 0 else fnt, fl), C(ws, s, fnt, fl), C(ws, n, fnt, fl, '#,##0'),
      C(ws, us, fnt, fl, '#,##0'), C(ws, '=D%d/1000000' % r, fnt, fl, '#,##0.000'), C(ws, pct, fnt, fl, '0.00%'))
R(C(ws, 'Hits = jumlah eksekusi SELECT. ZBMBC: 1 SELECT per batch (71.290 hit). ZMMI_WMS: FOR ALL ENTRIES '
    '(paket 100 key) → puluhan hit.', fnt_note, border=False))
blank()

# ---- 4. Kesimpulan
R(C(ws, '4. Kesimpulan', fnt_sec, border=False))
concl = [
    '• ZBMBC awal butuh ±6,2 menit (372 detik) karena membaca seluruh stok SR* dan menjalankan SELECT per batch '
    '(AUSP, MCH1, MSEG, LQUA masing-masing 71.290 kali).',
    '• ZBMBC dengan Execution Type WMS turun ke ±1,6–2,3 menit, tetapi masih membaca VEPO per baris (142.592 hit); '
    'pendekatan ini tidak dilanjutkan.',
    '• ZMMI_WMS (program baru) selesai dalam ±1,3 detik: seleksi dimulai dari HU (Created On), lalu semua data '
    'diambil sekaligus (mass select) dan dibaca dari memori.',
    '• Perbandingan tidak apple-to-apple dalam volume: ZBMBC membaca seluruh stok, ZMMI_WMS hanya HU sesuai '
    'Created On — memang inilah desainnya untuk feed WMS harian.',
    '• SAT ZMMI_WMS dijalankan mode Screen (ALV): 21% beban "External Processing" adalah transfer ALV ke SAP GUI, '
    'bukan insert ke database WMS.',
]
for t in concl:
    R(C(ws, t, fnt, border=False))

for r in rows:
    ws.append(r)

# =====================================================================
# Sheet 2 — Screenshot SAT
# =====================================================================
ws2 = wb.create_sheet('Screenshot SAT')
ws2.sheet_view.showGridLines = False
ws2.column_dimensions['A'].width = 3
ws2.sheet_properties.pageSetUpPr.fitToPage = True
ws2.page_setup.fitToWidth = 1
ws2.page_setup.fitToHeight = 0
shots = [
    ('A. Selection screen ZBMBC (Material SR*, Plant 1000)', os.path.join(MEDIA, 'image1.png')),
    ('B. SAT ZBMBC awal — 28.10.2026 14:14:10', os.path.join(MEDIA, 'image2.png')),
    ('C. SAT ZBMBC WMS run 1 — 28.10.2026 15:52:09', os.path.join(MEDIA, 'image3.png')),
    ('D. SAT ZBMBC WMS run 2 — 28.10.2026 16:40:35', os.path.join(MEDIA, 'image4.png')),
    ('E. SAT ZMMI_WMS (program baru) — 05.11.2026 10:21:37', ZMMI_PNG),
]
r2 = [[C(ws2, None, border=False), C(ws2, 'Screenshot Runtime Analysis (SAT)', fnt_title, border=False)], []]
row = 3
W = 1000  # px lebar gambar
for title, path in shots:
    while len(r2) < row - 1:
        r2.append([])
    r2.append([C(ws2, None, border=False), C(ws2, title, fnt_sec, border=False)])
    img = XImage(path)
    h = int(img.height * W / img.width)
    img.width, img.height = W, h
    ws2.add_image(img, 'B%d' % (row + 2))
    row += 2 + h // 20 + 3
for r in r2:
    ws2.append(r)

# =====================================================================
# Sheet 3 — Data ZBMBC Awal (data mentah, dirapikan)
# =====================================================================
if os.environ.get('PREVIEW'):  # tanpa sheet data (untuk cek tampilan)
    wb.save(OUT)
    sys.exit(0)
src = load_workbook(SRC, read_only=True)
sws = src['DEV BEFORE']
ws3 = wb.create_sheet('Data ZBMBC Awal')
ws3.freeze_panes = 'A2'
it = sws.iter_rows(values_only=True)
header = list(next(it))
ncol = len(header)
widths = {'Material No': 14, 'Plant': 7, 'Sloc': 7, 'Batch': 12, 'No Roll': 30, 'Customer Name': 34,
          'Description Grade': 24, 'Type': 10, 'Criteria': 14}
from openpyxl.utils import get_column_letter  # noqa: E402
for i, h in enumerate(header, 1):
    ws3.column_dimensions[get_column_letter(i)].width = widths.get(h, max(10, min(22, len(str(h)) + 3)))
nrows = sws.max_row
ws3.auto_filter.ref = 'A1:%s%d' % (get_column_letter(ncol), nrows)
ws3.append([C(ws3, h, fnt_h, fill_h, align=center, border=False) for h in header])
cnt = 0
for vals in it:
    cnt += 1
    out = []
    for v in vals[:ncol]:
        c = WriteOnlyCell(ws3, value=v)
        c.font = fnt
        out.append(c)
    ws3.append(out)
print('data rows', cnt)

wb.save(OUT)
print('OK', OUT)
