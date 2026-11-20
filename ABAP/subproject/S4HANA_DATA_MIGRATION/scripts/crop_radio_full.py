from PIL import Image

im = Image.open('/tmp/after_license_enter.png')
crop = im.crop((0, 250, 400, 320))
crop.save('/tmp/crop_radio1_full.png')
print("Cropped radio1 full")
