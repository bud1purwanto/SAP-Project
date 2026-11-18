import subprocess
import time

def run(cmd):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return p.stdout.strip()

print("Focusing TRD window...")
run("DISPLAY=:99 xdotool search --name 'TRD' windowactivate --sync")
time.sleep(0.5)

# Focus is currently on New Password
# Tab 1: Client
print("Moving to Client...")
run("DISPLAY=:99 xdotool key Tab")
time.sleep(0.3)
run("DISPLAY=:99 xdotool key BackSpace")
time.sleep(0.2)
run("DISPLAY=:99 xdotool type '130'")
time.sleep(0.3)

# Tab 2: User
print("Moving to User...")
run("DISPLAY=:99 xdotool key Tab")
time.sleep(0.3)
run("DISPLAY=:99 xdotool key BackSpace")
time.sleep(0.2)
run("DISPLAY=:99 xdotool type 'TRSTDEV'")
time.sleep(0.3)

# Tab 3: Password
print("Moving to Password...")
run("DISPLAY=:99 xdotool key Tab")
time.sleep(0.3)
run("DISPLAY=:99 xdotool key BackSpace")
time.sleep(0.2)
run("DISPLAY=:99 xdotool type 'ronin03'")
time.sleep(0.5)

# Screenshot before submit
run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_ready_submit.png")

# Submit
print("Pressing Return...")
run("DISPLAY=:99 xdotool key Return")

for i in range(5):
    time.sleep(1)
    print(f"Waiting {i+1}s...")

run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_after_submit.png")
print("Screenshot saved.")

out = run("DISPLAY=:99 xdotool search --name '.*'")
for wid in out.splitlines():
    wname = run(f"DISPLAY=:99 xdotool getwindowname {wid}")
    if wname:
        print(f"{wid}: {wname}")
