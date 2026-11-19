import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("Starting cleanup for Plant 1000 SLoc...")

# Currently focused on Row 3 SLoc (0200)
# Move Right to Row 3 Description
run("xdotool key Right")
time.sleep(0.2)

# Move Down to Row 4 Description (1011)
run("xdotool key Down")
time.sleep(0.2)

# Clear Row 4 Description and type 'Feed OPP WR'
print("Updating Row 4 (1011) description...")
run("xdotool key --delay 30 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 'Feed OPP WR'")
time.sleep(0.3)

# Move Down to Row 5 Description (1813)
print("Updating Row 5 (1813) description...")
run("xdotool key Down")
time.sleep(0.2)
run("xdotool key --delay 30 BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 'WR FGS-Non WM'")
time.sleep(0.3)

# Now delete Row 6 ('WR F')
# Row 6 selector is at Target(164, 465) -> Input(216, 410)
print("Selecting Row 6 at (216, 410)...")
run("xdotool mousemove 216 410 click 1")
time.sleep(0.3)

print("Deleting Row 6 with Shift+F2...")
run("xdotool key shift+F2")
time.sleep(0.5)

print("Saving with Ctrl+S...")
run("xdotool key ctrl+s")
time.sleep(1.5)
run("xdotool key Return")
time.sleep(2.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_1000_cleaned_final.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured final screenshot to", out_file)
