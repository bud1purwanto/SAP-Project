from PIL import Image

im = Image.open('/tmp/omx1_screen2.png')
crop = im.crop((260, 265, 460, 330))
crop.save('/tmp/crop_omx1_rows.png')
print("Cropped omx1 rows")
