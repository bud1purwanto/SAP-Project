import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Click Plant input field (X=210, Y=253)
run('export DISPLAY=:99; xdotool mousemove 210 253 click 1')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool key ctrl+a BackSpace; xdotool type 1000')
time.sleep(0.3)

# Uncheck Background Processing (X=22, Y=473)
run('export DISPLAY=:99; xdotool mousemove 22 473 click 1')
time.sleep(0.3)

# Take screenshot
run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/ckmstart_step1.png')
print('Step 1 executed successfully')
