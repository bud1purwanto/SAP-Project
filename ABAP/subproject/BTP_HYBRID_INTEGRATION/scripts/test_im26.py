from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/26_fiori_table_10_records_success.jpg").convert("RGB")
w, h = im.size
print("26 size:", w, h)
for y in range(50, h, 50):
    row = [im.getpixel((x, y)) for x in range(50, w, 50)]
    print(f"y={y:3d}: sample[2]={row[2]}")
