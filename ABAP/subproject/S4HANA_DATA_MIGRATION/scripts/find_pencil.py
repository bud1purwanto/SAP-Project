from PIL import Image
im = Image.open('/tmp/fs00_control_data.png')
# search X=280..320, Y=210..235
found = []
for y in range(210, 235):
    for x in range(280, 320):
        p = im.getpixel((x, y))[:3]
        if p[0] < 100:
            found.append((x, y))
if found:
    xs = [x for x, y in found]
    ys = [y for x, y in found]
    print('Pencil icon box:', min(xs), max(xs), min(ys), max(ys))
else:
    print('Not found')
