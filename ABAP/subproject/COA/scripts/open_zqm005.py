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

run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm005_sel.png")
print("Saved ZQM005 selection screen.")
