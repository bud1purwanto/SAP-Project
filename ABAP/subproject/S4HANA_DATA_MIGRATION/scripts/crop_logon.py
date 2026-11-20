from PIL import Image

im = Image.open('/tmp/logon_pad.png')
# Crop the connection list: x: 100 to 500, y: 80 to 400
crop = im.crop((100, 80, 500, 400))
crop.save('/tmp/crop_connections.png')
print("Cropped successfully")
