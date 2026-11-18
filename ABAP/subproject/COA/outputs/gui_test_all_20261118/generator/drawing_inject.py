"""Suntik drawing (gambar + panah konektor + kotak teks) ke xlsx hasil LibreOffice.
Semua objek memakai absoluteAnchor (posisi absolut EMU) sehingga bisa digeser bebas di Excel."""
import zipfile, re, io
from xml.sax.saxutils import escape

NS = ('xmlns:xdr="http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing" '
      'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"')


def pic_xml(i, name, rid, x, y, cx, cy):
    return (f'<xdr:absoluteAnchor><xdr:pos x="{x}" y="{y}"/><xdr:ext cx="{cx}" cy="{cy}"/>'
            f'<xdr:pic><xdr:nvPicPr><xdr:cNvPr id="{i}" name="{escape(name)}"/><xdr:cNvPicPr><a:picLocks noChangeAspect="1"/></xdr:cNvPicPr></xdr:nvPicPr>'
            f'<xdr:blipFill><a:blip r:embed="{rid}"/><a:stretch><a:fillRect/></a:stretch></xdr:blipFill>'
            f'<xdr:spPr><a:xfrm><a:off x="{x}" y="{y}"/><a:ext cx="{cx}" cy="{cy}"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom>'
            f'<a:ln w="9525"><a:solidFill><a:srgbClr val="9E9E9E"/></a:solidFill></a:ln></xdr:spPr></xdr:pic><xdr:clientData/></xdr:absoluteAnchor>')


def arrow_xml(i, name, x1, y1, x2, y2, color, w=19050):
    ox, oy = min(x1, x2), min(y1, y2)
    cx, cy = abs(x2 - x1), abs(y2 - y1)
    flip = ''
    if x2 < x1: flip += ' flipH="1"'
    if y2 < y1: flip += ' flipV="1"'
    return (f'<xdr:absoluteAnchor><xdr:pos x="{ox}" y="{oy}"/><xdr:ext cx="{cx}" cy="{cy}"/>'
            f'<xdr:cxnSp macro=""><xdr:nvCxnSpPr><xdr:cNvPr id="{i}" name="{escape(name)}"/><xdr:cNvCxnSpPr/></xdr:nvCxnSpPr>'
            f'<xdr:spPr><a:xfrm{flip}><a:off x="{ox}" y="{oy}"/><a:ext cx="{cx}" cy="{cy}"/></a:xfrm>'
            f'<a:prstGeom prst="straightConnector1"><a:avLst/></a:prstGeom>'
            f'<a:ln w="{w}"><a:solidFill><a:srgbClr val="{color}"/></a:solidFill><a:tailEnd type="triangle" w="med" len="med"/></a:ln></xdr:spPr>'
            f'</xdr:cxnSp><xdr:clientData/></xdr:absoluteAnchor>')


def text_xml(i, name, x, y, cx, cy, text, sz=1000, bold=True, color='1F1F1F'):
    b = ' b="1"' if bold else ''
    return (f'<xdr:absoluteAnchor><xdr:pos x="{x}" y="{y}"/><xdr:ext cx="{cx}" cy="{cy}"/>'
            f'<xdr:sp macro="" textlink=""><xdr:nvSpPr><xdr:cNvPr id="{i}" name="{escape(name)}"/><xdr:cNvSpPr txBox="1"/></xdr:nvSpPr>'
            f'<xdr:spPr><a:xfrm><a:off x="{x}" y="{y}"/><a:ext cx="{cx}" cy="{cy}"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/></xdr:spPr>'
            f'<xdr:txBody><a:bodyPr wrap="square" lIns="0" tIns="0" rIns="0" bIns="0" rtlCol="0" anchor="ctr"/><a:lstStyle/>'
            f'<a:p><a:r><a:rPr lang="en-US" sz="{sz}"{b}><a:solidFill><a:srgbClr val="{color}"/></a:solidFill><a:latin typeface="Arial"/></a:rPr><a:t>{escape(text)}</a:t></a:r></a:p></xdr:txBody>'
            f'</xdr:sp><xdr:clientData/></xdr:absoluteAnchor>')


def inject(src, dst, sheets):
    """sheets: {sheet_name: [ ('pic', name, png_bytes, x,y,cx,cy) | ('arrow', name, x1,y1,x2,y2,color) | ('text', name,x,y,cx,cy,text) ]}"""
    zin = zipfile.ZipFile(src)
    files = {n: zin.read(n) for n in zin.namelist()}
    wb = files['xl/workbook.xml'].decode('utf8')
    rels = files['xl/_rels/workbook.xml.rels'].decode('utf8')
    rid_of = {}
    for m in re.finditer(r'<sheet [^>]*?name="([^"]+)"[^>]*?r:id="([^"]+)"', wb):
        rid_of[m.group(1)] = m.group(2)
    target_of = {}
    for m in re.finditer(r'<Relationship [^>]*?>', rels):
        t = m.group(0)
        i = re.search(r'Id="([^"]+)"', t).group(1)
        tg = re.search(r'Target="([^"]+)"', t).group(1)
        target_of[i] = tg
    ct = files['[Content_Types].xml'].decode('utf8')
    if 'Extension="png"' not in ct:
        ct = ct.replace('<Override', '<Default Extension="png" ContentType="image/png"/><Override', 1)
    media_n = 0
    dn = 0
    for sname, items in sheets.items():
        dn += 1
        tg = target_of[rid_of[sname]]
        tg = tg.lstrip('/')
        sheet_path = tg if tg.startswith('xl/') else 'xl/' + tg
        base = sheet_path.rsplit('/', 1)[1]
        drels = []
        body = []
        oid = 2
        for it in items:
            oid += 1
            if it[0] == 'pic':
                _, name, png, x, y, cx, cy = it
                media_n += 1
                mp = f'xl/media/image{media_n}.png'
                files[mp] = png
                rid = f'rId{len(drels)+1}'
                drels.append(f'<Relationship Id="{rid}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="../media/image{media_n}.png"/>')
                body.append(pic_xml(oid, name, rid, x, y, cx, cy))
            elif it[0] == 'arrow':
                _, name, x1, y1, x2, y2, color = it
                body.append(arrow_xml(oid, name, x1, y1, x2, y2, color))
            elif it[0] == 'text':
                _, name, x, y, cx, cy, text = it[:7]
                body.append(text_xml(oid, name, x, y, cx, cy, text))
        dxml = f'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n<xdr:wsDr {NS}>' + ''.join(body) + '</xdr:wsDr>'
        files[f'xl/drawings/drawing{dn}.xml'] = dxml.encode('utf8')
        files[f'xl/drawings/_rels/drawing{dn}.xml.rels'] = ('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' + ''.join(drels) + '</Relationships>').encode('utf8')
        ct = ct.replace('</Types>', f'<Override PartName="/xl/drawings/drawing{dn}.xml" ContentType="application/vnd.openxmlformats-officedocument.drawing+xml"/></Types>')
        # sheet rels
        rp = f'xl/worksheets/_rels/{base}.rels'
        if rp in files:
            r = files[rp].decode('utf8')
            ids = [int(x) for x in re.findall(r'Id="rId(\d+)"', r)]
            newid = f'rId{max(ids+[0])+1}'
            r = r.replace('</Relationships>', f'<Relationship Id="{newid}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/drawing" Target="../drawings/drawing{dn}.xml"/></Relationships>')
        else:
            newid = 'rId1'
            r = ('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
                 f'<Relationship Id="{newid}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/drawing" Target="../drawings/drawing{dn}.xml"/></Relationships>')
        files[rp] = r.encode('utf8')
        sx = files[sheet_path].decode('utf8')
        if 'xmlns:r=' not in sx.split('>', 2)[1] + sx[:600]:
            sx = sx.replace('<worksheet ', '<worksheet xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" ', 1)
        tag = f'<drawing r:id="{newid}"/>'
        m = re.search(r'<(legacyDrawing|legacyDrawingHF|picture|oleObjects|controls|webPublishItems|tableParts|extLst)[ >/]', sx)
        if m:
            sx = sx[:m.start()] + tag + sx[m.start():]
        else:
            sx = sx.replace('</worksheet>', tag + '</worksheet>')
        files[sheet_path] = sx.encode('utf8')
    files['[Content_Types].xml'] = ct.encode('utf8')
    with zipfile.ZipFile(dst, 'w', zipfile.ZIP_DEFLATED) as z:
        order = ['[Content_Types].xml'] + [n for n in files if n != '[Content_Types].xml']
        for n in order:
            z.writestr(n, files[n])
