import os
import zipfile
import shutil
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter
from openpyxl.drawing.image import Image as OpenpyxlImage
from openpyxl.formatting.rule import FormulaRule

BASE_DIR = '/data/Projects/SAP/ABAP/subproject/COA/outputs/gui_test_20261118/'
OUTPUT_DIR = '/data/Projects/SAP/ABAP/subproject/COA/outputs/'

# Palet Warna Original & Modern
C_NAVY = '0F172A'       # Slate 900
C_HEADER_BLUE = '1E3A8A'# Deep Blue
C_HEADER_TEAL = '0F766E'# Deep Teal
C_CARD_BG = 'F8FAFC'    # Slate 50
C_BORDER = 'CBD5E1'     # Slate 300
C_TEXT_DARK = '0F172A'
C_TEXT_MUTED = '64748B'
C_ACCENT_BLUE = '2563EB'
C_ACCENT_TEAL = '0D9488'
C_GREEN_BG = 'DCFCE7'
C_GREEN_TXT = '166534'
C_RED_BG = 'FEE2E2'
C_RED_TXT = '991B1B'
C_YELLOW_BG = 'FEF9C3'
C_YELLOW_TXT = '854D0E'

HEX_COLORS = [
    'EF4444', # 1. Red
    '3B82F6', # 2. Blue
    '10B981', # 3. Emerald
    'F59E0B', # 4. Amber
    '8B5CF6', # 5. Purple
    '06B6D4', # 6. Cyan
    'EC4899', # 7. Pink
    '84CC16', # 8. Lime
    'F97316', # 9. Orange
    '64748B'  # 10. Slate Gray
]

# Data MIC Rekonsiliasi
MIC_DATA = [
    ('TH00', 'Thickness', 'Thickness', 'PSEFTH00', 11.64, 12.35, 12.00, 12.00, 'JR Base Film', '040000015885'),
    ('TSMD', 'Tensile Strength MD', 'Tensile Strength MD', 'PSEFTSMD', 16.00, 26.00, 23.00, 23.00, 'JR Base Film', '040000015885'),
    ('TSTD', 'Tensile Strength TD', 'Tensile Strength TD', 'PSEFTSTD', 18.00, 30.00, 27.00, 27.00, 'JR Base Film', '040000015885'),
    ('ELMD', 'Elongation MD', 'Elongation MD', 'PSEFELMD', 70, 150, 133, 133, 'JR Base Film', '040000015885'),
    ('ELTD', 'Elongation TD', 'Elongation TD', 'PSEFELTD', 60, 120, 123, 123, 'JR Base Film', '040000015885'),
    ('SHMD', 'Shrinkage MD', 'Shrinkage MD', 'PSEFSHMD', 1.00, 3.00, 2.00, 2.00, 'JR Base Film', '040000015885'),
    ('SHTD', 'Shrinkage TD', 'Shrinkage TD', 'PSEFSHTD', 0.00, 0.50, 0.30, 0.30, 'JR Base Film', '040000015885'),
    ('HZ00', 'Haze', 'Haze', 'PSEFHZ00', 1.50, 2.50, 2.00, 2.00, 'JR Base Film', '040000015885'),
    ('G400', 'Gloss 45', 'Gloss 45', 'PSEFG400', 120, 140, 128, 128, 'JR Base Film', '040000015885'),
    ('STNT', 'Surface Tension Untreated Side', '(tidak ada: lot SR belum ada)', '', None, None, 0, None, 'SR Base Film', 'tidak ada (Z04 SR TTA)')
]

SCENARIOS = [
    {
        'sheet': '0085006285',
        'title': 'REKONSILIASI COA — SKENARIO TTA-OUTSOURCE (DO 0085006285)',
        'subtitle': 'Sistem: DEV AIX (TRD 130) | User: TRSTDEV | Program: ZEQM015 (TOP 486, F01 6042)',
        'scenario': 'TTA-OUTSOURCE',
        'do': '0085006285',
        'so': '0000007209',
        'customer': '1141000514 (PT TRIAS SENTOSA)',
        'material': 'SRCBUX',
        'batches': '9000377390, 9000377391, 9000377392 (Roll 9*, Prodline Z3)',
        'prefix': 'PCAD',
        'trace': 'SRCBUX (Roll TTA) -> PO Subcontract SRCBUO -> Vendor Batch -> Order SR TTA -> Komponen JR TTA Lot 040000015885',
        'lots_desc': 'Lot JR TTA: 040000015885 (Plant TTA2, Mat JRSEFI, Batch 0000371969)',
        'stlim': (44, 50),
        'has_conv_lot': False
    },
    {
        'sheet': '0085006286',
        'title': 'REKONSILIASI COA — SKENARIO TTA-CONVERTING (DO 0085006286)',
        'subtitle': 'Sistem: DEV AIX (TRD 130) | User: TRSTDEV | Program: ZEQM015 (TOP 486, F01 6042)',
        'scenario': 'TTA-CONVERTING',
        'do': '0085006286',
        'so': '0000007209',
        'customer': '1141000514 (PT TRIAS SENTOSA)',
        'material': 'SREYAI',
        'batches': 'Roll TTA 9000377412/413/414 -> JREYAI 0000407417 -> SREYAI 0000407419/420',
        'prefix': 'PEYA',
        'trace': 'Roll TTA -> JREYAI Converting -> SREYAI Converting -> DO. Base film dari Lot JR TTA 040000015885. Lot Converting 040000021140 tanpa hasil.',
        'lots_desc': 'Lot JR TTA: 040000015885 (Plant TTA2) | Lot JR Conv: 040000021140 (Plant 2000)',
        'stlim': (0, 0),
        'has_conv_lot': True
    }
]

wb = openpyxl.Workbook()
wb.remove(wb.active)

thin_border = Side(style='thin', color=C_BORDER)
border_all = Border(left=thin_border, right=thin_border, top=thin_border, bottom=thin_border)
thick_bottom = Border(left=thin_border, right=thin_border, top=thin_border, bottom=Side(style='medium', color=C_NAVY))

# Build workbook
for sc in SCENARIOS:
    ws = wb.create_sheet(sc['sheet'])
    
    # 1. Header Banner
    ws['A1'] = sc['title']
    ws['A1'].font = Font(name='Segoe UI', size=13, bold=True, color='FFFFFF')
    ws['A1'].fill = PatternFill('solid', fgColor=C_HEADER_BLUE)
    ws['A1'].alignment = Alignment(vertical='center', indent=1)
    ws.row_dimensions[1].height = 32
    ws.merge_cells('A1:O1')
    
    ws['A2'] = sc['subtitle']
    ws['A2'].font = Font(name='Segoe UI', size=9, italic=True, color='E2E8F0')
    ws['A2'].fill = PatternFill('solid', fgColor='1E293B')
    ws['A2'].alignment = Alignment(vertical='center', indent=1)
    ws.row_dimensions[2].height = 20
    ws.merge_cells('A2:O2')
    
    # 2. KPI Summary Cards (Row 4)
    ws.row_dimensions[4].height = 42
    
    # Card 1: Delivery Order & Material
    ws['A4'] = f"DELIVERY ORDER\n{sc['do']} ({sc['material']})"
    ws['A4'].font = Font(name='Segoe UI', size=9, bold=True, color=C_HEADER_BLUE)
    ws['A4'].fill = PatternFill('solid', fgColor='EFF6FF')
    ws['A4'].alignment = Alignment(horizontal='center', vertical='center', wrap_text=True)
    ws['A4'].border = border_all
    ws.merge_cells('A4:C4')
    
    # Card 2: Sales Order & Customer
    ws['D4'] = f"SALES ORDER & CUSTOMER\nSO: {sc['so']} | Trias Sentosa"
    ws['D4'].font = Font(name='Segoe UI', size=9, bold=True, color='1E293B')
    ws['D4'].fill = PatternFill('solid', fgColor='F1F5F9')
    ws['D4'].alignment = Alignment(horizontal='center', vertical='center', wrap_text=True)
    ws['D4'].border = border_all
    ws.merge_cells('D4:F4')
    
    # Card 3: Status Match Hasil Uji
    ws['G4'] = f"STATUS KORELASI MIC\n9 MATCH ✅ (1 Beda: Lot SR blm ada)"
    ws['G4'].font = Font(name='Segoe UI', size=9, bold=True, color=C_GREEN_TXT)
    ws['G4'].fill = PatternFill('solid', fgColor=C_GREEN_BG)
    ws['G4'].alignment = Alignment(horizontal='center', vertical='center', wrap_text=True)
    ws['G4'].border = border_all
    ws.merge_cells('G4:J4')
    
    # Card 4: Lot Sumber Aktif
    ws['K4'] = f"LOT SUMBER AKTIF\n{sc['lots_desc']}"
    ws['K4'].font = Font(name='Segoe UI', size=9, bold=True, color='0F766E')
    ws['K4'].fill = PatternFill('solid', fgColor='CCFBF1')
    ws['K4'].alignment = Alignment(horizontal='center', vertical='center', wrap_text=True)
    ws['K4'].border = border_all
    ws.merge_cells('K4:O4')
    
    # 3. Table Column Headers at Row 6
    headers = [
        # Zone A: ZQM002 Delivery Result (Col A..E)
        ('A', 'No', 5, C_HEADER_BLUE),
        ('B', 'MIC ZQM002', 13, C_HEADER_BLUE),
        ('C', 'Deskripsi MIC', 26, C_HEADER_BLUE),
        ('D', 'Mapping ZMAP', 15, C_HEADER_BLUE),
        ('E', 'Value ZQM002', 13, C_HEADER_BLUE),
        # Zone B: Relasi & Panah Korelasi (Col F..H)
        ('F', 'Relasi Panah Visual (Movable)', 30, '0F766E'),
        ('G', 'Selisih (Δ)', 10, '0F766E'),
        ('H', 'Status Match', 18, '0F766E'),
        # Zone C: ZQM005 Source Lots (Col I..O)
        ('I', 'Inspection Lot', 18, '334155'),
        ('J', 'Karakteristik ZQM005', 26, '334155'),
        ('K', 'MIC Lot Asli', 13, '334155'),
        ('L', 'Lot 1 (ZQM005)', 14, '334155'),
        ('M', 'Lot 2 (jika ada)', 14, '334155'),
        ('N', 'Rata-rata ZQM005', 16, '334155'),
        ('O', 'Catatan / Alasan', 26, '334155')
    ]
    
    ws.row_dimensions[6].height = 32
    for col_letter, h_title, w, h_color in headers:
        c = ws[f'{col_letter}6']
        c.value = h_title
        c.font = Font(name='Segoe UI', size=9, bold=True, color='FFFFFF')
        c.fill = PatternFill('solid', fgColor=h_color)
        c.alignment = Alignment(horizontal='center', vertical='center', wrap_text=True)
        c.border = thick_bottom
        ws.column_dimensions[col_letter].width = w
        
    # 4. Data Rows (Row 7 to 16)
    for idx, item in enumerate(MIC_DATA):
        r = 7 + idx
        sfx, desc, kar, mic, lo, up, v2, v5, mp, lot_src = item
        is_sr = (mp == 'SR Base Film')
        
        ws.row_dimensions[r].height = 25
        row_bg = 'F8FAFC' if (idx % 2 == 1) else 'FFFFFF'
        
        # Values
        ws[f'A{r}'] = idx + 1
        ws[f'B{r}'] = sc['prefix'] + sfx
        ws[f'C{r}'] = desc
        ws[f'D{r}'] = mp
        ws[f'E{r}'] = v2 # Value ZQM002
        
        # Formulas Panah, Selisih, Status
        if not is_sr:
            ws[f'F{r}'] = f'="[{idx+1}]  ──────▶  {kar} ("&TEXT(N{r},"0.00")&")"'
        else:
            ws[f'F{r}'] = '✕ [10] (Lot SR tidak ada di TTA2)'
            
        ws[f'G{r}'] = f'=IF(N{r}="","",E{r}-N{r})'
        ws[f'H{r}'] = f'=IF(COUNT(L{r}:M{r})=0, IF(E{r}="","COCOK (kosong)","BEDA (ZQM002: "&E{r}&")"), IF(ABS(G{r})<0.005,"MATCH ✅","BEDA ❌"))'
        
        # ZQM005 Details
        ws[f'I{r}'] = lot_src
        ws[f'J{r}'] = kar
        ws[f'K{r}'] = mic
        ws[f'L{r}'] = v5 # Lot 1 Value
        ws[f'M{r}'] = None # Lot 2 Value (bisa diisi user)
        ws[f'N{r}'] = f'=IF(COUNT(L{r}:M{r})=0,"",AVERAGE(L{r}:M{r}))' # Formula RATA-RATA DINAMIS
        
        if not is_sr:
            ws[f'O{r}'] = 'Cocok 100% dari Lot JR TTA'
        else:
            ws[f'O{r}'] = 'ZQM002 tampil 0, seharusnya kosong'
            
        # Format sel
        for col_idx in range(1, 16):
            cl = get_column_letter(col_idx)
            cell = ws[f'{cl}{r}']
            cell.font = Font(name='Segoe UI', size=9, color=C_TEXT_DARK)
            cell.fill = PatternFill('solid', fgColor=row_bg)
            cell.border = border_all
            
            if cl in ['A', 'D', 'H']:
                cell.alignment = Alignment(horizontal='center', vertical='center')
            elif cl in ['E', 'G', 'L', 'M', 'N']:
                cell.alignment = Alignment(horizontal='right', vertical='center')
                if sfx in ['ELMD', 'ELTD', 'G400', 'STNT']:
                    cell.number_format = '0'
                else:
                    cell.number_format = '0.00'
            else:
                cell.alignment = Alignment(horizontal='left', vertical='center')
                
        # Visual highlights
        ws[f'E{r}'].font = Font(name='Segoe UI', size=9, bold=True, color='0033CC')
        ws[f'L{r}'].font = Font(name='Segoe UI', size=9, bold=True, color='0033CC')
        ws[f'M{r}'].font = Font(name='Segoe UI', size=9, bold=True, color='0033CC')
        ws[f'N{r}'].font = Font(name='Segoe UI', size=9, bold=True, color='0F766E')
        ws[f'F{r}'].font = Font(name='Segoe UI', size=9, bold=True, color='1E3A8A' if not is_sr else '94A3B8')
        
    # Conditional formatting status match
    ws.conditional_formatting.add('H7:H16', FormulaRule(formula=['LEFT(H7,5)="MATCH"'], fill=PatternFill('solid', fgColor=C_GREEN_BG), font=Font(color=C_GREEN_TXT, bold=True)))
    ws.conditional_formatting.add('H7:H16', FormulaRule(formula=['LEFT(H7,4)="BEDA"'], fill=PatternFill('solid', fgColor=C_RED_BG), font=Font(color=C_RED_TXT, bold=True)))
    
    # 5. Interactive Testing Box & Guidance (Row 18 to 20)
    ws['A18'] = 'PETUNJUK PENGUJIAN RATA-RATA & PANAH BERGESER:'
    ws['A18'].font = Font(name='Segoe UI', size=9, bold=True, color=C_HEADER_BLUE)
    ws.merge_cells('A18:C18')
    
    ws['D18'] = (
        '1. Panah visual berbentuk Shape Vector Excel di atas tabel dapat diklik, digeser (drag & drop), atau dipindahkan ke posisi lain secara bebas.\n'
        '2. Kolom M (Lot 2) dapat diisi nilai numerik baru untuk menguji formula rata-rata otomatis pada Kolom N (=AVERAGE(L..:M..)).\n'
        '3. Baris 10 (PCADSTNT / PEYASTNT) berstatus BEDA karena lot SR TTA tidak memiliki inspeksi di plant TTA2 (ZQM002 menampilkan 0).'
    )
    ws['D18'].font = Font(name='Segoe UI', size=9, italic=True, color=C_TEXT_MUTED)
    ws['D18'].alignment = Alignment(vertical='center', wrap_text=True)
    ws.row_dimensions[18].height = 45
    ws.merge_cells('D18:O18')
    
    # 6. Section Screenshots Pendukung (Row 22 onwards)
    cur_r = 22
    
    # Title Section Screenshots
    ws[f'A{cur_r}'] = 'DOKUMENTASI BUKTI SCREENSHOT SAP GUI SERVER (DEV AIX TRD 130)'
    ws[f'A{cur_r}'].font = Font(name='Segoe UI', size=11, bold=True, color='FFFFFF')
    ws[f'A{cur_r}'].fill = PatternFill('solid', fgColor=C_NAVY)
    ws[f'A{cur_r}'].alignment = Alignment(vertical='center', indent=1)
    ws.row_dimensions[cur_r].height = 28
    ws.merge_cells(f'A{cur_r}:O{cur_r}')
    cur_r += 2
    
    # Sub-header 1: ZQM002 ALV Grid
    ws[f'A{cur_r}'] = f'Bukti 1: Transaksi ZQM002 (DEV AIX) — Hasil ALV Print COA DO {sc["do"]}'
    ws[f'A{cur_r}'].font = Font(name='Segoe UI', size=10, bold=True, color=C_HEADER_BLUE)
    cur_r += 1
    
    z2_img_path = f'{BASE_DIR}zqm002_do{sc["do"]}.png'
    if os.path.exists(z2_img_path):
        im_z2 = OpenpyxlImage(z2_img_path)
        im_z2.width = 1150
        im_z2.height = int(900 * (1150 / 1440))
        ws.add_image(im_z2, f'A{cur_r}')
        cur_r += int(im_z2.height / 20) + 2
        
    # Sub-header 2: ZQM005 Lot TTA 040000015885
    ws[f'A{cur_r}'] = 'Bukti 2: Transaksi ZQM005 — Hasil Uji Lot JR TTA 040000015885 (Plant TTA2, Mat JRSEFI)'
    ws[f'A{cur_r}'].font = Font(name='Segoe UI', size=10, bold=True, color=C_HEADER_BLUE)
    cur_r += 1
    
    z5_tta_path = f'{BASE_DIR}zqm005_lot040000015885_JRSEFI.png'
    if os.path.exists(z5_tta_path):
        im_z5 = OpenpyxlImage(z5_tta_path)
        im_z5.width = 1150
        im_z5.height = int(900 * (1150 / 1440))
        ws.add_image(im_z5, f'A{cur_r}')
        cur_r += int(im_z5.height / 20) + 2
        
    # Sub-header 3 (Khusus DO 0085006286): ZQM005 Lot Converting
    if sc['has_conv_lot']:
        ws[f'A{cur_r}'] = 'Bukti 3: Transaksi ZQM005 — Lot Converting JREYAI 040000021140 (Plant 2000, Tanpa Hasil Uji)'
        ws[f'A{cur_r}'].font = Font(name='Segoe UI', size=10, bold=True, color=C_HEADER_BLUE)
        cur_r += 1
        
        z5_conv_path = f'{BASE_DIR}zqm005_lot040000021140_JREYAI.png'
        if os.path.exists(z5_conv_path):
            im_z5c = OpenpyxlImage(z5_conv_path)
            im_z5c.width = 1150
            im_z5c.height = int(900 * (1150 / 1440))
            ws.add_image(im_z5c, f'A{cur_r}')
            cur_r += int(im_z5c.height / 20) + 2
            
    # Sub-header 4: Mapping ZMAP_COA
    ws[f'A{cur_r}'] = 'Bukti Referensi: Konfigurasi Mapping for Get Insp. di ZMAP_COA (JR Base Film vs SR Base Film)'
    ws[f'A{cur_r}'].font = Font(name='Segoe UI', size=10, bold=True, color=C_HEADER_BLUE)
    cur_r += 1
    
    zmap_path = f'{BASE_DIR}zmap_mapping_for_get_insp.png'
    if os.path.exists(zmap_path):
        im_zm = OpenpyxlImage(zmap_path)
        ws.add_image(im_zm, f'A{cur_r}')
        cur_r += int(im_zm.height / 20) + 2
        
    ws.sheet_view.zoomScale = 90

# Simpan base workbook
temp_base_path = '/tmp/custom_workbook_base.xlsx'
wb.save(temp_base_path)
print('Base workbook saved.')

# Sekarang, Inject Native Movable Vector Arrow Shapes ke drawing XML!
# Unpack XLSX
unpack_dir = '/tmp/custom_wb_unpack'
if os.path.exists(unpack_dir):
    shutil.rmtree(unpack_dir)

with zipfile.ZipFile(temp_base_path, 'r') as z:
    z.extractall(unpack_dir)

drawings_dir = os.path.join(unpack_dir, 'xl/drawings')
drawing_files = [f for f in os.listdir(drawings_dir) if f.startswith('drawing') and f.endswith('.xml')]

# Untuk setiap drawing (sheet 1 dan sheet 2), tambahkan 9 movable vector arrow shapes!
for d_idx, d_file in enumerate(sorted(drawing_files), 1):
    d_path = os.path.join(drawings_dir, d_file)
    with open(d_path, 'r', encoding='utf-8') as f:
        xml = f.read()
        
    arrows_xml = ''
    # Tambahkan 9 arrow shapes untuk row 7 s.d. 15 (index 0..8)
    # Shapes diposisikan di Column F (Col 5) menghubungkan Col E ke Col I
    for i in range(9):
        r_num = 7 + i
        color = HEX_COLORS[i]
        shape_id = 2000 + (d_idx * 100) + i
        arrow_def = f'''
<twoCellAnchor editAs="twoCell">
  <from>
    <col>5</col>
    <colOff>20000</colOff>
    <row>{r_num-1}</row>
    <rowOff>40000</rowOff>
  </from>
  <to>
    <col>5</col>
    <colOff>2300000</colOff>
    <row>{r_num-1}</row>
    <rowOff>220000</rowOff>
  </to>
  <sp macro="" textlink="">
    <nvSpPr>
      <cNvPr id="{shape_id}" name="Panah_Movable_{i+1}"/>
      <cNvSpPr/>
    </nvSpPr>
    <spPr>
      <a:xfrm>
        <a:off x="0" y="0"/>
        <a:ext cx="0" cy="0"/>
      </a:xfrm>
      <a:prstGeom prst="rightArrow">
        <a:avLst/>
      </a:prstGeom>
      <a:solidFill>
        <a:srgbClr val="{color}"/>
      </a:solidFill>
      <a:ln w="12700">
        <a:solidFill>
          <a:srgbClr val="FFFFFF"/>
        </a:solidFill>
      </a:ln>
    </spPr>
    <txBody>
      <a:bodyPr vertOverflow="clip" horzOverflow="clip"/>
      <a:lstStyle/>
      <a:p>
        <a:pPr algn="ctr"/>
        <a:r>
          <a:rPr lang="en-US" sz="800" b="1">
            <a:solidFill><a:srgbClr val="FFFFFF"/></a:solidFill>
          </a:rPr>
          <a:t>MATCH [{i+1}]</a:t>
        </a:r>
      </a:p>
    </txBody>
  </sp>
  <clientData/>
</twoCellAnchor>
'''
        arrows_xml += arrow_def
        
    xml_updated = xml.replace('</wsDr>', arrows_xml + '</wsDr>')
    with open(d_path, 'w', encoding='utf-8') as f:
        f.write(xml_updated)

# Repack ke kedua lokasi target
final_out1 = f'{BASE_DIR}GUI_TEST_COA_TTA_DEV_20261118.xlsx'
final_out2 = f'{OUTPUT_DIR}TESTING_COA_TTA_DEV_AIX.xlsx'

for out_f in [final_out1, final_out2]:
    with zipfile.ZipFile(out_f, 'w', zipfile.ZIP_DEFLATED) as z:
        for root, dirs, files in os.walk(unpack_dir):
            for file in files:
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, unpack_dir)
                z.write(full_path, rel_path)

print('SUCCESS! Repacked custom workbook with movable vector arrow shapes to:')
print(f'  1. {final_out1}')
print(f'  2. {final_out2}')
