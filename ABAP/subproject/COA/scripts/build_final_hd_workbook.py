import os
import math
from PIL import Image, ImageDraw, ImageFont
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter
from openpyxl.drawing.image import Image as OpenpyxlImage
from openpyxl.formatting.rule import FormulaRule

BASE_DIR = '/data/Projects/SAP/ABAP/subproject/COA/outputs/gui_test_20261118/'
OUTPUT_DIR = '/data/Projects/SAP/ABAP/subproject/COA/outputs/'

font_path_bold = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
font_path_reg = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'

def get_font(size, bold=False):
    p = font_path_bold if bold else font_path_reg
    return ImageFont.truetype(p, size)

# Palette Warna Elegan & Kontras
NAVY_HEADER = '1B365D'
STEEL_BLUE  = '2B6CB0'
ICE_BLUE    = 'F0F7FF'
ZEBRA_ROW   = 'F8FAFC'
WHITE       = 'FFFFFF'
BORDER_COLOR= 'CBD5E1'
DARK_TEXT   = '0F172A'
MUTED_TEXT  = '475569'
GREEN_TEXT  = '15803D'
GREEN_FILL  = 'DCFCE7'
RED_TEXT    = 'B91C1C'
RED_FILL    = 'FEE2E2'
BLUE_VALUE  = '0033CC'

COL = [
    (220, 38, 38),   # 1: Merah
    (37, 99, 235),   # 2: Biru
    (22, 163, 74),   # 3: Hijau
    (217, 119, 6),   # 4: Kuning-orange
    (147, 51, 234),  # 5: Ungu
    (8, 145, 178),   # 6: Cyan
    (219, 39, 119),  # 7: Magenta
    (101, 163, 13),  # 8: Lime
    (234, 88, 12),   # 9: Orange tua
    (100, 116, 139)  # 10: Slate gray
]

Z2_Y = [224, 252, 280, 308, 336, 364, 392, 420, 448, 476]
Z5_Y = [186, 206, 226, 246, 266, 326, 346, 366, 386, 406]

def draw_arrow(d, p1, p2, color, width=3):
    d.line([p1, p2], fill=color, width=width)
    angle = math.atan2(p2[1] - p1[1], p2[0] - p1[0])
    L = 15
    pts = [
        p2,
        (p2[0] - L * math.cos(angle - 0.45), p2[1] - L * math.sin(angle - 0.45)),
        (p2[0] - L * math.cos(angle + 0.45), p2[1] - L * math.sin(angle + 0.45))
    ]
    d.polygon(pts, fill=color)

def generate_hd_panah_image(do_num, out_png):
    im_z2 = Image.open(f'{BASE_DIR}zqm002_do{do_num}.png').convert('RGB')
    a = im_z2.crop((30, 183, 865, 490))
    
    im_z5 = Image.open(f'{BASE_DIR}zqm005_lot040000015885_JRSEFI.png').convert('RGB')
    b = im_z5.crop((8, 158, 765, 425))
    
    gap = 140
    top = 70
    bottom = 55
    W = 15 + a.width + gap + b.width + 15
    H = top + max(a.height, b.height) + bottom
    
    canvas = Image.new('RGB', (W, H), (255, 255, 255))
    d = ImageDraw.Draw(canvas)
    
    ax = 15
    bx = ax + a.width + gap
    
    canvas.paste(a, (ax, top))
    canvas.paste(b, (bx, top))
    
    # Header dekoratif
    d.rectangle([ax, 8, ax + a.width, 62], fill=(241, 245, 249), outline=(203, 213, 225), width=1)
    d.text((ax + 12, 14), f'ZQM002  —  DO {do_num}', font=get_font(18, True), fill=(15, 23, 42))
    d.text((ax + 12, 38), 'Nilai MIC ALV Grid ZQM002 (Kolom Value)', font=get_font(12), fill=(71, 85, 105))
    
    d.rectangle([bx, 8, bx + b.width, 62], fill=(241, 245, 249), outline=(203, 213, 225), width=1)
    d.text((bx + 12, 14), 'ZQM005  —  Lot 040000015885 (JRSEFI 0000371969, Plant TTA2)', font=get_font(18, True), fill=(15, 23, 42))
    d.text((bx + 12, 38), 'Hasil Uji Lot JR Base Film (Kolom Mean Value)', font=get_font(12), fill=(71, 85, 105))
    
    d.rectangle([ax - 1, top - 1, ax + a.width + 1, top + a.height + 1], outline=(148, 163, 184), width=1)
    d.rectangle([bx - 1, top - 1, bx + b.width + 1, top + b.height + 1], outline=(148, 163, 184), width=1)
    
    for i, (y2, y5) in enumerate(zip(Z2_Y, Z5_Y)):
        color = COL[i]
        ya = top + y2 - 183
        yb = top + y5 - 158
        
        if i == 9:
            d.rectangle([ax + 305 - 30, ya - 13, ax + a.width - 2, ya + 13], outline=(148, 163, 184), width=3)
            d.rectangle([ax + a.width + 8, ya - 12, ax + a.width + 125, ya + 12], fill=(241, 245, 249), outline=(148, 163, 184), width=1)
            d.text((ax + a.width + 14, ya - 9), '10: Tanpa Panah', font=get_font(12, True), fill=(100, 116, 139))
            continue
            
        d.rectangle([ax + 305 - 30, ya - 13, ax + a.width - 2, ya + 13], outline=color, width=3)
        d.rectangle([bx + 2, yb - 9, bx + b.width - 2, yb + 9], outline=color, width=3)
        draw_arrow(d, (ax + a.width + 4, ya), (bx - 4, yb), color, width=3)
        
        num_str = f'{i+1}'
        badge_x = ax + a.width + 16
        badge_y = ya - 9
        d.ellipse([badge_x, badge_y - 2, badge_x + 22, badge_y + 20], fill=color)
        d.text((badge_x + (7 if len(num_str) == 1 else 3), badge_y + 1), num_str, font=get_font(12, True), fill=(255, 255, 255))
        
    foot_y = top + max(a.height, b.height) + 12
    d.rectangle([ax, foot_y, bx + b.width, foot_y + 34], fill=(248, 250, 252), outline=(203, 213, 225), width=1)
    foot_msg = 'Catatan: Baris 1-9 (JR Base Film) MATCH 100% dengan Mean Value Lot JR TTA 040000015885. Baris 10 (SR Base Film) tidak memiliki lot SR di TTA2.'
    d.text((ax + 12, foot_y + 9), foot_msg, font=get_font(12, True), fill=(30, 41, 59))
    
    canvas.save(out_png, quality=100)
    return out_png

print('Generating HD Panah PNGs...')
generate_hd_panah_image('0085006285', f'{BASE_DIR}peta_panah_do0085006285_hd.png')
generate_hd_panah_image('0085006286', f'{BASE_DIR}peta_panah_do0085006286_hd.png')

# Definisi baris data
MIC_ROWS = [
    ('TH00', 'Thickness', 'Thickness', 'PSEFTH00', 11.64, 12.35, 12.00, 12.00, 'JR Base Film'),
    ('TSMD', 'Tensile Strength MD', 'Tensile Strength MD', 'PSEFTSMD', 16.00, 26.00, 23.00, 23.00, 'JR Base Film'),
    ('TSTD', 'Tensile Strength TD', 'Tensile Strength TD', 'PSEFTSTD', 18.00, 30.00, 27.00, 27.00, 'JR Base Film'),
    ('ELMD', 'Elongation MD', 'Elongation MD', 'PSEFELMD', 70, 150, 133, 133, 'JR Base Film'),
    ('ELTD', 'Elongation TD', 'Elongation TD', 'PSEFELTD', 60, 120, 123, 123, 'JR Base Film'),
    ('SHMD', 'Shrinkage MD', 'Shrinkage MD', 'PSEFSHMD', 1.00, 3.00, 2.00, 2.00, 'JR Base Film'),
    ('SHTD', 'Shrinkage TD', 'Shrinkage TD', 'PSEFSHTD', 0.00, 0.50, 0.30, 0.30, 'JR Base Film'),
    ('HZ00', 'Haze', 'Haze', 'PSEFHZ00', 1.50, 2.50, 2.00, 2.00, 'JR Base Film'),
    ('G400', 'Gloss 45', 'Gloss 45', 'PSEFG400', 120, 140, 128, 128, 'JR Base Film'),
    ('STNT', 'Surface Tension Untreated Side', '(tidak ada: lot SR Base Film tidak ada)', '', None, None, 0, None, 'SR Base Film')
]

SCENARIOS = [
    {
        'sheet': '0085006285',
        'title': 'Test DEV AIX (client 130) - SAP GUI - DO 0085006285 (TTA-OUTSOURCE)',
        'scenario': 'TTA-OUTSOURCE',
        'do': '0085006285',
        'so': '0000007209',
        'mat': 'SRCBUX',
        'prefix': 'PCAD',
        'chain': 'SRCBUX 3 roll TTA (9000377390/391/392) -> SRCBUO (PO subcontract, vendor batch) -> SRSEFI di TTA2 -> JRSEFI 0000371969 -> lot JR 040000015885',
        'stlim': (44, 50),
        'has_conv_lot': False
    },
    {
        'sheet': '0085006286',
        'title': 'Test DEV AIX (client 130) - SAP GUI - DO 0085006286 (TTA-CONVERTING)',
        'scenario': 'TTA-CONVERTING',
        'do': '0085006286',
        'so': '0000007209',
        'mat': 'SREYAI',
        'prefix': 'PEYA',
        'chain': 'SRCBUX TTA 9000377412/413/414 -> JREYAI 0000407417 (JR converting) -> SREYAI 0000407419/420 (SR converting) -> DO. Base film dari lot JR TTA 040000015885. Lot JREYAI 040000021140 tanpa hasil dan MIC-nya tidak sama dengan MIC DO',
        'stlim': (0, 0),
        'has_conv_lot': True
    }
]

thin_border = Side(style='thin', color=BORDER_COLOR)
cell_border = Border(left=thin_border, right=thin_border, top=thin_border, bottom=thin_border)
header_border = Border(left=thin_border, right=thin_border, top=Side(style='medium', color=NAVY_HEADER), bottom=Side(style='medium', color=NAVY_HEADER))

wb = openpyxl.Workbook()
wb.remove(wb.active)

headers = [
    'No',
    'MIC ZQM002',
    'Deskripsi Karakteristik',
    'Mapping ZMAP',
    'Inspection Lot',
    'Karakteristik ZQM005',
    'MIC Lot Asli',
    'Lower',
    'Upper',
    'Lot 1 (ZQM005)',
    'Lot ke-2 (jika ada)',
    'Rata-rata ZQM005',
    'Value ZQM002',
    'Selisih',
    'Status Match',
    'Relasi Panah Visual'
]

col_widths = {
    'A': 5,
    'B': 14,
    'C': 30,
    'D': 17,
    'E': 20,
    'F': 30,
    'G': 14,
    'H': 10,
    'I': 10,
    'J': 14,
    'K': 15,
    'L': 16,
    'M': 14,
    'N': 10,
    'O': 28,
    'P': 34
}

for sc in SCENARIOS:
    ws = wb.create_sheet(sc['sheet'])
    
    # Title Banner
    ws['A1'] = sc['title']
    ws['A1'].font = Font(name='Segoe UI', size=14, bold=True, color='FFFFFF')
    ws['A1'].fill = PatternFill('solid', fgColor=NAVY_HEADER)
    ws['A1'].alignment = Alignment(vertical='center', indent=1)
    ws.row_dimensions[1].height = 36
    ws.merge_cells('A1:P1')
    
    # Meta Info
    meta_info = [
        ('A2', f"Material: {sc['mat']}  |  Skenario: {sc['scenario']}  |  Nomor DO: {sc['do']}  |  SO: {sc['so']}  |  Client: 130 DEV AIX (TRD)"),
        ('A3', f"Alur Trace: {sc['chain']}"),
        ('A4', "Mapping: MIC 1-9 mengambil Lot JR TTA 040000015885. MIC 10 SR Base Film (lot SR belum tersedia di TTA2). Kolom L menghitung AVERAGE otomatis jika ada multiple lot.")
    ]
    for ref, text in meta_info:
        row_idx = int(ref[1])
        ws[ref] = text
        ws[ref].font = Font(name='Segoe UI', size=9, italic=(row_idx>2), color=DARK_TEXT)
        ws[ref].alignment = Alignment(vertical='center', wrap_text=True)
        ws.row_dimensions[row_idx].height = 24
        ws.merge_cells(f'A{row_idx}:P{row_idx}')
        
    # Table Header at Row 6
    ws.row_dimensions[6].height = 30
    for col_idx, h_text in enumerate(headers, 1):
        col_letter = get_column_letter(col_idx)
        cell = ws[f'{col_letter}6']
        cell.value = h_text
        cell.font = Font(name='Segoe UI', size=10, bold=True, color='FFFFFF')
        cell.fill = PatternFill('solid', fgColor=STEEL_BLUE)
        cell.alignment = Alignment(horizontal='center', vertical='center', wrap_text=True)
        cell.border = header_border
        
    # Data Rows (Row 7 to 16)
    for idx, (sfx, desc, kar, mic, lo, up, v2, v5, mp) in enumerate(MIC_ROWS):
        r = 7 + idx
        is_sr = (mp == 'SR Base Film')
        lot_id = 'tidak ada (Z04 SR TTA)' if is_sr else '040000015885'
        if is_sr:
            lo, up = sc['stlim']
            
        row_vals = [
            idx + 1,
            sc['prefix'] + sfx,
            desc,
            mp,
            lot_id,
            kar,
            mic,
            lo,
            up,
            v5,
            None, # Kolom K: Lot ke-2
            None, # Kolom L: Rata-rata formula
            v2,
            None, # Kolom N: Selisih formula
            None, # Kolom O: Status formula
            None  # Kolom P: Relasi Panah
        ]
        
        ws.row_dimensions[r].height = 24
        row_fill = PatternFill('solid', fgColor=ZEBRA_ROW) if (idx % 2 == 1) else PatternFill('solid', fgColor=WHITE)
        
        for col_idx, val in enumerate(row_vals, 1):
            col_letter = get_column_letter(col_idx)
            c = ws[f'{col_letter}{r}']
            c.value = val
            c.font = Font(name='Segoe UI', size=10, color=DARK_TEXT)
            c.fill = row_fill
            c.border = cell_border
            
            # Numeric alignment & formats
            if col_letter in ['A', 'D']:
                c.alignment = Alignment(horizontal='center', vertical='center')
            elif col_letter in ['H', 'I', 'J', 'K', 'L', 'M', 'N']:
                c.alignment = Alignment(horizontal='right', vertical='center')
                if sfx in ['ELMD', 'ELTD', 'G400', 'STNT']:
                    c.number_format = '0'
                else:
                    c.number_format = '0.00'
            else:
                c.alignment = Alignment(horizontal='left', vertical='center')
                
        # Angka warna biru untuk input value
        ws[f'J{r}'].font = Font(name='Segoe UI', size=10, bold=True, color=BLUE_VALUE)
        ws[f'K{r}'].font = Font(name='Segoe UI', size=10, bold=True, color=BLUE_VALUE)
        ws[f'M{r}'].font = Font(name='Segoe UI', size=10, bold=True, color=BLUE_VALUE)
        
        # Formulas
        ws[f'L{r}'] = f'=IF(COUNT(J{r}:K{r})=0,"",AVERAGE(J{r}:K{r}))'
        ws[f'N{r}'] = f'=IF(L{r}="","",M{r}-L{r})'
        ws[f'O{r}'] = f'=IF(COUNT(J{r}:K{r})=0,IF(M{r}="","COCOK (kosong)","BEDA: ZQM002 tampil "&M{r}&", seharusnya kosong"),IF(ABS(N{r})<0.005,"COCOK","BEDA"))'
        
        if not is_sr:
            ws[f'P{r}'] = f'="{sc["prefix"]+sfx}  ──▶  ZQM005: "&F{r}&" ("&TEXT(J{r},"0.00")&")"'
        else:
            ws[f'P{r}'] = '(tidak ada panah: lot SR tidak ada)'
            
        for cl in ['L', 'N', 'O', 'P']:
            ws[f'{cl}{r}'].font = Font(name='Segoe UI', size=10, color=DARK_TEXT)
            ws[f'{cl}{r}'].border = cell_border
            if cl in ['L', 'N']:
                ws[f'{cl}{r}'].alignment = Alignment(horizontal='right', vertical='center')
                if sfx in ['ELMD', 'ELTD', 'G400', 'STNT']:
                    ws[f'{cl}{r}'].number_format = '0'
                else:
                    ws[f'{cl}{r}'].number_format = '0.00'
                    
    # Conditional Formatting Status Match
    ws.conditional_formatting.add('O7:O16', FormulaRule(formula=['LEFT(O7,5)="COCOK"'], fill=PatternFill('solid', fgColor=GREEN_FILL), font=Font(color=GREEN_TEXT, bold=True)))
    ws.conditional_formatting.add('O7:O16', FormulaRule(formula=['LEFT(O7,4)="BEDA"'], fill=PatternFill('solid', fgColor=RED_FILL), font=Font(color=RED_TEXT, bold=True)))
    
    # Ringkasan Row 18 & 19
    ws['A18'] = f'="Ringkasan: "&COUNTIF(O7:O16,"COCOK*")&" dari 10 MIC cocok sempurna (MATCH); "&COUNTIF(O7:O16,"BEDA*")&" CATATAN: {sc["prefix"]}STNT mapping SR Base Film, lot SR tidak ada, ZQM002 tampil 0 padahal seharusnya kosong."'
    ws['A18'].font = Font(name='Segoe UI', size=11, bold=True, color=NAVY_HEADER)
    ws.row_dimensions[18].height = 24
    ws.merge_cells('A18:P18')
    
    ws['A19'] = "Keterangan: Angka warna biru adalah nilai hasil extract SAP GUI (ZQM002 kolom Value, ZQM005 kolom Mean Value). Kolom L (Rata-rata) dan N (Selisih) menggunakan formula dinamis Excel. Kolom K dapat diisi jika ada lot ke-2."
    ws['A19'].font = Font(name='Segoe UI', size=9, italic=True, color=MUTED_TEXT)
    ws.row_dimensions[19].height = 20
    ws.merge_cells('A19:P19')
    
    # Set Column Widths
    for col_l, w in col_widths.items():
        ws.column_dimensions[col_l].width = w
        
    cur_row = 21
    
    # SECTION 1: PETA PANAH HD (DIAGRAM KORELASI MIC ZQM002 -> ZQM005)
    ws[f'A{cur_row}'] = f'1. PETA PANAH KORELASI MIC: ZQM002 (Kiri)  ──▶  ZQM005 (Kanan) [HD RESOLUTION - UNCOMPRESSED]'
    ws[f'A{cur_row}'].font = Font(name='Segoe UI', size=12, bold=True, color='FFFFFF')
    ws[f'A{cur_row}'].fill = PatternFill('solid', fgColor=NAVY_HEADER)
    ws[f'A{cur_row}'].alignment = Alignment(vertical='center', indent=1)
    ws.row_dimensions[cur_row].height = 28
    ws.merge_cells(f'A{cur_row}:P{cur_row}')
    cur_row += 1
    
    panah_img_path = f'{BASE_DIR}peta_panah_do{sc["do"]}_hd.png'
    if os.path.exists(panah_img_path):
        img_panah = OpenpyxlImage(panah_img_path)
        # 100% native scale (1762x432) -> Jernih, tidak pecah!
        ws.add_image(img_panah, f'A{cur_row}')
        cur_row += 24 # 432px / ~20px per row + margin
        
    # SECTION 2: SCREEN ZQM002
    ws[f'A{cur_row}'] = f'2. SCREENSHOT TRANSAKSI ZQM002 (DEV AIX TRD 130 - DO {sc["do"]})'
    ws[f'A{cur_row}'].font = Font(name='Segoe UI', size=12, bold=True, color='FFFFFF')
    ws[f'A{cur_row}'].fill = PatternFill('solid', fgColor=STEEL_BLUE)
    ws[f'A{cur_row}'].alignment = Alignment(vertical='center', indent=1)
    ws.row_dimensions[cur_row].height = 28
    ws.merge_cells(f'A{cur_row}:P{cur_row}')
    cur_row += 1
    
    z2_alv_path = f'{BASE_DIR}zqm002_do{sc["do"]}.png'
    if os.path.exists(z2_alv_path):
        im_z2_full = OpenpyxlImage(z2_alv_path)
        im_z2_full.width = 1200
        im_z2_full.height = int(900 * (1200 / 1440))
        ws.add_image(im_z2_full, f'A{cur_row}')
        cur_row += int(im_z2_full.height / 20) + 2
        
    # SECTION 3: SCREEN ZQM005 LOT TTA
    ws[f'A{cur_row}'] = f'3. SCREENSHOT TRANSAKSI ZQM005 (LOT JR TTA 040000015885 - PLANT TTA2)'
    ws[f'A{cur_row}'].font = Font(name='Segoe UI', size=12, bold=True, color='FFFFFF')
    ws[f'A{cur_row}'].fill = PatternFill('solid', fgColor=STEEL_BLUE)
    ws[f'A{cur_row}'].alignment = Alignment(vertical='center', indent=1)
    ws.row_dimensions[cur_row].height = 28
    ws.merge_cells(f'A{cur_row}:P{cur_row}')
    cur_row += 1
    
    z5_tta_path = f'{BASE_DIR}zqm005_lot040000015885_JRSEFI.png'
    if os.path.exists(z5_tta_path):
        im_z5_full = OpenpyxlImage(z5_tta_path)
        im_z5_full.width = 1200
        im_z5_full.height = int(900 * (1200 / 1440))
        ws.add_image(im_z5_full, f'A{cur_row}')
        cur_row += int(im_z5_full.height / 20) + 2
        
    # SECTION 4 (Untuk Scenario 2): SCREEN ZQM005 LOT CONVERTING
    if sc['has_conv_lot']:
        ws[f'A{cur_row}'] = '4. SCREENSHOT TRANSAKSI ZQM005 (LOT CONVERTING JREYAI 040000021140 - PLANT 2000)'
        ws[f'A{cur_row}'].font = Font(name='Segoe UI', size=12, bold=True, color='FFFFFF')
        ws[f'A{cur_row}'].fill = PatternFill('solid', fgColor=STEEL_BLUE)
        ws[f'A{cur_row}'].alignment = Alignment(vertical='center', indent=1)
        ws.row_dimensions[cur_row].height = 28
        ws.merge_cells(f'A{cur_row}:P{cur_row}')
        cur_row += 1
        
        z5_conv_path = f'{BASE_DIR}zqm005_lot040000021140_JREYAI.png'
        if os.path.exists(z5_conv_path):
            im_z5_conv = OpenpyxlImage(z5_conv_path)
            im_z5_conv.width = 1200
            im_z5_conv.height = int(900 * (1200 / 1440))
            ws.add_image(im_z5_conv, f'A{cur_row}')
            cur_row += int(im_z5_conv.height / 20) + 2
            
    # SECTION TERAKHIR: SCREEN MAPPING ZMAP_COA
    sec_num = 5 if sc['has_conv_lot'] else 4
    ws[f'A{cur_row}'] = f'{sec_num}. SCREENSHOT REFERENSI MAPPING FOR GET INSP (ZMAP_COA)'
    ws[f'A{cur_row}'].font = Font(name='Segoe UI', size=12, bold=True, color='FFFFFF')
    ws[f'A{cur_row}'].fill = PatternFill('solid', fgColor=STEEL_BLUE)
    ws[f'A{cur_row}'].alignment = Alignment(vertical='center', indent=1)
    ws.row_dimensions[cur_row].height = 28
    ws.merge_cells(f'A{cur_row}:P{cur_row}')
    cur_row += 1
    
    zmap_path = f'{BASE_DIR}zmap_mapping_for_get_insp.png'
    if os.path.exists(zmap_path):
        im_zmap = OpenpyxlImage(zmap_path)
        ws.add_image(im_zmap, f'A{cur_row}')
        cur_row += int(im_zmap.height / 20) + 2
        
    ws.sheet_view.zoomScale = 90

# Simpan ke KEDUA lokasi agar Baginda dapat membuka dari mana saja
out_file1 = f'{BASE_DIR}GUI_TEST_COA_TTA_DEV_20261118.xlsx'
out_file2 = f'{OUTPUT_DIR}TESTING_COA_TTA_DEV_AIX.xlsx'

wb.save(out_file1)
wb.save(out_file2)
print('SUCCESS! Saved to:')
print(f'  1. {out_file1}')
print(f'  2. {out_file2}')
