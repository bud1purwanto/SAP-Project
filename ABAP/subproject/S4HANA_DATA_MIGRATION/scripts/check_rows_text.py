from PIL import Image
im = Image.open('/tmp/omwd_tabbed.png')
# let's inspect the 4 rows: Y=195 (Row 1), Y=223 (Row 2), Y=251 (Row 3), Y=279 (Row 4)
for row_idx, y in enumerate([195, 223, 251, 279]):
    # check text around X=20..60 (Val. area)
    pixels = [im.getpixel((x, y))[:3] for x in range(20, 60)]
    dark = sum(1 for p in pixels if p[0] < 100)
    print(f'Row {row_idx+1} (Y={y}): {dark} dark pixels')
