import subprocess
import time

def run(cmd):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return p.stdout.strip()

print("Focusing TRD window...")
run("DISPLAY=:99 xdotool search --name 'TRD' windowactivate --sync")
time.sleep(1)

# 1. Client
print("Clearing and setting Client 130...")
run("DISPLAY=:99 xdotool mousemove 126 194 click 1")
time.sleep(0.2)
run("DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace Delete Delete Delete")
time.sleep(0.2)
run("DISPLAY=:99 xdotool type '130'")
time.sleep(0.3)

# 2. User
print("Clearing and setting User TRSTDEV...")
run("DISPLAY=:99 xdotool mousemove 150 257 click 1")
time.sleep(0.2)
run("DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete Delete Delete Delete")
time.sleep(0.2)
run("DISPLAY=:99 xdotool type 'TRSTDEV'")
time.sleep(0.3)

# 3. Password
print("Clearing and setting Password ronin03...")
run("DISPLAY=:99 xdotool mousemove 150 284 click 1")
time.sleep(0.2)
run("DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete Delete Delete Delete")
time.sleep(0.2)
run("DISPLAY=:99 xdotool type 'ronin03'")
time.sleep(0.5)

# 4. Take pre-enter screenshot to verify fields
run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_before_enter.png")

# 5. Press Enter
print("Submitting login...")
run("DISPLAY=:99 xdotool key Return")

for i in range(5):
    time.sleep(1)
    print(f"Waiting {i+1}s...")

run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_after_login2.png")
print("Screenshot saved.")

out = run("DISPLAY=:99 xdotool search --name '.*'")
for wid in out.splitlines():
    wname = run(f"DISPLAY=:99 xdotool getwindowname {wid}")
    if wname:
        print(f"{wid}: {wname}")
