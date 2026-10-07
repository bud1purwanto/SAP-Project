#!/usr/bin/env python3
"""Retarget the user's formatted COA workbook to go live on 23 Nov 2026."""

from datetime import date
from pathlib import Path
from zipfile import ZipFile

from lxml import etree


SOURCE = Path(
    "/home/abap/.codex/attachments/0a1de2bf-9ff1-4664-9a53-739fe5b1a4e8/"
    "Timeframe_COA_Rebaseline_10_Oktober_2026.xlsx"
)
OUTPUT = Path(__file__).resolve().parents[1] / "docs" / "Timeframe_COA_GoLive_23_November_2026.xlsx"
NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
NSMAP = {"x": NS}


def q(local):
    return "{" + NS + "}" + local


def serial(day):
    return (day - date(1899, 12, 30)).days


def cell(root, ref):
    found = root.xpath(f".//x:sheetData/x:row/x:c[@r='{ref}']", namespaces=NSMAP)
    if len(found) != 1:
        raise ValueError(f"Expected one cell {ref}, found {len(found)}")
    return found[0]


def clear_content(item):
    for child in list(item):
        if child.tag in (q("v"), q("is"), q("f")):
            item.remove(child)
    item.attrib.pop("t", None)


def set_text(root, ref, value):
    item = cell(root, ref)
    clear_content(item)
    item.set("t", "inlineStr")
    inline = etree.SubElement(item, q("is"))
    text = etree.SubElement(inline, q("t"))
    text.text = value


def set_date(root, ref, day):
    item = cell(root, ref)
    clear_content(item)
    etree.SubElement(item, q("v")).text = str(serial(day))


def set_style(root, ref, style):
    cell(root, ref).set("s", str(style))


def replace_merge(root, old, new):
    found = root.xpath(f".//x:mergeCells/x:mergeCell[@ref='{old}']", namespaces=NSMAP)
    if len(found) != 1:
        raise ValueError(f"Expected one merge {old}, found {len(found)}")
    found[0].set("ref", new)


def reset_row(root, row, active, style, markers=None):
    markers = markers or {}
    for col in "CDEFGHIJKL":
        ref = f"{col}{row}"
        item = cell(root, ref)
        clear_content(item)
        item.set("s", str(style if col in active else 3))
        if col in markers:
            set_text(root, ref, markers[col])


def edit_timeline(root):
    set_text(root, "A4", "Target go live: 23 November 2026 (usulan)")
    set_text(root, "A11", "   Sepakati aturan & kebutuhan final")
    set_text(root, "A15", "   Setujui kebutuhan & kriteria UAT")
    set_text(root, "A30", "   GO LIVE  ·  23 November")
    set_text(
        root,
        "A35",
        "Asumsi: input QA final 16 Okt; UAT disetujui 19 Nov; kesiapan produksi selesai 20 Nov. "
        "Jika salah satu mundur, target 23 Nov harus ditinjau ulang.",
    )

    # Each column is a work week. C=12–16 Oct, ... I=23–27 Nov.
    plans = {
        16: ("EF", 17, {"E": "REALIZE"}),
        17: ("EF", 4, {"E": "BUILD"}),
        18: ("F", 4, {"F": "BUILD"}),
        19: ("EF", 4, {"E": "BUILD"}),
        20: ("EF", 4, {"E": "BUILD"}),
        21: ("F", 4, {"F": "BUILD"}),
        22: ("F", 4, {"F": "BUILD"}),
        23: ("G", 17, {"G": "TEST"}),
        24: ("G", 5, {"G": "SIT"}),
        25: ("G", 5, {"G": "FIX"}),
        26: ("HI", 17, {"H": "DEPLOY"}),
        27: ("H", 5, {"H": "UAT"}),
        28: ("H", 6, {"H": "READY"}),
        29: ("H", 6, {"H": "CUT"}),
        30: ("I", 7, {"I": "23 NOV"}),
        31: ("IJ", 17, {"I": "GO LIVE SUPPORT"}),
        32: ("IJ", 6, {"I": "RUN"}),
    }
    for row, (active, style, markers) in plans.items():
        reset_row(root, row, active, style, markers)

    replace_merge(root, "E16:G16", "E16:F16")
    replace_merge(root, "H23", "G23")
    replace_merge(root, "I26:K26", "H26:I26")
    replace_merge(root, "K31:L31", "I31:J31")


def edit_detail(root):
    set_text(
        root,
        "A2",
        "Tanggal usulan. Target go live 23 Nov memerlukan input QA final 16 Okt, "
        "persetujuan UAT 19 Nov, dan kesiapan produksi 20 Nov.",
    )
    set_text(root, "G11", "Daftar keputusan dan kebutuhan final")
    set_text(root, "I11", "Persetujuan 16 Okt")
    set_text(root, "C14", "Setujui kebutuhan final dan kriteria penerimaan UAT.")
    set_text(root, "G14", "Persetujuan kebutuhan dan skenario uji")
    set_text(root, "I14", "Persetujuan 23 Okt")

    dates = {
        "F17": date(2026, 11, 6),
        "F18": date(2026, 11, 6),
        "F19": date(2026, 11, 6),
        "F20": date(2026, 11, 6),
        "F21": date(2026, 11, 6),
        "E22": date(2026, 11, 2),
        "F22": date(2026, 11, 6),
        "E23": date(2026, 11, 9),
        "F23": date(2026, 11, 12),
        "E24": date(2026, 11, 12),
        "F24": date(2026, 11, 13),
        "E25": date(2026, 11, 16),
        "F25": date(2026, 11, 19),
        "E26": date(2026, 11, 16),
        "F26": date(2026, 11, 20),
        "E27": date(2026, 11, 19),
        "F27": date(2026, 11, 20),
        "E28": date(2026, 11, 23),
        "F28": date(2026, 11, 23),
        "E29": date(2026, 11, 23),
        "F29": date(2026, 12, 4),
    }
    for ref, day in dates.items():
        set_date(root, ref, day)
    set_text(root, "H27", "UAT disetujui 19 Nov; window produksi siap")
    set_text(root, "H28", "Transport selesai 20 Nov; window produksi disetujui")


def edit_confirmations(root):
    set_text(root, "A1", "DAFTAR KONFIRMASI  |  SYARAT JADWAL")
    set_text(root, "F4", "Menunda mapping dan pengujian")
    set_text(root, "A17", "SYARAT TARGET 23 NOVEMBER")
    set_text(
        root,
        "A18",
        "Target 23 Nov hanya berlaku bila input QA lengkap dan kebutuhan disetujui 16 Okt, "
        "UAT disetujui 19 Nov, serta window produksi tersedia.",
    )
    set_text(
        root,
        "A19",
        "Jika kebutuhan belum disetujui 16 Okt atau berubah setelahnya, "
        "hitung ulang sisa pekerjaan dan tetapkan tanggal baru bersama QA/produksi.",
    )


def main():
    editors = {
        "xl/worksheets/sheet1.xml": edit_timeline,
        "xl/worksheets/sheet2.xml": edit_detail,
        "xl/worksheets/sheet3.xml": edit_confirmations,
    }
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(SOURCE) as source, ZipFile(OUTPUT, "w") as output:
        for info in source.infolist():
            data = source.read(info.filename)
            if info.filename in editors:
                root = etree.fromstring(data)
                editors[info.filename](root)
                data = etree.tostring(root, encoding="UTF-8", xml_declaration=True)
            output.writestr(info, data)
    print(OUTPUT)


if __name__ == "__main__":
    main()
