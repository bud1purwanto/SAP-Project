#!/usr/bin/env python3
"""Build PDF dokumentasi flow penelusuran Inspection Lot COA (multi-level converting).
Output: docs/Flow_Penelusuran_Lot_COA_Multi_Level.html + .pdf (render via Chrome headless).
"""
import pathlib
import subprocess

BASE = pathlib.Path(__file__).resolve().parent.parent
DOCS = BASE / "docs"
HTML = DOCS / "Flow_Penelusuran_Lot_COA_Multi_Level.html"
PDF = DOCS / "Flow_Penelusuran_Lot_COA_Multi_Level.pdf"

C = {
    "ink": "#1b2430", "muted": "#5b6675", "line": "#cfd6df", "soft": "#f4f6f9",
    "sr": "#1f7a72", "sr_bg": "#e6f3f1", "jr": "#2f5d9e", "jr_bg": "#e8eef8",
    "amber": "#b7791f", "amber_bg": "#fbf3e4", "green": "#2f7d4f", "green_bg": "#e7f4ec",
    "red": "#b4423a", "red_bg": "#fbeceb", "navy": "#1f3a5f",
}


def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


# ---------------------------------------------------------------- chain SVG
def chain_svg(nodes, terminal, width=640, note_w=250, highlight=None):
    """nodes: list of dict(stage, mat, batch, lot, label, slot, tone, mics)
    tone: 'conv' | 'base' | 'mislabel'"""
    box_w, box_h, gap = 268, 46, 20
    x0 = 4
    h = len(nodes) * (box_h + gap) + 54
    out = [f'<svg viewBox="0 0 {width} {h}" width="100%" xmlns="http://www.w3.org/2000/svg" '
           f'font-family="Noto Sans, DejaVu Sans, sans-serif">']
    out.append('<defs><marker id="ar" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="7" '
               f'markerHeight="7" orient="auto"><path d="M0,0 L10,5 L0,10 z" fill="{C["muted"]}"/></marker></defs>')
    y = 8
    for i, n in enumerate(nodes):
        col = C["sr"] if n["stage"] == "SR" else C["jr"]
        bg = C["sr_bg"] if n["stage"] == "SR" else C["jr_bg"]
        stroke = col
        dash = ""
        if highlight and i in highlight:
            stroke = C["amber"]
        out.append(f'<rect x="{x0}" y="{y}" width="{box_w}" height="{box_h}" rx="7" fill="{bg}" '
                   f'stroke="{stroke}" stroke-width="{2.2 if highlight and i in highlight else 1.2}"{dash}/>')
        out.append(f'<rect x="{x0}" y="{y}" width="34" height="{box_h}" rx="7" fill="{col}"/>'
                   f'<rect x="{x0+27}" y="{y}" width="8" height="{box_h}" fill="{col}"/>')
        out.append(f'<text x="{x0+17}" y="{y+box_h/2+4.5}" text-anchor="middle" font-size="12.5" '
                   f'font-weight="700" fill="#fff">{n["stage"]}</text>')
        out.append(f'<text x="{x0+46}" y="{y+19}" font-size="13" font-weight="700" fill="{C["ink"]}">'
                   f'{esc(n["mat"])}<tspan font-weight="400" fill="{C["muted"]}" font-size="11">  ·  {esc(n["label"])}</tspan></text>')
        out.append(f'<text x="{x0+46}" y="{y+36}" font-size="10.5" fill="{C["muted"]}" '
                   f'font-family="Noto Sans Mono, DejaVu Sans Mono, monospace">batch {n["batch"]} · lot {n["lot"]}</text>')
        # right side: slot + mics
        rx = x0 + box_w + 14
        if n.get("slot"):
            tone = n.get("tone", "conv")
            tc = {"conv": C["navy"], "base": C["navy"], "mislabel": C["red"], "deep": C["amber"]}[tone]
            tb = {"conv": "#eef1f6", "base": "#eef1f6", "mislabel": C["red_bg"], "deep": C["amber_bg"]}[tone]
            tw = 9 + 6.6 * len(n["slot"])
            out.append(f'<rect x="{rx}" y="{y+6}" width="{tw}" height="17" rx="8.5" fill="{tb}" stroke="{tc}" stroke-width="0.8"/>')
            out.append(f'<text x="{rx+tw/2}" y="{y+18.5}" text-anchor="middle" font-size="10" font-weight="700" '
                       f'fill="{tc}" font-family="Noto Sans Mono, DejaVu Sans Mono, monospace">{esc(n["slot"])}</text>')
        if n.get("mics"):
            mics = n["mics"]
            if len(mics) > 30 and " · " in mics:
                parts = mics.split(" · "); half = (len(parts) + 1) // 2
                l1, l2 = " · ".join(parts[:half]) + " ·", " · ".join(parts[half:])
                out.append(f'<text x="{rx}" y="{y+36}" font-size="10" fill="{C["ink"]}">{l1}</text>')
                out.append(f'<text x="{rx}" y="{y+48}" font-size="10" fill="{C["ink"]}">{l2}</text>')
            else:
                out.append(f'<text x="{rx}" y="{y+39}" font-size="10.5" fill="{C["ink"]}">{mics}</text>')
        # arrow to next
        if i < len(nodes) - 1:
            ax = x0 + box_w / 2
            out.append(f'<line x1="{ax}" y1="{y+box_h+2}" x2="{ax}" y2="{y+box_h+gap-4}" stroke="{C["muted"]}" '
                       f'stroke-width="1.3" marker-end="url(#ar)"/>')
            if n.get("edge"):
                out.append(f'<text x="{ax+9}" y="{y+box_h+gap/2+4}" font-size="9.5" fill="{C["muted"]}" font-style="italic">{esc(n["edge"])}</text>')
        y += box_h + gap
    # terminal
    ax = x0 + box_w / 2
    y_t = y - gap
    out.append(f'<line x1="{ax}" y1="{y_t+2}" x2="{ax}" y2="{y_t+gap-4}" stroke="{C["muted"]}" stroke-width="1.3" marker-end="url(#ar)"/>')
    out.append(f'<rect x="{x0}" y="{y_t+gap}" width="{box_w}" height="26" rx="13" fill="{C["soft"]}" '
               f'stroke="{C["line"]}" stroke-dasharray="4 3"/>')
    out.append(f'<text x="{ax}" y="{y_t+gap+17}" text-anchor="middle" font-size="10" fill="{C["muted"]}">{esc(terminal)}</text>')
    out.append('</svg>')
    return "\n".join(out)


# ---------------------------------------------------------------- decision flow SVG
def flow_svg():
    W = 640
    o = [f'<svg viewBox="0 0 {W} 600" width="100%" xmlns="http://www.w3.org/2000/svg" '
         f'font-family="Noto Sans, DejaVu Sans, sans-serif">',
         '<defs><marker id="fa" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="7" markerHeight="7" orient="auto">'
         f'<path d="M0,0 L10,5 L0,10 z" fill="{C["muted"]}"/></marker></defs>']

    def box(x, y, w, h, t1, t2="", fill=C["soft"], stroke=C["line"], bold=True):
        o.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="8" fill="{fill}" stroke="{stroke}" stroke-width="1.2"/>')
        if t2:
            o.append(f'<text x="{x+w/2}" y="{y+h/2-3}" text-anchor="middle" font-size="12" font-weight="{700 if bold else 400}" fill="{C["ink"]}">{esc(t1)}</text>')
            o.append(f'<text x="{x+w/2}" y="{y+h/2+13}" text-anchor="middle" font-size="10.5" fill="{C["muted"]}">{esc(t2)}</text>')
        else:
            o.append(f'<text x="{x+w/2}" y="{y+h/2+4}" text-anchor="middle" font-size="12" font-weight="{700 if bold else 400}" fill="{C["ink"]}">{esc(t1)}</text>')

    def dia(cx, cy, w, h, t1, t2=""):
        o.append(f'<polygon points="{cx},{cy-h/2} {cx+w/2},{cy} {cx},{cy+h/2} {cx-w/2},{cy}" fill="#fff" '
                 f'stroke="{C["navy"]}" stroke-width="1.4"/>')
        o.append(f'<text x="{cx}" y="{cy-2 if t2 else cy+4}" text-anchor="middle" font-size="11.5" font-weight="700" fill="{C["navy"]}">{esc(t1)}</text>')
        if t2:
            o.append(f'<text x="{cx}" y="{cy+13}" text-anchor="middle" font-size="10.5" fill="{C["navy"]}">{esc(t2)}</text>')

    def arr(x1, y1, x2, y2, lab="", lx=None, ly=None, col=C["muted"]):
        o.append(f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{col}" stroke-width="1.4" marker-end="url(#fa)"/>')
        if lab:
            o.append(f'<text x="{lx if lx is not None else (x1+x2)/2+6}" y="{ly if ly is not None else (y1+y2)/2}" '
                     f'font-size="10.5" font-weight="700" fill="{col}">{esc(lab)}</text>')

    def path(d, lab="", lx=0, ly=0, col=C["muted"]):
        o.append(f'<path d="{d}" fill="none" stroke="{col}" stroke-width="1.4" marker-end="url(#fa)"/>')
        if lab:
            o.append(f'<text x="{lx}" y="{ly}" font-size="10.5" font-weight="700" fill="{col}">{esc(lab)}</text>')

    cx = 230
    box(cx-150, 8, 300, 44, "1. Penelusuran lama (tetap jalan)", "isi 4 slot: SR Conv · JR Conv · SR Base · JR Base")
    arr(cx, 52, cx, 82)
    dia(cx, 132, 300, 96, "2. Order JR di slot JR Base", "masih memakai batch SR/JR?")
    # NO branch -> right
    path(f"M{cx+150},132 L455,132", "TIDAK", cx+160, 124, C["green"])
    box(455, 104, 175, 56, "Skenario biasa", "logika lama 100%", fill=C["green_bg"], stroke=C["green"])
    # YES down
    arr(cx, 180, cx, 212, "YA", cx+8, 200, C["amber"])
    box(cx-150, 212, 300, 44, "3. Telusur silsilah penuh", "dari roll DO sampai JR Base Film asli", fill=C["amber_bg"], stroke=C["amber"])
    arr(cx, 256, cx, 284)
    box(cx-150, 284, 300, 34, "4. Untuk setiap MIC di ZMAP_COA ...", bold=True)
    arr(cx, 318, cx, 346)
    dia(cx, 394, 300, 92, "MIC ada di lot", "hasil penelusuran lama?")
    path(f"M{cx+150},394 L455,394", "YA", cx+160, 386, C["green"])
    box(455, 368, 175, 52, "Pakai lot lama", "tidak ada perubahan", fill=C["green_bg"], stroke=C["green"])
    arr(cx, 440, cx, 470, "TIDAK", cx+8, 459, C["amber"])
    box(cx-150, 470, 300, 50, "5. Cari lot terdekat, stage sama", "mapping JR → lot JR · mapping SR → lot SR", fill=C["amber_bg"], stroke=C["amber"])
    arr(cx, 520, cx, 548)
    box(cx-150, 548, 300, 44, "Pakai lot yang memiliki MIC tsb", "tidak ketemu → tetap kosong (0), sama spt lama", fill="#fff", stroke=C["navy"])
    o.append('</svg>')
    return "\n".join(o)


# ---------------------------------------------------------------- data
A_NODES = [
    dict(stage="SR", mat="SRCADI", label="SR Base Film (roll DO)", batch="0000405751", lot="—",
         slot="LOT_SR_BASE", edge="slitting dari"),
    dict(stage="JR", mat="JRCADI", label="JR Base Film", batch="0000405370", lot="040000020662",
         slot="LOT_JR_BASE", mics="10 MIC <tspan font-weight='700'>PCAD*</tspan> (JR Base Film) ✓"),
]
B_NODES = [
    dict(stage="SR", mat="SRGIDI", label="SR Converting (roll DO)", batch="0000405583", lot="via sibling",
         slot="LOT_SR_CONV", mics="SGIDSTCD (SR Converting) ✓", edge="slitting dari"),
    dict(stage="JR", mat="JRGIDI", label="JR Converting", batch="0000405468", lot="040000020757",
         slot="LOT_JR_CONV", mics="PGID* 7 MIC (JR Converting) ✓", edge="komponen order 100000072887"),
    dict(stage="SR", mat="SRALZI", label="SR Base Film", batch="0000405412", lot="050000014200",
         slot="LOT_SR_BASE", edge="slitting dari"),
    dict(stage="JR", mat="JRALZI", label="JR Base Film", batch="0000405384", lot="040000020676",
         slot="LOT_JR_BASE", mics="PALZTH00 (JR Base Film) ✓"),
]
C_NODES = [
    dict(stage="SR", mat="SRGLBI", label="SR Conv · Coat 2 (roll DO)", batch="0000406850", lot="050000014314",
         slot="LOT_SR_CONV", edge="slitting dari"),
    dict(stage="JR", mat="JRGLBI", label="JR Conv · Coat 2", batch="0000406821", lot="040000021043",
         slot="LOT_JR_CONV", mics="PGLBOD00 Optical Density ✓", edge="komponen order"),
    dict(stage="SR", mat="SRGLAI", label="SR Conv · Metz", batch="0000406810", lot="050000014288",
         slot="LOT_SR_BASE ✗", tone="mislabel", mics="SGLASTCD · SGLASTMZ", edge="slitting dari"),
    dict(stage="JR", mat="JRGLAI", label="JR Conv · Metz", batch="0000406781", lot="040000021033",
         slot="LOT_JR_BASE ✗", tone="mislabel", mics="PGLASHMD · PGLASHTD · PGLAG6CD", edge="komponen order"),
    dict(stage="SR", mat="SRGKAI", label="SR Conv · Coat 1", batch="0000406756", lot="050000014276",
         slot="tak terjangkau", tone="deep", mics="(tidak ada mapping)", edge="slitting dari"),
    dict(stage="JR", mat="JRGKAI", label="JR Conv · Coat 1", batch="0000406727", lot="040000021018",
         slot="tak terjangkau", tone="deep", mics="(tidak ada mapping)", edge="komponen order"),
    dict(stage="SR", mat="SRAH8I", label="SR Base Film", batch="0000406711", lot="—",
         slot="tak terjangkau", tone="deep", mics="(tidak ada mapping)", edge="slitting dari"),
    dict(stage="JR", mat="JRAH8I", label="JR Base Film", batch="0000406686", lot="040000021012",
         slot="tak terjangkau", tone="deep", mics="PAH8TSMD · PAH8TSTD · PAH8ELMD · PAH8ELTD"),
]

MIC_ROWS = [
    ("PAH8TSMD", "Tensile Strength MD", "JR Base Film", "JRAH8I", "0.00", "0.00"),
    ("PAH8TSTD", "Tensile Strength TD", "JR Base Film", "JRAH8I", "0.00", "0.00"),
    ("PAH8ELMD", "Elongation MD", "JR Base Film", "JRAH8I", "0", "0"),
    ("PAH8ELTD", "Elongation TD", "JR Base Film", "JRAH8I", "0", "0"),
    ("PGLASHMD", "Shrinkage MD", "JR Converting", "JRGLAI", "2.62", "2.62"),
    ("PGLASHTD", "Shrinkage TD", "JR Converting", "JRGLAI", "0.34", "0.34"),
    ("PGLAG6CD", "Gloss 60° Coated Side", "JR Converting", "JRGLAI", "636", "636"),
    ("SGLASTCD", "Surface Tension Coated Side", "SR Converting", "SRGLAI", "42", "42"),
    ("SGLASTMZ", "Surface Tension Metz Side", "SR Converting", "SRGLAI", "52", "52"),
    ("PGLBOD00", "Optical Density", "JR Converting", "JRGLBI", "2.38", "2.378 *"),
]

REG_ROWS = [
    ("QM01", "0085006234", "SRCADI", 10), ("QM02", "0085006235", "SRAABI", 10),
    ("QM03", "0085006240", "SRGIDI", 9), ("QM04", "0085006241", "SREWEI", 8),
    ("QM05/06", "0085006242", "SRVC2I", 13), ("QM07/08", "0085006243", "SREASI", 10),
    ("QM09", "0085006244", "SRAABI", 10), ("QM10", "0085006245", "SRGJBI", 9),
    ("Tambahan", "0085003462", "SRAAAI", 11), ("Tambahan", "0085003495", "SRAAAI", 11),
    ("Tambahan", "0085000596", "SRAABI", 10), ("Tambahan", "0085000604", "SRAABI", 10),
    ("Tambahan", "0085006276", "SRACBI", 14), ("Tambahan", "0085006277", "SRACBI", 14),
    ("Tambahan", "0085000867", "SRCADI", 10), ("Tambahan", "0085006272", "SREASI", 10),
    ("Tambahan", "0085003655", "SRETRI", 7), ("Tambahan", "0085003679", "SRETRI", 1),
    ("Tambahan", "0085006204", "SREWEI", 8), ("Tambahan", "0085006273", "SREWEI / SRIA5I", 16),
    ("Tambahan", "0085002169", "SRGJBI", 9), ("Tambahan", "0085003278", "SRGJBI", 9),
]


def mic_table():
    r = []
    for mic, desc, mp, src, val, exp in MIC_ROWS:
        same_old = mic == "PGLBOD00"
        before = '<span class="ok">2.38</span>' if same_old else '<span class="bad">0 · tanpa lot</span>'
        r.append(f"<tr><td class='mono'>{mic}</td><td>{desc}</td><td>{mp}</td>"
                 f"<td>{before}</td><td class='mono'>{src}</td><td class='num'><b>{val}</b></td><td class='num'>{exp}</td></tr>")
    return "\n".join(r)


def reg_table():
    r = []
    for i, (sc, do, mat, n) in enumerate(REG_ROWS):
        r.append(f"<tr><td>{sc}</td><td class='mono'>{do}</td><td class='mono'>{mat}</td><td class='num'>{n}</td>"
                 f"<td><span class='pill ok'>identik</span></td></tr>")
    r.append("<tr class='hl'><td>Multi-level</td><td class='mono'>0085006278</td><td class='mono'>SRGLBI</td>"
             "<td class='num'>10</td><td><span class='pill amber'>9 MIC terisi, sesuai ekspektasi</span></td></tr>")
    return "\n".join(r)


TEMPLATE = (BASE / "scripts" / "doc_multilevel_template.html").read_text(encoding="utf-8")
html = (TEMPLATE
        .replace("{{CHAIN_A}}", chain_svg(A_NODES, "order JR: bahan baku resin → penelusuran selesai", width=530))
        .replace("{{CHAIN_B}}", chain_svg(B_NODES, "order JR: bahan baku resin → penelusuran selesai", width=530))
        .replace("{{CHAIN_C}}", chain_svg(C_NODES, "order JRAH8I: bahan baku resin → JR Base Film asli", width=530,
                                          highlight={3}))
        .replace("{{FLOW}}", flow_svg())
        .replace("{{MIC_ROWS}}", mic_table())
        .replace("{{REG_ROWS}}", reg_table()))
HTML.write_text(html, encoding="utf-8")

subprocess.run(["google-chrome", "--headless=new", "--no-sandbox", "--disable-gpu", "--no-pdf-header-footer",
                f"--print-to-pdf={PDF}", HTML.as_uri()], check=True,
               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
print(PDF)
