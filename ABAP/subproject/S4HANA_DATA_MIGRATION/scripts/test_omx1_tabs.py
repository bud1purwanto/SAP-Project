import subprocess
import time
import os

env = dict(os.environ)
env['DISPLAY'] = ':99'

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

print("1. Click on Row 3 (1000) at X: 50, Y: 276...")
run("xdotool mousemove 50 276 click 1")
time.sleep(0.5)

print("2. Tabbing across Row 3...")
# Tab 4 times to reach ML Act checkbox
run("xdotool key Tab Tab Tab Tab")
time.sleep(0.3)
# Check ML Act with Space
run("xdotool key space")
time.sleep(0.3)

# Tab to Price Deter
run("xdotool key Tab")
time.sleep(0.2)
run("xdotool type '2'")
time.sleep(0.2)

# Tab to Price Det Binding
run("xdotool key Tab")
time.sleep(0.2)
run("xdotool key space")
time.sleep(0.5)

run("ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/omx1_row3_checked.png")
print("Captured /tmp/omx1_row3_checked.png")
