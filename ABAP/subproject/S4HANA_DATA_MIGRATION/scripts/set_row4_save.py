import subprocess
import time
import os

env = dict(os.environ)
env['DISPLAY'] = ':99'

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("1. Down arrow to Row 4 ML Act...")
run("xdotool key Down")
time.sleep(0.3)

print("2. Checking ML Act for Row 4...")
run("xdotool key space")
time.sleep(1)

print("3. Acknowledging popup...")
run("xdotool key Return")
time.sleep(0.5)

print("4. Tab to Price Deter and typing 2...")
run("xdotool key Tab")
time.sleep(0.3)
run("xdotool key ctrl+a BackSpace")
run("xdotool type '2'")
time.sleep(0.3)

print("5. Tab to Price Det Binding and checking it...")
run("xdotool key Tab")
time.sleep(0.3)
run("xdotool key space")
time.sleep(0.5)

print("6. Saving changes (Ctrl+S)...")
run("xdotool key ctrl+s")
time.sleep(2)

# Check if TR prompt appears
r = run("xdotool search --name 'Prompt' 2>/dev/null")
if r.stdout.strip():
    print("TR prompt detected, confirming...")
    run("xdotool key Return")
    time.sleep(2)

run("ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/omx1_fully_saved.png")
print("Captured /tmp/omx1_fully_saved.png")
