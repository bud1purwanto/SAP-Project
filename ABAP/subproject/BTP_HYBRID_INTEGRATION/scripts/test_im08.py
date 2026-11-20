from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/08_bas_fiori_generator_destination.png").convert("RGB")
w, h = im.size
for y in range(100, 600, 40):
    row = [im.getpixel((x, y)) for x in range(100, 800, 40)]
    colored = [px for px in row if max(px) - min(px) > 30]
    if colored:
        print(f"y={y}: colored={colored[:2]}")
