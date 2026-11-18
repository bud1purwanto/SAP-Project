import subprocess
import time

def run(cmd):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return p.stdout.strip()

print("Focusing TRD window...")
run("DISPLAY=:99 xdotool search --name 'TRD' windowactivate --sync")
time.sleep(0.5)

# Press Shift+Tab twice to go up to Client
print("Pressing Shift+Tab twice...")
run("DISPLAY=:99 xdotool key --delay 200 shift+Tab shift+Tab")
time.sleep(0.5)

run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_tab.png")
print("Screenshot saved to screen_tab.png")
