import json, re, io, os, sys, collections, difflib, subprocess, pickle
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter as L
from PIL import Image
S = '/tmp/claude-1000/-data-Projects-SAP-ABAP/f652a661-609b-4c79-b0c2-40d8b6bf2445/scratchpad'
C = '/data/Projects/SAP/ABAP/subproject/COA'
O = C + '/outputs/gui_test_all_20261118'
OUT = O + '/GUI_TEST_COA_SEMUA_SKENARIO_DEV_20261118.xlsx'
sys.path.insert(0, S)
D2 = json.load(open(S + '/data2.json'))
RD = json.load(open(O + '/read.json'))
z5ocr = json.load(open(O + '/ocr_z5.json'))
QD = D2['qals']
SCEN = {
 '0085006234': ('L-QM01, L-QM15', 'SRCADI'), '0085006235': ('L-QM02', 'SRAABI'), '0085006240': ('L-QM03', 'SRGIDI'),
 '0085006241': ('L-QM04', 'SREWEI'), '0085006242': ('L-QM05, L-QM06', 'SRVC2I'), '0085006243': ('L-QM07, L-QM08', 'SREASI'),
 '0085006244': ('L-QM09', 'SRAABI'), '0085006245': ('L-QM10', 'SRGJBI'), '0085006270': ('L-QM11', 'SRAABI'),
 '0085006271': ('L-QM12', 'SRAABI'), '0085006272': ('L-QM13', 'SREASI'), '0085006276': ('ML-QM01', 'SRACBI'),
 '0085006277': ('ML-QM02', 'SRACBI'), '0085006278': ('ML-QM03', 'SRGLBI'), '0085006279': ('ML-QM04', 'SREC7I'),
 '0085006280': ('AL-STRUKTUR', 'SRAABI, SRABDI'), '0085006281': ('AL-MIXED', 'SRAABI'), '0085006282': ('AL-VALUE1', 'SRAABI'),
 '0085006284': ('AL-VALUE2', 'SRAABI, SRAAAI'), '0085006285': ('TTA-OUTSOURCE', 'SRCBUX'), '0085006286': ('TTA-CONVERTING', 'SREYAI'),
}
DOS = list(SCEN)

ZLOG = {}
for l in open(S + '/zlog.txt'):
    p = [x.strip() for x in l.split('|')]
    if len(p) >= 4: ZLOG[(p[0], p[1])] = p[3]
BAR = ('MVTR', 'WVTR', 'OTR', 'O2TR')

def norm(s):
    return re.sub(r'[^a-z0-9]', '', s.lower().replace('\u00b0', ''))
def numv(t):
    t = t.strip().replace(',', '')
    return float(t) if re.fullmatch(r'-?\d+(\.\d+)?', t) else None

def zrows(lot):
    return RD['z5'].get('z5_%s.png' % lot)   # None bila ZQM005 tidak menampilkan lot
def screen_mean(lot, text):
    rs = zrows(lot)
    if not rs: return None, None
    best = None; bs = 0
    for r in rs:
        sc = difflib.SequenceMatcher(None, norm(text), norm(r['name'])).ratio()
        if sc > bs: best, bs = r, sc
    if best and bs >= 0.6:
        return (numv(best['mean']) if best['mean'] not in ('', '?') else None), best['y']
    return None, None

ZMAP = {}
for l in open(S + '/zmap.txt'):
    p = [x.strip() for x in l.split(' | ')]
    if p[5] != 'X': ZMAP.setdefault(p[2], (p[3], p[6]))
order = collections.defaultdict(list)
for l in open(C + '/outputs/MT_20261118_dev_after_543.txt'):
    if l.startswith('|'):
        p = l.rstrip('\n').split('|')
        if p[5] not in order[p[1]]: order[p[1]].append(p[5])
RW = {(r['do'], r['mic']): r for r in D2['rows']}

data = {}
for do in DOS:
    items = []
    z2 = RD['z2']['z2_%s.png' % do]
    for i, mic in enumerate(order[do]):
        zr = z2[i]
        r = RW.get((do, mic), dict(srcs=[], val=''))
        srcs = []
        for sc in r['srcs']:
            lots = []
            for l in sc['lots']:
                sm, y = screen_mean(l['lot'], l['text'])
                lots.append(dict(lot=l['lot'], text=l['text'], screen=sm, y=y, db=l['mean'], shown=zrows(l['lot']) is not None))
            key = tuple(l['lot'] for l in lots)
            dup = [x for x in srcs if sc.get('kind') == 'SR' and x.get('kind') == 'SR' and tuple(l['lot'] for l in x['lots']) == key]
            if dup: dup[0]['ins'] += ' / ' + sc['ins']
            else: srcs.append(dict(ins=sc['ins'], lots=lots, kind=sc.get('kind')))
        items.append(dict(no=i + 1, mic=mic, desc=ZMAP.get(mic, ('?', mic))[1], map=ZMAP.get(mic, ('?', ''))[0], srcs=srcs,
                          zv=zr['val'], low=zr['low'], up=zr['up'], y2=zr['y'], hv=r['val']))
    data[do] = items
pickle.dump(data, open(S + '/data_build.pkl', 'wb'))

# ---------- Excel ----------
wb = Workbook()
FONT = 'Arial'
fN = Font(name=FONT, size=10); fB = Font(name=FONT, size=10, bold=True)
fH = Font(name=FONT, size=10, bold=True, color='FFFFFF'); fT = Font(name=FONT, size=14, bold=True)
fBlue = Font(name=FONT, size=10, color='0000FF')
fillH = PatternFill('solid', fgColor='1F4E78'); fillIn = PatternFill('solid', fgColor='F2F2F2'); fillDb = PatternFill('solid', fgColor='FCE4D6')
thin = Side(style='thin', color='BFBFBF'); bd = Border(left=thin, right=thin, top=thin, bottom=thin)
ctr = Alignment(horizontal='center', vertical='center', wrap_text=True)
lft = Alignment(horizontal='left', vertical='center', wrap_text=True)
PAL = ['E53935', '1E88E5', '43A047', 'FB8C00', '8E24AA', '00ACC1', '6D4C41', 'D81B60', '3949AB', '7CB342']
PT = 12700; PX = 9525
S2 = 0.58; S5 = 0.66; ROW1_Y = 187
sum_ws = wb.active; sum_ws.title = 'Ringkasan'
sheets_draw = {}; sheet_stats = {}

def crop_png(path, box, scale):
    im = Image.open(path).convert('RGB').crop(box)
    im = im.resize((int(im.width * scale), int(im.height * scale)), Image.LANCZOS)
    im = im.quantize(colors=96, method=Image.Quantize.MEDIANCUT).convert('RGB')
    b = io.BytesIO(); im.save(b, 'PNG', optimize=True)
    return b.getvalue(), im.width, im.height

for do in DOS:
    items = data[do]
    ws = wb.create_sheet(do)
    nl = min(max([len(i['srcs']) for i in items] + [1]), 12)
    c_m0 = 7
    c_avg = c_m0 + nl
    c_zv, c_tol, c_sel, c_st, c_note = c_avg + 1, c_avg + 2, c_avg + 3, c_avg + 4, c_avg + 5
    ws.sheet_view.showGridLines = False
    ws['A1'] = 'Uji SAP GUI ZQM002 vs ZQM005: DO %s' % do; ws['A1'].font = fT
    ws['A2'] = 'Skenario %s | Material %s | Development AIX client 130 | uji 18 Nov 2026 lewat SAP GUI di server' % SCEN[do]; ws['A2'].font = fN
    ws['A3'] = ('Aturan ZQM002: tiap INSLOT unik per MIC punya satu nilai (lot sendiri; bila lot JR tanpa hasil diganti lot saudara terdekat; SR converting = rata-rata lot saudara). '
                'Nilai DO = rata-rata nilai INSLOT unik. Kolom Sumber 1..n = INSLOT; angkanya Mean Value ZQM005 lot sumber. Panah = objek Excel, bisa digeser.')
    ws['A3'].font = Font(name=FONT, size=9, italic=True)
    hdr = ['No', 'MIC ZQM002', 'Deskripsi', 'Mapping for Get Insp.', 'Sumber nilai (INSLOT > lot sumber ZQM005)', 'Karakteristik ZQM005']
    hdr += ['Sumber %d' % (k + 1) for k in range(nl)] + ['Rata-rata sumber', 'Value ZQM002', 'Toleransi bulat', 'Selisih', 'Status', 'Catatan']
    HR = 5
    for j, h in enumerate(hdr, 1):
        c = ws.cell(HR, j, h); c.font = fH; c.fill = fillH; c.alignment = ctr; c.border = bd
    ws.row_dimensions[HR].height = 42
    for j, w in enumerate([5, 13, 24, 15, 44, 26] + [10] * nl + [11, 11, 10, 10, 26, 46], 1): ws.column_dimensions[L(j)].width = w
    r0 = HR + 1
    for i, it in enumerate(items):
        r = r0 + i
        zvn = numv(it['zv']) if it['zv'] else None
        dec = len(it['zv'].split('.')[1]) if it['zv'] and '.' in it['zv'] else 0
        lines = []
        for k, sc in enumerate(it['srcs']):
            lines.append('%d) %s > %s' % (k + 1, sc['ins'], ', '.join(l['lot'] for l in sc['lots'])))
        ws.row_dimensions[r].height = max(20, 13 * max(1, len(lines)))
        char = ''
        for sc in it['srcs']:
            for l in sc['lots']:
                if l['text']: char = l['text']
        vals = [it['no'], it['mic'], it['desc'], it['map'], '\n'.join(lines) if lines else 'tidak ada lot', char or '-']
        for j, v in enumerate(vals, 1):
            c = ws.cell(r, j, v); c.font = fN; c.border = bd; c.alignment = lft if j in (3, 5, 6) else ctr
        notes = []
        for k in range(nl):
            c = ws.cell(r, c_m0 + k); c.border = bd; c.alignment = ctr; c.font = fBlue; c.fill = fillIn
            if k >= len(it['srcs']): continue
            parts = []
            for l in it['srcs'][k]['lots']:
                v = l['screen'] if l['screen'] is not None else l['db']
                if l['screen'] is not None and l['db'] is not None:
                    st = repr(round(l['screen'], 6)); dd = len(st.split('.')[1].rstrip('0')) if '.' in st else 0
                    if abs(l['screen'] - l['db']) <= 0.5 * 10 ** -dd + 1e-9:
                        if dd < 2 and abs(l['screen'] - l['db']) > 1e-9:
                            notes.append('lot %s: layar ZQM005 membulatkan %s, dipakai angka penuh QAMR %.4f' % (l['lot'], st, l['db']))
                        v = l['db']
                    else:
                        notes.append('lot %s: layar %s beda dari QAMR %.4f' % (l['lot'], st, l['db']))
                if l['screen'] is None and l['db'] is not None:
                    c.fill = fillDb
                    notes.append(('lot %s tidak tampil di ZQM005, angka dari QAMR' if not l['shown'] else 'lot %s: angka dari QAMR (sel layar kosong)') % l['lot'])
                if v is not None: parts.append(round(v, 6))
            if len(parts) == 1: c.value = parts[0]
            elif len(parts) > 1: c.value = '=AVERAGE(%s)' % ','.join(str(p) for p in parts)
            c.number_format = '0.0000'
        rng = '%s%d:%s%d' % (L(c_m0), r, L(c_m0 + nl - 1), r)
        c = ws.cell(r, c_avg, '=IF(COUNT(%s)=0,"-",AVERAGE(%s))' % (rng, rng)); c.number_format = '0.0000'
        c = ws.cell(r, c_zv, zvn); c.font = fBlue; c.number_format = '0' if dec == 0 else '0.' + '0' * dec
        c = ws.cell(r, c_tol, '=0.5*10^-%d' % dec); c.number_format = '0.000'
        avg = '%s%d' % (L(c_avg), r); zv = '%s%d' % (L(c_zv), r)
        c = ws.cell(r, c_sel, '=IF(ISNUMBER(%s),%s-%s,"-")' % (avg, avg, zv)); c.number_format = '0.0000'
        ws.cell(r, c_st, '=IF(COUNT(%s)=0,IF(%s=0,"TANPA LOT","BEDA"),IF(ABS(%s%d)<=%s%d+0.000001,"COCOK","BEDA"))' % (rng, zv, L(c_sel), r, L(c_tol), r))
        # kasus khusus yang dijelaskan aturan
        if do in ('0085006285', '0085006286') and mic_is_stnt(it) if False else False: pass
        if (do, it['mic']) in ZLOG:
            ws.cell(r, c_st, 'OVERRIDE ZLOG_COA')
            notes.insert(0, 'Value di ZQM002 = angka yang diketik user di ZLOG_COA (%s), bukan rata-rata lot.' % ZLOG[(do, it['mic'])])
        elif any(b in it['mic'] for b in BAR) and it['srcs']:
            ws.cell(r, c_st, '=IF(COUNT(%s)=0,"TANPA LOT",IF(ABS(%s%d)<=%s%d+0.000001,"COCOK","QASE (bukan ZQM005)"))' % (rng, L(c_sel), r, L(c_tol), r) if False else
                    '=IF(ABS(%s%d)<=%s%d+0.000001,"COCOK","QASE (bukan ZQM005)")' % (L(c_sel), r, L(c_tol), r))
            notes.append('MVTR/O2TR: program rata-rata cycle terakhir dari QASE, ZQM005 hanya menampilkan Mean QAMR.')
        if do in ('0085006285', '0085006286') and it['mic'].endswith('STNT'):
            ws.cell(r, c_st, 'BEDA: tampil 0, seharusnya kosong')
            notes.insert(0, 'Mapping SR Base Film, lot Z04 tidak ada. ZQM002 tampil 0; harapan user kosong.')
        elif not it['srcs']:
            notes.append('Tidak ada inspection lot: ZQM002 tampil 0 (konvensi program).')
        ws.cell(r, c_note, ' '.join(dict.fromkeys(notes)))
        for j in (c_avg, c_tol, c_sel, c_st, c_note):
            c = ws.cell(r, j); c.border = bd; c.font = fN; c.alignment = lft if j in (c_note, c_st) else ctr
        ws.cell(r, c_zv).border = bd; ws.cell(r, c_zv).alignment = ctr
    rl = r0 + len(items) - 1
    for k, (lab, pat) in enumerate((('COCOK', 'COCOK'), ('TANPA LOT', 'TANPA LOT'), ('BEDA', 'BEDA*'), ('OVERRIDE ZLOG_COA', 'OVERRIDE*'), ('QASE (bukan ZQM005)', 'QASE*'))):
        ws.cell(rl + 2 + k, 5, lab).font = fB
        ws.cell(rl + 2 + k, 6, '=COUNTIF(%s%d:%s%d,"%s")' % (L(c_st), r0, L(c_st), rl, pat)).font = fB
    sheet_stats[do] = dict(n=len(items), nlot=len(set(l['lot'] for i in items for s in i['srcs'] for l in s['lots'])),
                           rcocok=rl + 2, rtanpa=rl + 3, rbeda=rl + 4, rovr=rl + 5, rqase=rl + 6)
    ws.freeze_panes = ws.cell(HR + 1, 3)

    # ---------- gambar & panah ----------
    total_pt = sum((ws.row_dimensions[rr].height or 15) for rr in range(1, rl + 8))
    ytop = int((total_pt + 24) * PT)
    draw = []
    p2 = O + '/zqm002/z2_%s.png' % do
    n = len(items)
    box2 = (0, 180, 1312, 224 + 28 * n - 8 + 20)
    b2, w2, h2 = crop_png(p2, box2, S2)
    x2 = 10 * PX; y2 = ytop + 22 * PX
    draw.append(('text', 'Judul ZQM002', x2, ytop, 700 * PX, 20 * PX, 'ZQM002 (Print COA) DO %s' % do))
    draw.append(('pic', 'ZQM002 %s' % do, b2, x2, y2, w2 * PX, h2 * PX))
    lots_all = []
    for it in items:
        for sc in it['srcs']:
            for l in sc['lots']:
                if l['lot'] not in lots_all: lots_all.append(l['lot'])
    ncol = 1 if len(lots_all) <= 4 else (2 if len(lots_all) <= 10 else 3)
    xz5 = x2 + w2 * PX + 260 * PX
    blocks = {}; cur = [ytop] * ncol
    for lot in lots_all:
        pth = O + '/zqm005/z5_%s.png' % lot
        qq = QD.get(lot, {})
        cap = 'ZQM005 lot %s | %s | batch %s | plant %s' % (lot, qq.get('mat', ''), qq.get('batch', ''), qq.get('plant', ''))
        rs = zrows(lot)
        ci = min(range(ncol), key=lambda c: cur[c])
        if rs:
            last_y = max([r_['y'] for r_ in rs] + [ROW1_Y])
            b5, w5, h5 = crop_png(pth, (0, 158, int(z5ocr['z5_%s.png' % lot]['mean'][0]) + 95, last_y + 14), S5)
            x5 = xz5 + ci * (w5 + 120) * PX; y5 = cur[ci] + 22 * PX
            draw.append(('text', 'Judul lot %s' % lot, x5, cur[ci], w5 * PX, 20 * PX, cap))
            draw.append(('pic', 'ZQM005 %s' % lot, b5, x5, y5, w5 * PX, h5 * PX))
            blocks[lot] = (x5, y5, S5, z5ocr.get('z5_%s.png' % lot))
            cur[ci] = y5 + h5 * PX + 30 * PX
        else:
            b5, w5, h5 = crop_png(pth, (0, 0, 470, 60), 1.0) if os.path.exists(pth) else (None, 0, 0)
            x5 = xz5 + ci * (1012 * S5 + 120) * PX; y5 = cur[ci] + 36 * PX
            draw.append(('text', 'Judul lot %s' % lot, x5, cur[ci], int(1012 * S5) * PX, 34 * PX, cap + ' | ZQM005: Tidak ada data!'))
            if b5: draw.append(('pic', 'ZQM005 %s tidak ada data' % lot, b5, x5, y5, w5 * PX, h5 * PX))
            cur[ci] = y5 + (h5 + 30) * PX
    for i, it in enumerate(items):
        col = PAL[i % len(PAL)]
        seen = set()
        for sc in it['srcs']:
            for l in sc['lots']:
                if l['lot'] in seen or l['lot'] not in blocks or l['y'] is None: continue
                seen.add(l['lot'])
                x5, y5, s5, d = blocks[l['lot']]
                sx = x2 + int((1306 - box2[0]) * S2 * PX); sy = y2 + int((it['y2'] - box2[1]) * S2 * PX)
                ex = x5 + int((d['mean'][0] - 8) * s5 * PX); ey = y5 + int((l['y'] - 158) * s5 * PX)
                draw.append(('arrow', 'Panah %s lot %s' % (it['mic'], l['lot']), sx, sy, ex, ey, col))
    sheets_draw[do] = draw

# ---------- sheet Ringkasan ----------
ws = sum_ws
ws.sheet_view.showGridLines = False
ws['A1'] = 'Hasil uji SAP GUI ZQM002 vs ZQM005: semua skenario COA (21 DO)'; ws['A1'].font = fT
ws['A2'] = 'Sistem Development AIX client 130, program ZQMI_COA versi DEV 18 Nov 2026 (TTA ikut ZEQM015). Uji dijalankan lewat SAP GUI di server (Xvfb :99), bukan laptop. Hanya membaca, tidak ada posting.'
ws['A2'].font = fN
ws['A3'] = 'Metode: tiap DO dijalankan di ZQM002; semua inspection lot yang dipakai program (lewat harness read-only) dibuka di ZQM005 (Date + Plant + Material + Batch, Jumbo/Slitting Roll). Mean Value tiap lot dirata-rata per MIC lalu dibandingkan dengan Value ZQM002.'
ws['A3'].font = fN
H = ['No', 'Skenario', 'No DO', 'Material', 'Jumlah MIC', 'Jumlah lot ZQM005', 'COCOK', 'TANPA LOT', 'BEDA', 'Hasil', 'Sheet']
for j, h in enumerate(H, 1):
    c = ws.cell(5, j, h); c.font = fH; c.fill = fillH; c.alignment = ctr; c.border = bd
ws.row_dimensions[5].height = 30
for j, w in enumerate([5, 18, 14, 18, 11, 14, 10, 11, 8, 16, 14], 1): ws.column_dimensions[L(j)].width = w
for i, do in enumerate(DOS):
    r = 6 + i; st = sheet_stats[do]
    q = "'%s'!" % do
    vals = [i + 1, SCEN[do][0], do, SCEN[do][1], st['n'], st['nlot'],
            '=%sF%d' % (q, st['rcocok']), '=%sF%d' % (q, st['rtanpa']), '=%sF%d' % (q, st['rbeda']),
            '=IF(I%d=0,"LULUS","ADA BEDA")' % r, do]
    for j, v in enumerate(vals, 1):
        c = ws.cell(r, j, v); c.font = fN; c.border = bd; c.alignment = ctr
    ws.cell(r, 11).hyperlink = "#'%s'!A1" % do
    ws.cell(r, 11).font = Font(name=FONT, size=10, color='0563C1', underline='single')
rt = 6 + len(DOS)
ws.cell(rt, 2, 'Total').font = fB
for j, col in ((5, 'E'), (6, 'F'), (7, 'G'), (8, 'H'), (9, 'I')):
    c = ws.cell(rt, j, '=SUM(%s6:%s%d)' % (col, col, rt - 1)); c.font = fB; c.border = bd; c.alignment = ctr
ws.cell(rt + 2, 1, 'Keterangan').font = fB
notes = [
 'COCOK: |rata-rata Mean Value lot - Value ZQM002| <= setengah satuan desimal yang tampil di layar.',
 'TANPA LOT: MIC tidak punya inspection lot; ZQM002 menampilkan 0 (konvensi program, mis. DO 0085006280/81).',
 'BEDA: nilai tidak sama, atau hasil yang tidak sesuai harapan user (DO 0085006285/86 PCADSTNT/PEYASTNT: mapping SR Base Film, tanpa lot Z04, ZQM002 tampil 0 padahal diharapkan kosong).',
 'Sel biru = angka yang dibaca dari layar SAP (Mean Value ZQM005 dan Value ZQM002); sel hitam = rumus.',
 'Setiap sheet DO berisi: tabel perbandingan, screenshot ZQM002, screenshot ZQM005 tiap inspection lot, dan panah (objek Excel yang bisa digeser).',
]
for i, t in enumerate(notes):
    ws.cell(rt + 3 + i, 1, t).font = fN

wb.save(S + '/pre_all.xlsx')
json.dump({k: [(x[0],) + tuple(x[1:2]) for x in v] for k, v in sheets_draw.items()} if False else {}, open(S + '/_d.json', 'w'))
import pickle
pickle.dump(sheets_draw, open(S + '/draw.pkl', 'wb'))
print('saved pre_all', {k: (len(v)) for k, v in sheets_draw.items()})
