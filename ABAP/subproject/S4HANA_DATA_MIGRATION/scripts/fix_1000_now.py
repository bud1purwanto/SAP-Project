import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("Starting from focused 1813...")
run("xdotool windowactivate --sync 35651634")
time.sleep(0.2)

# Move Up to Row 4 SLoc (1011)
run("xdotool key Up")
time.sleep(0.2)

# Move Right to Row 4 Description
run("xdotool key Right")
time.sleep(0.2)

# Clear and type Feed OPP WR
print("Clearing Row 4 Desc...")
run("xdotool key --delay 25 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 'Feed OPP WR'")
time.sleep(0.3)

# Move Down to Row 5 Description (1813)
print("Typing Row 5 Desc...")
run("xdotool key Down")
time.sleep(0.2)
run("xdotool key --delay 25 BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 'WR FGS-Non WM'")
time.sleep(0.3)

# Move Down to Row 6 Description
run("xdotool key Down")
time.sleep(0.2)

# Move Left to Row 6 SLoc (WR F)
run("xdotool key Left")
time.sleep(0.2)

# Delete Row 6
print("Deleting Row 6...")
run("xdotool key shift+F2")
time.sleep(0.5)

# Validate with Return
run("xdotool key Return")
time.sleep(1.0)

# Save with Ctrl+S
print("Saving...")
run("xdotool key ctrl+s")
time.sleep(1.5)
run("xdotool key Return")
time.sleep(2.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_1000_fixed_final.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
