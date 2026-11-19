import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("1. Typing 1813 in currently focused Row 2 SLoc...")
run("xdotool type --delay 60 '1813'")
time.sleep(0.3)

print("2. Fixing Row 1 Description at (299, 257)...")
run("xdotool mousemove 299 257 click --repeat 2 1")
time.sleep(0.3)
run("xdotool key --delay 30 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 'Feed OPP WR'")
time.sleep(0.3)

print("3. Typing Row 2 Description at (299, 290)...")
run("xdotool mousemove 299 290 click --repeat 2 1")
time.sleep(0.3)
run("xdotool key --delay 30 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 'WR FGS-Non WM'")
time.sleep(0.3)

print("4. Pressing Return to validate...")
run("xdotool key Return")
time.sleep(1.5)

print("5. Saving with Ctrl+S...")
run("xdotool key ctrl+s")
time.sleep(1.5)
run("xdotool key Return")
time.sleep(2.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_1000_done.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
