import openpyxl

wb = openpyxl.load_workbook("/data/Projects/SAP/ABAP/subproject/COA/outputs/gui_test_20261118/GUI_TEST_COA_TTA_DEV_20261118.xlsx", data_only=True)
print("Sheet names:", wb.sheetnames)
for sheet in wb.sheetnames:
    ws = wb[sheet]
    print(f"\n--- SHEET: {sheet} (images: {len(ws._images)}) ---")
    for r in range(1, 125):
        row_vals = [str(ws.cell(r, c).value or "").strip() for c in range(1, 15)]
        if any(row_vals):
            non_empty = [f"Col{c}:{ws.cell(r, c).value}" for c in range(1, 15) if ws.cell(r, c).value is not None]
            print(f"Row {r:3d}: {non_empty[:6]}")
    for idx, img in enumerate(ws._images):
        print(f"  Img {idx}: anchor={img.anchor}, size={img.width}x{img.height}")
