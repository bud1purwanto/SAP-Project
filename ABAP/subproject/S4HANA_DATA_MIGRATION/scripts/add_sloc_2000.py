import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("1. Typing Plant 2000 and pressing Return...")
run("xdotool type --delay 60 '2000'")
time.sleep(0.3)
run("xdotool key Return")
time.sleep(1.5)

print("2. Pressing F5 for New Entries...")
run("xdotool key F5")
time.sleep(1.5)

print("3. Entering Row 1: SLoc 2011 at (234, 257)...")
run("xdotool mousemove 234 257 click --repeat 2 1")
time.sleep(0.3)
run("xdotool type --delay 60 '2011'")
time.sleep(0.3)

print("4. Entering Row 1: Desc Feed XLM1 at (299, 257)...")
run("xdotool mousemove 299 257 click --repeat 2 1")
time.sleep(0.3)
run("xdotool type --delay 60 'Feed XLM1'")
time.sleep(0.3)

print("5. Entering Row 2: SLoc 2021 at (234, 290)...")
run("xdotool mousemove 234 290 click --repeat 2 1")
time.sleep(0.3)
run("xdotool type --delay 60 '2021'")
time.sleep(0.3)

print("6. Entering Row 2: Desc Feed OPP4 at (299, 290)...")
run("xdotool mousemove 299 290 click --repeat 2 1")
time.sleep(0.3)
run("xdotool type --delay 60 'Feed OPP4'")
time.sleep(0.3)

print("7. Entering Row 3: SLoc 1813 at (234, 323)...")
run("xdotool mousemove 234 323 click --repeat 2 1")
time.sleep(0.3)
run("xdotool type --delay 60 '1813'")
time.sleep(0.3)

print("8. Entering Row 3: Desc WR FGS (Non WM) at (299, 323)...")
run("xdotool mousemove 299 323 click --repeat 2 1")
time.sleep(0.3)
run("xdotool type --delay 60 'WR FGS (Non WM)'")
time.sleep(0.3)

print("9. Pressing Return to validate...")
run("xdotool key Return")
time.sleep(1.5)

print("10. Saving with Ctrl+S...")
run("xdotool key ctrl+s")
time.sleep(1.5)

print("11. Confirming TR dialog...")
run("xdotool key Return")
time.sleep(2.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_2000_saved.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
