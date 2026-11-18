import subprocess
import time

def run(cmd):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return p.stdout.strip()

print("Focusing TRD window...")
run("DISPLAY=:99 xdotool search --name 'TRD' windowactivate --sync")
time.sleep(1)

# Click on Client field (125, 193)
print("Setting Client 130...")
run("DISPLAY=:99 xdotool mousemove 125 193 click 1")
time.sleep(0.3)
run("DISPLAY=:99 xdotool key ctrl+a BackSpace")
time.sleep(0.3)
run("DISPLAY=:99 xdotool type '130'")
time.sleep(0.5)

# Click on User field (150, 256)
print("Setting User TRSTDEV...")
run("DISPLAY=:99 xdotool mousemove 150 256 click 1")
time.sleep(0.3)
run("DISPLAY=:99 xdotool key ctrl+a BackSpace")
time.sleep(0.3)
run("DISPLAY=:99 xdotool type 'TRSTDEV'")
time.sleep(0.5)

# Click on Password field (150, 284)
print("Setting Password...")
run("DISPLAY=:99 xdotool mousemove 150 284 click 1")
time.sleep(0.3)
run("DISPLAY=:99 xdotool key ctrl+a BackSpace")
time.sleep(0.3)
run("DISPLAY=:99 xdotool type 'ronin03'")
time.sleep(0.5)

# Press Enter
print("Submitting login...")
run("DISPLAY=:99 xdotool key Return")

for i in range(5):
    time.sleep(1)
    print(f"Waiting {i+1}s...")

run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_after_login.png")
print("Screenshot saved to screen_after_login.png")

out = run("DISPLAY=:99 xdotool search --name '.*'")
for wid in out.splitlines():
    wname = run(f"DISPLAY=:99 xdotool getwindowname {wid}")
    if wname:
        print(f"{wid}: {wname}")
