from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/snap_sicf_raw.png")
# crop title area: x=0..800, y=30..120
crop = im.crop((20, 30, 800, 110))
crop.save("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/crop_title.png")
print("Cropped title, checking pixel colors...")
# check if non-background
colors = sorted(crop.getcolors(800*80), key=lambda x: x[0], reverse=True)
print("Top 5 colors in title area:", colors[:5])
