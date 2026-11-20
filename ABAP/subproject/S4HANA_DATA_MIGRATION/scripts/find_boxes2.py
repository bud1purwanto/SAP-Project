from PIL import Image
im = Image.open('/tmp/ckmstart_step1.png')

# Let's find checkbox borders: look for blue/cyan checkmark inside or blue borders
for y in [484, 508]:
    for x in range(20, 30):
        print(f'({x}, {y}): {im.getpixel((x, y))[:3]}')

