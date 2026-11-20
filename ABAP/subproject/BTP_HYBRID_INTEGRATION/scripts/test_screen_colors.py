from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/current_screen.png")
print("Size:", im.size, "Colors:", len(im.getcolors(1440*900) or []))
print("Sample colors:", (im.getcolors(1440*900) or [])[:5])
