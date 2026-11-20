from PIL import Image

im = Image.open('/tmp/after_enter_click.png')
crop = im.crop((1300, 850, 1440, 900))
crop.save('/tmp/crop_enter_actual.png')
print("Cropped actual enter")
