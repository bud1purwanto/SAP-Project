import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("Starting keyboard navigation from Row 1...")
# First activate window 35651634
run("xdotool windowactivate 35651634")
time.sleep(0.5)

# Down 4 times to reach Row 5 description
for i in range(4):
    run("xdotool key Down")
    time.sleep(0.15)

# Left to Row 5 SLoc
run("xdotool key Left")
time.sleep(0.2)

# Clear Row 5 SLoc (Backspace 6 times, Delete 6 times)
run("xdotool key --delay 30 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace")
time.sleep(0.1)
run("xdotool key --delay 30 Delete Delete Delete Delete Delete")
time.sleep(0.1)

# Type 1011
run("xdotool type --delay 60 '1011'")
time.sleep(0.2)

# Right to Row 5 Description
run("xdotool key Right")
time.sleep(0.2)

# Clear and type Feed OPP WR
run("xdotool key --delay 30 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace")
time.sleep(0.1)
run("xdotool type --delay 60 'Feed OPP WR'")
time.sleep(0.2)

# Down to Row 6 Description
run("xdotool key Down")
time.sleep(0.2)

# Left to Row 6 SLoc
run("xdotool key Left")
time.sleep(0.2)

# Clear Row 6 SLoc
run("xdotool key --delay 30 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace")
time.sleep(0.1)
run("xdotool key --delay 30 Delete Delete Delete Delete Delete")
time.sleep(0.1)

# Type 1813
run("xdotool type --delay 60 '1813'")
time.sleep(0.2)

# Right to Row 6 Description
run("xdotool key Right")
time.sleep(0.2)

# Clear and type WR FGS-Non WM
run("xdotool key --delay 30 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace")
time.sleep(0.1)
run("xdotool type --delay 60 'WR FGS-Non WM'")
time.sleep(0.3)

# Return to validate
run("xdotool key Return")
time.sleep(1.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_keyboard_result.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
