import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Press F6 to switch to Change mode
run('export DISPLAY=:99; xdotool key F6')
time.sleep(1.0)

# Click Tab 2 'Control Data' at (125, 280)
run('export DISPLAY=:99; xdotool mousemove 125 280 click 1')
time.sleep(1.0)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/fs00_tab_switched.png')
print('F6 and tab clicked')
