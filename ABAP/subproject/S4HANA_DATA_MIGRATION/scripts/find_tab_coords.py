from PIL import Image
im = Image.open('/tmp/fs00_control_data.png')
# search X=100..180, Y=260..300 for dark text pixels
found = []
for y in range(260, 300):
    for x in range(105, 170):
        p = im.getpixel((x, y))[:3]
        if p[0] < 50:
            found.append((x, y))
if found:
    xs = [x for x, y in found]
    ys = [y for x, y in found]
    print('Control Data text box:', min(xs), max(xs), min(ys), max(ys))
else:
    print('Not found')
