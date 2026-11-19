import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("Double clicking Row 1 SLoc at (182, 307)...")
run("xdotool mousemove 182 307 click --repeat 2 1")
time.sleep(0.5)

print("Typing 1011...")
run("xdotool type --delay 80 '1011'")
time.sleep(0.5)

print("Moving to Row 1 Desc at (247, 307) and double clicking...")
run("xdotool mousemove 247 307 click --repeat 2 1")
time.sleep(0.5)

print("Typing Feed OPP WR...")
run("xdotool type --delay 80 'Feed OPP WR'")
time.sleep(0.5)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/test_cell_input.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
