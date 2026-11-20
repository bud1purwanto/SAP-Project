import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Focus Plant 1000 box
run('export DISPLAY=:99; xdotool mousemove 210 253 click 1')
time.sleep(0.3)

# 6 Tabs to Test Run
for i in range(6):
    run('export DISPLAY=:99; xdotool key Tab')
    time.sleep(0.15)

# Press Space to uncheck Test Run
run('export DISPLAY=:99; xdotool key space')
time.sleep(0.3)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/ckmstart_ready_live.png')
print('Test Run unchecked')
