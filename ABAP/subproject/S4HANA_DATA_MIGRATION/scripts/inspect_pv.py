from PIL import Image

im = Image.open('/tmp/gui_latest.png')
print('Image format:', im.format, 'size:', im.size)

# The Check button is next to 'PLE-18 LINE 1'
crop_check = im.crop((400, 100, 500, 140))
crop_check.save('/tmp/check_btn.png')

# The Save (floppy disk) icon at the bottom right
w, h = im.size
crop_bottom_right = im.crop((w - 100, h - 50, w, h))
crop_bottom_right.save('/tmp/bottom_right_btn.png')

print('Cropped successfully')
