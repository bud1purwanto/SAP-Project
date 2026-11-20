from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/01_onprem_fiori_launchpad_login.png")
# Check URL bar area at y=40
url_pixels = [im.getpixel((x, 40))[:3] for x in range(50, 800, 50)]
print("URL bar y=40:", url_pixels[:5])

# Find login card bounds
# scan horizontally at y=350 to find left and right white edges
row = [im.getpixel((x, 350))[:3] for x in range(im.width)]
card_xs = [x for x, px in enumerate(row) if px[0] > 240 and px[1] > 240 and px[2] > 240]
if card_xs:
    print(f"Card bounds at y=350: x_min={min(card_xs)}, x_max={max(card_xs)}")

# scan vertically at x=430 to find top and bottom card edges
col = [im.getpixel((430, y))[:3] for y in range(im.height)]
card_ys = [y for y, px in enumerate(col) if px[0] > 240 and px[1] > 240 and px[2] > 240]
if card_ys:
    print(f"Card bounds at x=430: y_min={min(card_ys)}, y_max={max(card_ys)}")
