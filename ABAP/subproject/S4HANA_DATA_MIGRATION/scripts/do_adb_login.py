import subprocess
import time
import os

env = dict(os.environ)
env['DISPLAY'] = ':99'

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

# Find ADB window
r = run("xdotool search --name 'ADB' 2>/dev/null")
win = [w.strip() for w in r.stdout.splitlines() if w.strip()][-1]
run(f"xdotool windowactivate {win}")
time.sleep(0.5)

# Click Client box (125, 195)
print("Setting Client 130...")
run("xdotool mousemove 125 195 click 1")
time.sleep(0.2)
run("xdotool key ctrl+a BackSpace")
run("xdotool type '130'")
time.sleep(0.2)

# Tab to User
print("Setting User TRSTABAP...")
run("xdotool key Tab")
time.sleep(0.2)
run("xdotool key ctrl+a BackSpace")
run("xdotool type 'TRSTABAP'")
time.sleep(0.2)

# Tab to Password
print("Setting Password...")
run("xdotool key Tab")
time.sleep(0.2)
run("xdotool type 'supporter'")
time.sleep(0.2)

# Press Enter to Login
print("Submitting login...")
run("xdotool key Return")
time.sleep(2)

# Check if License Dialog appeared
run("ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/after_login_submit.png")
print("Captured /tmp/after_login_submit.png")
