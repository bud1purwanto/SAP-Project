import os
import time
import subprocess
from PIL import Image

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("Moving mouse to (182, 420)...")
run("xdotool mousemove 182 420")
time.sleep(0.3)
run("xdotool click 1")
time.sleep(0.5)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/click_420.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")

img = Image.open(out_file)
pixels = img.load()
cursor_pixels = []
for y in range(img.height):
    for x in range(img.width):
        r, g, b = pixels[x, y][:3]
        if r == 0 and g == 0 and b == 0:
            cursor_pixels.append((x, y))

print("Total black pixels:", len(cursor_pixels))
if cursor_pixels:
    print("Cursor top-left:", cursor_pixels[0])
