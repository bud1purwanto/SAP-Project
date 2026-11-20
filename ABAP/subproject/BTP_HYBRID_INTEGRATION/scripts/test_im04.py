from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/04_scc_resources_mapping.png").convert("RGB")
w, h = im.size

# Look for section headers or dark lines
for y in range(50, h, 25):
    row = [im.getpixel((x, y)) for x in range(50, w, 50)]
    print(f"y={y:3d}: sample={row[1]}")
