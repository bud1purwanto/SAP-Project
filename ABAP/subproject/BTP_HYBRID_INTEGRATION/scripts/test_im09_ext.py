from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/09_btp_destination_dynamic_property.png").convert("RGB")
print("Min/Max RGB:", im.getextrema())
