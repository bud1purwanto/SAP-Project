import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter
from openpyxl.drawing.image import Image as OpenpyxlImage
import os
from PIL import Image as PILImage

# Initialize Workbook
wb = openpyxl.Workbook()
# Remove default sheet
wb.remove(wb.active)

# Color Palette
DARK_NAVY = "1B365D"
HEADER_BLUE = "2B6CB0"
ACCENT_BLUE = "EBF8FF"
ZEBRA_FILL = "F7FAFC"
WHITE = "FFFFFF"
BORDER_GRAY = "CBD5E0"
TEXT_DARK = "1A202C"
GREEN_FILL = "C6F6D5"
GREEN_TEXT = "22543D"
ARROW_BLUE = "2B6CB0"

font_title = Font(name="Segoe UI", size=14, bold=True, color=WHITE)
font_subtitle = Font(name="Segoe UI", size=10, italic=True, color="E2E8F0")
font_section = Font(name="Segoe UI", size=11, bold=True, color=WHITE)
font_tbl_header = Font(name="Segoe UI", size=10, bold=True, color=WHITE)
font_data = Font(name="Segoe UI", size=10, color=TEXT_DARK)
font_data_bold = Font(name="Segoe UI", size=10, bold=True, color=TEXT_DARK)
font_match = Font(name="Segoe UI", size=10, bold=True, color=GREEN_TEXT)
font_arrow = Font(name="Segoe UI", size=12, bold=True, color=ARROW_BLUE)
font_meta_lbl = Font(name="Segoe UI", size=9, bold=True, color="4A5568")
font_meta_val = Font(name="Segoe UI", size=9, color=TEXT_DARK)

thin_border_side = Side(border_style="thin", color=BORDER_GRAY)
cell_border = Border(left=thin_border_side, right=thin_border_side, top=thin_border_side, bottom=thin_border_side)
thick_bottom = Border(bottom=Side(border_style="medium", color=DARK_NAVY))

def resize_image_for_excel(img_path, out_path, max_w=680):
    if not os.path.exists(img_path):
        return None
    with PILImage.open(img_path) as im:
        w, h = im.size
        if w > max_w:
            ratio = max_w / float(w)
            new_w = max_w
            new_h = int(float(h) * ratio)
            im_resized = im.resize((new_w, new_h), PILImage.Resampling.LANCZOS)
            im_resized.save(out_path)
            return out_path
        else:
            im.save(out_path)
            return out_path

# Scenarios definition
scenarios = [
    {
        "sheet_name": "TTA-OUTSOURCE - 0085006285",
        "title": "SKENARIO 20: TTA-OUTSOURCE — DO 0085006285",
        "scenario_code": "TTA-OUTSOURCE",
        "do_num": "0085006285",
        "so_num": "0000007209",
        "material": "SRCBUX",
        "customer": "1141000514 (PT TRIAS SENTOSA)",
        "batches": "9000377390, 9000377391, 9000377392 (Roll berawalan 9*, Prodline Z3)",
        "lots": "Lot JR TTA: 040000015885 (Plant TTA2, Mat JRSEFI, Batch 0000371969)",
        "notes": (
            "Pada skenario TTA-OUTSOURCE, roll DO berawalan 9* dengan prodline Z3 terdeteksi sebagai produk outsource TTA.\n"
            "Alur penelusuran (trace) bergerak ke order 101 -> komponen GI 261 dari PO -> vendor batch MCH1-LICHA -> order SR TTA -> komponen JR TTA (Lot 040000015885).\n"
            "9 MIC JR Base Film mengambil nilai dari lot JR TTA (ZQM005). 1 MIC SR Base Film (PCADSTNT) bernilai 0 karena SR TTA tidak memiliki lot inspeksi."
        ),
        "zqm002_sel": "/data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_do6285_sel.png",
        "zqm002_alv": "/data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_do6285_alv.png",
        "zqm005_sel": "/data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm005_tta_sel.png",
        "zqm005_res": "/data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm005_tta_result.png",
        "lot_res2": None,
        "data": [
            ("1", "PCADTH00", "Thickness", "JR Base Film", "um", 11.64, 12.35, "", 12.00, "040000015885", "TTA2 / JRSEFI", "PSEFTH00", 12.00, None, "12.00", "MATCH ✅"),
            ("2", "PCADTSMD", "Tensile Strength MD", "JR Base Film", "kg/mm2", 16.00, 26.00, "", 23.00, "040000015885", "TTA2 / JRSEFI", "PSEFTSMD", 23.00, None, "23.00", "MATCH ✅"),
            ("3", "PCADTSTD", "Tensile Strength TD", "JR Base Film", "kg/mm2", 18.00, 30.00, "", 27.00, "040000015885", "TTA2 / JRSEFI", "PSEFTSTD", 27.00, None, "27.00", "MATCH ✅"),
            ("4", "PCADELMD", "Elongation MD", "JR Base Film", "%", 70.0, 150.0, "", 133.0, "040000015885", "TTA2 / JRSEFI", "PSEFELMD", 132.67, None, "133.00", "MATCH ✅ (Round)"),
            ("5", "PCADELTD", "Elongation TD", "JR Base Film", "%", 60.0, 120.0, "X", 123.0, "040000015885", "TTA2 / JRSEFI", "PSEFELTD", 122.67, None, "123.00", "MATCH ✅ (Round)"),
            ("6", "PCADSHMD", "Shrinkage MD", "JR Base Film", "%", 1.00, 3.00, "", 2.00, "040000015885", "TTA2 / JRSEFI", "PSEFSHMD", 2.00, None, "2.00", "MATCH ✅"),
            ("7", "PCADSHTD", "Shrinkage TD", "JR Base Film", "%", 0.00, 0.50, "", 0.30, "040000015885", "TTA2 / JRSEFI", "PSEFSHTD", 0.30, None, "0.30", "MATCH ✅"),
            ("8", "PCADHZ00", "Haze", "JR Base Film", "%", 1.50, 2.50, "", 2.00, "040000015885", "TTA2 / JRSEFI", "PSEFHZ00", 2.00, None, "2.00", "MATCH ✅"),
            ("9", "PCADG400", "Gloss 45", "JR Base Film", "%", 120.0, 140.0, "", 128.0, "040000015885", "TTA2 / JRSEFI", "PSEFG400", 127.67, None, "128.00", "MATCH ✅ (Round)"),
            ("10", "PCADSTNT", "Surface Tension Untreated Side", "SR Base Film", "dyne/cm", 44.0, 50.0, "X", 0.00, "-", "TTA2 / SRSEFI (No Lot)", "-", 0.00, None, "0.00", "VALID ✅ (SR BF No Lot)")
        ]
    },
    {
        "sheet_name": "TTA-CONVERTING - 0085006286",
        "title": "SKENARIO 21: TTA-CONVERTING — DO 0085006286",
        "scenario_code": "TTA-CONVERTING",
        "do_num": "0085006286",
        "so_num": "0000007210",
        "material": "SREYAI",
        "customer": "1141000514 (PT TRIAS SENTOSA)",
        "batches": "0000407419, 0000407420 (SR Converting SREYAI)",
        "lots": "Lot JR Conv: 040000021140 (Plant 2000, JREYAI) | Lot JR TTA: 040000015885 (Plant TTA2, JRSEFI)",
        "notes": (
            "Pada skenario TTA-CONVERTING, rantai produksi mencakup Converting: SRCBUX TTA (9*, Z3) sebagai SR Base Film -> JR Converting JREYAI (Lot 040000021140) -> SR Converting SREYAI -> DO 0085006286.\n"
            "Program mendeteksi batch TTA pada tahap SR Base Film (L_SR_BASE_BATCH) di dalam rantai converting.\n"
            "9 MIC Base Film pada SREYAI mengambil nilai dari lot JR TTA (040000015885). PEYASTNT bernilai 0 karena SR Base Film TTA tidak memiliki lot."
        ),
        "zqm002_sel": "/data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_do6286_sel.png",
        "zqm002_alv": "/data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_do6286_alv.png",
        "zqm005_sel": "/data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm005_conv_sel.png",
        "zqm005_res": "/data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm005_conv_result.png",
        "lot_res2": "/data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm005_tta_result.png",
        "data": [
            ("1", "PEYATH00", "Thickness", "JR Base Film", "um", 11.64, 12.35, "", 12.00, "040000015885", "TTA2 / JRSEFI", "PSEFTH00", 12.00, None, "12.00", "MATCH ✅"),
            ("2", "PEYATSMD", "Tensile Strength MD", "JR Base Film", "kg/mm2", 16.00, 26.00, "", 23.00, "040000015885", "TTA2 / JRSEFI", "PSEFTSMD", 23.00, None, "23.00", "MATCH ✅"),
            ("3", "PEYATSTD", "Tensile Strength TD", "JR Base Film", "kg/mm2", 18.00, 30.00, "", 27.00, "040000015885", "TTA2 / JRSEFI", "PSEFTSTD", 27.00, None, "27.00", "MATCH ✅"),
            ("4", "PEYAELMD", "Elongation MD", "JR Base Film", "%", 70.0, 150.0, "", 133.0, "040000015885", "TTA2 / JRSEFI", "PSEFELMD", 132.67, None, "133.00", "MATCH ✅ (Round)"),
            ("5", "PEYAELTD", "Elongation TD", "JR Base Film", "%", 60.0, 120.0, "X", 123.0, "040000015885", "TTA2 / JRSEFI", "PSEFELTD", 122.67, None, "123.00", "MATCH ✅ (Round)"),
            ("6", "PEYASHMD", "Shrinkage MD", "JR Base Film", "%", 1.00, 3.00, "", 2.00, "040000015885", "TTA2 / JRSEFI", "PSEFSHMD", 2.00, None, "2.00", "MATCH ✅"),
            ("7", "PEYASHTD", "Shrinkage TD", "JR Base Film", "%", 0.00, 0.50, "", 0.30, "040000015885", "TTA2 / JRSEFI", "PSEFSHTD", 0.30, None, "0.30", "MATCH ✅"),
            ("8", "PEYAHZ00", "Haze", "JR Base Film", "%", 1.50, 2.50, "", 2.00, "040000015885", "TTA2 / JRSEFI", "PSEFHZ00", 2.00, None, "2.00", "MATCH ✅"),
            ("9", "PEYAG400", "Gloss 45", "JR Base Film", "%", 120.0, 140.0, "", 128.0, "040000015885", "TTA2 / JRSEFI", "PSEFG400", 127.67, None, "128.00", "MATCH ✅ (Round)"),
            ("10", "PEYASTNT", "Surface Tension Untreated Side", "SR Base Film", "dyne/cm", 0.0, 0.0, "", 0.00, "-", "TTA2 / SRSEFI (No Lot)", "-", 0.00, None, "0.00", "VALID ✅ (SR BF No Lot)")
        ]
    }
]

for sc in scenarios:
    ws = wb.create_sheet(title=sc["sheet_name"])
    ws.views.sheetView[0].showGridLines = True
    
    # 1. Main Header Banner
    ws.merge_cells("A1:Q1")
    c1 = ws["A1"]
    c1.value = sc["title"]
    c1.font = font_title
    c1.fill = PatternFill(start_color=DARK_NAVY, end_color=DARK_NAVY, fill_type="solid")
    c1.alignment = Alignment(horizontal="center", vertical="center")
    ws.row_dimensions[1].height = 35

    ws.merge_cells("A2:Q2")
    c2 = ws["A2"]
    c2.value = "Laporan Resmi Hasil Pengujian SAP GUI di Server Development AIX (TRD Client 130) — ZQM002 vs ZQM005"
    c2.font = font_subtitle
    c2.fill = PatternFill(start_color=DARK_NAVY, end_color=DARK_NAVY, fill_type="solid")
    c2.alignment = Alignment(horizontal="center", vertical="center")
    ws.row_dimensions[2].height = 20

    # 2. Metadata Section
    ws.merge_cells("A4:Q4")
    c_sec1 = ws["A4"]
    c_sec1.value = "📌 INFORMASI DOKUMEN & PARAMETER PENGUJIAN"
    c_sec1.font = font_section
    c_sec1.fill = PatternFill(start_color=HEADER_BLUE, end_color=HEADER_BLUE, fill_type="solid")
    c_sec1.alignment = Alignment(horizontal="left", vertical="center", indent=1)
    ws.row_dimensions[4].height = 24

    meta_items = [
        ("Nomor Delivery Order (DO):", sc["do_num"], "Sales Order (SO):", sc["so_num"]),
        ("Material Code (DO):", sc["material"], "Customer Target:", sc["customer"]),
        ("Daftar Batch Delivery:", sc["batches"], "Sistem & Client:", "Development AIX (TRD) / Client 130"),
        ("Inspection Lot Terlibat:", sc["lots"], "Eksekutor:", "TRSTDEV (Automated SAP GUI Driver)")
    ]

    cur_row = 5
    for lbl1, val1, lbl2, val2 in meta_items:
        ws.row_dimensions[cur_row].height = 20
        # Col A-B: Label 1
        ws.merge_cells(f"A{cur_row}:B{cur_row}")
        ws[f"A{cur_row}"] = lbl1
        ws[f"A{cur_row}"].font = font_meta_lbl
        ws[f"A{cur_row}"].fill = PatternFill(start_color=ACCENT_BLUE, end_color=ACCENT_BLUE, fill_type="solid")
        ws[f"A{cur_row}"].alignment = Alignment(horizontal="left", vertical="center", indent=1)
        # Col C-H: Val 1
        ws.merge_cells(f"C{cur_row}:H{cur_row}")
        ws[f"C{cur_row}"] = val1
        ws[f"C{cur_row}"].font = font_meta_val
        ws[f"C{cur_row}"].alignment = Alignment(horizontal="left", vertical="center")
        # Col I-K: Label 2
        ws.merge_cells(f"I{cur_row}:K{cur_row}")
        ws[f"I{cur_row}"] = lbl2
        ws[f"I{cur_row}"].font = font_meta_lbl
        ws[f"I{cur_row}"].fill = PatternFill(start_color=ACCENT_BLUE, end_color=ACCENT_BLUE, fill_type="solid")
        ws[f"I{cur_row}"].alignment = Alignment(horizontal="left", vertical="center", indent=1)
        # Col L-Q: Val 2
        ws.merge_cells(f"L{cur_row}:Q{cur_row}")
        ws[f"L{cur_row}"] = val2
        ws[f"L{cur_row}"].font = font_meta_val
        ws[f"L{cur_row}"].alignment = Alignment(horizontal="left", vertical="center")
        cur_row += 1

    # 3. Notes / Markdown Block
    ws.merge_cells(f"A{cur_row}:Q{cur_row}")
    c_note_hdr = ws[f"A{cur_row}"]
    c_note_hdr.value = "📝 CATATAN TEKNIS & ANALISIS SKENARIO (MARKDOWN SUMMARY)"
    c_note_hdr.font = font_section
    c_note_hdr.fill = PatternFill(start_color=HEADER_BLUE, end_color=HEADER_BLUE, fill_type="solid")
    c_note_hdr.alignment = Alignment(horizontal="left", vertical="center", indent=1)
    ws.row_dimensions[cur_row].height = 24
    cur_row += 1

    ws.merge_cells(f"A{cur_row}:Q{cur_row+2}")
    c_note_val = ws[f"A{cur_row}"]
    c_note_val.value = sc["notes"]
    c_note_val.font = font_data
    c_note_val.alignment = Alignment(horizontal="left", vertical="top", wrap_text=True)
    c_note_val.fill = PatternFill(start_color=ZEBRA_FILL, end_color=ZEBRA_FILL, fill_type="solid")
    ws.row_dimensions[cur_row].height = 20
    ws.row_dimensions[cur_row+1].height = 20
    ws.row_dimensions[cur_row+2].height = 20
    cur_row += 3

    # 4. Data Comparison Table
    cur_row += 1
    ws.merge_cells(f"A{cur_row}:Q{cur_row}")
    c_sec2 = ws[f"A{cur_row}"]
    c_sec2.value = "📊 TABEL REKONSILIASI HASIL INSPEKSI: ZQM002 vs ZQM005"
    c_sec2.font = font_section
    c_sec2.fill = PatternFill(start_color=DARK_NAVY, end_color=DARK_NAVY, fill_type="solid")
    c_sec2.alignment = Alignment(horizontal="left", vertical="center", indent=1)
    ws.row_dimensions[cur_row].height = 24
    cur_row += 1

    headers = [
        "No", "MIC ZQM002", "Deskripsi MIC ZQM002", "Stage", "Unit", 
        "Lower Lim.", "Upper Lim.", "Out Lim", "Nilai ZQM002",
        "➔ MATCH ➔", 
        "Lot Sumber (ZQM005)", "Plant / Mat Sumber", "MIC Asli ZQM005",
        "Nilai Lot 1", "Nilai Lot 2", "Rata-Rata (Formula)", "Status Verifikasi"
    ]
    ws.row_dimensions[cur_row].height = 28
    for col_idx, h in enumerate(headers, 1):
        cell = ws.cell(row=cur_row, column=col_idx)
        cell.value = h
        cell.font = font_tbl_header
        cell.fill = PatternFill(start_color=HEADER_BLUE, end_color=HEADER_BLUE, fill_type="solid")
        cell.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
        cell.border = cell_border

    table_start_row = cur_row + 1
    for r_idx, row_data in enumerate(sc["data"]):
        r_num = table_start_row + r_idx
        ws.row_dimensions[r_num].height = 22
        fill_color = ZEBRA_FILL if r_idx % 2 == 1 else WHITE
        fill = PatternFill(start_color=fill_color, end_color=fill_color, fill_type="solid")

        # row_data: (no, mic, desc, stage, uom, low, up, out, val_zqm, lot, plant_mat, mic_005, val1, val2, avg_disp, status)
        (no, mic, desc, stage, uom, low, up, out, val_zqm, lot, plant_mat, mic_005, val1, val2, avg_disp, status) = row_data

        ws.cell(row=r_num, column=1, value=int(no)).alignment = Alignment(horizontal="center", vertical="center")
        ws.cell(row=r_num, column=2, value=mic).font = font_data_bold
        ws.cell(row=r_num, column=3, value=desc).alignment = Alignment(horizontal="left", vertical="center")
        ws.cell(row=r_num, column=4, value=stage).alignment = Alignment(horizontal="center", vertical="center")
        ws.cell(row=r_num, column=5, value=uom).alignment = Alignment(horizontal="center", vertical="center")
        
        c_low = ws.cell(row=r_num, column=6, value=low)
        c_low.number_format = "0.00"
        c_low.alignment = Alignment(horizontal="right", vertical="center")

        c_up = ws.cell(row=r_num, column=7, value=up)
        c_up.number_format = "0.00"
        c_up.alignment = Alignment(horizontal="right", vertical="center")

        ws.cell(row=r_num, column=8, value=out).alignment = Alignment(horizontal="center", vertical="center")
        
        c_val_zqm = ws.cell(row=r_num, column=9, value=val_zqm)
        c_val_zqm.font = font_data_bold
        c_val_zqm.number_format = "0.00"
        c_val_zqm.alignment = Alignment(horizontal="right", vertical="center")

        # Arrow indicator column
        c_arrow = ws.cell(row=r_num, column=10, value="──────➔")
        c_arrow.font = font_arrow
        c_arrow.alignment = Alignment(horizontal="center", vertical="center")

        ws.cell(row=r_num, column=11, value=lot).alignment = Alignment(horizontal="center", vertical="center")
        ws.cell(row=r_num, column=12, value=plant_mat).alignment = Alignment(horizontal="center", vertical="center")
        ws.cell(row=r_num, column=13, value=mic_005).alignment = Alignment(horizontal="center", vertical="center")

        c_val1 = ws.cell(row=r_num, column=14, value=val1)
        c_val1.number_format = "0.00"
        c_val1.alignment = Alignment(horizontal="right", vertical="center")

        c_val2 = ws.cell(row=r_num, column=15, value=val2 if val2 is not None else "-")
        c_val2.alignment = Alignment(horizontal="center" if val2 is None else "right", vertical="center")
        if val2 is not None:
            c_val2.number_format = "0.00"

        # Formula for Average
        c_avg = ws.cell(row=r_num, column=16)
        if val2 is not None:
            c_avg.value = f"=AVERAGE(N{r_num}:O{r_num})"
        else:
            c_avg.value = f"=AVERAGE(N{r_num})"
        c_avg.font = font_data_bold
        c_avg.number_format = "0.00"
        c_avg.alignment = Alignment(horizontal="right", vertical="center")

        # Status
        c_stat = ws.cell(row=r_num, column=17, value=status)
        c_stat.font = font_match
        c_stat.fill = PatternFill(start_color=GREEN_FILL, end_color=GREEN_FILL, fill_type="solid")
        c_stat.alignment = Alignment(horizontal="center", vertical="center")

        # Apply borders and backgrounds
        for c in range(1, 18):
            cell_to_style = ws.cell(row=r_num, column=c)
            cell_to_style.border = cell_border
            if c != 17:
                cell_to_style.fill = fill
                if cell_to_style.font == Font():
                    cell_to_style.font = font_data

    cur_row = table_start_row + len(sc["data"]) + 1

    # 5. Visual Screenshots Section
    ws.merge_cells(f"A{cur_row}:Q{cur_row}")
    c_sec3 = ws[f"A{cur_row}"]
    c_sec3.value = "📷 BUKTI SCREENSHOT RESMI SAP GUI DI SERVER DEVELOPMENT AIX"
    c_sec3.font = font_section
    c_sec3.fill = PatternFill(start_color=DARK_NAVY, end_color=DARK_NAVY, fill_type="solid")
    c_sec3.alignment = Alignment(horizontal="left", vertical="center", indent=1)
    ws.row_dimensions[cur_row].height = 24
    cur_row += 1

    # Subheaders for images
    ws.merge_cells(f"A{cur_row}:H{cur_row}")
    ws[f"A{cur_row}"] = "Layar Seleksi Transaksi ZQM002"
    ws[f"A{cur_row}"].font = font_tbl_header
    ws[f"A{cur_row}"].fill = PatternFill(start_color=HEADER_BLUE, end_color=HEADER_BLUE, fill_type="solid")
    ws[f"A{cur_row}"].alignment = Alignment(horizontal="center", vertical="center")

    ws.merge_cells(f"J{cur_row}:Q{cur_row}")
    ws[f"J{cur_row}"] = "Layar Hasil ALV Transaksi ZQM002 (Print COA)"
    ws[f"J{cur_row}"].font = font_tbl_header
    ws[f"J{cur_row}"].fill = PatternFill(start_color=HEADER_BLUE, end_color=HEADER_BLUE, fill_type="solid")
    ws[f"J{cur_row}"].alignment = Alignment(horizontal="center", vertical="center")
    ws.row_dimensions[cur_row].height = 20
    cur_row += 1

    # Insert images
    img1_res = resize_image_for_excel(sc["zqm002_sel"], f"/data/Projects/SAP/ABAP/subproject/COA/outputs/temp_img_{sc['do_num']}_1.png", max_w=580)
    if img1_res:
        img_obj1 = OpenpyxlImage(img1_res)
        ws.add_image(img_obj1, f"A{cur_row}")

    img2_res = resize_image_for_excel(sc["zqm002_alv"], f"/data/Projects/SAP/ABAP/subproject/COA/outputs/temp_img_{sc['do_num']}_2.png", max_w=580)
    if img2_res:
        img_obj2 = OpenpyxlImage(img2_res)
        ws.add_image(img_obj2, f"J{cur_row}")

    cur_row += 22

    # Second row of images (ZQM005)
    ws.merge_cells(f"A{cur_row}:H{cur_row}")
    ws[f"A{cur_row}"] = "Layar Seleksi Transaksi ZQM005"
    ws[f"A{cur_row}"].font = font_tbl_header
    ws[f"A{cur_row}"].fill = PatternFill(start_color=HEADER_BLUE, end_color=HEADER_BLUE, fill_type="solid")
    ws[f"A{cur_row}"].alignment = Alignment(horizontal="center", vertical="center")

    ws.merge_cells(f"J{cur_row}:Q{cur_row}")
    ws[f"J{cur_row}"] = "Layar Hasil Transaksi ZQM005 (Lot Inspeksi & Nilai Rata-Rata)"
    ws[f"J{cur_row}"].font = font_tbl_header
    ws[f"J{cur_row}"].fill = PatternFill(start_color=HEADER_BLUE, end_color=HEADER_BLUE, fill_type="solid")
    ws[f"J{cur_row}"].alignment = Alignment(horizontal="center", vertical="center")
    ws.row_dimensions[cur_row].height = 20
    cur_row += 1

    img3_res = resize_image_for_excel(sc["zqm005_sel"], f"/data/Projects/SAP/ABAP/subproject/COA/outputs/temp_img_{sc['do_num']}_3.png", max_w=580)
    if img3_res:
        img_obj3 = OpenpyxlImage(img3_res)
        ws.add_image(img_obj3, f"A{cur_row}")

    img4_res = resize_image_for_excel(sc["zqm005_res"], f"/data/Projects/SAP/ABAP/subproject/COA/outputs/temp_img_{sc['do_num']}_4.png", max_w=580)
    if img4_res:
        img_obj4 = OpenpyxlImage(img4_res)
        ws.add_image(img_obj4, f"J{cur_row}")

    cur_row += 22

    # If scenario 21 has second inspection lot result (Lot TTA result)
    if sc.get("lot_res2"):
        ws.merge_cells(f"A{cur_row}:Q{cur_row}")
        ws[f"A{cur_row}"] = "Layar Hasil ZQM005 Lot JR TTA 040000015885 (Sumber Nilai Base Film Converting)"
        ws[f"A{cur_row}"].font = font_tbl_header
        ws[f"A{cur_row}"].fill = PatternFill(start_color=HEADER_BLUE, end_color=HEADER_BLUE, fill_type="solid")
        ws[f"A{cur_row}"].alignment = Alignment(horizontal="center", vertical="center")
        ws.row_dimensions[cur_row].height = 20
        cur_row += 1

        img5_res = resize_image_for_excel(sc["lot_res2"], f"/data/Projects/SAP/ABAP/subproject/COA/outputs/temp_img_{sc['do_num']}_5.png", max_w=750)
        if img5_res:
            img_obj5 = OpenpyxlImage(img5_res)
            ws.add_image(img_obj5, f"C{cur_row}")

    # Set Column Widths
    col_widths = {
        1: 5,   # No
        2: 14,  # MIC ZQM002
        3: 30,  # Deskripsi MIC
        4: 15,  # Stage
        5: 10,  # Unit
        6: 12,  # Lower Lim
        7: 12,  # Upper Lim
        8: 9,   # Out Lim
        9: 14,  # Nilai ZQM002
        10: 14, # Arrow
        11: 18, # Lot Sumber
        12: 18, # Plant / Mat
        13: 16, # MIC Asli 005
        14: 14, # Val 1
        15: 14, # Val 2
        16: 18, # Rata2 Formula
        17: 24  # Status
    }
    for col_idx, width in col_widths.items():
        col_letter = get_column_letter(col_idx)
        ws.column_dimensions[col_letter].width = width

out_excel = "/data/Projects/SAP/ABAP/subproject/COA/outputs/TESTING_COA_TTA_DEV_AIX.xlsx"
wb.save(out_excel)
print(f"Excel workbook successfully created at: {out_excel}")
