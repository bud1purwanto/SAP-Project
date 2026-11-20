from PIL import Image

im = Image.open('/tmp/after_login_submit.png')
# Crop login area
crop = im.crop((50, 170, 250, 380))
crop.save('/tmp/crop_login_fields.png')
print("Cropped login fields")
