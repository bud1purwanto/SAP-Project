import subprocess
import time
import os

env = dict(os.environ)
env['DISPLAY'] = ':99'

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("1. Launching S4 HANA...")
run("nohup /opt/SAPClients/SAPGUI/bin/guilogon -o '/H/192.168.1.199/S/3201' > /dev/null 2>&1 &")
time.sleep(3)

print("2. Finding ADB window...")
win = None
for _ in range(10):
    r = run("xdotool search --name 'ADB' 2>/dev/null")
    wins = [w.strip() for w in r.stdout.splitlines() if w.strip()]
    if wins:
        win = wins[-1]
        break
    time.sleep(1)

if not win:
    print("ERROR: ADB window not found!")
    exit(1)

print(f"ADB window: {win}")
run(f"xdotool windowactivate {win}")
time.sleep(0.5)

print("3. Entering login credentials...")
run("xdotool key Shift+Tab")
time.sleep(0.2)
run("xdotool key ctrl+a BackSpace")
run("xdotool type '130'")
time.sleep(0.2)

run("xdotool key Tab")
time.sleep(0.2)
run("xdotool key ctrl+a BackSpace")
run("xdotool type 'TRSTABAP'")
time.sleep(0.2)

run("xdotool key Tab")
time.sleep(0.2)
run("xdotool key ctrl+a BackSpace")
run("xdotool type 'supporter'")
time.sleep(0.2)

run("xdotool key Return")
time.sleep(2.5)

# Check if License dialog is up
r = run("xdotool search --name 'License' 2>/dev/null")
lic_wins = [w.strip() for w in r.stdout.splitlines() if w.strip()]
if lic_wins:
    print("License dialog detected!")
    lic_win = lic_wins[-1]
    run(f"xdotool windowactivate {lic_win}")
    time.sleep(0.5)
    # Click Option 1 text (X: 100, Y: 305)
    print("Clicking Option 1 (X: 100, Y: 305)...")
    run("xdotool mousemove 100 305 click 1")
    time.sleep(1)
    run("ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/license_selected.png")
    
    # Click Enter button at bottom right (X: 955, Y: 880)
    print("Clicking Enter button (X: 955, Y: 880)...")
    run("xdotool mousemove 955 880 click 1")
    time.sleep(3)

# Verify final window title
r = run("xdotool getactivewindow getwindowname")
print("Active window name:", r.stdout.strip())

run("ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/after_license_enter.png")
print("Saved /tmp/after_license_enter.png")
