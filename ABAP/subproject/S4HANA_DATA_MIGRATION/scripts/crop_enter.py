from PIL import Image

im = Image.open('/tmp/after_enter_click.png')
# Crop bottom right
crop = im.crop((900, 950, 1010, 1000)) if im.size[1] > 950 else im.crop((900, 850, 1010, 900))
crop.save('/tmp/crop_enter_btn.png')
print("Image size:", im.size)
