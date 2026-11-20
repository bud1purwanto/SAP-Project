from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/03_scc_subaccount_connected.png").convert("RGB")
w, h = im.size
blue_ys = []
for y in range(h):
    for x in range(w):
        if im.getpixel((x, y)) == (225, 244, 255):
            blue_ys.append(y)
            break
print(f"Light blue row in im03: y_min={min(blue_ys)}, y_max={max(blue_ys)}")
