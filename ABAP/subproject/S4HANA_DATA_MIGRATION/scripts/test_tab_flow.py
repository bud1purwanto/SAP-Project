import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("Clearing cell and typing 1011...")
run("xdotool mousemove 182 307 click --repeat 2 1")
time.sleep(0.3)
run("xdotool key --delay 50 ctrl+a BackSpace")
time.sleep(0.2)
run("xdotool type --delay 60 '1011'")
time.sleep(0.3)

print("Pressing Tab...")
run("xdotool key Tab")
time.sleep(0.3)

print("Typing Feed OPP WR...")
run("xdotool type --delay 60 'Feed OPP WR'")
time.sleep(0.3)

print("Pressing Tab...")
run("xdotool key Tab")
time.sleep(0.3)

print("Typing 1813...")
run("xdotool type --delay 60 '1813'")
time.sleep(0.3)

print("Pressing Tab...")
run("xdotool key Tab")
time.sleep(0.3)

print("Typing WR FGS-Non WM...")
run("xdotool type --delay 60 'WR FGS-Non WM'")
time.sleep(0.3)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/test_tab_flow.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
