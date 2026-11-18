import subprocess
import time

def run(cmd):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return p.stdout.strip()

print("Focusing TRD window...")
run("DISPLAY=:99 xdotool search --name 'TRD' windowactivate --sync")
time.sleep(0.5)

# Click Nomor ODO field
print("Clicking Nomor ODO...")
run("DISPLAY=:99 xdotool mousemove 225 315 click 1")
time.sleep(0.5)

# Type using delay
print("Typing 0085006285...")
run("DISPLAY=:99 xdotool type --delay 100 '0085006285'")
time.sleep(0.5)

# Save selection screenshot
run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_do6285_sel.png")

# Now press Return to validate
run("DISPLAY=:99 xdotool key Return")
time.sleep(1)

# Now press F8 to execute
run("DISPLAY=:99 xdotool key F8")
time.sleep(4)

# Save result screen
run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_do6285_alv.png")
print("Saved screens.")
