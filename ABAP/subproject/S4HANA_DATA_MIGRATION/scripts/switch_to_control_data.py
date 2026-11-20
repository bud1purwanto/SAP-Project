import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Click pencil (Change) icon at (296, 223)
run('export DISPLAY=:99; xdotool mousemove 296 223 click 1')
time.sleep(1.0)

# Click Tab 'Control Data' at (135, 280)
run('export DISPLAY=:99; xdotool mousemove 135 280 click 1')
time.sleep(1.0)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/fs00_control_data.png')
print('Control Data tab loaded')
