from PIL import Image

im = Image.open('/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox18_after_f3.png')

print("Row 3 selector x=0..20 at y=305:")
for x in range(0, 20):
    print(f"x={x}: {im.getpixel((x, 305))}")

print("Row 4 selector x=0..20 at y=333:")
for x in range(0, 20):
    print(f"x={x}: {im.getpixel((x, 333))}")
