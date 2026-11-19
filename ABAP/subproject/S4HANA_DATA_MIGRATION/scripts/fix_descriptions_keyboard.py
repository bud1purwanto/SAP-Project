import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("1. Moving Up twice from Row 6 to Row 4 SLoc...")
run("xdotool key Up")
time.sleep(0.3)
run("xdotool key Up")
time.sleep(0.3)

print("2. Moving Right to Row 4 Description...")
run("xdotool key Right")
time.sleep(0.3)

print("3. Clearing Row 4 Description and typing 'Feed OPP WR'...")
run("xdotool key --delay 25 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete Delete Delete")
time.sleep(0.2)
run("xdotool type --delay 60 'Feed OPP WR'")
time.sleep(0.3)

print("4. Moving Down to Row 5 Description...")
run("xdotool key Down")
time.sleep(0.3)

print("5. Clearing Row 5 Description and typing 'WR FGS-Non WM'...")
run("xdotool key --delay 25 BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete")
time.sleep(0.2)
run("xdotool type --delay 60 'WR FGS-Non WM'")
time.sleep(0.3)

print("6. Pressing Return to validate...")
run("xdotool key Return")
time.sleep(1.2)

print("7. Saving with Ctrl+S...")
run("xdotool key ctrl+s")
time.sleep(1.5)

print("8. Confirming TR dialog...")
run("xdotool key Return")
time.sleep(2.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_1000_verified.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
