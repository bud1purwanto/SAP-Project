import subprocess
import time
import os

env = dict(os.environ)
env['DISPLAY'] = ':99'

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("1. Checking Price Det. Binding on Row 3...")
run("xdotool key space")
time.sleep(0.3)

print("2. Shift+Tab to Price Deter and typing 2...")
run("xdotool key Shift+Tab")
time.sleep(0.3)
run("xdotool key ctrl+a BackSpace")
run("xdotool type '2'")
time.sleep(0.3)

print("3. Shift+Tab to ML Act and checking it...")
run("xdotool key Shift+Tab")
time.sleep(0.3)
run("xdotool key space")
time.sleep(1)

print("4. Acknowledging popup...")
run("xdotool key Return")
time.sleep(1)

run("ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/omx1_row3_done.png")
print("Captured /tmp/omx1_row3_done.png")
