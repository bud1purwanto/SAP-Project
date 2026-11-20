from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/05_btp_create_destination_scratch.png").convert("RGB")
w, h = im.size
print("Size:", w, h)
# BTP dark theme: background is dark (23, 28, 34)
# Let's see the fields
for y in range(40, h, 30):
    row = [im.getpixel((x, y)) for x in range(50, w, 50)]
    bright = [px for px in row if px[0] > 120 or px[1] > 120 or px[2] > 120]
    print(f"y={y:3d}: bright pixels count={len(bright)}")
