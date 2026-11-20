from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/screen_live.png")
print("Size:", im.size)
# inspect sample pixels
print("Top bar:", im.getpixel((100, 10)))
print("Center:", im.getpixel((720, 450)))
