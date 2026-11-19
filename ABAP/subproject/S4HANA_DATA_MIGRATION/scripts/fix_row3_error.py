import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("Typing 2021 in focused Row 3 SLoc...")
run("xdotool type --delay 60 '2021'")
time.sleep(0.3)

print("Moving Right to Row 3 Description...")
run("xdotool key Right")
time.sleep(0.3)

print("Typing Feed OPP4...")
run("xdotool type --delay 60 'Feed OPP4'")
time.sleep(0.3)

print("Pressing Return...")
run("xdotool key Return")
time.sleep(1.5)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/after_row3_typed.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
