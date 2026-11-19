import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("First, click Row 1 SLoc at (182, 307)...")
run("xdotool mousemove 182 307 click --repeat 2 1")
time.sleep(0.3)
run("xdotool type --delay 60 '1011'")
time.sleep(0.3)

print("Direct click Row 1 Desc at (247, 307)...")
run("xdotool mousemove 247 307 click --repeat 2 1")
time.sleep(0.3)
run("xdotool type --delay 60 'Feed OPP WR'")
time.sleep(0.3)

print("Direct click Row 2 SLoc at (182, 327)...")
run("xdotool mousemove 182 327 click --repeat 2 1")
time.sleep(0.3)
run("xdotool type --delay 60 '1813'")
time.sleep(0.3)

print("Direct click Row 2 Desc at (247, 327)...")
run("xdotool mousemove 247 327 click --repeat 2 1")
time.sleep(0.3)
run("xdotool type --delay 60 'WR FGS-Non WM'")
time.sleep(0.3)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/test_arrow_click.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
