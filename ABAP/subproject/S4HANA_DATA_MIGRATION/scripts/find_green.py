from PIL import Image

im = Image.open('/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox10_addr_confirmed.png')
print("Bottom right pixels around 1200..1440, y=870..890:")
for x in range(1200, 1400, 20):
    for y in range(860, 895, 10):
        print(f"({x}, {y}): {im.getpixel((x, y))}")
