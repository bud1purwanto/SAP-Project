from PIL import Image
im = Image.open('/tmp/omwd_tabbed.png')
# search for horizontal table grid lines around X=350, Y=150..350
for y in range(180, 350):
    p = im.getpixel((350, y))[:3]
    # grid lines are usually gray (around 200..220)
    if p[0] != 255 and p[1] != 255:
        print(f'Y={y}: {p}')
