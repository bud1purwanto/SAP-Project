from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/01_onprem_fiori_launchpad_login.png")

# find input field boxes inside the card
# looking for borders or distinct horizontal lines
for y in range(45, 635, 10):
    row = [im.getpixel((x, y))[:3] for x in range(120, 700, 10)]
    # check if any non-white pixels
    non_white = [px for px in row if not (px[0] > 245 and px[1] > 245 and px[2] > 245)]
    if len(non_white) > 5:
        # sample some
        print(f"y={y}: non-white count={len(non_white)}, sample={non_white[0]}")
