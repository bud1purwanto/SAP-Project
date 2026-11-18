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
print("Entering Date low: 18.11.2026...")
run("DISPLAY=:99 xdotool type --delay 50 '18.11.2026'")
time.sleep(0.2)

# 2. Date high
print("Entering Date high: 18.11.2026...")
run("DISPLAY=:99 xdotool key Tab")
time.sleep(0.2)
run("DISPLAY=:99 xdotool type --delay 50 '18.11.2026'")
time.sleep(0.2)

# Tab to Plant (Tab 2 times: multiple sel, then Plant low)
run("DISPLAY=:99 xdotool key Tab Tab")
time.sleep(0.2)
print("Entering Plant: 2000...")
run("DISPLAY=:99 xdotool type --delay 50 '2000'")
time.sleep(0.2)

# Tab to Material (Tab 6 times)
run("DISPLAY=:99 xdotool key Tab Tab Tab Tab Tab Tab")
time.sleep(0.2)
print("Entering Material: JREYAI...")
run("DISPLAY=:99 xdotool type --delay 50 'JREYAI'")
time.sleep(0.2)

# Tab to Batch (Tab 3 times)
run("DISPLAY=:99 xdotool key Tab Tab Tab")
time.sleep(0.2)
print("Entering Batch: 0000407417...")
run("DISPLAY=:99 xdotool type --delay 50 '0000407417'")
time.sleep(0.5)

# Save selection screenshot
run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm005_conv_sel.png")
print("Saved ZQM005 selection screen for converting lot.")

# Press F8 to execute
print("Pressing F8...")
run("DISPLAY=:99 xdotool key F8")
time.sleep(4)

# Save result screen
run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm005_conv_result.png")
print("Saved ZQM005 result screen for converting lot.")
