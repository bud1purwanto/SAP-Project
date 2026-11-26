#!/usr/bin/env python3
"""Timeframe Conversion Migration ECC 6 -> S/4HANA, Fase 1 (5 program Z dari file Alfa).

Format mengikuti timeframe COA: sheet Schedule Table (PHASE/ACTIVITIES/DELIVERABLES/
START/END/STATUS) + sheet Gantt. Jalankan dengan python yang punya openpyxl.
"""
from datetime import date, timedelta
from pathlib import Path

from openpyxl import Workbook
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter

OUTPUT = Path(__file__).resolve().parents[1] / "docs" / "Timeframe_Konversi_S4_Fase1_v1.xlsx"

HOLIDAYS = {date(2026, 12, 24), date(2026, 12, 25), date(2026, 12, 31), date(2027, 1, 1)}

# (phase, activity, deliverable, start, end)
ITEMS = [
    ("PREPARE", "Phase 1 scope & baseline",
     "5 programs confirmed (ZFI103, ZSD008, ZQM014, ZMM056, ZPP005); Alfa extraction 24 Nov 2026 as source baseline",
     date(2026, 11, 30), date(2026, 12, 1)),
    ("PREPARE", "S/4 sandbox readiness (ADB client 130)",
     "ZS4CCA detection/conversion tool generated and active; local ATC variant S4HANA_READINESS_1909 ready",
     date(2026, 11, 30), date(2026, 12, 2)),
    ("EXPLORE", "Object inventory & dependency analysis",
     "Per program: includes, Z tables/data elements, FM, BDC, Native SQL; missing objects list",
     date(2026, 12, 2), date(2026, 12, 3)),
    ("EXPLORE", "ATC / ZS4CCA findings & classification",
     "Findings report per program, classified auto-fix / manual / no change; remediation list",
     date(2026, 12, 3), date(2026, 12, 4)),
    ("EXPLORE", "Test data preparation in ADB",
     "Test data for CC 9999 / plant 1000-2000 per program (FI, SD, QM, MM, PP)",
     date(2026, 12, 3), date(2026, 12, 9)),
    ("REALIZE", "ZPP005 – ZPPC_UP_BOM (PP)",
     "BOM upload BDC (CS01) checked against S/4 screens; converted, activated, unit tested",
     date(2026, 12, 7), date(2026, 12, 8)),
    ("REALIZE", "ZQM014 – ZQMI_DEL_INS_LIST (QM)",
     "VBUK/VBUP replaced; converted, activated, unit tested",
     date(2026, 12, 8), date(2026, 12, 10)),
    ("REALIZE", "ZSD008 – ZSDI_SOTOSO (SD)",
     "VBUK/VBUP and stock reads adjusted; converted, activated, unit tested",
     date(2026, 12, 9), date(2026, 12, 11)),
    ("REALIZE", "ZMM056 – ZMM_GRN_PO (MM)",
     "MKPF/MSEG reads (MATDOC) and Native SQL reviewed for HANA; converted, activated, unit tested",
     date(2026, 12, 14), date(2026, 12, 16)),
    ("REALIZE", "ZFI103 – ZFIF_KWITANSI_PENJUALAN (FI)",
     "KONV -> PRCD_ELEMENTS, BSID/BSAD index tables, customer master (BP/CVI) adjusted; converted, activated, unit tested",
     date(2026, 12, 14), date(2026, 12, 18)),
    ("REALIZE", "Functional test with key users",
     "Each of the 5 programs run in ADB with key users; defects logged and fixed",
     date(2026, 12, 21), date(2026, 12, 23)),
    ("REPORT", "Phase 1 assessment & remediation report",
     "Per-program result, effort actual vs plan, lessons learned, proposal and estimate for Phase 2",
     date(2026, 12, 28), date(2026, 12, 30)),
    ("REPORT", "Phase 1 review & sign-off",
     "Manager review; decision on Phase 2 scope",
     date(2026, 12, 30), date(2026, 12, 30)),
]

NAVY = "1F3864"
thin = Side(style="thin", color="BFBFBF")
BORDER = Border(left=thin, right=thin, top=thin, bottom=thin)
WRAP = Alignment(wrap_text=True, vertical="center")
CENTER = Alignment(horizontal="center", vertical="center", wrap_text=True)


def fill(color):
    return PatternFill("solid", fgColor=color)


def workdays(start, end):
    d = start
    while d <= end:
        if d.weekday() < 5 and d not in HOLIDAYS:
            yield d
        d += timedelta(days=1)


def title(ws, text, ncols, row=1):
    ws.merge_cells(start_row=row, start_column=1, end_row=row, end_column=ncols)
    c = ws.cell(row=row, column=1, value=text)
    c.font = Font(bold=True, size=14, color="FFFFFF")
    c.fill = fill(NAVY)
    c.alignment = CENTER
    ws.row_dimensions[row].height = 32


def note(ws, text, ncols, row):
    ws.merge_cells(start_row=row, start_column=1, end_row=row, end_column=ncols)
    c = ws.cell(row=row, column=1, value=text)
    c.font = Font(italic=True, size=10)
    c.alignment = WRAP
    ws.row_dimensions[row].height = 30


def table_sheet(wb):
    ws = wb.active
    ws.title = "Schedule Table"
    widths = [14, 44, 72, 14, 14, 12, 12]
    for i, w in enumerate(widths, 1):
        ws.column_dimensions[get_column_letter(i)].width = w
    title(ws, "CONVERSION MIGRATION ECC 6 TO S/4HANA  |  PHASE 1: 5 Z PROGRAMS", 7)
    note(ws, "Target: S/4HANA 1909 sandbox ADB client 130 (CC 9999, plant 1000/2000). Objects in $TMP, "
             "suffix _ECC6, no transport. Source baseline: Alfa extraction 24 Nov 2026.", 7, 2)
    hdr = ("PHASE", "ACTIVITIES", "DELIVERABLES", "START DATE", "END DATE", "WORK DAYS", "STATUS")
    for col, h in enumerate(hdr, 1):
        c = ws.cell(row=4, column=col, value=h)
        c.font = Font(bold=True, color="FFFFFF")
        c.fill = fill("2F5597")
        c.alignment = CENTER
        c.border = BORDER
    prev = None
    for r, (phase, act, deliv, s, e) in enumerate(ITEMS, 5):
        vals = (phase if phase != prev else "", act, deliv, s, e, len(list(workdays(s, e))), "Planned")
        for col, v in enumerate(vals, 1):
            c = ws.cell(row=r, column=col, value=v)
            c.border = BORDER
            c.alignment = CENTER if col in (1, 4, 5, 6, 7) else WRAP
            if col in (4, 5):
                c.number_format = "DD MMM YYYY"
            if col == 1:
                c.font = Font(bold=True)
        ws.row_dimensions[r].height = 42
        prev = phase
    last = 4 + len(ITEMS)
    note(ws, "Holidays excluded: 24-25 Dec 2026, 31 Dec 2026. Dates depend on ZS4CCA readiness in ADB and "
             "test data availability for FI/SD/QM/MM.", 7, last + 2)
    ws.freeze_panes = "A5"
    ws.auto_filter.ref = f"A4:G{last}"


def gantt_sheet(wb):
    ws = wb.create_sheet("Gantt")
    days = list(workdays(date(2026, 11, 30), date(2026, 12, 30)))
    ncols = 1 + len(days)
    ws.column_dimensions["A"].width = 44
    for i in range(len(days)):
        ws.column_dimensions[get_column_letter(i + 2)].width = 4.2
    title(ws, "PHASE 1 TIMEFRAME  |  30 NOV – 30 DEC 2026", ncols)
    ws.cell(row=3, column=1, value="ACTIVITY").font = Font(bold=True)
    # baris bulan + tanggal
    for i, d in enumerate(days, 2):
        m = ws.cell(row=2, column=i, value=d.strftime("%b").upper())
        m.alignment = CENTER
        m.font = Font(bold=True, size=8)
        c = ws.cell(row=3, column=i, value=d.day)
        c.alignment = CENTER
        c.font = Font(bold=True, size=9, color="FFFFFF")
        c.fill = fill("2F5597")
        c.border = BORDER
    colors = {"PREPARE": "8EA9DB", "EXPLORE": "F4B183", "REALIZE": "A9D18E", "REPORT": "FFD966"}
    row, prev = 4, None
    for phase, act, _, s, e in ITEMS:
        if phase != prev:
            c = ws.cell(row=row, column=1, value=phase)
            c.font = Font(bold=True)
            c.fill = fill("D9E1F2")
            for i in range(2, ncols + 1):
                ws.cell(row=row, column=i).fill = fill("D9E1F2")
            row += 1
            prev = phase
        ws.cell(row=row, column=1, value="   " + act).alignment = WRAP
        for i, d in enumerate(days, 2):
            c = ws.cell(row=row, column=i)
            c.border = BORDER
            if s <= d <= e:
                c.fill = fill(colors[phase])
        ws.row_dimensions[row].height = 20
        row += 1
    note(ws, "BLUE Prepare | ORANGE Explore (assessment) | GREEN Realize (conversion per program) | YELLOW Report. "
             "Working days only.", ncols, row + 1)
    ws.freeze_panes = "B4"


if __name__ == "__main__":
    wb = Workbook()
    table_sheet(wb)
    gantt_sheet(wb)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    for ws in wb.worksheets:  # cetak 1 halaman lebar, landscape
        ws.page_setup.orientation = "landscape"
        ws.page_setup.fitToWidth = 1
        ws.page_setup.fitToHeight = 0
        ws.sheet_properties.pageSetUpPr.fitToPage = True
    wb.save(OUTPUT)
    print(OUTPUT)
