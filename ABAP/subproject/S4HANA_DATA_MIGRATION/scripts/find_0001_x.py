from PIL import Image
im = Image.open('/tmp/omwd_typed_perfect.png')
# search X=300..400 at Y=195 (Row 1) for dark pixels of '0001'
pixels = []
for x in range(300, 400):
    p = im.getpixel((x, 195))[:3]
    if p[0] < 100:
        pixels.append(x)
print('Pixels of 0001 in Row 1:', min(pixels) if pixels else None, max(pixels) if pixels else None)
