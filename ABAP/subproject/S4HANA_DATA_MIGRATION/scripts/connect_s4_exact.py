import subprocess
import time
import os

env = dict(os.environ)
env['DISPLAY'] = ':99'

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

# 1. Close any TRD window
r = run("xdotool search --name 'TRD' 2>/dev/null")
for win in r.stdout.splitlines():
    if win.strip():
        run(f"xdotool windowclose {win.strip()}")
time.sleep(1)

# 2. Activate SAP GUI for Java
r = run("xdotool search --name 'SAP GUI for Java' 2>/dev/null")
win_ids = [w.strip() for w in r.stdout.splitlines() if w.strip()]
if not win_ids:
    print("SAP GUI for Java not found!")
    exit(1)
win = win_ids[-1]
run(f"xdotool windowactivate {win}")
time.sleep(0.5)

# 3. Single click on S4 HANA (X: 250, Y: 280)
print("Clicking S4 HANA...")
run("xdotool mousemove 250 280 click 1")
time.sleep(0.5)

# 4. Double click S4 HANA to connect
print("Double clicking S4 HANA...")
run("xdotool mousemove 250 280 click --repeat 2 --delay 100 1")
time.sleep(3)

# 5. Check if ADB window opened
for i in range(10):
    r = run("xdotool search --name 'ADB' 2>/dev/null")
    adb_wins = [w.strip() for w in r.stdout.splitlines() if w.strip()]
    if adb_wins:
        print("ADB window found:", adb_wins)
        break
    time.sleep(1)

run("ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/after_s4_launch.png")
print("Done launch check")
