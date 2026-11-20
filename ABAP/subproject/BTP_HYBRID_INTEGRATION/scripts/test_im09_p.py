from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/09_btp_destination_dynamic_property.png").convert("RGB")
w, h = im.size
for y in range(20, h, 20):
    row = [im.getpixel((x, y)) for x in range(20, w, 20)]
    # count pixels with r>100
    p100 = [p for p in row if p[0] > 100]
    if len(p100) > 3:
        print(f"y={y}: count={len(p100)}, sample={p100[0]}")
