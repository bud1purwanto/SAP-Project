from PIL import Image
im = Image.open('/tmp/fs00_control_data.png')
for x in range(260, 330):
    for y in range(215, 230):
        p = im.getpixel((x, y))[:3]
        if p != (245, 246, 247) and p != (255, 255, 255):
            print(f'({x}, {y}): {p}')
            break
