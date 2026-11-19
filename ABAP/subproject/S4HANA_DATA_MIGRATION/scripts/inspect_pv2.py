from PIL import Image

im = Image.open('/tmp/gui_latest.png')
crop_check = im.crop((550, 100, 680, 130))
crop_check.save('/tmp/check_btn2.png')
print('Done')
