import subprocess
import time
import os

env = dict(os.environ)
env['DISPLAY'] = ':99'

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

# Focus ADB window
r = run("xdotool search --name 'ADB' 2>/dev/null")
win = [w.strip() for w in r.stdout.splitlines() if w.strip()][-1]
run(f"xdotool windowactivate {win}")
time.sleep(0.5)

# Press Shift+Tab to move from User to Client
print("Navigating to Client via Shift+Tab...")
run("xdotool key Shift+Tab")
time.sleep(0.3)
run("xdotool key ctrl+a BackSpace")
run("xdotool type '130'")
time.sleep(0.2)

# Tab to User
print("Navigating to User...")
run("xdotool key Tab")
time.sleep(0.2)
run("xdotool key ctrl+a BackSpace")
run("xdotool type 'TRSTABAP'")
time.sleep(0.2)

# Tab to Password
print("Navigating to Password...")
run("xdotool key Tab")
time.sleep(0.2)
run("xdotool key ctrl+a BackSpace")
run("xdotool type 'supporter'")
time.sleep(0.2)

# Submit
print("Submitting login...")
run("xdotool key Return")
time.sleep(2.5)

run("ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/after_tab_login.png")
print("Captured /tmp/after_tab_login.png")
