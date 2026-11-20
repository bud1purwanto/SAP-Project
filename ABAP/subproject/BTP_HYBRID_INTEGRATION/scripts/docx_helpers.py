import os
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

# Palette
COLOR_NAVY = RGBColor(15, 23, 42)        # Slate 900
COLOR_BLUE = RGBColor(30, 58, 138)       # Blue 900
COLOR_ACCENT = RGBColor(37, 99, 235)     # Blue 600
COLOR_BODY = RGBColor(51, 65, 85)        # Slate 700
COLOR_MUTED = RGBColor(100, 116, 139)    # Slate 500
COLOR_SUCCESS = RGBColor(5, 150, 105)    # Emerald 600
COLOR_WARNING = RGBColor(217, 119, 6)    # Amber 600
COLOR_DANGER = RGBColor(220, 38, 38)     # Red 600

def set_cell_background(cell, hex_color):
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{hex_color}"/>')
    cell._tc.get_or_add_tcPr().append(shd)

def set_cell_left_border(cell, hex_color, sz="36"):
    tcPr = cell._tc.get_or_add_tcPr()
    tcBorders = parse_xml(f'''
        <w:tcBorders {nsdecls("w")}>
            <w:top w:val="none"/>
            <w:left w:val="single" w:sz="{sz}" w:space="0" w:color="{hex_color}"/>
            <w:bottom w:val="none"/>
            <w:right w:val="none"/>
        </w:tcBorders>
    ''')
    tcPr.append(tcBorders)

def set_cell_margins(cell, top=140, bottom=140, left=200, right=200):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(f'''
        <w:tcMar {nsdecls("w")}>
            <w:top w:w="{top}" w:type="dxa"/>
            <w:bottom w:w="{bottom}" w:type="dxa"/>
            <w:left w:w="{left}" w:type="dxa"/>
            <w:right w:w="{right}" w:type="dxa"/>
        </w:tcMar>
    ''')
    tcPr.append(tcMar)

def add_heading_1(doc, text, page_break_before=False):
    if page_break_before:
        doc.add_page_break()
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(16)
    p.paragraph_format.space_after = Pt(8)
    p.paragraph_format.keep_with_next = True
    run = p.add_run(text)
    run.font.name = "Calibri"
    run.font.size = Pt(18)
    run.font.bold = True
    run.font.color.rgb = COLOR_BLUE
    return p

def add_heading_2(doc, text):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(12)
    p.paragraph_format.space_after = Pt(6)
    p.paragraph_format.keep_with_next = True
    run = p.add_run(text)
    run.font.name = "Calibri"
    run.font.size = Pt(14)
    run.font.bold = True
    run.font.color.rgb = COLOR_ACCENT
    return p

def add_heading_3(doc, text):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(8)
    p.paragraph_format.space_after = Pt(4)
    p.paragraph_format.keep_with_next = True
    run = p.add_run(text)
    run.font.name = "Calibri"
    run.font.size = Pt(11.5)
    run.font.bold = True
    run.font.color.rgb = COLOR_NAVY
    return p

def add_p(doc, text="", bold_prefix="", italic=False):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(4)
    p.paragraph_format.line_spacing = 1.15
    if bold_prefix:
        r_pre = p.add_run(bold_prefix)
        r_pre.font.name = "Calibri"
        r_pre.font.size = Pt(10.5)
        r_pre.font.bold = True
        r_pre.font.color.rgb = COLOR_NAVY
    if text:
        r_text = p.add_run(text)
        r_text.font.name = "Calibri"
        r_text.font.size = Pt(10.5)
        r_text.font.italic = italic
        r_text.font.color.rgb = COLOR_BODY
    return p

def add_bullet(doc, text, bold_prefix=""):
    p = doc.add_paragraph(style='List Bullet')
    p.paragraph_format.space_after = Pt(3)
    p.paragraph_format.line_spacing = 1.15
    if bold_prefix:
        r_pre = p.add_run(bold_prefix)
        r_pre.font.name = "Calibri"
        r_pre.font.size = Pt(10)
        r_pre.font.bold = True
        r_pre.font.color.rgb = COLOR_NAVY
    r_text = p.add_run(text)
    r_text.font.name = "Calibri"
    r_text.font.size = Pt(10)
    r_text.font.color.rgb = COLOR_BODY
    return p

def add_callout(doc, text, title="", kind="tip"):
    table = doc.add_table(rows=1, cols=1)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False
    
    cell = table.cell(0, 0)
    cell.width = Inches(6.5)
    
    colors = {
        "tip": ("EFF6FF", "2563EB", "💡 TIP PENTING"),
        "warning": ("FEF3C7", "D97706", "⚠️ PERHATIAN / PERINGATAN"),
        "success": ("ECFDF5", "059669", "✅ STATUS SUKSES / TERVERIFIKASI"),
        "danger": ("FEF2F2", "DC2626", "🛑 MASALAH / ERROR DITEMUKAN")
    }
    bg_hex, border_hex, default_title = colors.get(kind, colors["tip"])
    
    set_cell_background(cell, bg_hex)
    set_cell_left_border(cell, border_hex, sz="36")
    set_cell_margins(cell, top=140, bottom=140, left=200, right=200)
    
    cp = cell.paragraphs[0]
    cp.paragraph_format.space_after = Pt(2)
    display_title = title if title else default_title
    trun = cp.add_run(display_title + "\n")
    trun.font.name = "Calibri"
    trun.font.size = Pt(10.5)
    trun.font.bold = True
    
    mrun = cp.add_run(text)
    mrun.font.name = "Calibri"
    mrun.font.size = Pt(9.5)
    mrun.font.color.rgb = COLOR_BODY
    
    # spacing after callout
    p_after = doc.add_paragraph()
    p_after.paragraph_format.space_before = Pt(0)
    p_after.paragraph_format.space_after = Pt(4)

def add_styled_table(doc, headers, data, col_widths=None):
    table = doc.add_table(rows=len(data) + 1, cols=len(headers))
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False
    
    # Header Row
    hdr_cells = table.rows[0].cells
    for i, h in enumerate(headers):
        hdr_cells[i].text = h
        set_cell_background(hdr_cells[i], "1E3A8A") # Navy Blue
        set_cell_margins(hdr_cells[i], top=120, bottom=120, left=150, right=150)
        p = hdr_cells[i].paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.LEFT
        for r in p.runs:
            r.font.name = "Calibri"
            r.font.size = Pt(9.5)
            r.font.bold = True
            r.font.color.rgb = RGBColor(255, 255, 255)
            
    # Data Rows
    for row_idx, row_data in enumerate(data):
        row_cells = table.rows[row_idx + 1].cells
        bg_hex = "F8FAFC" if row_idx % 2 == 1 else "FFFFFF"
        for col_idx, cell_value in enumerate(row_data):
            row_cells[col_idx].text = str(cell_value)
            set_cell_background(row_cells[col_idx], bg_hex)
            set_cell_margins(row_cells[col_idx], top=100, bottom=100, left=150, right=150)
            p = row_cells[col_idx].paragraphs[0]
            p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            for r in p.runs:
                r.font.name = "Calibri"
                r.font.size = Pt(9)
                r.font.color.rgb = COLOR_BODY
                
    # Column widths
    if col_widths:
        for r in table.rows:
            for idx, w in enumerate(col_widths):
                r.cells[idx].width = Inches(w)
                
    p_after = doc.add_paragraph()
    p_after.paragraph_format.space_after = Pt(4)

def add_annotated_image(doc, img_name, fig_number, caption, annotations_list):
    """
    img_name: file in attachments/annotated/
    fig_number: e.g. "Gambar 4.1"
    caption: e.g. "Pemetaan Virtual Host dan Accessible Resources di Cloud Connector"
    annotations_list: list of tuples: (badge_number_str, bold_label, explanation_str)
    """
    img_path = f"/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/annotated/{img_name}"
    if not os.path.exists(img_path):
        # fallback to non-annotated
        img_path = f"/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/{img_name}"
        
    p_img = doc.add_paragraph()
    p_img.paragraph_format.space_before = Pt(8)
    p_img.paragraph_format.space_after = Pt(4)
    p_img.paragraph_format.keep_with_next = True
    p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
    
    if os.path.exists(img_path):
        run = p_img.add_run()
        run.add_picture(img_path, width=Inches(6.2))
    else:
        p_img.add_run(f"[File Gambar {img_name} Tidak Ditemukan]").font.italic = True
        
    # Caption
    p_cap = doc.add_paragraph()
    p_cap.paragraph_format.space_after = Pt(6)
    p_cap.paragraph_format.keep_with_next = True
    p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r_cap_lbl = p_cap.add_run(f"{fig_number}: ")
    r_cap_lbl.font.name = "Calibri"
    r_cap_lbl.font.size = Pt(9.5)
    r_cap_lbl.font.bold = True
    r_cap_lbl.font.color.rgb = COLOR_NAVY
    
    r_cap_txt = p_cap.add_run(caption)
    r_cap_txt.font.name = "Calibri"
    r_cap_txt.font.size = Pt(9.5)
    r_cap_txt.font.italic = True
    r_cap_txt.font.color.rgb = COLOR_MUTED
    
    # Annotations list
    if annotations_list:
        p_note = doc.add_paragraph()
        p_note.paragraph_format.space_after = Pt(2)
        r_nhdr = p_note.add_run("Keterangan Kotak & Panah Anotasi:")
        r_nhdr.font.name = "Calibri"
        r_nhdr.font.size = Pt(9.5)
        r_nhdr.font.bold = True
        r_nhdr.font.color.rgb = COLOR_NAVY
        
        for badge_num, bold_lbl, desc in annotations_list:
            p_item = doc.add_paragraph(style='List Bullet')
            p_item.paragraph_format.space_after = Pt(2)
            p_item.paragraph_format.line_spacing = 1.15
            
            rbadge = p_item.add_run(f"[{badge_num}] ")
            rbadge.font.name = "Calibri"
            rbadge.font.size = Pt(9.5)
            rbadge.font.bold = True
            rbadge.font.color.rgb = COLOR_DANGER
            
            rlbl = p_item.add_run(f"{bold_lbl}: ")
            rlbl.font.name = "Calibri"
            rlbl.font.size = Pt(9.5)
            rlbl.font.bold = True
            rlbl.font.color.rgb = COLOR_NAVY
            
            rdesc = p_item.add_run(desc)
            rdesc.font.name = "Calibri"
            rdesc.font.size = Pt(9)
            rdesc.font.color.rgb = COLOR_BODY
            
    p_space = doc.add_paragraph()
    p_space.paragraph_format.space_after = Pt(6)

def add_code_block(doc, code_text):
    table = doc.add_table(rows=1, cols=1)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False
    
    cell = table.cell(0, 0)
    cell.width = Inches(6.5)
    set_cell_background(cell, "F1F5F9") # Slate 100
    set_cell_margins(cell, top=100, bottom=100, left=150, right=150)
    
    p = cell.paragraphs[0]
    p.paragraph_format.space_after = Pt(0)
    p.paragraph_format.line_spacing = 1.05
    run = p.add_run(code_text)
    run.font.name = "Consolas"
    run.font.size = Pt(8.5)
    run.font.color.rgb = RGBColor(30, 41, 59)
    
    p_after = doc.add_paragraph()
    p_after.paragraph_format.space_after = Pt(4)

print("Docx helpers written successfully.")
