"""Gambar flowchart hitam-putih (gaya template FS) untuk WRICEF ZQM002 (COA).

Pemakaian: python3 draw_flow.py <out_dir>
"""
import sys
from PIL import Image, ImageDraw, ImageFont

FONT = '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf'
F = ImageFont.truetype(FONT, 22)
FS = ImageFont.truetype(FONT, 20)
LINE = (60, 60, 60)
BW, BH = 400, 100         # ukuran box utama
DW, DH = 330, 120         # ukuran decision
SW, SH = 380, 90          # ukuran box samping
GAP = 70
CX = 290                  # x tengah kolom utama
SIDE_X = 790              # x tengah kolom samping


def text_center(d, cx, cy, txt, font=F):
    lines = txt.split('\n')
    hs = [d.textbbox((0, 0), l, font=font)[3] for l in lines]
    tot = sum(hs) + 4 * (len(lines) - 1)
    y = cy - tot / 2
    for l, h in zip(lines, hs):
        w = d.textlength(l, font=font)
        d.text((cx - w / 2, y), l, fill='black', font=font)
        y += h + 4


def arrow(d, pts):
    d.line(pts, fill=LINE, width=2)
    (x1, y1), (x2, y2) = pts[-2], pts[-1]
    if x1 == x2:
        s = 1 if y2 > y1 else -1
        d.polygon([(x2, y2), (x2 - 8, y2 - 14 * s), (x2 + 8, y2 - 14 * s)], fill=LINE)
    else:
        s = 1 if x2 > x1 else -1
        d.polygon([(x2, y2), (x2 - 14 * s, y2 - 8), (x2 - 14 * s, y2 + 8)], fill=LINE)


def shape(d, kind, cx, cy, txt, w=BW, h=BH):
    if kind == 'term':
        d.ellipse([cx - 80, cy - 32, cx + 80, cy + 32], outline='black', width=2, fill='white')
    elif kind == 'box':
        d.rectangle([cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2], outline='black', width=2, fill='white')
    elif kind == 'io':
        o = 30
        d.polygon([(cx - w / 2 + o, cy - h / 2), (cx + w / 2 + o, cy - h / 2),
                   (cx + w / 2 - o, cy + h / 2), (cx - w / 2 - o, cy + h / 2)], outline='black', width=2, fill='white')
    elif kind == 'dec':
        d.polygon([(cx, cy - DH / 2), (cx + DW / 2, cy), (cx, cy + DH / 2), (cx - DW / 2, cy)],
                  outline='black', width=2, fill='white')
    text_center(d, cx, cy, txt, FS if kind == 'dec' else F)


def half_h(kind):
    return {'term': 32, 'dec': DH / 2}.get(kind, BH / 2)


def render(nodes, out, width=1000):
    """nodes: list of dict(kind, text, side=None, yes='Ya', no='Tidak', side_mode='end'|'rejoin').
    Decision: cabang 'yes' ke kanan (side box), 'no' lurus ke bawah.
    """
    ys, y = [], 60
    for n in nodes:
        hh = half_h(n['kind'])
        ys.append(y + hh)
        y += 2 * hh + GAP
    end_y = ys[-1]
    img = Image.new('RGB', (width, int(y)), 'white')
    d = ImageDraw.Draw(img)
    lanes = 0
    for i, n in enumerate(nodes):
        cy = ys[i]
        if i + 1 < len(nodes):
            nxt = nodes[i + 1]
            arrow(d, [(CX, cy + half_h(n['kind'])), (CX, ys[i + 1] - half_h(nxt['kind']))])
            if n['kind'] == 'dec':
                d.text((CX + 10, cy + DH / 2 + 8), n.get('no', 'Tidak'), fill='black', font=FS)
        if n.get('side'):
            sx = SIDE_X
            arrow(d, [(CX + DW / 2, cy), (sx - SW / 2, cy)])
            d.text((CX + DW / 2 + 15, cy - 28), n.get('yes', 'Ya'), fill='black', font=FS)
            shape(d, 'box', sx, cy, n['side'], SW, SH)
            if n.get('side_mode', 'end') == 'end':
                lx = sx + SW / 2 + 30 + lanes * 18
                lanes += 1
                d.line([(sx, cy + SH / 2), (sx, cy + SH / 2 + 20), (lx, cy + SH / 2 + 20), (lx, end_y)], fill=LINE, width=2)
                arrow(d, [(lx, end_y), (CX + 80, end_y)])
            else:  # rejoin: kembali ke node utama berikutnya + 1
                tgt = ys[i + 2]
                ty = tgt - half_h(nodes[i + 2]['kind']) - GAP / 2
                d.line([(sx, cy + SH / 2), (sx, ty)], fill=LINE, width=2)
                arrow(d, [(sx, ty), (CX, ty)])
    for i, n in enumerate(nodes):
        shape(d, n['kind'], CX, ys[i], n['text'])
    img.save(out)


FLOW1 = [
    dict(kind='term', text='Start'),
    dict(kind='io', text='TCODE ZQM002\n(layar seleksi 1000)'),
    dict(kind='dec', text='P_VBELN\n(DO) kosong?', side="Pesan I 'Nomor ODO\n(Delivery) WAJIB diisi!'"),
    dict(kind='box', text='GET_DATA: baca LIPS (PSTYV ZB)\n+ klasifikasi batch\n(INOB/AUSP bulk)'),
    dict(kind='dec', text='Mapping\nZMAP_COA ada?', yes='Tidak', no='Ya',
         side="Pesan 'Material belum\ndimapping' + STOP"),
    dict(kind='box', text='Per batch: GET_TRACED_LOTS\n(SR/JR Conv, SR/JR Base)\n-> GET_MIC (QAMV/QAMR/QASE)'),
    dict(kind='box', text='Agregasi rata-rata per\nDO-Material-MIC + override\nZLOG_COA + range flag'),
    dict(kind='io', text='Screen 0100: daftar MIC\n(edit value, SAVE ke ZLOG_COA)'),
    dict(kind='dec', text='EXEC valid?\n(1 DO, 1 material,\nsudah Save)', yes='Tidak', no='Ya',
         side='Pesan validasi,\ntetap di Screen 0100'),
    dict(kind='io', text='Screen 0200: detail COA\n(DLOAD / BATLIST / PRNT)'),
    dict(kind='dec', text='Value kosong /\ndi luar limit?', side='Pesan blokir cetak'),
    dict(kind='dec', text='LFART = ZELF\n(Export)?', side='Popup header 9000\n-> ZQMF_COA_EXPORT',
         side_mode='rejoin'),
    dict(kind='box', text='ZQMF_COA + ZQMF_COA_BATCH\n(Batch List 1-7 kolom)'),
    dict(kind='io', text='Spool LOCL\n(SSF_OPEN / SSF_CLOSE)'),
    dict(kind='term', text='End'),
]

FLOW2 = [
    dict(kind='term', text='Start'),
    dict(kind='box', text='Batch DO: QALS ART Z04\n-> LOT_SR_CONV\n(fallback GET_ORIGINAL_BATCH)'),
    dict(kind='dec', text='Mother roll ada\ndi GT_TRACE_DATA?', side='Pakai lot dari cache\n(selesai)'),
    dict(kind='box', text='ZQM_GET_BATCH_JR_BY_SR -> JR Conv\n(gagal: fallback MSEG 101 ->\nkomponen 261 -> original batch)'),
    dict(kind='box', text='QALS Z02/Z03 -> LOT_JR_CONV\n(fallback JR sibling;\nSR sibling bila SR kosong)'),
    dict(kind='box', text='Order GR JR Conv -> komponen\nSR/JR (filter BKTXT, LICHA)\n-> batch SR Base Film'),
    dict(kind='dec', text='Komponen SR\ntidak ada?', side='Re-label: JR = JR Base,\nbatch DO = SR Base',
         side_mode='rejoin'),
    dict(kind='box', text='QALS Z04 -> LOT_SR_BASE\n-> JR_BY_SR -> JR Base Film'),
    dict(kind='box', text='QALS Z02/Z03 -> LOT_JR_BASE\n(fallback JR sibling)'),
    dict(kind='box', text='Simpan cache GT_TRACE_DATA;\nGET_MT_LOTS bila multi-level'),
    dict(kind='term', text='End'),
]

if __name__ == '__main__':
    out = sys.argv[1]
    render(FLOW1, out + '/flow_zqm002.png', width=1130)
    render(FLOW2, out + '/flow_trace_lot_zqm002.png', width=1130)
