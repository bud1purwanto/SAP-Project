import copy, re, sys
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from lxml import etree

SRC, OUT = sys.argv[1], sys.argv[2]
A = '{http://schemas.openxmlformats.org/drawingml/2006/main}'
P = '{http://schemas.openxmlformats.org/presentationml/2006/main}'
R = '{http://schemas.openxmlformats.org/officeDocument/2006/relationships}'

BLUE = RGBColor(0x00, 0x8F, 0xD3)
NAVY = RGBColor(0x00, 0x47, 0x6A)
GOLD = RGBColor(0xF0, 0xAB, 0x00)
LBLUE = RGBColor(0xDD, 0xEF, 0xF8)
YEL = RGBColor(0xFF, 0xF2, 0xB3)
GREY = RGBColor(0x59, 0x59, 0x59)
WHITE = RGBColor(0xFF, 0xFF, 0xFF)
BLACK = RGBColor(0, 0, 0)

prs = Presentation(SRC)
orig = list(prs.slides)              # orig[n-1] = original slide n
S = lambda n: orig[n - 1]

# ---------------------------------------------------------------- helpers
def text_frames(shapes):
    for sh in shapes:
        if sh.shape_type == 6:  # group
            yield from text_frames(sh.shapes)
        elif sh.has_text_frame:
            yield sh.text_frame
        elif getattr(sh, 'has_table', False) and sh.has_table:
            for row in sh.table.rows:
                for c in row.cells:
                    yield c.text_frame

def replace_in_tf(tf, old, new):
    hit = False
    for p in tf.paragraphs:
        runs = p.runs
        done = False
        for r in runs:
            if old in r.text:
                r.text = r.text.replace(old, new); done = hit = True
        if not done and runs:
            full = ''.join(r.text for r in runs)
            if old in full:
                runs[0].text = full.replace(old, new)
                for r in runs[1:]:
                    r.text = ''
                hit = True
    return hit

def set_runs(p, texts):
    """Put texts into the first len(texts) runs of paragraph p, drop the rest."""
    rs = p._p.findall(A + 'r')
    for i, t in enumerate(texts):
        rs[i].find(A + 't').text = t
    for r in rs[len(texts):]:
        p._p.remove(r)

def subtitle_shape(slide):
    c = [sh for sh in slide.shapes if sh.has_text_frame and sh.text_frame.text.strip()
         and 0.38 < Emu(sh.top).inches < 0.75 and Emu(sh.left).inches < 0.5]
    return c[0] if c else None

def set_subtitle(slide, text):
    sh = subtitle_shape(slide)
    if sh is None:
        print('no subtitle on', slide.slide_id); return
    p = sh.text_frame.paragraphs[0]
    set_runs(p, [text])
    for extra in sh.text_frame.paragraphs[1:]:
        sh.text_frame._txBody.remove(extra._p)

def set_divider(slide, label, name):
    ph = [sh for sh in slide.shapes if sh.is_placeholder and sh.placeholder_format.type is not None
          and 'TITLE' in str(sh.placeholder_format.type)][0]
    p = ph.text_frame.paragraphs[0]._p
    kids = [k for k in p if k.tag in (A + 'r', A + 'br')]
    first_r = next(k for k in kids if k.tag == A + 'r')
    first_r.find(A + 't').text = label
    br = next((k for k in kids if k.tag == A + 'br'), None)
    after = kids[kids.index(br) + 1:] if br is not None else kids[kids.index(first_r) + 1:]
    rs_after = [k for k in after if k.tag == A + 'r']
    if br is None:
        br = etree.SubElement(p, A + 'br'); first_r.addnext(br)
    rs_after[0].find(A + 't').text = name
    for k in kids:
        if k.tag == A + 'r' and k is not first_r and k is not rs_after[0]:
            p.remove(k)

def style_cell(cell, text, size=10.5, bold=False, color=BLACK, fill=None, align=PP_ALIGN.LEFT):
    cell.text = ''
    tf = cell.text_frame
    lines = text.split('\n')
    for i, line in enumerate(lines):
        para = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        para.alignment = align
        r = para.add_run(); r.text = line
        r.font.size = Pt(size); r.font.bold = bold; r.font.color.rgb = color; r.font.name = 'Arial'
    cell.margin_left = cell.margin_right = Inches(0.06)
    cell.margin_top = cell.margin_bottom = Inches(0.03)
    cell.vertical_anchor = MSO_ANCHOR.MIDDLE
    if fill is not None:
        cell.fill.solid(); cell.fill.fore_color.rgb = fill
    else:
        cell.fill.background()

GRID_STYLE = '{5940675A-B579-460E-94D1-54222C63F5DA}'  # No Style, Table Grid

def add_table(slide, x, y, widths, rows, header=True, size=10.5, row_h=0.3, first_col_fill=None, name='Tabel'):
    shp = slide.shapes.add_table(len(rows), len(widths), Inches(x), Inches(y),
                                 Inches(sum(widths)), Inches(row_h * len(rows)))
    shp.name = name
    tbl = shp.table
    tblPr = tbl._tbl.tblPr
    tblPr.set('firstRow', '0'); tblPr.set('bandRow', '0')
    sid = tblPr.find(A + 'tableStyleId')
    if sid is None:
        sid = etree.SubElement(tblPr, A + 'tableStyleId')
    sid.text = GRID_STYLE
    for i, w in enumerate(widths):
        tbl.columns[i].width = Inches(w)
    for ri, row in enumerate(rows):
        tbl.rows[ri].height = Inches(row_h)
        for ci, val in enumerate(row):
            c = tbl.cell(ri, ci)
            if header and ri == 0:
                style_cell(c, val, size, True, WHITE, BLUE, PP_ALIGN.CENTER)
            elif first_col_fill is not None and ci == 0:
                style_cell(c, val, size, False, BLACK, first_col_fill)
            else:
                fill = LBLUE if (header and ri % 2 == 1) else WHITE
                al = PP_ALIGN.CENTER if (header and widths[ci] <= 1.0) else PP_ALIGN.LEFT
                style_cell(c, val, size, False, BLACK, fill, al)
    # thin grey borders
    for c in (tbl.cell(r, k) for r in range(len(rows)) for k in range(len(widths))):
        tcPr = c._tc.get_or_add_tcPr()
        for tag in ('lnL', 'lnR', 'lnT', 'lnB'):
            ln = etree.SubElement(tcPr, A + tag, w='6350')
            sf = etree.SubElement(ln, A + 'solidFill')
            etree.SubElement(sf, A + 'srgbClr', val='A6A6A6')
        # schema order: borders must precede fill
        fills = [e for e in tcPr if e.tag in (A + 'solidFill', A + 'noFill')]
        for f in fills:
            tcPr.remove(f); tcPr.append(f)
    return shp

def add_box(slide, x, y, w, h, fill, text='', size=12, bold=False, color=WHITE, shape=MSO_SHAPE.ROUNDED_RECTANGLE,
            align=PP_ALIGN.LEFT, name='Kotak', anchor=MSO_ANCHOR.MIDDLE):
    b = slide.shapes.add_shape(shape, Inches(x), Inches(y), Inches(w), Inches(h))
    b.name = name
    b.fill.solid(); b.fill.fore_color.rgb = fill
    b.line.fill.background()
    b.shadow.inherit = False
    if shape == MSO_SHAPE.ROUNDED_RECTANGLE:
        b.adjustments[0] = 0.12
    tf = b.text_frame; tf.word_wrap = True
    tf.margin_left = tf.margin_right = Inches(0.1)
    tf.vertical_anchor = anchor
    lines = text.split('\n') if text else []
    for i, line in enumerate(lines):
        para = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        para.alignment = align
        r = para.add_run(); r.text = line
        r.font.size = Pt(size); r.font.bold = bold if i == 0 else False; r.font.color.rgb = color; r.font.name = 'Arial'
    return b

def add_text(slide, x, y, w, h, runs_lines, size=12, color=BLACK, name='Teks', align=PP_ALIGN.LEFT):
    tb = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    tb.name = name
    tf = tb.text_frame; tf.word_wrap = True
    tf.margin_left = tf.margin_right = 0
    for i, line in enumerate(runs_lines):
        para = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        para.alignment = align
        para.space_after = Pt(4)
        parts = line if isinstance(line, list) else [(line, False)]
        for t, b in parts:
            r = para.add_run(); r.text = t
            r.font.size = Pt(size); r.font.bold = b; r.font.color.rgb = color; r.font.name = 'Arial'
    return tb

TEMPLATE_CONTENT = S(10)
title_xml = [copy.deepcopy(sh._element) for sh in TEMPLATE_CONTENT.shapes if sh.shape_id in (208, 381)]

def new_content_slide(title, subtitle):
    s = prs.slides.add_slide(TEMPLATE_CONTENT.slide_layout)
    for ph in list(s.placeholders):
        ph._element.getparent().remove(ph._element)
    for x in title_xml:
        s.shapes._spTree.append(copy.deepcopy(x))
    t1, t2 = [sh for sh in s.shapes][-2:]
    set_runs(t1.text_frame.paragraphs[0], [title])
    set_runs(t2.text_frame.paragraphs[0], [subtitle])
    for extra in t2.text_frame.paragraphs[1:]:
        t2.text_frame._txBody.remove(extra._p)
    return s

# ---------------------------------------------------------------- 1. global wording fixes
REPL = [
    ('Berdasarkan Konfirmasi Pak Abram (Blueprint Confirmation)', 'Catatan Penting'),
    ('Berdasarkan Konfirmasi Tim QA by Email', 'Catatan Penting'),
    ('Berdasarkan Konfirmasi Tim QA', 'Catatan Penting'),
    ('Berdasarkan Confirmation', 'Catatan Penting'),
    ('Information New!', 'Catatan'),
    ('Tracing by Backgroud Process Sistem', 'Penelusuran Otomatis oleh Sistem'),
    ('Calculate by Backgroud Process Sistem', 'Perhitungan Otomatis oleh Sistem'),
    ('Tracebility of Trias to TTA by Background System', 'Traceability Trias ke TTA (otomatis oleh sistem)'),
    ('Parameter input ditambahkan “Batch SR” dan Inspection Date tidak required',
     'Field “Batch SR” dapat dipakai sebagai filter, dan Inspection Date tidak wajib diisi.'),
    ('menginpukan', 'menginputkan'), ('diinpeksi', 'diinspeksi'), ('inpeksi', 'inspeksi'),
    ('kegenerate', 'ter-generate'), ('tergenerate', 'ter-generate'), ('Delate', 'Delete'),
    ('sebelum di submite', 'sebelum di-submit'), ('ourtcource', 'outsource'), ('manikkan', 'menaikkan'),
    ('undeletetion', 'Undeletion'), ('Inspcetion', 'Inspection'), ('properti alu dirata-rata', 'properti lalu dirata-rata'),
    ('Contoh Lanscape', 'Contoh Landscape'), ('Contoh Potrait', 'Contoh Portrait'), ('Backgroud', 'Background'),
    ('Pending List Inspection', 'Pending List Inspection'),
]
for s in orig:
    for tf in text_frames(s.shapes):
        for o, n in REPL:
            replace_in_tf(tf, o, n)

# ---------------------------------------------------------------- 2. cover
for sh in S(1).shapes:
    if sh.name == 'CoverPill':
        set_runs(sh.text_frame.paragraphs[0], ['END USER TRAINING & UAT'])

# ---------------------------------------------------------------- 3. slide 43 (Print COA intro) – sesuai perilaku program terbaru
tf43 = [sh for sh in S(43).shapes if sh.has_text_frame and 'Tujuan' in sh.text_frame.text][0].text_frame
for p in list(tf43.paragraphs):
    t = ''.join(r.text for r in p.runs)
    if t.strip().startswith('Berdasarkan Blueprint Confirmation'):
        tf43._txBody.remove(p._p)
replace_in_tf(tf43, 'Fungsi Background Job:', 'Proses Otomatis oleh Sistem:')
for p in tf43.paragraphs:
    t = ''.join(r.text for r in p.runs)
    if t.startswith('Apabila lot inspeksi utama tidak ditemukan'):
        set_runs(p, ['Apabila JR tidak memiliki hasil inspeksi, sistem otomatis mengambil hasil inspeksi dari '
                     'maksimal 20 sequence JR sebelumnya (type film & line yang sama; dimulai dari bulan yang sama, '
                     'lalu bulan sebelumnya).'])

# ---------------------------------------------------------------- 4. subtitles content slides
def rng(a, b): return range(a, b + 1)
SUB = {}
for n in rng(9, 13): SUB[n] = 'ZQM004  ·  Skenario 3 – Input Hasil Barrier Manual'
for n in rng(15, 22): SUB[n] = 'ZQM004  ·  Skenario 4 – Input Hasil Barrier via Upload'
for n in rng(26, 41): SUB[n] = 'ZQM004  ·  Skenario 5 – Hapus Sampel Barrier (1 JR = 1 Sampel SR)'
for n in (44, 45, 46, 56, 65, 66, 67): SUB[n] = 'ZQM002  ·  Skenario 6 – COA Base Film (Print COA s/d Batch List)'
for n in rng(112, 115): SUB[n] = 'ZQM002  ·  Skenario 6 – COA Base Film: Cetak Batch List'
for n in (54, 58): SUB[n] = 'ZQM002  ·  Skenario 7 – COA Converting'
for n in rng(60, 64): SUB[n] = 'ZQM002  ·  Skenario 8 – Out Limit → Change → Print'
for n in (106, 108, 109, 110): SUB[n] = 'ZQM002  ·  Skenario 9 – Print COA dari TTA'
for n in rng(117, 118): SUB[n] = 'ZQM003  ·  Skenario 10 – Report COA'
for n in rng(122, 123): SUB[n] = 'Prasyarat  ·  MIC & Inspection Plan Barrier'
for n, s in SUB.items():
    set_subtitle(S(n), s)
for n in rng(125, 144):
    sh = subtitle_shape(S(n)); t = sh.text_frame.text.strip()
    t = t.replace('Edit New Master Data COA', 'Edit & Delete Master Data COA') \
         .replace('Display New Master Data COA', 'Display & Undeletion Master Data COA')
    t = re.sub(r'^Mapping Master Data COA', 'ZQM001  ·  Skenario 1 – Mapping COA', t)
    set_subtitle(S(n), t)
for n in rng(146, 158):
    sh = subtitle_shape(S(n)); t = sh.text_frame.text.strip()
    t = re.sub(r'^Mapping COA Batch ?/ ?Roll', 'ZQM001  ·  Skenario 2 – Mapping Batch List', t)
    set_subtitle(S(n), t)

# ---------------------------------------------------------------- 5. dividers + info table
DIV = {
    124: ('Skenario 1', 'Mapping COA (MIC) – ZQM001', 'ZQM001', 'Tim QA (Admin Master Data)', 'Type film: ________   Customer: ________', None),
    145: ('Skenario 2', 'Mapping Batch List – ZQM001', 'ZQM001', 'Tim QA (Admin Master Data)', 'Group: ________   Customer: ________', None),
    8:   ('Skenario 3', 'Input Hasil Barrier Manual – ZQM004', 'ZQM004', 'QA Lab', 'Batch JR: ________   Batch SR: ________', None),
    14:  ('Skenario 4', 'Input Hasil Barrier via Upload – ZQM004', 'ZQM004', 'QA Lab', 'Batch JR: ________   Batch SR: ________', None),
    23:  ('Skenario 5', 'Hapus Sampel Barrier – ZQM004', 'ZQM004', 'QA Lab', 'Batch JR: ________   Batch SR: ________', None),
    43:  ('Skenario 6', 'COA Base Film – ZQM002', 'ZQM002', 'QA Delivery', 'No. DO: ________   Type film: ________', 'Print COA → Print → Print COA → Batch List'),
    68:  ('Skenario 7', 'COA Converting – ZQM002', 'ZQM002', 'QA Delivery', 'No. DO: ________   Type film: ________', 'Sama dengan Skenario 6 (Print COA s/d Batch List)'),
    76:  ('Skenario 8', 'Out Limit → Change → Print – ZQM002', 'ZQM002', 'QA Delivery', 'No. DO: ________   MIC: ________', 'Cek Out Limit → edit nilai → Save → Print COA → Batch List'),
    105: ('Skenario 9', 'Print COA dari TTA – ZQM002', 'ZQM002', 'QA Delivery', 'No. DO: ________   Batch TTA: ________', 'Sama dengan Skenario 6 (Print COA s/d Batch List)'),
}
for n, (lab, name, tcode, user, data, alur) in DIV.items():
    set_divider(S(n), lab, name)
    rows = [['T-Code', tcode], ['User', user]] + ([['Alur', alur]] if alur else []) + [['Data uji (diisi saat UAT)', data]]
    add_table(S(n), 2.33, 1.15, [2.6, 6.4], rows,
              header=False, size=12, row_h=0.4, first_col_fill=YEL, name='Info Skenario')
set_divider(S(121), 'Prasyarat', 'MIC & Inspection Plan Barrier')
cover_rect = [sh for sh in S(8).shapes if sh.name == 'Rectangle 1'][0]._element
for n in (121, 124, 145):
    S(n).shapes._spTree.append(copy.deepcopy(cover_rect))

def set_divider_body(slide, items):
    tf = [sh for sh in slide.shapes if sh.has_text_frame and sh.text_frame.text.strip().startswith('Tujuan')][0].text_frame
    tpl = copy.deepcopy(tf.paragraphs[0]._p)
    for p in list(tf.paragraphs):
        tf._txBody.remove(p._p)
    for lab, txt in items:
        p = copy.deepcopy(tpl)
        rs = p.findall(A + 'r')
        rs[0].find(A + 't').text = lab; rs[1].find(A + 't').text = ': '; rs[2].find(A + 't').text = txt
        for x in rs[3:]: p.remove(x)
        tf._txBody.append(p)
tf43 = [sh for sh in S(43).shapes if sh.has_text_frame and 'Tujuan' in sh.text_frame.text][0].text_frame
set_runs(tf43.paragraphs[0], ['Tujuan', ': ', 'Mencetak COA sampai Batch List untuk DO produk Base Film (Plain Film) dari sistem SAP.'])
set_divider_body(S(68), [('Tujuan', 'Mencetak COA sampai Batch List untuk DO produk Converting.'),
    ('Latar Belakang', 'Nilai COA ditelusuri otomatis dari Slit Roll Converting → Jumbo Roll Converting → Slit Roll Base Film → Jumbo Roll Base Film sesuai Mapping COA.')])
set_divider_body(S(76), [('Tujuan', 'Memastikan nilai kosong atau di luar Lower/Upper Limit ditandai Out Limit, dikoreksi, lalu COA dan Batch List dapat dicetak.'),
    ('Latar Belakang', 'Print COA diblok selama masih ada tanda X pada kolom Out Limit. User QA dapat mengedit nilai langsung di layar Print COA lalu Save.')])
set_divider_body(S(105), [('Tujuan', 'Mencetak COA sampai Batch List untuk produk yang menggunakan input material dari TTA.'),
    ('Latar Belakang', 'Mapping COA mengikuti material Slit Roll yang dijual, sedangkan nilai COA diambil dari hasil inspeksi plant TTA (traceability Trias → TTA otomatis oleh sistem).')])

for tf in text_frames(S(109).shapes):
    for p in tf.paragraphs:
        t = ''.join(r.text for r in p.runs)
        if t.startswith('Tipe film dengan input material outsource'):
            set_runs(p, ['Sistem otomatis menelusuri roll Trias ke roll TTA melalui batch vendor, lalu mengambil hasil inspeksi plant TTA sebagai nilai COA.'])
        elif t.startswith('Karena material outsource saat ini'):
            set_runs(p, ['User cukup memastikan nilai pada layar Print COA sama dengan hasil inspeksi pada Report Tracing Roll TTA.'])

# nomor langkah COA dimulai dari 1 per skenario
def all_shapes(shs):
    for sh in shs:
        if sh.shape_type == 6: yield from all_shapes(sh.shapes)
        else: yield sh
def renum(n, steps, callouts):
    sl = S(n)
    for sh in all_shapes(sl.shapes):
        if not sh.has_text_frame: continue
        for p in sh.text_frame.paragraphs:
            t = ''.join(r.text for r in p.runs).strip()
            if t in callouts and len(t) <= 2:
                set_runs(p, [callouts[t]])
                if len(callouts[t]) == 2:
                    sh.text_frame.word_wrap = False
                    sh.text_frame.margin_left = sh.text_frame.margin_right = 0
                    p.alignment = PP_ALIGN.CENTER
                    for rr in p.runs: rr.font.size = Pt(10)
                continue
            for old, new in steps:
                if t.startswith(old):
                    set_runs(p, [new])
# Skenario 6 – Base Film
renum(45, [('3. Data COA', '3. Data COA akan ditampilkan sebagai berikut:')], {})
renum(65, [('8. Klik', '4. Klik “Print” untuk memulai proses Print COA'), ('9. Klik', '5. Klik “Print COA” untuk print COA')], {'8': '4', '9': '5'})
renum(66, [('10. Pilih', '6. Pilih “Print Preview” untuk melihat COA sebelum dicetak'),
           ('11. Pilih', '7. Pilih “Print” untuk mencetak COA (hardfile)'), ('12. Untuk', '8. Untuk kembali atau batal')],
      {'10': '6', '11': '7', '12': '8'})
renum(112, [('1. Pilih Batch List', '9. Klik “Batch List” untuk print Batch List')], {'1': '9'})
renum(113, [('2. Pilih fitur', '10. Pilih fitur (Open / Save As / Open & Save), lalu 11. klik centang')], {'2': '10', '3': '11'})
# Skenario 8 – Out Limit
renum(60, [('5. Klik', '1. Setelah isi Nomor ODO & Execute (Skenario 6 langkah 1–2), klik “Print”')], {'5': '1'})
renum(61, [('6.', '2. Klik “Print COA” untuk mencetak COA melalui printer')], {'6': '2'})
renum(64, [('6. Setelah', '3. Setelah nilai diedit, klik “Save” untuk menyimpan perubahan'),
           ('7. Validasi', '4. Klik “Yes” untuk menyimpan, lalu lanjutkan Print COA & Batch List')], {'6': '3', '7': '4'})
# Skenario 9 – TTA
renum(110, [], {'2': '3'})
add_text(S(110), 8.4, 1.6, 4.6, 2.0, [
    '3. Klik “Print” untuk lanjut Print COA dan Batch List (langkah sama dengan Skenario 6).',
    'Cek: nilai COA (kotak merah) sama dengan hasil inspeksi plant TTA pada Properties Report di bawah.'], size=14, name='Langkah TTA')

# ---------------------------------------------------------------- 6. agenda (TOC) tables
AGENDA = ['Ringkasan Program & Alur Penggunaan',
          'Master Data – Mapping COA & Batch List (ZQM001)',
          'Barrier Inspection (ZQM004)',
          'Certificate of Analysis – Print COA s/d Batch List (ZQM002)',
          'Report COA (ZQM003)',
          'Checklist Skenario UAT & Sign-off']
def rebuild_toc(slide, hi):
    for sh in slide.shapes:
        if sh.has_text_frame and sh.text_frame.text.strip() == 'Table of Contents':
            set_runs(sh.text_frame.paragraphs[0], ['Agenda'])
    tblsh = [sh for sh in slide.shapes if sh.has_table][0]
    tbl = tblsh.table._tbl
    trs = tbl.findall(A + 'tr')
    def has_fill(tr):
        tcPr = tr.find(A + 'tc').find(A + 'tcPr')
        return tcPr is not None and tcPr.find(A + 'solidFill') is not None
    hi_tpl = HI_TPL
    no_tpl = next(tr for tr in trs if not has_fill(tr) and re.match(r'^\d\.', ''.join(tr.itertext()).strip()))
    hi_tpl, no_tpl = copy.deepcopy(hi_tpl), copy.deepcopy(no_tpl)
    for tr in trs: tbl.remove(tr)
    for i, txt in enumerate(AGENDA):
        tr = copy.deepcopy(hi_tpl if i == hi else no_tpl)
        tr.set('h', str(Inches(0.62)))
        ts = tr.findall('.//' + A + 't')
        ts[0].text = f'{i + 1}.\t{txt}'
        for t in ts[1:]: t.text = ''
        tbl.append(tr)
_t2 = [sh for sh in S(2).shapes if sh.has_table][0].table._tbl.findall(A + 'tr')[0]
HI_TPL = copy.deepcopy(_t2)
TOC = {2: 0, 119: 1, 7: 2, 42: 3, 116: 4, 5: 5}
for n, hi in TOC.items():
    rebuild_toc(S(n), hi)

# ---------------------------------------------------------------- 7. new slides
# 7a. Ringkasan program
sA = new_content_slide('Ringkasan Program EUT', 'Program, T-Code dan Peran User')
add_text(sA, 0.33, 1.0, 12.6, 0.4, [[('Daftar program yang dilatih dan diuji pada sesi End User Training & UAT ini:', False)]], size=14)
add_table(sA, 0.33, 1.5, [3.4, 1.1, 1.2, 2.3, 2.4, 1.6], [
    ['BP Step', 'T-Code', 'R/I/C/E/F', 'Department', 'End User Role', 'Skenario'],
    ['Mapping COA (MIC) & Mapping Batch List', 'ZQM001', 'E', 'Quality Assurance', 'Admin Master Data QA', '1 – 2'],
    ['Input Hasil Inspeksi Barrier (MVTR / O2TR)', 'ZQM004', 'E', 'Quality Assurance', 'QA Lab', '3 – 5'],
    ['Print Certificate of Analysis & Batch List', 'ZQM002', 'F', 'Quality Assurance', 'QA Delivery', '6 – 9'],
    ['Report COA', 'ZQM003', 'R', 'Quality Assurance', 'QA Delivery', '10'],
], size=12, row_h=0.42, name='Tabel Program')
add_box(sA, 0.33, 4.0, 12.0, 0.42, NAVY, 'Prasyarat sebelum UAT', size=12, bold=True, name='Judul Prasyarat')
add_text(sA, 0.5, 4.6, 11.8, 2.4, [
    [('User & otorisasi: ', True), ('user uji memiliki akses T-Code ZQM001, ZQM002, ZQM003, ZQM004 dan transaksi pendukung (Gun Scanner SR, QE51N, QA32).', False)],
    [('Master data: ', True), ('MIC dan Inspection Plan Barrier sudah disesuaikan; Mapping COA tiap type film dan Mapping Batch List customer sudah dinaikkan.', False)],
    [('Data uji: ', True), ('nomor DO, batch JR/SR dan customer untuk tiap skenario sudah disiapkan oleh tim QA bersama tim SAP.', False)],
    [('Printer: ', True), ('printer SAP untuk cetak COA sudah terhubung (gunakan Print Preview bila belum).', False)],
], size=14, name='Isi Prasyarat')

# 7b. Alur penggunaan
sB = new_content_slide('Alur Penggunaan COA', 'Urutan transaksi dari master data sampai cetak COA')
steps = [('1', 'Master Data', 'ZQM001', 'Naikkan Mapping COA per type film / customer dan Mapping Batch List', 'Tim QA'),
         ('2', 'Inspeksi SR', 'Gun Scanner + UD', 'Scan roll SR, inspection lot terbentuk, input hasil & Usage Decision', 'QA / Produksi'),
         ('3', 'Input Barrier', 'ZQM004', 'Input Value 1–3 MVTR / O2TR manual atau upload; hapus sampel berlebih', 'QA Lab'),
         ('4', 'Print COA', 'ZQM002', 'Isi nomor DO, cek nilai & Out Limit, edit bila perlu, Save, Print COA lalu Print Batch List', 'QA Delivery'),
         ('5', 'Report COA', 'ZQM003', 'Monitoring nilai COA per batch SR dan nilai hasil edit (New Value)', 'QA Delivery')]
x0, w, gap = 0.33, 2.32, 0.25
for i, (num, name, tc, desc, who) in enumerate(steps):
    x = x0 + i * (w + gap)
    add_box(sB, x, 1.45, w, 0.8, BLUE, name, size=15, bold=True, align=PP_ALIGN.CENTER, name=f'Langkah {num}')
    c = sB.shapes.add_shape(MSO_SHAPE.OVAL, Inches(x + w / 2 - 0.27), Inches(1.1), Inches(0.54), Inches(0.54))
    c.name = f'Nomor {num}'; c.fill.solid(); c.fill.fore_color.rgb = GOLD; c.line.color.rgb = WHITE; c.line.width = Pt(2)
    tf = c.text_frame; tf.margin_left = tf.margin_right = 0
    r = tf.paragraphs[0].add_run(); r.text = num; r.font.size = Pt(16); r.font.bold = True; r.font.color.rgb = WHITE
    tf.paragraphs[0].alignment = PP_ALIGN.CENTER
    add_box(sB, x, 2.38, w, 0.5, YEL, tc, size=13, bold=True, color=BLACK, align=PP_ALIGN.CENTER, name=f'TCode {num}')
    add_box(sB, x, 3.0, w, 1.75, LBLUE, desc, size=14, color=BLACK, anchor=MSO_ANCHOR.TOP, name=f'Deskripsi {num}')
    add_text(sB, x, 4.88, w, 0.4, [[('User: ', True), (who, False)]], size=12, color=GREY, name=f'User {num}', align=PP_ALIGN.CENTER)
    if i < len(steps) - 1:
        a = sB.shapes.add_shape(MSO_SHAPE.RIGHT_ARROW, Inches(x + w + 0.02), Inches(1.72), Inches(0.21), Inches(0.26))
        a.name = 'Panah'; a.fill.solid(); a.fill.fore_color.rgb = GOLD; a.line.fill.background()
add_box(sB, 0.33, 5.5, 12.6, 1.0, NAVY,
        'Penting\nSetiap bulan, JR pertama tiap type film dan line produksi wajib diinspeksi. JR berikutnya yang tidak diinspeksi '
        'akan mengambil hasil inspeksi dari maksimal 20 sequence JR sebelumnya.', size=13, bold=True, name='Catatan Alur')

# 7c. Ringkasan logika nilai COA (pengganti slide tracing)
sC = new_content_slide('Certificate of Analysis', 'ZQM002  ·  Cara Sistem Mengisi Nilai COA (otomatis)')
add_text(sC, 0.33, 0.98, 12.6, 0.4, [[('Nilai pada layar Print COA dihitung otomatis. User cukup memeriksa hasilnya:', False)]], size=14)
cards = [('Penelusuran berjenjang', 'Sistem menelusuri hasil inspeksi dari Slit Roll Converting → Jumbo Roll Converting → Slit Roll Base Film → Jumbo Roll Base Film, sesuai MIC pada Mapping COA.'),
         ('JR tidak diinspeksi', 'Sistem mengambil hasil dari maksimal 20 sequence JR sebelumnya (type film & line sama, bulan sama lalu bulan sebelumnya). Jika tidak ditemukan, nilai kosong.'),
         ('Lebih dari 1 sumber', 'Jika DO berisi beberapa JR / SR yang diinspeksi, nilai COA = rata-rata seluruh hasil inspeksi sumber. Barrier: rata-rata Last Value per sampel SR.'),
         ('Out Limit', 'Nilai kosong atau di luar Lower/Upper Limit diberi tanda X pada kolom Out Limit. Print COA diblok sampai nilai dikoreksi dan disimpan.')]
for i, (h, d) in enumerate(cards):
    x = 0.33 + (i % 2) * 6.4; y = 1.55 + (i // 2) * 2.45
    add_box(sC, x, y, 6.2, 2.25, LBLUE, '', name=f'Kartu {i+1}')
    c = sC.shapes.add_shape(MSO_SHAPE.OVAL, Inches(x + 0.2), Inches(y + 0.22), Inches(0.5), Inches(0.5))
    c.name = f'Ikon {i+1}'; c.fill.solid(); c.fill.fore_color.rgb = GOLD; c.line.fill.background()
    tf = c.text_frame; tf.margin_left = tf.margin_right = 0
    r = tf.paragraphs[0].add_run(); r.text = str(i + 1); r.font.size = Pt(16); r.font.bold = True; r.font.color.rgb = WHITE
    tf.paragraphs[0].alignment = PP_ALIGN.CENTER
    add_text(sC, x + 0.85, y + 0.25, 5.15, 0.45, [[(h, True)]], size=16, color=NAVY, name=f'Judul Kartu {i+1}')
    add_text(sC, x + 0.85, y + 0.75, 5.15, 1.4, [[(d, False)]], size=13, name=f'Isi Kartu {i+1}')

# 7d. Checklist slides
COLS = [0.5, 2.1, 3.8, 3.8, 0.9, 1.5]
HDR = ['No', 'Skenario', 'Langkah Utama', 'Hasil yang Diharapkan', 'OK / NOK', 'Catatan']
def checklist(sub, rows, size=10.5, row_h=0.6):
    s = new_content_slide('Checklist Skenario UAT', sub)
    add_table(s, 0.33, 1.0, COLS, [HDR] + [r + ['☐ OK\n☐ NOK', ''] for r in rows], size=size, row_h=row_h, name='Checklist')
    return s
sD1 = checklist('Master Data – ZQM001', [
    ['1a', 'Upload Mapping COA (.txt)', 'Mapping COA MIC → Upload Master Data COA → pilih file .txt (tanpa header) → Execute',
     'Pesan “Successfully added”; MIC tidak terdaftar ditolak dengan pesan “MIC : … is not valid in master data!”'],
    ['1b', 'Tambah Mapping COA', 'Add New Master Data COA → isi data → select baris → Create Data', 'Data tersimpan dan tampil pada Display Master Data COA'],
    ['1c', 'Edit & hapus Mapping COA', 'Edit Master Data COA → ubah → Change Data; select → Delete Data → Yes',
     'Perubahan tersimpan; Remarks “Material … and MIC … : successfully deleted”'],
    ['1d', 'Display & Undeletion', 'Display Master Data COA → centang data terhapus → Execute → Undeletion Flag → Yes', 'Tanda X pada Del-Flag hilang, mapping aktif kembali'],
    ['2a', 'Buat Group Batch List', 'Menu Group → New → isi nama group → centang', 'Group baru tampil di daftar group'],
    ['2b', 'Kolom & customer group', 'Tambah Kolom → pilih kolom → centang; Assign Customer → pilih customer → simpan',
     'Kolom dan customer tersimpan; Batch List DO customer tersebut memakai kolom group'],
], row_h=0.72)
sD2 = checklist('Barrier Inspection – ZQM004', [
    ['3', 'Input hasil Barrier manual', 'Pending List Inspection → Execute → isi Value 1, 2, 3 → Submit → NIK → Save',
     'Pesan “Transaction Success”; Last Value = Value ke-3; hasil tercatat di inspection result; UD dipulihkan otomatis'],
    ['4', 'Input hasil Barrier via upload', 'Template → isi Value 1–3 di Excel → simpan .txt → Upload → pilih file → Execute → Submit → NIK',
     'Data upload tampil untuk dicek; pesan “Transaction Success”; Last Value = Value ke-3'],
    ['5', 'Hapus sampel Barrier', 'Inspeksi 2 sampel SR dari 1 JR → select sampel NOT OK → Delete → Yes',
     'Sampel terhapus, 1 JR tersisa 1 sampel SR; nilai Barrier di COA = Last Value sampel tersisa'],
], row_h=1.15, size=12)
sD3 = checklist('Certificate of Analysis – ZQM002 & Report COA – ZQM003', [
    ['6', 'COA Base Film', 'Isi Nomor ODO (DO base film) → Execute → cek nilai → Print → Print COA → Print Preview / Print → Batch List → Open / Save',
     'Nilai MIC = hasil inspeksi JR Base Film (rata-rata bila > 1 JR); COA tercetak; Excel Batch List sesuai DO & kolom group customer'],
    ['7', 'COA Converting', 'Isi Nomor ODO (DO converting) → Execute → cek nilai → Print COA → Batch List',
     'Nilai MIC ditelusuri dari SR/JR Converting dan Base Film sesuai mapping (rata-rata bila > 1 sumber); COA & Batch List tercetak'],
    ['8', 'Out Limit → Change → Print', 'Isi Nomor ODO → cek kolom Out Limit → coba Print COA → edit nilai → Save → Yes → Print COA → Batch List',
     'Print diblok selama ada tanda X; setelah Save tanda hilang; COA & Batch List tercetak; nilai baru tampil di Report (New Value)'],
    ['9', 'Print COA dari TTA', 'Isi Nomor ODO (roll dengan input TTA) → Execute → cek nilai → Print COA → Batch List',
     'MIC sesuai mapping SR yang dijual; nilai diambil dari hasil inspeksi plant TTA; COA & Batch List tercetak'],
    ['10', 'Report COA (ZQM003)', 'Isi Delivery Order Date / Nomor ODO → Execute', 'Data per batch SR; kolom Value = nilai print; New Value = nilai hasil edit'],
], size=11, row_h=1.0)

# 7e. Sign-off
sE = new_content_slide('Berita Acara UAT', 'Persetujuan hasil User Acceptance Test')
add_text(sE, 0.33, 1.0, 12.6, 0.8, [[('Dengan ini menyatakan bahwa skenario 1–10 pada program ZQM001, ZQM002, ZQM003 dan ZQM004 telah diuji di sistem SAP QAS dengan hasil:', False)]], size=14)
add_text(sE, 0.33, 1.8, 12.6, 0.45, [[('☐  Diterima        ☐  Diterima dengan catatan        ☐  Ditolak', True)]], size=16, color=NAVY)
add_table(sE, 0.33, 2.45, [3.2, 3.2, 3.6, 2.6], [
    ['Nama', 'Departemen / Peran', 'Tanda Tangan', 'Tanggal'],
    ['', 'QA Lab', '', ''], ['', 'QA Delivery', '', ''], ['', 'Admin Master Data QA', '', ''], ['', 'Tim SAP / IT', '', ''],
], size=12, row_h=0.58, name='Tanda Tangan')
add_box(sE, 0.33, 5.55, 12.6, 1.35, LBLUE, 'Catatan / temuan UAT:', size=12, bold=True, color=NAVY, anchor=MSO_ANCHOR.TOP, name='Catatan UAT')

# ---------------------------------------------------------------- 8. order + delete
newid = {'A': sA, 'B': sB, 'C': sC, 'D1': sD1, 'D2': sD2, 'D3': sD3, 'E': sE}
order = [1, 2, 'A', 'B',
         119, 120, 121, 122, 123, 124, 125, 126, 127, 128, *rng(131, 144), 145, 146, 147, 149, *rng(150, 158),
         7, *rng(8, 23), *rng(26, 41),
         42, 43, 44, 45, 'C', 46, 56, 65, 66, 67, *rng(112, 115), 68, 54, 58, 76, *rng(60, 64), 105, 106, *rng(108, 110),
         116, 117, 118,
         5, 'D1', 'D2', 'D3', 'E', 159]
want = [newid[k] if isinstance(k, str) else S(k) for k in order]
assert len(set(map(id, want))) == len(want)
sldIdLst = prs.slides._sldIdLst
by_rid = {}
for sid in list(sldIdLst):
    by_rid[sid.get(R + 'id')] = sid
part_to_rid = {prs.part.related_part(rid): rid for rid in by_rid}
keep_rids = [part_to_rid[s.part] for s in want]
for sid in list(sldIdLst):
    sldIdLst.remove(sid)
for rid in keep_rids:
    sldIdLst.append(by_rid[rid])
for rid in by_rid:
    if rid not in keep_rids:
        prs.part.drop_rel(rid)
prs.core_properties.title = 'EUT & UAT – SAP Enhancement for Streamlined COA Workflow'
prs.save(OUT)
print('slides:', len(want))
