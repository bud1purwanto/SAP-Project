from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/live_su01_display.png")
print("Size:", im.size)
# crop tabs area: x=10..700, y=100..200
crop_tabs = im.crop((10, 80, 700, 150))
crop_tabs.save("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/crop_su01_tabs.png")
print("Saved crop_su01_tabs.png")
