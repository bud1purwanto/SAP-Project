from PIL import Image

im = Image.open('/tmp/after_license_enter.png')
crop = im.crop((0, 290, 40, 320))
crop.save('/tmp/crop_radio1.png')
print("Cropped radio1")
