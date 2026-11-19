import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("A. Clicking Row 4 (1011) Description at (299, 356)...")
run("xdotool mousemove 299 356 click --repeat 2 1")
time.sleep(0.3)
run("xdotool key --delay 25 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 'Feed OPP WR'")
time.sleep(0.3)

print("B. Clicking Row 5 (1813) Description at (299, 389)...")
run("xdotool mousemove 299 389 click --repeat 2 1")
time.sleep(0.3)
run("xdotool key --delay 25 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete")
time.sleep(0.1)
run("xdotool type --delay 60 'WR FGS-Non WM'")
time.sleep(0.3)

print("C. Selecting Row 6 (WR F) at (216, 422)...")
run("xdotool mousemove 216 422 click 1")
time.sleep(0.4)

print("D. Clicking Delete button at (174, 92)...")
run("xdotool mousemove 174 92 click 1")
time.sleep(0.5)

print("E. Validating with Return...")
run("xdotool key Return")
time.sleep(1.0)

print("F. Saving with Ctrl+S...")
run("xdotool key ctrl+s")
time.sleep(1.5)

print("G. Confirming TR dialog with Return...")
run("xdotool key Return")
time.sleep(2.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_1000_success_final.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured final screenshot to", out_file)
