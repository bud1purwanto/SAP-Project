#!/usr/bin/env python3
"""Build the COA rebaseline workbook with Python's standard library."""

from datetime import date
from pathlib import Path
from xml.sax.saxutils import escape
from zipfile import ZIP_DEFLATED, ZipFile


OUTPUT = Path(__file__).resolve().parents[1] / "docs" / "Timeframe_COA_Rebaseline_10_Oktober_2026.xlsx"

NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
REL = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"


def column(number):
    result = ""
    while number:
        number, remainder = divmod(number - 1, 26)
        result = chr(65 + remainder) + result
    return result


def serial(value):
    return (value - date(1899, 12, 30)).days


def xml_text(value):
    return escape(str(value), {'"': "&quot;"})


class Sheet:
    def __init__(self, name, widths, freeze=None, fit_height=0):
        self.name = name
        self.widths = widths
        self.freeze = freeze
        self.fit_height = fit_height
        self.cells = {}
        self.heights = {}
        self.merges = []
        self.filter_ref = None

    def put(self, row, col, value="", style=0):
        self.cells[(row, col)] = (value, style)

    def span(self, row, first, last, value, style):
        for col in range(first, last + 1):
            self.put(row, col, "", style)
        self.put(row, first, value, style)
        self.merges.append(f"{column(first)}{row}:{column(last)}{row}")

    def height(self, row, height):
        self.heights[row] = height

    def to_xml(self):
        rows = sorted(set(row for row, _ in self.cells))
        parts = [
            f'<worksheet xmlns="{NS}">',
            '<sheetPr><pageSetUpPr fitToPage="1"/></sheetPr>',
        ]
        if self.freeze:
            parts.append(
                '<sheetViews><sheetView workbookViewId="0">'
                f'<pane xSplit="{self.freeze[0]}" ySplit="{self.freeze[1]}" '
                f'topLeftCell="{column(self.freeze[0] + 1)}{self.freeze[1] + 1}" '
                'activePane="bottomRight" state="frozen"/>'
                '</sheetView></sheetViews>'
            )
        parts.append('<sheetFormatPr defaultRowHeight="18"/>')
        parts.append('<cols>')
        for index, width in enumerate(self.widths, 1):
            parts.append(
                f'<col min="{index}" max="{index}" width="{width}" customWidth="1"/>'
            )
        parts.append('</cols><sheetData>')
        for row in rows:
            height = self.heights.get(row)
            custom = f' ht="{height}" customHeight="1"' if height else ""
            parts.append(f'<row r="{row}"{custom}>')
            for _, col in sorted((r, c) for r, c in self.cells if r == row):
                value, style = self.cells[(row, col)]
                ref = f"{column(col)}{row}"
                if isinstance(value, date):
                    parts.append(f'<c r="{ref}" s="{style}"><v>{serial(value)}</v></c>')
                elif isinstance(value, (int, float)):
                    parts.append(f'<c r="{ref}" s="{style}"><v>{value}</v></c>')
                elif value == "":
                    parts.append(f'<c r="{ref}" s="{style}"/>')
                else:
                    parts.append(
                        f'<c r="{ref}" s="{style}" t="inlineStr">'
                        f'<is><t xml:space="preserve">{xml_text(value)}</t></is></c>'
                    )
            parts.append('</row>')
        parts.append('</sheetData>')
        # SpreadsheetML requires autoFilter before mergeCells.
        if self.filter_ref:
            parts.append(f'<autoFilter ref="{self.filter_ref}"/>')
        if self.merges:
            parts.append(f'<mergeCells count="{len(self.merges)}">')
            parts.extend(f'<mergeCell ref="{ref}"/>' for ref in self.merges)
            parts.append('</mergeCells>')
        parts.append(
            '<pageMargins left="0.25" right="0.25" top="0.4" '
            'bottom="0.4" header="0.2" footer="0.2"/>'
            '<pageSetup orientation="landscape" paperSize="9" fitToWidth="1" '
            f'fitToHeight="{self.fit_height}"/>'
            '</worksheet>'
        )
        return "".join(parts)


def styles_xml():
    fonts = [
        '<font><sz val="10"/><name val="Aptos"/></font>',
        '<font><b/><sz val="16"/><color rgb="FFFFFFFF"/><name val="Aptos Display"/></font>',
        '<font><b/><sz val="11"/><color rgb="FFFFFFFF"/><name val="Aptos"/></font>',
        '<font><b/><sz val="10"/><color rgb="FF17324D"/><name val="Aptos"/></font>',
        '<font><sz val="10"/><color rgb="FF17324D"/><name val="Aptos"/></font>',
        '<font><b/><sz val="10"/><color rgb="FFE15A2D"/><name val="Aptos"/></font>',
    ]
    fills = [
        '<fill><patternFill patternType="none"/></fill>',
        '<fill><patternFill patternType="gray125"/></fill>',
    ]
    for color in (
        "17324D", "007FB0", "00A4D6", "E8F3FA", "F4F8FB", "00B86B",
        "F5B400", "B4C0C9", "E33E3E", "FFF1CB", "E9F8F0", "FDEBE8",
    ):
        fills.append(
            '<fill><patternFill patternType="solid">'
            f'<fgColor rgb="FF{color}"/><bgColor indexed="64"/>'
            '</patternFill></fill>'
        )
    borders = [
        '<border><left/><right/><top/><bottom/><diagonal/></border>',
        '<border><left style="thin"><color rgb="FFD7E3EB"/></left>'
        '<right style="thin"><color rgb="FFD7E3EB"/></right>'
        '<top style="thin"><color rgb="FFD7E3EB"/></top>'
        '<bottom style="thin"><color rgb="FFD7E3EB"/></bottom><diagonal/></border>',
    ]
    # font, fill, border, number format, alignment
    specs = [
        (0, 0, 0, 0, "left"),       # 0 plain
        (1, 2, 0, 0, "left"),       # 1 title
        (2, 2, 1, 0, "center"),     # 2 dark header
        (2, 3, 1, 0, "center"),     # 3 phase/month
        (3, 5, 1, 0, "center"),     # 4 week
        (2, 3, 1, 0, "left"),       # 5 stage
        (4, 0, 1, 0, "left"),       # 6 task/grid: white background
        (2, 7, 1, 0, "center"),     # 7 green
        (2, 8, 1, 0, "center"),     # 8 amber
        (4, 9, 1, 0, "center"),     # 9 grey
        (2, 3, 1, 0, "center"),     # 10 blue
        (2, 10, 1, 0, "center"),    # 11 red milestone
        (4, 0, 1, 0, "left"),       # 12 detail body
        (3, 5, 1, 0, "left"),       # 13 detail section
        (4, 11, 1, 0, "left"),      # 14 yellow note
        (4, 12, 1, 0, "left"),      # 15 green note
        (5, 13, 1, 0, "left"),      # 16 red note
        (4, 0, 1, 164, "center"),   # 17 date
        (2, 2, 1, 0, "left"),       # 18 detail header
        (4, 0, 1, 0, "center"),     # 19 body center
    ]
    xfs = []
    for font, fill, border, fmt, horizontal in specs:
        xfs.append(
            f'<xf numFmtId="{fmt}" fontId="{font}" fillId="{fill}" '
            f'borderId="{border}" xfId="0" applyFont="1" applyFill="1" '
            f'applyBorder="1" applyAlignment="1" applyNumberFormat="1">'
            f'<alignment horizontal="{horizontal}" vertical="center" wrapText="1"/>'
            '</xf>'
        )
    return (
        f'<styleSheet xmlns="{NS}">'
        '<numFmts count="1"><numFmt numFmtId="164" formatCode="dd mmm yyyy"/></numFmts>'
        f'<fonts count="{len(fonts)}">{"".join(fonts)}</fonts>'
        f'<fills count="{len(fills)}">{"".join(fills)}</fills>'
        f'<borders count="{len(borders)}">{"".join(borders)}</borders>'
        '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
        f'<cellXfs count="{len(xfs)}">{"".join(xfs)}</cellXfs>'
        '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>'
        '</styleSheet>'
    )


def timeline_sheet():
    s = Sheet("Timeline Visual", [59, 16] + [12] * 10, freeze=(2, 4), fit_height=1)
    s.span(1, 1, 12, "COA & BARRIER  |  REBASELINE TIMEFRAME  |  10 OKTOBER 2026", 1)
    s.height(1, 34)
    s.put(2, 1, "ACTIVITY", 2)
    s.put(2, 2, "PIC", 2)
    s.span(2, 3, 12, "2026", 2)
    s.span(3, 3, 5, "OCTOBER", 3)
    s.span(3, 6, 9, "NOVEMBER", 3)
    s.span(3, 10, 12, "DECEMBER", 3)
    s.put(4, 1, "Target go live: 10 Desember 2026 (usulan)", 14)
    s.put(4, 2, "WEEK", 4)
    weeks = ["12–16", "19–23", "26–30", "02–06", "09–13", "16–20", "23–27", "30–04", "07–11", "14–18"]
    for col, label in enumerate(weeks, 3):
        s.put(4, col, label, 4)
    s.height(4, 32)

    def stage(row, label, start, end):
        s.span(row, 1, 2, label, 5)
        s.span(row, start, end, label + "  ▶", 3)
        for col in range(3, 13):
            if not (start <= col <= end):
                s.put(row, col, "", 6)
        s.height(row, 24)

    def task(row, label, owner, start, end, color=7, marker=""):
        s.put(row, 1, "   " + label, 6)
        s.put(row, 2, owner, 19)
        for col in range(3, 13):
            s.put(row, col, marker if col == start else "", color if start <= col <= end else 6)
        s.height(row, 27)

    stage(5, "PREPARE  ·  Input & keputusan", 3, 3)
    task(6, "Template COA per film/customer + limit", "QA", 3, 3, marker="QA")
    task(7, "MIC Barrier, Inspection Plan SPSR0003", "QA", 3, 3, marker="QA")
    task(8, "Header Export/Domestic + Product Alias", "QA", 3, 3, marker="QA")
    task(9, "Batch List customer khusus", "QA", 3, 3, marker="QA")
    task(10, "Daftar film outsource & status revisi", "IT", 3, 3, marker="IT")
    task(11, "Keputusan aturan terbuka / scope freeze", "QA + IT", 3, 3, 8, "GATE")

    stage(12, "EXPLORE  ·  Validasi master data", 4, 4)
    task(13, "Review mapping, MIC, plan, alias, Batch List", "QA + IT", 4, 4, marker="REVIEW")
    task(14, "Skenario DO / lot / customer + hasil harapan", "QA + IT", 4, 4, marker="CASE")
    task(15, "Persetujuan baseline & kriteria UAT", "QA + IT", 4, 4, 8, "GATE")

    stage(16, "REALIZE  ·  Revisi program", 5, 7)
    task(17, "Barrier: input manual & upload 3 value", "IT", 5, 6, marker="BUILD")
    task(18, "Barrier: delete sampel, Last Value & UD", "IT", 6, 7, marker="BUILD")
    task(19, "COA: mapping, alias & tracing 4 step", "IT", 5, 7, marker="BUILD")
    task(20, "COA: spec limit, indikator out-of-spec", "IT", 5, 7, marker="BUILD")
    task(21, "Form COA Export/Domestic & Batch List", "IT", 6, 7, marker="BUILD")
    task(22, "Report COA & ekspor data", "IT", 7, 7, marker="BUILD")

    stage(23, "TEST  ·  Integrasi & regresi", 8, 8)
    task(24, "SIT Barrier–COA–Batch List", "IT", 8, 8, 8, "SIT")
    task(25, "Perbaikan hasil SIT & paket UAT", "IT", 8, 8, 8, "FIX")

    stage(26, "DEPLOY  ·  UAT & kesiapan", 9, 11)
    task(27, "UAT QA, retest & persetujuan", "QA + IT", 9, 10, 8, "UAT")
    task(28, "Pelatihan, data produksi & cutover plan", "QA + IT", 10, 10, 9, "READY")
    task(29, "Transport & cutover produksi", "IT + Basis", 11, 11, 9, "CUT")
    task(30, "GO LIVE  ·  10 Desember", "QA + IT", 11, 11, 11, "10 DES")

    stage(31, "GO LIVE SUPPORT", 11, 12)
    task(32, "Monitoring hasil cetak & incident support", "QA + IT", 11, 12, 9, "RUN")

    s.span(34, 1, 12, "LEGENDA  Hijau: pekerjaan IT/QA  |  Kuning: validasi/test  |  Abu: deploy/support  |  Merah: go live", 13)
    s.span(35, 1, 12, "Asumsi: seluruh input QA lengkap dan scope disetujui 16 Okt. Target cutover bergeser bila gate ini atau jendela produksi berubah.", 14)
    s.height(35, 31)
    return s


DETAIL = [
    ("P01", "PREPARE", "QA serahkan template Master Data COA per film/customer, Lower–Upper Limit, mapping outsource dan produksi empat tahap.", "QA", date(2026, 10, 12), date(2026, 10, 16), "Template final dan versi yang disetujui QA", "MOM deadline awal 4 Okt; belum diterima per 10 Okt", "Belum diterima"),
    ("P02", "PREPARE", "QA review MIC Barrier: Lower Limit, Upper Limit, Target Value, Decimal Places.", "QA", date(2026, 10, 12), date(2026, 10, 16), "Daftar MIC dan nilai final", "MOM deadline awal 4 Okt; status aktual perlu konfirmasi", "Perlu konfirmasi"),
    ("P03", "PREPARE", "QA review Inspection Plan, Sampling Procedure SPSR0003 dan versi plan yang berlaku.", "QA", date(2026, 10, 12), date(2026, 10, 16), "Daftar plan/versi dan bukti keputusan", "MOM deadline awal 4 Okt; status aktual perlu konfirmasi", "Perlu konfirmasi"),
    ("P04", "PREPARE", "QA serahkan header resmi COA Export/Domestic, field input manual, bahasa dan format tanggal.", "QA", date(2026, 10, 12), date(2026, 10, 16), "Template cetak dua pasar disetujui", "MOM deadline awal 4 Okt; belum diterima per 10 Okt", "Belum diterima"),
    ("P05", "PREPARE", "QA serahkan template Batch List customer khusus, termasuk urutan, label dan ukuran kolom.", "QA", date(2026, 10, 12), date(2026, 10, 16), "Template per customer dan aturan default", "MOM deadline awal 4 Okt; status aktual perlu konfirmasi", "Perlu konfirmasi"),
    ("P06", "PREPARE", "QA serahkan contoh COA/DO dengan Product Alias dan aturan deskripsi MIC khusus customer.", "QA", date(2026, 10, 12), date(2026, 10, 16), "Contoh DO, customer, alias, hasil harapan", "MOM deadline awal 4 Okt; status aktual perlu konfirmasi", "Perlu konfirmasi"),
    ("P07", "PREPARE", "IT konfirmasi daftar tipe film yang memakai material outsource dan progres revisi Oktober.", "IT", date(2026, 10, 12), date(2026, 10, 13), "Daftar film dan status pekerjaan aktual", "MOM deadline daftar film 2 Okt; status belum diketahui", "Perlu konfirmasi"),
    ("P08", "PREPARE", "QA/IT putuskan Ship-to vs Sold-to, hierarki alias, batas khusus/general, tracing 20 sequence, dan aturan Barrier upload/delete/UD.", "QA + IT", date(2026, 10, 13), date(2026, 10, 16), "Daftar keputusan dan scope freeze", "P01–P07; beda Ship-to MOM vs Sold-to spesifikasi lama", "Gate 16 Okt"),
    ("E01", "EXPLORE", "Review master mapping COA, Batch List, MIC Barrier dan Inspection Plan terhadap template final.", "QA + IT", date(2026, 10, 19), date(2026, 10, 22), "Daftar gap dan master data siap uji", "P01–P08", "Usulan"),
    ("E02", "EXPLORE", "Siapkan DO/lot/customer uji: general, khusus, alias, outsource, empat tahap, multi-item, out-of-spec, Barrier dan UD.", "QA + IT", date(2026, 10, 19), date(2026, 10, 23), "Matriks test case dengan expected result", "Template final dan data uji tersedia", "Usulan"),
    ("E03", "EXPLORE", "Setujui baseline kebutuhan dan kriteria penerimaan UAT.", "QA + IT", date(2026, 10, 23), date(2026, 10, 23), "Sign-off scope dan test case", "E01–E02", "Gate 23 Okt"),
    ("R01", "REALIZE", "Revisi Barrier Pending List: Inspection Date opsional, filter batch SR, input 3 value dan NIK.", "IT", date(2026, 10, 26), date(2026, 11, 6), "Fungsi input manual siap SIT", "E03; master MIC/plan siap", "Usulan"),
    ("R02", "REALIZE", "Revisi upload .txt Barrier sesuai template; simpan Last Value siklus ke-3.", "IT", date(2026, 10, 26), date(2026, 11, 6), "Upload dan validasi file siap SIT", "E03; format/NIK diputuskan", "Usulan"),
    ("R03", "REALIZE", "Revisi reset/delete sampel dan alur update result/Usage Decision sesuai keputusan QA.", "IT", date(2026, 11, 2), date(2026, 11, 13), "Skenario koreksi Barrier siap SIT", "E03; aturan otorisasi/audit dan hasil harapan", "Usulan"),
    ("R04", "REALIZE", "Revisi COA mapping customer/alias, material outsource, tracing empat tahap dan JR terdekat maks. 20 sequence.", "IT", date(2026, 10, 26), date(2026, 11, 13), "Penarikan lot/MIC sesuai matriks uji", "E03; mapping QA dan data uji", "Usulan"),
    ("R05", "REALIZE", "Revisi limit customer/general, indikator out-of-spec, blank value dan edit pra-cetak.", "IT", date(2026, 10, 26), date(2026, 11, 13), "Display dan print sesuai batas yang disetujui", "E03; nilai limit final", "Usulan"),
    ("R06", "REALIZE", "Revisi COA Smart Form Export/Domestic, field header manual, Product Alias dan Properties Description.", "IT", date(2026, 11, 2), date(2026, 11, 13), "Preview/cetak dua format siap SIT", "P04, P06, E03", "Usulan"),
    ("R07", "REALIZE", "Revisi Batch List default otomatis bersama COA; customer khusus melalui ekspor/cetak sesuai mapping.", "IT", date(2026, 11, 2), date(2026, 11, 13), "Cetak/ekspor Batch List siap SIT", "P05 dan E03", "Usulan"),
    ("R08", "REALIZE", "Revisi Report COA: Customer Number/Name, nilai average dan edited value, ekspor Excel.", "IT", date(2026, 11, 9), date(2026, 11, 13), "Report siap SIT", "E03", "Usulan"),
    ("T01", "TEST", "SIT end-to-end Barrier, COA, Batch List dan Report; regression skenario existing.", "IT", date(2026, 11, 16), date(2026, 11, 19), "Bukti test dan daftar defect", "R01–R08", "Usulan"),
    ("T02", "TEST", "Perbaikan defect SIT dan penyerahan paket UAT ke QA.", "IT", date(2026, 11, 19), date(2026, 11, 20), "Paket UAT serta known issue", "T01", "Usulan"),
    ("D01", "DEPLOY", "QA jalankan UAT dengan data uji disetujui; IT dampingi dan triage defect.", "QA + IT", date(2026, 11, 23), date(2026, 12, 4), "Bukti UAT, retest dan sign-off QA", "T02; PIC QA dan slot UAT tersedia", "Usulan"),
    ("D02", "DEPLOY", "Siapkan master data produksi, user training singkat, transport dan rencana cutover/rollback.", "QA + IT + Basis", date(2026, 11, 30), date(2026, 12, 4), "Checklist readiness dan window produksi", "D01; approval transport dan window", "Usulan"),
    ("D03", "DEPLOY", "Transport ke landscape sesuai prosedur; validasi master data dan smoke test.", "IT + Basis", date(2026, 12, 7), date(2026, 12, 9), "Transport/validasi selesai", "Sign-off QA dan kesiapan produksi", "Usulan"),
    ("G01", "GO LIVE", "Cutover dan go live COA/Barrier pada window produksi yang disetujui.", "QA + IT + Basis", date(2026, 12, 10), date(2026, 12, 10), "Berita acara go live", "D03; window produksi disetujui", "Target usulan"),
    ("S01", "SUPPORT", "Pantau hasil cetak, upload Barrier, laporan, spool dan incident setelah go live.", "QA + IT", date(2026, 12, 11), date(2026, 12, 18), "Log insiden dan serah terima support", "G01", "Usulan"),
]


def detail_sheet():
    s = Sheet("Detail Aktivitas", [8, 15, 68, 18, 16, 16, 53, 55, 23], freeze=(0, 3))
    s.span(1, 1, 9, "DETAIL AKTIVITAS  |  COA & BARRIER  |  REBASELINE 10 OKTOBER 2026", 1)
    s.height(1, 34)
    s.span(2, 1, 9, "Tanggal bersifat usulan. Gate 16 Okt bergantung pada input QA; target go live 10 Des memerlukan sign-off UAT dan window produksi.", 14)
    s.height(2, 32)
    headers = ["ID", "FASE", "AKTIVITAS", "PIC", "MULAI", "SELESAI", "OUTPUT / BUKTI", "KETERGANTUNGAN / CATATAN", "STATUS"]
    for col, header in enumerate(headers, 1):
        s.put(3, col, header, 18)
    s.height(3, 29)
    for row, item in enumerate(DETAIL, 4):
        for col, value in enumerate(item, 1):
            style = 17 if col in (5, 6) else (19 if col in (1, 2, 4) else 12)
            if col == 9:
                style = 16 if value == "Belum diterima" else (14 if "Gate" in value or "konfirmasi" in value.lower() else 15)
            s.put(row, col, value, style)
        s.height(row, 57 if len(item[2]) > 80 else 48)
    s.filter_ref = f"A3:I{3 + len(DETAIL)}"
    return s


CONFIRM = [
    (1, "Template COA final per tipe film/customer; batas spesifikasi, outsource dan produksi empat tahap", "QA", date(2026, 10, 16), "File final + versi/disetujui", "Blokir baseline mapping dan pengujian"),
    (2, "MIC Barrier dan Inspection Plan SPSR0003, termasuk versi plan yang berlaku", "QA", date(2026, 10, 16), "Daftar master data final", "Blokir uji tiga siklus dan status inspeksi"),
    (3, "Header COA Export/Domestic, field manual, bahasa, tanggal dan contoh output", "QA", date(2026, 10, 16), "Dua template cetak yang disetujui", "Blokir finalisasi Smart Form"),
    (4, "Batch List customer khusus serta aturan default general", "QA", date(2026, 10, 16), "Template dan daftar customer", "Blokir mapping dan test print"),
    (5, "Contoh DO dengan Product Alias dan aturan deskripsi MIC customer", "QA", date(2026, 10, 16), "DO/customer/alias + expected result", "Blokir uji alias dan urutan parameter"),
    (6, "Daftar tipe film outsource dan status aktual revisi IT", "IT", date(2026, 10, 13), "Daftar film dan progres tervalidasi", "Blokir scoping effort dan test data"),
    (7, "Kunci customer untuk mapping: Ship-to pada MOM vs Sold-to pada spesifikasi lama", "QA + IT", date(2026, 10, 16), "Keputusan satu sumber customer", "Risiko salah mapping customer"),
    (8, "Prioritas Customer+Alias → Customer+Material → General dan fallback bila mapping kosong", "QA + IT", date(2026, 10, 16), "Contoh tiap prioritas", "Risiko hasil MIC tidak sesuai"),
    (9, "Tracing empat tahap, maksimum 20 sequence per line/type/bulan, serta sample edge case", "QA + IT", date(2026, 10, 16), "Aturan dan data uji lot", "Risiko hasil lot salah; uji bertambah"),
    (10, "Barrier upload .txt: susunan kolom, NIK, Inspection Date opsional, reset/delete dan UD ulang", "QA + IT", date(2026, 10, 16), "Aturan input/koreksi dan bukti audit", "Risiko perubahan result/UD tanpa kriteria jelas"),
    (11, "Tampilan indikator out-of-spec, edit nilai kosong/di luar batas, dan sumber limit customer/general", "QA + IT", date(2026, 10, 16), "Contoh layar/cetak dan expected result", "Risiko revisi tampilan saat UAT"),
    (12, "PIC UAT, jadwal review defect, approval final dan window cutover produksi", "QA + IT + Basis", date(2026, 10, 23), "Kalender UAT/cutover dan PIC", "Target go live tidak bisa dikunci"),
]


def confirm_sheet():
    s = Sheet("Konfirmasi & Asumsi", [7, 76, 20, 18, 46, 53], freeze=(0, 3))
    s.span(1, 1, 6, "DAFTAR KONFIRMASI  |  GATE TIMEFRAME", 1)
    s.height(1, 34)
    s.span(2, 1, 6, "MOM 24 Sep: deadline IT 2 Okt dan QA 4 Okt. Per 10 Okt, template QA belum diserahkan menurut informasi proyek. Status item lain perlu dikonfirmasi.", 14)
    s.height(2, 35)
    headers = ["NO", "KEPUTUSAN / MASUKAN", "PIC", "BATAS USULAN", "BUKTI YANG DIPERLUKAN", "DAMPAK JIKA BELUM SELESAI"]
    for col, title in enumerate(headers, 1):
        s.put(3, col, title, 18)
    s.height(3, 30)
    for row, item in enumerate(CONFIRM, 4):
        for col, value in enumerate(item, 1):
            s.put(row, col, value, 17 if col == 4 else (19 if col == 1 else 12))
        s.height(row, 54)
    s.filter_ref = f"A3:F{3 + len(CONFIRM)}"
    row = 5 + len(CONFIRM)
    s.span(row, 1, 6, "ATURAN REBASELINE", 13)
    s.height(row, 27)
    s.span(row + 1, 1, 6, "Target 10 Des hanya berlaku bila input lengkap dan scope dikunci 16 Okt, UAT disetujui, serta window produksi tersedia.", 14)
    s.height(row + 1, 32)
    s.span(row + 2, 1, 6, "Jika gate 16 Okt terlewati atau kebutuhan berubah, hitung ulang durasi berdasarkan sisa pekerjaan dan tetapkan tanggal baru bersama QA/produksi.", 14)
    s.height(row + 2, 32)
    s.span(row + 3, 1, 6, "Penghapusan result Barrier dan pembatalan/posting ulang UD adalah perubahan data QM; wajib diuji dengan otorisasi, jejak audit, dan rollback yang disetujui.", 16)
    s.height(row + 3, 39)
    return s


def write_workbook(sheets):
    content_types = [
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">',
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>',
        '<Default Extension="xml" ContentType="application/xml"/>',
        '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>',
        '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>',
    ]
    for index in range(1, len(sheets) + 1):
        content_types.append(
            f'<Override PartName="/xl/worksheets/sheet{index}.xml" '
            'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
        )
    content_types.append('</Types>')
    root_rels = (
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" '
        'Target="xl/workbook.xml"/></Relationships>'
    )
    workbook = [f'<workbook xmlns="{NS}" xmlns:r="{REL}"><sheets>']
    workbook_rels = ['<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">']
    for index, sheet in enumerate(sheets, 1):
        workbook.append(
            f'<sheet name="{xml_text(sheet.name)}" sheetId="{index}" r:id="rId{index}"/>'
        )
        workbook_rels.append(
            f'<Relationship Id="rId{index}" '
            'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" '
            f'Target="worksheets/sheet{index}.xml"/>'
        )
    workbook.append('</sheets></workbook>')
    workbook_rels.append(
        f'<Relationship Id="rId{len(sheets) + 1}" '
        'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" '
        'Target="styles.xml"/></Relationships>'
    )
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(OUTPUT, "w", ZIP_DEFLATED) as z:
        z.writestr('[Content_Types].xml', ''.join(content_types))
        z.writestr('_rels/.rels', root_rels)
        z.writestr('xl/workbook.xml', ''.join(workbook))
        z.writestr('xl/_rels/workbook.xml.rels', ''.join(workbook_rels))
        z.writestr('xl/styles.xml', styles_xml())
        for index, sheet in enumerate(sheets, 1):
            z.writestr(f'xl/worksheets/sheet{index}.xml', sheet.to_xml())
    print(OUTPUT)


if __name__ == "__main__":
    write_workbook([timeline_sheet(), detail_sheet(), confirm_sheet()])
