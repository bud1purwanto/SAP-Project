from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/01_sap_logon.png")
print("Size:", im.size)
bg = im.getpixel((0, 0))
print("Background pixel [0,0]:", bg)

min_x, max_x = im.width, 0
min_y, max_y = im.height, 0
non_bg = 0

for y in range(0, im.height, 4):
    for x in range(0, im.width, 4):
        p = im.getpixel((x, y))
        diff = abs(p[0] - bg[0]) + abs(p[1] - bg[1]) + abs(p[2] - bg[2])
        if diff > 30:
            non_bg += 1
            if x < min_x: min_x = x
            if x > max_x: max_x = x
            if y < min_y: min_y = y
            if y > max_y: max_y = y

if non_bg > 0:
    print(f"Content bbox: x=[{min_x}, {max_x}], y=[{min_y}, {max_y}], non_bg_samples={non_bg}")
else:
    print("Image is uniform/blank!")
