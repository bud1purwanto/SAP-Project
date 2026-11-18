from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_sel.png")
# Let's save a visual grid with red markers every 50 pixels!
draw_im = im.copy()
import PIL.ImageDraw as ImageDraw
draw = ImageDraw.Draw(draw_im)
for y in range(200, 400, 20):
    draw.line([(0, y), (500, y)], fill="red", width=1)
    draw.text((5, y-10), f"y={y}", fill="red")

for x in range(150, 450, 50):
    draw.line([(x, 200), (x, 400)], fill="blue", width=1)
    draw.text((x, 190), f"x={x}", fill="blue")

draw_im.crop((0, 180, 500, 420)).save("/data/Projects/SAP/ABAP/subproject/COA/outputs/grid_sel.png")
print("Grid saved.")
