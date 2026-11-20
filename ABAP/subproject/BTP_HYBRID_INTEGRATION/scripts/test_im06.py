from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/06_btp_destination_check_success.jpg").convert("RGB")
w, h = im.size

# check dialog box in center
# scan at center y=h//2 horizontally
row = [im.getpixel((x, h//2)) for x in range(w)]
# dialog is lighter or darker than background
for x in range(100, w-100, 50):
    print(f"x={x}: {row[x]}")
