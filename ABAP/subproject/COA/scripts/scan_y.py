from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_sel.png")
# Find white boxes for each row between y=200 and y=400 at x=250..350
for y in range(210, 390, 5):
    whites = [x for x in range(200, 350) if im.getpixel((x, y)) == (255, 255, 255)]
    if whites:
        print(f"y={y}: len={len(whites)} range=[{min(whites)}, {max(whites)}]")
