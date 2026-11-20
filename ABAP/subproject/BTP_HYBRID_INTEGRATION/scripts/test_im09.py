from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/09_btp_destination_dynamic_property.png").convert("L")
w, h = im.size
# find table rows with text
for y in range(50, h, 20):
    row = [im.getpixel((x, y)) for x in range(50, 900, 20)]
    bright = [v for v in row if v > 150]
    if len(bright) > 5:
        print(f"y={y}: bright text count={len(bright)}")
