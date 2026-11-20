import subprocess
import time
import os

env = dict(os.environ)
env['DISPLAY'] = ':99'

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("1. Click Position... button...")
run("xdotool mousemove 160 670 click 1")
time.sleep(1)

print("2. Typing 1000 in Position popup...")
run("xdotool type '1000'")
time.sleep(0.3)
run("xdotool key Return")
time.sleep(1.5)

run("ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/omx1_position_1000.png")
print("Captured /tmp/omx1_position_1000.png")
