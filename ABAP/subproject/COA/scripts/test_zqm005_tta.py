import subprocess
import time

def run(cmd):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return p.stdout.strip()

print("Focusing TRD window...")
run("DISPLAY=:99 xdotool search --name 'TRD' windowactivate --sync")
time.sleep(0.5)

# Reset to /nZQM005
print("Navigating to /nZQM005...")
run("DISPLAY=:99 xdotool mousemove 60 75 click 1")
time.sleep(0.2)
run("DISPLAY=:99 xdotool key ctrl+a BackSpace")
time.sleep(0.2)
run("DISPLAY=:99 xdotool type '/nZQM005'")
time.sleep(0.3)
run("DISPLAY=:99 xdotool key Return")
time.sleep(2.5)

# 1. Date low
print("Entering Date low: 06.11.2019...")
run("DISPLAY=:99 xdotool type --delay 50 '06.11.2019'")
time.sleep(0.2)

# 2. Date high
print("Entering Date high: 06.11.2019...")
run("DISPLAY=:99 xdotool key Tab")
time.sleep(0.2)
run("DISPLAY=:99 xdotool type --delay 50 '06.11.2019'")
time.sleep(0.2)

# Tab to Plant (Tab 2 times: multiple sel, then Plant low)
run("DISPLAY=:99 xdotool key Tab Tab")
time.sleep(0.2)
print("Entering Plant: TTA2...")
run("DISPLAY=:99 xdotool type --delay 50 'TTA2'")
time.sleep(0.2)

# Tab to Material (Tab 6 times: Plant high, Plant mult, Line low, Line high, Line mult, Material low)
run("DISPLAY=:99 xdotool key Tab Tab Tab Tab Tab Tab")
time.sleep(0.2)
print("Entering Material: JRSEFI...")
run("DISPLAY=:99 xdotool type --delay 50 'JRSEFI'")
time.sleep(0.2)

# Tab to Batch (Tab 3 times: Mat high, Mat mult, Batch low)
run("DISPLAY=:99 xdotool key Tab Tab Tab")
time.sleep(0.2)
print("Entering Batch: 0000371969...")
run("DISPLAY=:99 xdotool type --delay 50 '0000371969'")
time.sleep(0.5)

# Save selection screenshot
run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm005_tta_sel.png")
print("Saved ZQM005 selection screen.")

# Press F8 to execute
print("Pressing F8...")
run("DISPLAY=:99 xdotool key F8")
time.sleep(4)

# Save result screen
run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm005_tta_result.png")
print("Saved ZQM005 result screen.")

out = run("DISPLAY=:99 xdotool search --name '.*'")
for wid in out.splitlines():
    wname = run(f"DISPLAY=:99 xdotool getwindowname {wid}")
    if wname:
        print(f"{wid}: {wname}")
