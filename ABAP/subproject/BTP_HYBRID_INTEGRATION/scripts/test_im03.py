from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/03_scc_subaccount_connected.png").convert("RGB")
w, h = im.size

# look for green pixels in im03
green_pts = []
for y in range(h):
    for x in range(w):
        r, g, b = im.getpixel((x, y))
        # green icon: g noticeably higher than r and b
        if g > 110 and r < 80 and b < 80:
            green_pts.append((x, y))

if green_pts:
    xs = [p[0] for p in green_pts]
    ys = [p[1] for p in green_pts]
    print(f"Green icon found at: x=[{min(xs)}, {max(xs)}], y=[{min(ys)}, {max(ys)}]")
else:
    print("No vivid green found, checking other colors...")
