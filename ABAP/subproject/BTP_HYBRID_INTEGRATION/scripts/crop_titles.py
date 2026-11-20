from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/win_46137391.png")
# let crop title area
crop_title = im.crop((50, 25, 600, 75))
crop_title.save("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/crop_win_title.png")

# let crop status area at bottom
crop_status = im.crop((10, 840, 800, 875))
crop_status.save("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/crop_win_status.png")

print("Cropped title and status successfully.")
