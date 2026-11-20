import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# 1 more Tab to reach Background Processing
run('export DISPLAY=:99; xdotool key Tab')
time.sleep(0.2)
# Press Space to toggle
run('export DISPLAY=:99; xdotool key space')
time.sleep(0.3)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/ckmstart_toggled.png')
print('Toggled')
