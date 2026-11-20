from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/07_bas_devspace_running.png").convert("RGB")
# look for badges or status pills: check non-white pixels
# sample y at interval 30
w, h = im.size
for y in range(50, 400, 30):
    row = [im.getpixel((x, y)) for x in range(50, w, 30)]
    colored = [px for px in row if max(px) - min(px) > 30]
    if colored:
        print(f"y={y}: colored samples={colored[:3]}")
