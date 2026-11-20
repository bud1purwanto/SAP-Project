import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Press F3 twice to get back to selection screen
run('export DISPLAY=:99; xdotool key F3')
time.sleep(1.0)
run('export DISPLAY=:99; xdotool key F3')
time.sleep(1.0)

# Focus Plant box, enter 2000
run('export DISPLAY=:99; xdotool mousemove 210 253 click 1')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool key ctrl+a BackSpace; xdotool type 2000')
time.sleep(0.3)

# Execute F8 (Background Processing and Test Run should still be unchecked)
run('export DISPLAY=:99; xdotool key F8')
time.sleep(3.5)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/ckmstart_2000_result.png')
print('Plant 2000 CKMSTART executed')
