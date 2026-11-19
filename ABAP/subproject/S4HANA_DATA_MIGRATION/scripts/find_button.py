from PIL import Image

im = Image.open('/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox10_after_enter_click.png')
print('Image size:', im.size)

# Scan from y=850 to 900 around x=1250..1300
found = []
for y in range(850, 900):
    for x in range(1200, 1300):
        # Look for non-white pixels
        p = im.getpixel((x, y))
        if p != (255, 255, 255):
            found.append((x, y, p))

print(f"Total non-white pixels: {len(found)}")
if found:
    ys = [f[1] for f in found]
    xs = [f[0] for f in found]
    print(f"X range: {min(xs)}..{max(xs)}, Y range: {min(ys)}..{max(ys)}")
    for f in found[:10]:
        print(f)
