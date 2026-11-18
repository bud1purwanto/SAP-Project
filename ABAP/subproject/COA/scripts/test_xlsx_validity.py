import glob
import openpyxl

files = sorted(glob.glob('/data/Projects/SAP/ABAP/subproject/COA/outputs/*.xlsx'))
for f in files:
    try:
        wb = openpyxl.load_workbook(f)
        print('OK:', f, 'Sheets:', len(wb.sheetnames))
    except Exception as e:
        print('CORRUPT:', f, '->', e)
