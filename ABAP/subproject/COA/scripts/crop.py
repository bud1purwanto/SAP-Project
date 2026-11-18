from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_sel.png")
# Crop selection area
crop = im.crop((10, 200, 500, 400))
crop.save("/data/Projects/SAP/ABAP/subproject/COA/outputs/crop_sel.png")
print("Cropped successfully")
