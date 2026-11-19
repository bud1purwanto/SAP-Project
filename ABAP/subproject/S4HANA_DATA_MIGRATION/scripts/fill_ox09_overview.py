import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("Clicking Row 5 SLoc at (182, 424)...")
run("xdotool mousemove 182 424 click --repeat 2 1")
time.sleep(0.3)
run("xdotool key --delay 40 ctrl+a BackSpace")
time.sleep(0.2)
run("xdotool type --delay 60 '1011'")
time.sleep(0.3)

print("Clicking Row 5 Desc at (240, 424)...")
run("xdotool mousemove 240 424 click --repeat 2 1")
time.sleep(0.3)
run("xdotool key --delay 40 ctrl+a BackSpace")
time.sleep(0.2)
run("xdotool type --delay 60 'Feed OPP WR'")
time.sleep(0.3)

print("Clicking Row 6 SLoc at (182, 452)...")
run("xdotool mousemove 182 452 click --repeat 2 1")
time.sleep(0.3)
run("xdotool key --delay 40 ctrl+a BackSpace")
time.sleep(0.2)
run("xdotool type --delay 60 '1813'")
time.sleep(0.3)

print("Clicking Row 6 Desc at (240, 452)...")
run("xdotool mousemove 240 452 click --repeat 2 1")
time.sleep(0.3)
run("xdotool key --delay 40 ctrl+a BackSpace")
time.sleep(0.2)
run("xdotool type --delay 60 'WR FGS-Non WM'")
time.sleep(0.3)

print("Pressing Return to validate...")
run("xdotool key Return")
time.sleep(1.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_rows_filled.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
