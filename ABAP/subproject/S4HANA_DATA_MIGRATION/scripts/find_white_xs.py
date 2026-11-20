from PIL import Image
im = Image.open('/tmp/omwd_tabbed.png')
row3_y = 251
white_xs = [x for x in range(300, 400) if im.getpixel((x, row3_y))[:3] == (255, 255, 255)]
print('White Xs in Row 3:', min(white_xs) if white_xs else None, max(white_xs) if white_xs else None)
