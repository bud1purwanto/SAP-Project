import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("1. Selecting Row 5 (1011) with F9...")
run("xdotool key F9")
time.sleep(0.5)

print("2. Deleting Row 5 with Shift+F2...")
run("xdotool key shift+F2")
time.sleep(0.5)

print("3. Row 5 is now 1813. Moving Right to Row 5 Description...")
run("xdotool key Right")
time.sleep(0.3)
run("xdotool type --delay 60 'WR FGS (Non WM)'")
time.sleep(0.3)

print("4. Moving Down to Row 6 Description (2011)...")
run("xdotool key Down")
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
run("xdotool key --delay 20 BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace")
time.sleep(0.1)
run("xdotool type --delay 60 'Feed XLM1'")
time.sleep(0.3)

print("5. Moving Down to Row 7 Description (2021)...")
run("xdotool key Down")
time.sleep(0.3)
run("xdotool type --delay 60 'Feed OPP4'")
time.sleep(0.3)

print("6. Validating with Return...")
run("xdotool key Return")
time.sleep(1.2)

print("7. Saving with Ctrl+S...")
run("xdotool key ctrl+s")
time.sleep(1.5)
run("xdotool key Return")
time.sleep(2.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_2000_perfect_final.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured final screenshot to", out_file)
