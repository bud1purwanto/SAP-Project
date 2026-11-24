"""Terapkan sheet hasil build (Ringkasan + Daftar Program) ke workbook terbaru dari user,
tanpa menyentuh sheet lain (mis. preview label yang ditambahkan tim di 'Label & Cetak').
Pakai: python merge_into_latest.py <file_terbaru.xlsx> <hasil_build.xlsx> <output.xlsx>
"""
import sys
from copy import copy
from openpyxl import load_workbook

latest, built, out = sys.argv[1:4]
wb = load_workbook(latest)
src = load_workbook(built)

for name in ('Ringkasan', 'Titik Expired Date', 'Hasil Scan', 'Daftar Program'):
    if name in wb.sheetnames:
        del wb[name]


def clone(s, idx):
    d = wb.create_sheet(s.title, idx)
    for row in s.iter_rows():
        for c in row:
            if c.__class__.__name__ == 'MergedCell':
                continue
            n = d.cell(row=c.row, column=c.column, value=c.value)
            if c.has_style:
                n.font, n.fill, n.border = copy(c.font), copy(c.fill), copy(c.border)
                n.alignment, n.number_format, n.protection = copy(c.alignment), c.number_format, copy(c.protection)
            if c.hyperlink:
                n.hyperlink = copy(c.hyperlink)
    for k, dim in s.column_dimensions.items():
        d.column_dimensions[k].width = dim.width
    for k, dim in s.row_dimensions.items():
        if dim.height:
            d.row_dimensions[k].height = dim.height
    for m in s.merged_cells.ranges:
        d.merge_cells(str(m))
    d.freeze_panes = s.freeze_panes
    if s.auto_filter.ref:
        d.auto_filter.ref = s.auto_filter.ref
    d.sheet_view.showGridLines = False


clone(src['Ringkasan'], 0)
clone(src['Daftar Program'], 1)
for ws in wb.worksheets:
    if ws.title.startswith('SS-') and ws['P1'].hyperlink:
        ws['P1'].hyperlink = "#'Daftar Program'!A1"
wb.active = 0
wb.save(out)
print(wb.sheetnames)
