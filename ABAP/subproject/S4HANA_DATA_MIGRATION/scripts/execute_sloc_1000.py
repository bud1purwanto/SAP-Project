import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("1. Editing Row 5 SLoc at (234, 385)...")
run("xdotool mousemove 234 385 click --repeat 2 1")
time.sleep(0.3)
run("xdotool key --delay 40 BackSpace BackSpace BackSpace BackSpace Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 '1011'")
time.sleep(0.3)

print("2. Editing Row 5 Desc at (299, 385)...")
run("xdotool mousemove 299 385 click --repeat 2 1")
time.sleep(0.3)
run("xdotool key --delay 40 BackSpace BackSpace BackSpace BackSpace Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 'Feed OPP WR'")
time.sleep(0.3)

print("3. Editing Row 6 SLoc at (234, 409)...")
run("xdotool mousemove 234 409 click --repeat 2 1")
time.sleep(0.3)
run("xdotool key --delay 40 BackSpace BackSpace BackSpace BackSpace Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 '1813'")
time.sleep(0.3)

print("4. Editing Row 6 Desc at (299, 409)...")
run("xdotool mousemove 299 409 click --repeat 2 1")
time.sleep(0.3)
run("xdotool key --delay 40 BackSpace BackSpace BackSpace BackSpace Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 'WR FGS-Non WM'")
time.sleep(0.3)

print("5. Pressing Return to validate...")
run("xdotool key Return")
time.sleep(1.5)

print("6. Saving with Ctrl+S...")
run("xdotool key ctrl+s")
time.sleep(1.5)

print("7. Confirming TR dialog with Return...")
run("xdotool key Return")
time.sleep(2.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_1000_saved_final.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured final screenshot to", out_file)
