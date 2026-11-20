from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/05_btp_create_destination_scratch.png").convert("L")
w, h = im.size

# find where white text is located (brightness > 180)
text_pts = []
for y in range(0, h, 5):
    for x in range(0, w, 5):
        if im.getpixel((x, y)) > 180:
            text_pts.append((x, y))

print("Total white text points:", len(text_pts))
# group by columns
left_col = [p for p in text_pts if p[0] < 500]
right_col = [p for p in text_pts if p[0] >= 500]
print(f"Left col points: {len(left_col)}, y-range: {min([p[1] for p in left_col]) if left_col else 0}-{max([p[1] for p in left_col]) if left_col else 0}")
print(f"Right col points: {len(right_col)}, y-range: {min([p[1] for p in right_col]) if right_col else 0}-{max([p[1] for p in right_col]) if right_col else 0}")
