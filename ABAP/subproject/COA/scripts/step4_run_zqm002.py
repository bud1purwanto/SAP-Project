import subprocess
import time

def run(cmd):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return p.stdout.strip()

print("Focusing TRD window...")
run("DISPLAY=:99 xdotool search --name 'TRD' windowactivate --sync")
time.sleep(0.5)

# Focus command field with ctrl+/ or click (x=60, y=75)
print("Navigating to /nZQM002...")
run("DISPLAY=:99 xdotool mousemove 60 75 click 1")
time.sleep(0.2)
run("DISPLAY=:99 xdotool key ctrl+a BackSpace")
time.sleep(0.2)
run("DISPLAY=:99 xdotool type '/nZQM002'")
time.sleep(0.3)
run("DISPLAY=:99 xdotool key Return")

for i in range(4):
    time.sleep(1)
    print(f"Waiting {i+1}s...")

run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_sel.png")
print("Screenshot saved to screen_zqm002_sel.png")

out = run("DISPLAY=:99 xdotool search --name '.*'")
for wid in out.splitlines():
    wname = run(f"DISPLAY=:99 xdotool getwindowname {wid}")
    if wname:
        print(f"{wid}: {wname}")
