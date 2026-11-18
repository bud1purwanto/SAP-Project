from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_sel.png")
# Scan for the white background of the Nomor ODO box
# In row y around 315-325, x between 250 and 370
for y in [315, 320, 325]:
    white_xs = [x for x in range(200, 400) if im.getpixel((x, y)) == (255, 255, 255)]
    if white_xs:
        print(f"y={y}: min_x={min(white_xs)}, max_x={max(white_xs)}")
