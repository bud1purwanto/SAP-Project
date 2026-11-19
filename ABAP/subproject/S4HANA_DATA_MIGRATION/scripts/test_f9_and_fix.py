import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("1. From Row 5 Desc, moving Up to Row 4 Desc...")
run("xdotool key Up")
time.sleep(0.3)

print("2. Clearing Row 4 Desc...")
# Home, Shift+End, Delete
run("xdotool key Home")
time.sleep(0.1)
run("xdotool keydown Shift")
time.sleep(0.1)
run("xdotool key End")
time.sleep(0.1)
run("xdotool keyup Shift")
time.sleep(0.1)
run("xdotool key Delete")
time.sleep(0.1)
run("xdotool key --delay 20 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace")
time.sleep(0.1)

print("3. Typing exact 'Feed OPP WR'...")
run("xdotool type --delay 60 'Feed OPP WR'")
time.sleep(0.3)

print("4. Moving Down twice to Row 6 Desc, then Left to Row 6 SLoc (WR F)...")
run("xdotool key Down")
time.sleep(0.2)
run("xdotool key Down")
time.sleep(0.2)
run("xdotool key Left")
time.sleep(0.2)

print("5. Selecting Row 6 with F9...")
run("xdotool key F9")
time.sleep(0.5)

print("6. Deleting Row 6 with Shift+F2...")
run("xdotool key shift+F2")
time.sleep(0.5)

print("7. Validating with Return...")
run("xdotool key Return")
time.sleep(1.0)

print("8. Saving with Ctrl+S...")
run("xdotool key ctrl+s")
time.sleep(1.5)
run("xdotool key Return")
time.sleep(2.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_1000_clean_check.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
