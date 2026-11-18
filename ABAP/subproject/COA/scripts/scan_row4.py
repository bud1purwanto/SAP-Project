from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_sel.png")
for x in range(180, 360, 5):
    p = im.getpixel((x, 315))
    print(f"x={x}: {p}")
