from PIL import Image
im = Image.open('/tmp/ckmstart_step1.png')
for y in range(495, 525):
    row = [im.getpixel((x, y))[:3] for x in range(20, 30)]
    if any(r < 50 and g < 50 and b < 50 for r, g, b in row):
        print(f'Test Run row Y={y}')
