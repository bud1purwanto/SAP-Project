"""Bangun WRICEF/FS ZMM061 dengan meng-klon format template FS PO Notification.

Pemakaian:
  python3 build_wricef.py <template.docx> <unpack_dir> <out.docx> [pages.json]
pages.json (opsional) = {"<heading text>": page} untuk mengisi nomor halaman TOC.
"""
import copy
import json
import os
import shutil
import sys
import zipfile

from lxml import etree

sys.path.insert(0, os.path.dirname(__file__))
from wricef_content import BODY, HEADER_OLD, HEADER_NEW, IMAGES  # noqa: E402

W = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
WP = 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing'
A = 'http://schemas.openxmlformats.org/drawingml/2006/main'
NS = {'w': W, 'wp': WP, 'a': A}


def q(tag):
    p, t = tag.split(':')
    return '{%s}%s' % (NS[p], t)


tpl, unpack, out = sys.argv[1], sys.argv[2], sys.argv[3]
pages = json.load(open(sys.argv[4])) if len(sys.argv) > 4 else {}

if os.path.exists(unpack):
    shutil.rmtree(unpack)
with zipfile.ZipFile(tpl) as z:
    z.extractall(unpack)

doc_path = os.path.join(unpack, 'word', 'document.xml')
tree = etree.parse(doc_path)
body = tree.getroot().find('w:body', NS)
els = list(body)
P = {
    'cover1': els[0], 'cover2': els[1], 'cover3': els[2], 'cover4': els[3], 'cover5': els[4],
    'break': els[5], 'h1': els[6], 'h2': els[7], 'empty': els[9], 'toc': els[17],
    'label': els[20], 'para': els[21], 'field': els[22], 'note': els[34],
    'figintro': els[49], 'image1': els[50], 'figcap': els[51], 'sub': els[54],
    'end': els[116], 'tbl': els[14], 'sect': els[117],
}


def set_runs(p, text):
    """Ganti isi paragraf dengan satu run, mempertahankan rPr run pertama."""
    runs = p.findall('w:r', NS)
    rpr = runs[0].find('w:rPr', NS) if runs else None
    for child in list(p):
        if child.tag != q('w:pPr'):
            p.remove(child)
    r = etree.SubElement(p, q('w:r'))
    if rpr is not None:
        r.append(copy.deepcopy(rpr))
    t = etree.SubElement(r, q('w:t'))
    t.text = text
    t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
    return r


def para(kind, text):
    p = copy.deepcopy(P[kind])
    set_runs(p, text)
    return p


bm_id = [100]
headings = []


def heading(level, text):
    p = copy.deepcopy(P['h1' if level == 1 else 'h2'])
    r = set_runs(p, text)
    ppr = p.find('w:pPr', NS)
    ppr.insert(1, etree.Element(q('w:keepNext')))   # setelah pStyle: cegah heading yatim
    bm_id[0] += 1
    name = '_Toc9%08d' % bm_id[0]
    bs = etree.Element(q('w:bookmarkStart'))
    bs.set(q('w:id'), str(bm_id[0]))
    bs.set(q('w:name'), name)
    be = etree.Element(q('w:bookmarkEnd'))
    be.set(q('w:id'), str(bm_id[0]))
    r.addprevious(bs)
    r.addnext(be)
    headings.append((level, text, name))
    return p


def field(label, value):
    p = copy.deepcopy(P['field'])
    runs = p.findall('w:r', NS)
    runs[0].find('w:t', NS).text = label
    runs[2].find('w:t', NS).text = value
    return p


def cell_text(tc, text):
    ps = tc.findall('w:p', NS)
    for extra in ps[1:]:
        tc.remove(extra)
    set_runs(ps[0], text)


def table(widths, rows):
    src = P['tbl']
    tbl = etree.Element(q('w:tbl'))
    tbl.append(copy.deepcopy(src.find('w:tblPr', NS)))
    tbl.find('w:tblPr/w:tblW', NS).set(q('w:w'), str(sum(widths)))
    grid = etree.SubElement(tbl, q('w:tblGrid'))
    for w in widths:
        etree.SubElement(grid, q('w:gridCol')).set(q('w:w'), str(w))
    src_rows = src.findall('w:tr', NS)
    protos = [src_rows[0], src_rows[1], src_rows[2]]   # header, putih, abu
    for i, row in enumerate(rows):
        proto = protos[0] if i == 0 else protos[1 if i % 2 == 1 else 2]
        tr = copy.deepcopy(proto)
        trpr = tr.find('w:trPr', NS)
        if trpr is None:
            trpr = etree.Element(q('w:trPr'))
            tr.insert(0, trpr)
        if trpr.find('w:cantSplit', NS) is None:
            trpr.insert(0, etree.Element(q('w:cantSplit')))
        tcs = tr.findall('w:tc', NS)
        for extra in tcs[1:]:
            tr.remove(extra)
        base = tcs[0]
        tr.remove(base)
        for w, txt in zip(widths, row):
            tc = copy.deepcopy(base)
            tc.find('w:tcPr/w:tcW', NS).set(q('w:w'), str(w))
            cell_text(tc, txt)
            tr.append(tc)
        tbl.append(tr)
    return tbl


def image(idx, cx):
    p = copy.deepcopy(P['image1'])
    from PIL import Image
    path, rid = IMAGES[idx]
    w, h = Image.open(path).size
    cy = int(cx * h / w)
    p.find('.//wp:extent', NS).set('cx', str(cx))
    p.find('.//wp:extent', NS).set('cy', str(cy))
    p.find('.//a:xfrm/a:ext', NS).set('cx', str(cx))
    p.find('.//a:xfrm/a:ext', NS).set('cy', str(cy))
    p.find('.//wp:docPr', NS).set('id', str(idx + 1))
    p.find('.//wp:docPr', NS).set('name', 'Picture %d' % (idx + 1))
    p.find('.//a:blip', NS).set('{http://schemas.openxmlformats.org/officeDocument/2006/relationships}embed', rid)
    return p


# ---- susun body baru
new = []
for op in BODY:
    k = op[0]
    if k == 'h1':
        new.append(heading(1, op[1]))
    elif k == 'h2':
        new.append(heading(2, op[1]))
    elif k == 'field':
        new.append(field(op[1], op[2]))
    elif k == 'table':
        new.append(table(op[1], op[2]))
    elif k == 'image':
        new.append(image(op[1], op[2]))
    elif k == 'break':
        new.append(copy.deepcopy(P['break']))
    elif k == 'empty':
        new.append(copy.deepcopy(P['empty']))
    elif k == 'toc':
        new.append('TOC')
    else:
        new.append(para(k, op[1]))

# ---- TOC: klon entri template, ganti teks/anchor/halaman
sdt = copy.deepcopy(P['toc'])
content = sdt.find('w:sdtContent', NS)
tps = list(content)
first, toc1, toc2, last = tps[0], tps[4], tps[1], tps[-1]
for c in list(content):
    content.remove(c)


def toc_entry(proto, text, anchor, page):
    p = copy.deepcopy(proto)
    hl = p.find('w:hyperlink', NS)
    hl.set(q('w:anchor'), anchor)
    hl.find('w:r/w:t', NS).text = text
    for it in hl.iter(q('w:instrText')):
        it.text = ' PAGEREF %s \\h ' % anchor
    ts = hl.findall('w:r/w:t', NS)
    ts[-1].text = str(page)
    return p


for i, (lvl, text, name) in enumerate(headings):
    proto = first if i == 0 else (toc1 if lvl == 1 else toc2)
    content.append(toc_entry(proto, text, name, pages.get(text, 0)))
content.append(last)

for c in list(body):
    body.remove(c)
for e in new:
    body.append(sdt if isinstance(e, str) else e)
body.append(P['sect'])
tree.write(doc_path, xml_declaration=True, encoding='UTF-8', standalone=True)

# ---- header & gambar
hp = os.path.join(unpack, 'word', 'header1.xml')
s = open(hp, encoding='utf-8').read()
assert HEADER_OLD in s, 'teks header template tidak ditemukan'
open(hp, 'w', encoding='utf-8').write(s.replace(HEADER_OLD, HEADER_NEW))
for path, rid in IMAGES:
    target = {'rId7': 'image1.png', 'rId8': 'image2.png'}[rid]
    shutil.copy(path, os.path.join(unpack, 'word', 'media', target))

if os.path.exists(out):
    os.remove(out)
with zipfile.ZipFile(tpl) as zt, zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as zo:
    for info in zt.infolist():   # pertahankan urutan entry template
        zo.write(os.path.join(unpack, info.filename), info.filename)
print('OK', out, len(headings), 'headings')
