from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/11_bas_odata_services_loaded.png").convert("RGB")
w, h = im.size
for y in range(100, 500, 30):
    row = [im.getpixel((x, y)) for x in range(100, 800, 30)]
    colored = [p for p in row if max(p) - min(p) > 40]
    if colored:
        print(f"y={y}: colored={colored[:2]}")
