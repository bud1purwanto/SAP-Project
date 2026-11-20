import subprocess
import time
import os

env = dict(os.environ)
env['DISPLAY'] = ':99'

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

# Focus license dialog
r = run("xdotool search --name 'License' 2>/dev/null")
win = [w.strip() for w in r.stdout.splitlines() if w.strip()][-1]
run(f"xdotool windowactivate {win}")
time.sleep(0.5)

# Click radio button 2: Continue with this logon without ending other logons
print("Selecting Option 2 (X: 10, Y: 405)...")
run("xdotool mousemove 10 405 click 1")
time.sleep(0.5)

# Press Enter (or click Enter button at bottom right)
print("Pressing Enter...")
run("xdotool key Return")
time.sleep(3)

run("ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/after_license.png")
print("Captured /tmp/after_license.png")
