import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("Starting from focused Row 2 SLoc...")

# 1. Type 2021 in Row 2 SLoc
print("Typing 2021 in Row 2 SLoc...")
run("xdotool type --delay 60 '2021'")
time.sleep(0.3)

# 2. Right to Row 2 Description
print("Right to Row 2 Description...")
run("xdotool key Right")
time.sleep(0.3)

# Clear text and type Feed OPP4
run("xdotool key --delay 25 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 'Feed OPP4'")
time.sleep(0.3)

# 3. Down to Row 3 Description
print("Down to Row 3 Description...")
run("xdotool key Down")
time.sleep(0.3)

# 4. Left to Row 3 SLoc
print("Left to Row 3 SLoc...")
run("xdotool key Left")
time.sleep(0.3)
run("xdotool type --delay 60 '1813'")
time.sleep(0.3)

# 5. Right to Row 3 Description
print("Right to Row 3 Description...")
run("xdotool key Right")
time.sleep(0.3)
run("xdotool type --delay 60 'WR FGS (Non WM)'")
time.sleep(0.3)

# 6. Up twice to Row 1 Description
print("Up twice to Row 1 Description...")
run("xdotool key Up")
time.sleep(0.2)
run("xdotool key Up")
time.sleep(0.2)

# Clear Row 1 Description and type Feed XLM1
print("Clearing Row 1 Description...")
run("xdotool key --delay 25 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 'Feed XLM1'")
time.sleep(0.3)

# 7. Validate with Return
print("Validating with Return...")
run("xdotool key Return")
time.sleep(1.5)

# 8. Save with Ctrl+S
print("Saving with Ctrl+S...")
run("xdotool key ctrl+s")
time.sleep(1.5)

# 9. Confirm TR dialog
print("Confirming TR...")
run("xdotool key Return")
time.sleep(2.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_2000_final_verified.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
