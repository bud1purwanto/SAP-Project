import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Focus Plant box first to be 100% sure:
run('export DISPLAY=:99; xdotool mousemove 210 253 click 1')
time.sleep(0.3)
# Send 4 Tabs
for i in range(4):
    run('export DISPLAY=:99; xdotool key Tab')
    time.sleep(0.2)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/ckmstart_tab.png')
print('Tab test complete')
