import subprocess
import time
import os

env = dict(os.environ)
env['DISPLAY'] = ':99'

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

# Focus window
r = run("xdotool search --name 'ADB' 2>/dev/null")
win = [w.strip() for w in r.stdout.splitlines() if w.strip()][-1]
run(f"xdotool windowactivate {win}")
time.sleep(0.5)

print("1. Activating Plant 1000...")
# ML Act checkbox (X: 280, Y: 280)
run("xdotool mousemove 280 280 click 1")
time.sleep(0.2)

# Price Deter (X: 330, Y: 280) -> '2'
run("xdotool mousemove 330 280 click 1")
time.sleep(0.2)
run("xdotool key ctrl+a BackSpace")
run("xdotool type '2'")
time.sleep(0.2)

# Price Det Binding (X: 430, Y: 280)
run("xdotool mousemove 430 280 click 1")
time.sleep(0.2)

print("2. Activating Plant 2000...")
# ML Act checkbox (X: 280, Y: 308)
run("xdotool mousemove 280 308 click 1")
time.sleep(0.2)

# Price Deter (X: 330, Y: 308) -> '2'
run("xdotool mousemove 330 308 click 1")
time.sleep(0.2)
run("xdotool key ctrl+a BackSpace")
run("xdotool type '2'")
time.sleep(0.2)

# Price Det Binding (X: 430, Y: 308)
run("xdotool mousemove 430 308 click 1")
time.sleep(0.2)

print("3. Pressing Enter to validate...")
run("xdotool key Return")
time.sleep(1.5)

run("ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/omx1_after_input.png")
print("Captured /tmp/omx1_after_input.png")

print("4. Saving changes (Ctrl+S)...")
run("xdotool key ctrl+s")
time.sleep(2)

# In case TR popup appears, press Enter
r = run("xdotool search --name 'Prompt' 2>/dev/null")
if r.stdout.strip():
    print("TR Prompt detected, confirming...")
    run("xdotool key Return")
    time.sleep(2)

run("ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/omx1_after_save.png")
print("Captured /tmp/omx1_after_save.png")
