from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/snap_se16n_test.png")
# check non-white pixels
crop = im.crop((10, 30, 400, 100))
crop.save("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/crop_se16n.png")
print("Saved crop_se16n.png, size:", crop.size)
