from PIL import Image

img = Image.open('/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/mouse_500_500.png')
print("Image size:", img.size)

# Find black cursor tip
# The black cursor has pure black pixels (0,0,0) or near black with white border
# Let's inspect region around (490..520, 490..520)
pixels = img.load()
found = []
for y in range(480, 520):
    for x in range(480, 520):
        r, g, b = pixels[x, y][:3]
        if r < 10 and g < 10 and b < 10:
            found.append((x, y))

if found:
    print(f"Found {len(found)} black pixels around 500,500. First: {found[0]}, Last: {found[-1]}")
else:
    print("No black pixels around 500,500!")
    # scan whole image for black cursor
    for y in range(0, img.height):
        for x in range(0, img.width):
            r, g, b = pixels[x, y][:3]
            if r == 0 and g == 0 and b == 0:
                # check if white neighbor
                found.append((x, y))
                if len(found) > 10:
                    break
        if len(found) > 10:
            break
    print(f"Found black pixels starting at: {found[:5]}")
