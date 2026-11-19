import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("Clearing Row 1 and Row 2...")
run("xdotool mousemove 182 307 click --repeat 2 1")
time.sleep(0.3)
run("xdotool key --delay 40 ctrl+a BackSpace")
time.sleep(0.2)
run("xdotool type --delay 50 '1011'")
time.sleep(0.3)

run("xdotool mousemove 182 327 click --repeat 2 1")
time.sleep(0.3)
run("xdotool key --delay 40 ctrl+a BackSpace")
time.sleep(0.2)
run("xdotool type --delay 50 '1813'")
time.sleep(0.3)

print("Pressing Return...")
run("xdotool key Return")
time.sleep(1.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/after_slocs_typed.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
