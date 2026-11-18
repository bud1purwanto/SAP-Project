import subprocess
import time

def run(cmd):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return p.stdout.strip()

print("Focusing TRD window...")
run("DISPLAY=:99 xdotool search --name 'TRD' windowactivate --sync")
time.sleep(0.5)

# Click Nomor ODO box at (305, 320)
print("Clicking Nomor ODO at (305, 320)...")
run("DISPLAY=:99 xdotool mousemove 305 320 click 1")
time.sleep(0.3)
run("DISPLAY=:99 xdotool key ctrl+a BackSpace")
time.sleep(0.2)
run("DISPLAY=:99 xdotool type --delay 50 '0085006285'")
time.sleep(0.5)

# Save selection screenshot
run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_do6285_sel.png")
print("Saved selection screen.")

# Press F8 to execute
print("Pressing F8...")
run("DISPLAY=:99 xdotool key F8")
time.sleep(4)

# Save result screen
run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_do6285_alv.png")
print("Saved result screen.")
