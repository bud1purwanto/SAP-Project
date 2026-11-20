import subprocess
import time
import os

env = dict(os.environ)
env['DISPLAY'] = ':99'

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("Selecting S4 HANA...")
run("xdotool mousemove 200 275 click 1")
time.sleep(0.5)
print("Clicking Connect / Pressing Enter...")
run("xdotool key Return")
time.sleep(3)

# Check active window
r = run("xdotool search --name '' getwindowname %@ | grep -E 'ADB|SAP'")
print("Windows after connect:\n", r.stdout)

run("ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/s4_after_connect.png")
