import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("Pressing Up twice...")
run("xdotool key Up")
time.sleep(0.2)
run("xdotool key Up")
time.sleep(0.2)

print("Pressing Right...")
run("xdotool key Right")
time.sleep(0.3)

print("Typing TEST...")
run("xdotool type --delay 50 'TEST'")
time.sleep(0.3)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/test_right_arrow.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
