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
run("DISPLAY=:99 xdotool mousemove 225 322 click 1")
time.sleep(0.3)
run("DISPLAY=:99 xdotool key ctrl+a BackSpace")
time.sleep(0.2)
run("DISPLAY=:99 xdotool type '0085006285'")
time.sleep(0.5)

# Save selection screen screenshot
run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_do6285_sel.png")
print("Saved selection screen.")

# Press F8 to execute
print("Pressing F8...")
run("DISPLAY=:99 xdotool key F8")

for i in range(5):
    time.sleep(1)
    print(f"Waiting {i+1}s...")

# Save result screen
run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_zqm002_do6285_alv.png")
print("Saved ALV result screen.")

out = run("DISPLAY=:99 xdotool search --name '.*'")
for wid in out.splitlines():
    wname = run(f"DISPLAY=:99 xdotool getwindowname {wid}")
    if wname:
        print(f"{wid}: {wname}")
