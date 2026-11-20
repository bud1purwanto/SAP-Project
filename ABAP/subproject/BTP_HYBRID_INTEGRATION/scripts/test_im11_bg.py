from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/11_bas_odata_services_loaded.png").convert("RGB")
# find where non-white pixels are
w, h = im.size
pts = []
for y in range(0, h, 10):
    for x in range(0, w, 10):
        if im.getpixel((x, y)) != (255, 255, 255) and im.getpixel((x, y)) != (250, 250, 253):
            pts.append((x, y))
print(f"im11 non-bg points: {len(pts)}")
if pts:
    print(f"x range: {min([p[0] for p in pts])} to {max([p[0] for p in pts])}")
    print(f"y range: {min([p[1] for p in pts])} to {max([p[1] for p in pts])}")
