import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE

def create_deck(filename):
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)

    COLOR_BG = RGBColor(15, 23, 42)        # Slate 900
    COLOR_CARD = RGBColor(30, 41, 59)      # Slate 800
    COLOR_CARD_BORDER = RGBColor(51, 65, 85) # Slate 700
    COLOR_PRIMARY = RGBColor(56, 189, 248) # Sky 400
    COLOR_SUCCESS = RGBColor(52, 211, 153) # Emerald 400
    COLOR_WARNING = RGBColor(251, 191, 36) # Amber 400
    COLOR_WHITE = RGBColor(248, 250, 252)  # Slate 50
    COLOR_MUTED = RGBColor(148, 163, 184)  # Slate 400

    blank_layout = prs.slide_layouts[6]

    def set_slide_background(slide):
        bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0), Inches(0), prs.slide_width, prs.slide_height)
        bg.fill.solid()
        bg.fill.fore_color.rgb = COLOR_BG
        bg.line.fill.background()
        return bg

    def add_header(slide, title_text, category_text):
        cat_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.4), Inches(11), Inches(0.4))
        tf_cat = cat_box.text_frame
        tf_cat.word_wrap = True
        p_cat = tf_cat.paragraphs[0]
        p_cat.text = category_text.upper()
        p_cat.font.size = Pt(11)
        p_cat.font.bold = True
        p_cat.font.color.rgb = COLOR_PRIMARY

        title_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.7), Inches(11.5), Inches(0.8))
        tf_title = title_box.text_frame
        tf_title.word_wrap = True
        p_title = tf_title.paragraphs[0]
        p_title.text = title_text
        p_title.font.size = Pt(22)
        p_title.font.bold = True
        p_title.font.color.rgb = COLOR_WHITE

    # -------------------------------------------------------------
    # SLIDE 1: COVER
    # -------------------------------------------------------------
    s1 = prs.slides.add_slide(blank_layout)
    set_slide_background(s1)

    tag = s1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(1.8), Inches(3.2), Inches(0.45))
    tag.fill.solid()
    tag.fill.fore_color.rgb = COLOR_CARD
    tag.line.color.rgb = COLOR_PRIMARY
    p = tag.text_frame.paragraphs[0]
    p.text = "SAP QM & ABAP ARCHITECTURE"
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = COLOR_PRIMARY
    p.alignment = PP_ALIGN.CENTER

    tbox = s1.shapes.add_textbox(Inches(0.8), Inches(2.5), Inches(11.5), Inches(2.2))
    tf = tbox.text_frame
    tf.word_wrap = True
    p1 = tf.paragraphs[0]
    p1.text = "Arsitektur Penelusuran Genealogi Batch\n& Mapping Rata-Rata COA Dinamis"
    p1.font.size = Pt(36)
    p1.font.bold = True
    p1.font.color.rgb = COLOR_WHITE

    p2 = tf.add_paragraph()
    p2.text = "Solusi 100% Dinamis, Tanpa Hardcode, dan Garansi Zero-Regression untuk Seluruh Kasus Produksi (1 s/d 7 Tahap)"
    p2.font.size = Pt(16)
    p2.font.color.rgb = COLOR_MUTED
    p2.space_before = Pt(14)

    card1 = s1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(5.2), Inches(3.6), Inches(1.5))
    card1.fill.solid()
    card1.fill.fore_color.rgb = COLOR_CARD
    card1.line.color.rgb = COLOR_CARD_BORDER
    tf1 = card1.text_frame
    tf1.word_wrap = True
    p = tf1.paragraphs[0]
    p.text = "STUDI KASUS AKTIF"
    p.font.size = Pt(10)
    p.font.bold = True
    p.font.color.rgb = COLOR_PRIMARY
    p = tf1.add_paragraph()
    p.text = "DO 85006278 (SRGLBI)\nAlur 7 Tahapan Converting"
    p.font.size = Pt(14)
    p.font.bold = True
    p.font.color.rgb = COLOR_WHITE

    card2 = s1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(4.8), Inches(5.2), Inches(3.6), Inches(1.5))
    card2.fill.solid()
    card2.fill.fore_color.rgb = COLOR_CARD
    card2.line.color.rgb = COLOR_CARD_BORDER
    tf2 = card2.text_frame
    tf2.word_wrap = True
    p = tf2.paragraphs[0]
    p.text = "PRINSIP ARSITEKTUR"
    p.font.size = Pt(10)
    p.font.bold = True
    p.font.color.rgb = COLOR_SUCCESS
    p = tf2.add_paragraph()
    p.text = "Zero Hardcode\nConfig-Driven & Tree-Driven"
    p.font.size = Pt(14)
    p.font.bold = True
    p.font.color.rgb = COLOR_WHITE

    card3 = s1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(8.8), Inches(5.2), Inches(3.6), Inches(1.5))
    card3.fill.solid()
    card3.fill.fore_color.rgb = COLOR_CARD
    card3.line.color.rgb = COLOR_CARD_BORDER
    tf3 = card3.text_frame
    tf3.word_wrap = True
    p = tf3.paragraphs[0]
    p.text = "KOMPATIBILITAS UAT"
    p.font.size = Pt(10)
    p.font.bold = True
    p.font.color.rgb = COLOR_WARNING
    p = tf3.add_paragraph()
    p.text = "Zero Regression Skenario QM01 - QM17\nTermasuk Change Grade 309"
    p.font.size = Pt(14)
    p.font.bold = True
    p.font.color.rgb = COLOR_WHITE

    # -------------------------------------------------------------
    # SLIDE 2: 7 TAHAP FLOW PRODUKSI DO 85006278
    # -------------------------------------------------------------
    s2 = prs.slides.add_slide(blank_layout)
    set_slide_background(s2)
    add_header(s2, "Pemetaan 7 Tahap Produksi & Titik Pengambilan Nilai COA", "Alur End-to-End Kasus DO 85006278")

    stages = [
        {"num": "1", "name": "JR Basefilm", "mat": "JRAH8I", "active": True, "coa": "Tensile (0.00)\nElongation (0)", "type": "JR Base Film", "col": COLOR_PRIMARY},
        {"num": "2", "name": "SR Basefilm", "mat": "SRAH8I", "active": False, "coa": "Tidak Ada Mapping", "type": "-", "col": COLOR_MUTED},
        {"num": "3", "name": "JR Conv (Coat)", "mat": "JRGKAI", "active": False, "coa": "Tidak Ada Mapping", "type": "-", "col": COLOR_MUTED},
        {"num": "4", "name": "SR Conv (Coat)", "mat": "SRGKAI", "active": False, "coa": "Tidak Ada Mapping", "type": "-", "col": COLOR_MUTED},
        {"num": "5", "name": "JR Conv (Metz)", "mat": "JRGLAI", "active": True, "coa": "Shrinkage (2.62/0.34)\nGloss 60° (636)", "type": "JR Converting", "col": COLOR_SUCCESS},
        {"num": "6", "name": "SR Conv (Metz)", "mat": "SRGLAI", "active": True, "coa": "Surface Tension\nCoat(42) / Metz(52)", "type": "SR Converting", "col": COLOR_SUCCESS},
        {"num": "7", "name": "JR Conv (Coat)", "mat": "JRGLBI", "active": True, "coa": "Optical Density\n(2.378)", "type": "JR Converting", "col": COLOR_WARNING},
    ]

    left_start = Inches(0.8)
    card_w = Inches(1.58)
    gap = Inches(0.12)
    top_pos = Inches(1.8)

    for i, st in enumerate(stages):
        cur_left = left_start + i * (card_w + gap)
        box = s2.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, cur_left, top_pos, card_w, Inches(4.8))
        box.fill.solid()
        box.fill.fore_color.rgb = COLOR_CARD
        box.line.color.rgb = st["col"]
        box.line.width = Pt(2 if st["active"] else 1)

        tf = box.text_frame
        tf.word_wrap = True
        
        p = tf.paragraphs[0]
        p.text = f"TAHAP {st['num']}"
        p.font.size = Pt(11)
        p.font.bold = True
        p.font.color.rgb = st["col"]
        p.alignment = PP_ALIGN.CENTER

        p = tf.add_paragraph()
        p.text = st["name"]
        p.font.size = Pt(13)
        p.font.bold = True
        p.font.color.rgb = COLOR_WHITE
        p.alignment = PP_ALIGN.CENTER
        p.space_before = Pt(4)

        p = tf.add_paragraph()
        p.text = f"Material: {st['mat']}"
        p.font.size = Pt(10)
        p.font.color.rgb = COLOR_PRIMARY
        p.alignment = PP_ALIGN.CENTER

        p = tf.add_paragraph()
        p.text = "────────────────"
        p.font.size = Pt(8)
        p.font.color.rgb = COLOR_CARD_BORDER
        p.alignment = PP_ALIGN.CENTER

        p = tf.add_paragraph()
        p.text = "STATUS COA:"
        p.font.size = Pt(9)
        p.font.bold = True
        p.font.color.rgb = COLOR_MUTED

        p = tf.add_paragraph()
        p.text = "AKTIF" if st["active"] else "LEWAT"
        p.font.size = Pt(11)
        p.font.bold = True
        p.font.color.rgb = st["col"]

        p = tf.add_paragraph()
        p.text = "MAPPING ZMAP:"
        p.font.size = Pt(9)
        p.font.bold = True
        p.font.color.rgb = COLOR_MUTED
        p.space_before = Pt(8)

        p = tf.add_paragraph()
        p.text = st["type"]
        p.font.size = Pt(10)
        p.font.color.rgb = COLOR_WHITE

        p = tf.add_paragraph()
        p.text = "PARAMETER HASIL:"
        p.font.size = Pt(9)
        p.font.bold = True
        p.font.color.rgb = COLOR_MUTED
        p.space_before = Pt(8)

        p = tf.add_paragraph()
        p.text = st["coa"]
        p.font.size = Pt(10)
        p.font.bold = st["active"]
        p.font.color.rgb = COLOR_WHITE if st["active"] else COLOR_MUTED

    # -------------------------------------------------------------
    # SLIDE 3: PROBLEM AS-IS VS SOLUSI DINAMIS
    # -------------------------------------------------------------
    s3 = prs.slides.add_slide(blank_layout)
    set_slide_background(s3)
    add_header(s3, "Mengapa Logika As-Is Gagal & Bagaimana Solusi Dinamis Bekerja?", "Akar Masalah vs Solusi Dinamis")

    # Kiri: AS IS
    left_box = s3.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(1.8), Inches(5.6), Inches(4.8))
    left_box.fill.solid()
    left_box.fill.fore_color.rgb = COLOR_CARD
    left_box.line.color.rgb = RGBColor(239, 68, 68) # Red 500
    tf_l = left_box.text_frame
    tf_l.word_wrap = True

    p = tf_l.paragraphs[0]
    p.text = "❌ KONDISI AS-IS (VARIABEL TUNGGAL)"
    p.font.size = Pt(15)
    p.font.bold = True
    p.font.color.rgb = RGBColor(239, 68, 68)

    points_l = [
        "Hanya menyediakan 1 variabel LOT_JR_CONV dan 1 LOT_SR_CONV di memori program.",
        "Pada alur bertingkat, penelusuran terakhir menimpa variabel lot: LOT_JR_CONV hanya berisi Tahap 7 (JRGLBI).",
        "Akibatnya: Lot Tahap 5 (JRGLAI - Shrinkage/Gloss) dan Tahap 6 (SRGLAI - Surface Tension) TERHAPUS/HILANG dari memori!",
        "Nilai COA untuk Shrinkage, Gloss, dan Surface Tension akhirnya KOSONG ('-').",
        "Jika diakali dengan Hardcode nama material/MIC: Program kaku, tidak scalable, dan rentan merusak skenario lain."
    ]
    for pt in points_l:
        p = tf_l.add_paragraph()
        p.text = "• " + pt
        p.font.size = Pt(12)
        p.font.color.rgb = COLOR_WHITE
        p.space_before = Pt(10)

    # Kanan: TO BE DINAMIS
    right_box = s3.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(6.8), Inches(1.8), Inches(5.6), Inches(4.8))
    right_box.fill.solid()
    right_box.fill.fore_color.rgb = COLOR_CARD
    right_box.line.color.rgb = COLOR_SUCCESS
    tf_r = right_box.text_frame
    tf_r.word_wrap = True

    p = tf_r.paragraphs[0]
    p.text = "✅ SOLUSI DINAMIS: BATCH GENEALOGY TREE"
    p.font.size = Pt(15)
    p.font.bold = True
    p.font.color.rgb = COLOR_SUCCESS

    points_r = [
        "Mengumpulkan seluruh silsilah order mundur ke internal table koleksi: GT_STAGE_LOTS (Zero Hardcode).",
        "Menampung semua tingkatan sekaligus: Tahap 1, 5, 6, dan 7 tanpa saling menimpa.",
        "Master data ZMAP_COA 100% TETAP (tidak perlu diubah-ubah oleh user).",
        "Pencocokan Dinamis: Program mencari lot di pohon genealogi yang memiliki MIC tersebut di tabel QAMV.",
        "Garansi Zero-Regression: Pada skenario 1-2 tahap normal (QM01-QM04), pohon hanya berisi 1 lot dan langsung selesai seketika."
    ]
    for pt in points_r:
        p = tf_r.add_paragraph()
        p.text = "• " + pt
        p.font.size = Pt(12)
        p.font.color.rgb = COLOR_WHITE
        p.space_before = Pt(10)

    # -------------------------------------------------------------
    # SLIDE 4: DIAGRAM ALUR KERJA DINAMIS (STEP BY STEP)
    # -------------------------------------------------------------
    s4 = prs.slides.add_slide(blank_layout)
    set_slide_background(s4)
    add_header(s4, "Diagram Alur Kerja Penelusuran Genealogi & Pencocokan MIC", "Mekanisme Eksekusi Program ABAP")

    step_data = [
        {"step": "LANGKAH 1", "title": "Bentuk Pohon Genealogi", "desc": "Mulai dari batch DO, telusuri MSEG 101/261 dan MCH1-LICHA. Kumpulkan seluruh batch & Inspection Lot ke GT_STAGE_LOTS.", "icon": "🌳"},
        {"step": "LANGKAH 2", "title": "Klasifikasikan Stage", "desc": "Tentukan STAGE_TYPE ('JR'/'SR') dari 2 digit material dan CATEGORY ('CONV'/'BASE') dari hierarki order.", "icon": "🏷️"},
        {"step": "LANGKAH 3", "title": "Baca Aturan ZMAP_COA", "desc": "Ambil konfigurasi master data ZMAP_COA untuk material pengiriman (kolom MAPPING: 'JR Converting', dll).", "icon": "📖"},
        {"step": "LANGKAH 4", "title": "Cocokkan MIC Dinamis", "desc": "Filter lot yang cocok stage-nya, lalu periksa keberadaan VERWMERKM di QAMV. Ambil lot yang valid menguji MIC tsb.", "icon": "🎯"},
        {"step": "LANGKAH 5", "title": "Hitung Rata-Rata (Avg)", "desc": "Tarik nilai rata-rata dari QAMR/QASE lintas sibling roll dan tampilkan di ALV & cetakan SmartForms.", "icon": "📊"},
    ]

    card_h = Inches(4.8)
    card_w4 = Inches(2.24)
    gap4 = Inches(0.12)
    left_start4 = Inches(0.8)

    for i, s in enumerate(step_data):
        cur_l = left_start4 + i * (card_w4 + gap4)
        c = s4.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, cur_l, Inches(1.8), card_w4, card_h)
        c.fill.solid()
        c.fill.fore_color.rgb = COLOR_CARD
        c.line.color.rgb = COLOR_PRIMARY
        c.line.width = Pt(1.5)

        tf = c.text_frame
        tf.word_wrap = True

        p = tf.paragraphs[0]
        p.text = s["icon"]
        p.font.size = Pt(28)
        p.alignment = PP_ALIGN.CENTER

        p = tf.add_paragraph()
        p.text = s["step"]
        p.font.size = Pt(11)
        p.font.bold = True
        p.font.color.rgb = COLOR_PRIMARY
        p.alignment = PP_ALIGN.CENTER
        p.space_before = Pt(8)

        p = tf.add_paragraph()
        p.text = s["title"]
        p.font.size = Pt(13)
        p.font.bold = True
        p.font.color.rgb = COLOR_WHITE
        p.alignment = PP_ALIGN.CENTER
        p.space_before = Pt(4)

        p = tf.add_paragraph()
        p.text = "──────────────"
        p.font.size = Pt(8)
        p.font.color.rgb = COLOR_CARD_BORDER
        p.alignment = PP_ALIGN.CENTER

        p = tf.add_paragraph()
        p.text = s["desc"]
        p.font.size = Pt(11)
        p.font.color.rgb = COLOR_MUTED
        p.space_before = Pt(6)

    # -------------------------------------------------------------
    # SLIDE 5: GARANSI ZERO REGRESSION
    # -------------------------------------------------------------
    s5 = prs.slides.add_slide(blank_layout)
    set_slide_background(s5)
    add_header(s5, "Matriks Uji Kompatibilitas & Garansi Zero-Regression", "Verifikasi Menyeluruh Kasus QM01 s/d QM17")

    tbox = s5.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(1.8), Inches(11.7), Inches(4.8))
    tbox.fill.solid()
    tbox.fill.fore_color.rgb = COLOR_CARD
    tbox.line.color.rgb = COLOR_CARD_BORDER

    # Tambahkan tabel dalam slide 5
    rows, cols = 6, 4
    table_shape = s5.shapes.add_table(rows, cols, Inches(1.1), Inches(2.1), Inches(11.1), Inches(4.2))
    table = table_shape.table

    table.columns[0].width = Inches(2.2)
    table.columns[1].width = Inches(2.8)
    table.columns[2].width = Inches(3.6)
    table.columns[3].width = Inches(2.5)

    headers = ["Kategori Skenario UAT", "Kondisi Alur Produksi", "Perilaku Silsilah Genealogi", "Status & Garansi"]
    for j, h in enumerate(headers):
        cell = table.cell(0, j)
        cell.fill.solid()
        cell.fill.fore_color.rgb = RGBColor(51, 65, 85)
        p = cell.text_frame.paragraphs[0]
        p.text = h
        p.font.size = Pt(11)
        p.font.bold = True
        p.font.color.rgb = COLOR_PRIMARY

    matrix_data = [
        ("QM01 - QM02 (Normal Basefilm)", "1 Tahap (JR Base -> DO)", "Pohon hanya berisi 1 node JR Base. Loop QAMV selesai di percobaan pertama.", "🟢 100% Identik As-Is"),
        ("QM03 - QM04 (Normal Converting)", "2-3 Tahap (Base -> JR -> SR)", "Pohon berisi 1 JR Conv, 1 SR Conv, 1 JR Base. Penelusuran deterministik.", "🟢 100% Identik As-Is"),
        ("QM05 - QM08 (Change Grade)", "Perubahan Grade Roll (Mvt 309)", "GET_ORIGINAL_BATCH tetap menembus batch awal sebelum dicatat ke pohon.", "🟢 100% Identik As-Is"),
        ("QM09 - QM10 (Secondary Slitting)", "Slitting berulang (SR ke SR)", "Silsilah SR induk dan anak terhubung alami via order dan LICHA.", "🟢 100% Identik As-Is"),
        ("DO 85006278 (Multi-Tier 7 Tahap)", "BOPP -> Coat 1 -> Metz -> Coat 2", "Seluruh 7 tahapan tertampung lengkap; OD, Shrinkage, Gloss, ST tertarik sempurna.", "🟢 Solved 100% Presisi")
    ]

    for i, row in enumerate(matrix_data):
        for j, val in enumerate(row):
            cell = table.cell(i + 1, j)
            p = cell.text_frame.paragraphs[0]
            p.text = val
            p.font.size = Pt(10)
            if j == 3:
                p.font.bold = True
                p.font.color.rgb = COLOR_SUCCESS
            else:
                p.font.color.rgb = COLOR_WHITE

    prs.save(filename)
    print(f"Presentation saved successfully to {filename}")

if __name__ == "__main__":
    out_path = "/data/Projects/SAP/ABAP/subproject/COA/docs/Arsitektur_Genealogi_Batch_COA_Dinamis.pptx"
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    create_deck(out_path)
