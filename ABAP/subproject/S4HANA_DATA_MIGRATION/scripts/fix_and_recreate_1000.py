import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("1. Selecting Row 5 selector at (216, 385)...")
run("xdotool mousemove 216 385 click 1")
time.sleep(0.3)

print("2. Selecting Row 6 selector with Shift at (216, 409)...")
run("xdotool keydown Shift")
time.sleep(0.1)
run("xdotool mousemove 216 409 click 1")
time.sleep(0.1)
run("xdotool keyup Shift")
time.sleep(0.3)

print("3. Deleting selected rows with Shift+F2...")
run("xdotool key shift+F2")
time.sleep(1.0)

print("4. Saving deletion with Ctrl+S...")
run("xdotool key ctrl+s")
time.sleep(1.2)
run("xdotool key Return")
time.sleep(1.5)

print("5. Clicking New Entries with F5...")
run("xdotool key F5")
time.sleep(1.5)

# In New Entries:
# Row 1 SLoc is at Target(182, 312) -> Input(234, 257)
# Row 1 Desc is at Target(247, 312) -> Input(299, 257)
# Row 2 SLoc is at Target(182, 336) -> Input(234, 281)
# Row 2 Desc is at Target(247, 336) -> Input(299, 281)

print("6. Entering Row 1: SLoc 1011...")
run("xdotool mousemove 234 257 click --repeat 2 1")
time.sleep(0.3)
run("xdotool type --delay 60 '1011'")
time.sleep(0.3)

print("7. Entering Row 1: Desc Feed OPP WR...")
run("xdotool mousemove 299 257 click --repeat 2 1")
time.sleep(0.3)
run("xdotool type --delay 60 'Feed OPP WR'")
time.sleep(0.3)

print("8. Entering Row 2: SLoc 1813...")
run("xdotool mousemove 234 281 click --repeat 2 1")
time.sleep(0.3)
run("xdotool type --delay 60 '1813'")
time.sleep(0.3)

print("9. Entering Row 2: Desc WR FGS-Non WM...")
run("xdotool mousemove 299 281 click --repeat 2 1")
time.sleep(0.3)
run("xdotool type --delay 60 'WR FGS-Non WM'")
time.sleep(0.3)

print("10. Pressing Return to validate...")
run("xdotool key Return")
time.sleep(1.5)

print("11. Saving with Ctrl+S...")
run("xdotool key ctrl+s")
time.sleep(1.5)
run("xdotool key Return")
time.sleep(2.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_1000_perfect.png'
run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}")
print("Captured screenshot to", out_file)
