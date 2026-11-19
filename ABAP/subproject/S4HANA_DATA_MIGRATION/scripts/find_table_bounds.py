from PIL import Image

img = Image.open('/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/current_screen.png')
pixels = img.load()

# Let's find the header "SLoc" or the table boundaries
# SLoc column header is around x=160..210, y=275..295
# The table data rows start below the header (around y=300..330)
# Look for the white background of the first editable cell
# In current_screen.png, find white pixels in region x in 160..250, y in 290..350
white_cells = []
for y in range(295, 340):
    for x in range(165, 205):
        r, g, b = pixels[x, y][:3]
        if r > 240 and g > 240 and b > 240:
            white_cells.append((x, y))

print(f"White pixels in SLoc col: count={len(white_cells)}, min_x={min(x for x,y in white_cells)}, max_x={max(x for x,y in white_cells)}, min_y={min(y for x,y in white_cells)}, max_y={max(y for x,y in white_cells)}")

# Description column: x in 210..280, y in 295..340
desc_cells = []
for y in range(295, 340):
    for x in range(215, 280):
        r, g, b = pixels[x, y][:3]
        if r > 240 and g > 240 and b > 240:
            desc_cells.append((x, y))

print(f"White pixels in Desc col: count={len(desc_cells)}, min_x={min(x for x,y in desc_cells)}, max_x={max(x for x,y in desc_cells)}, min_y={min(y for x,y in desc_cells)}, max_y={max(y for x,y in desc_cells)}")
