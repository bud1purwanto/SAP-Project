import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("Starting from focused Row 7 SLoc (2021)...")

# 1. Right to Row 7 Description
run("xdotool key Right")
time.sleep(0.3)
run("xdotool type --delay 60 'Feed OPP4'")
time.sleep(0.3)

# 2. Up to Row 6 Description (2011)
run("xdotool key Up")
time.sleep(0.3)
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
run("xdotool key --delay 20 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace")
time.sleep(0.1)
run("xdotool type --delay 60 'Feed XLM1'")
time.sleep(0.3)

# 3. Up to Row 5 Description (1813)
run("xdotool key Up")
time.sleep(0.3)
run("xdotool key --delay 20 BackSpace BackSpace BackSpace BackSpace Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 'WR FGS (Non WM)'")
time.sleep(0.3)

# 4. Return to validate
run("xdotool key Return")
time.sleep(1.2)

# 5. Save with Ctrl+S
run("xdotool key ctrl+s")
time.sleep(1.5)
run("xdotool key Return")
time.sleep(2.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_2000_finished_clean.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
