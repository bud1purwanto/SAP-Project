from PIL import Image
im = Image.open('/tmp/ckmstart_step1.png')
w, h = im.size
print('Image size:', w, h)

# Search for the checkbox borders around X=15..30, Y=450..550
# The checkboxes in SAP GUI have a distinct dark blue/black border
found = []
for y in range(450, 550):
    for x in range(15, 40):
        r, g, b = im.getpixel((x, y))[:3]
        if r < 50 and g < 50 and b < 50:
            found.append((x, y))

print('Found dark pixels count:', len(found))
if found:
    ys = [y for x, y in found]
    print('Y range:', min(ys), max(ys))
    # Group by Y clusters
    import itertools
    lines = sorted(list(set(ys)))
    print('Unique Ys:', lines)

