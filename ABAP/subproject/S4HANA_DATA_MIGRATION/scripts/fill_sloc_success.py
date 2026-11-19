import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("Starting from Row 2 SLoc...")

# Down 3 times: Row 3 (0100), Row 4 (0200), Row 5 (FEED)
for i in range(3):
    run("xdotool key Down")
    time.sleep(0.15)

print("At Row 5 SLoc. Clearing and typing 1011...")
run("xdotool key --delay 30 BackSpace BackSpace BackSpace BackSpace Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 '1011'")
time.sleep(0.2)

print("Moving Right to Row 5 Description...")
run("xdotool key Right")
time.sleep(0.2)
run("xdotool key --delay 30 BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 'Feed OPP WR'")
time.sleep(0.2)

print("Moving Down to Row 6 Description...")
run("xdotool key Down")
time.sleep(0.2)

print("Moving Left to Row 6 SLoc...")
run("xdotool key Left")
time.sleep(0.2)
run("xdotool key --delay 30 BackSpace BackSpace BackSpace BackSpace Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 '1813'")
time.sleep(0.2)

print("Moving Right to Row 6 Description...")
run("xdotool key Right")
time.sleep(0.2)
run("xdotool key --delay 30 BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 'WR FGS-Non WM'")
time.sleep(0.3)

print("Pressing Return to validate...")
run("xdotool key Return")
time.sleep(1.2)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_sloc_success.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
