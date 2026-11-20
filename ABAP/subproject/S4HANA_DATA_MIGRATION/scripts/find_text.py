from PIL import Image
im = Image.open('/tmp/ckmstart_step1.png')
# search X=15..100, Y=450..550 for black text pixels
for y in range(460, 540):
    black_pixels = [x for x in range(20, 100) if sum(im.getpixel((x, y))[:3]) < 200]
    if len(black_pixels) > 5:
        print(f'Y={y}: {len(black_pixels)} text pixels')
