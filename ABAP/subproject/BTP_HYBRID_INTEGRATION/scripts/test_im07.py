from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/07_bas_devspace_running.png").convert("RGB")
w, h = im.size

# find green badge (RUNNING)
green_pts = []
for y in range(h):
    for x in range(w):
        r, g, b = im.getpixel((x, y))
        if g > 120 and r < 80 and b < 80:
            green_pts.append((x, y))

if green_pts:
    xs = [p[0] for p in green_pts]
    ys = [p[1] for p in green_pts]
    print(f"RUNNING green badge: x=[{min(xs)}, {max(xs)}], y=[{min(ys)}, {max(ys)}]")
