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

# 1. Client 130
print("1. Set Client...")
run("xdotool mousemove 130 180 click 1")
time.sleep(0.2)
run("xdotool key ctrl+a BackSpace")
run("xdotool type '130'")
time.sleep(0.2)

# 2. User TRSTABAP
print("2. Set User...")
run("xdotool mousemove 130 245 click 1")
time.sleep(0.2)
run("xdotool key ctrl+a BackSpace")
run("xdotool type 'TRSTABAP'")
time.sleep(0.2)

# 3. Password supporter
print("3. Set Password...")
run("xdotool mousemove 130 285 click 1")
time.sleep(0.2)
run("xdotool key ctrl+a BackSpace")
run("xdotool type 'supporter'")
time.sleep(0.2)

# 4. Logon Language clear
print("4. Clear Language...")
run("xdotool mousemove 130 345 click 1")
time.sleep(0.2)
run("xdotool key ctrl+a BackSpace")
time.sleep(0.2)

# 5. Submit
print("5. Submitting...")
run("xdotool key Return")
time.sleep(2)

run("ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/login_perfect.png")
print("Captured /tmp/login_perfect.png")
