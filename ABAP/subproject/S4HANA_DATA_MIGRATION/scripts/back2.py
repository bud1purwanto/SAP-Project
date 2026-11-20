import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

run('export DISPLAY=:99; xdotool key F3')
time.sleep(1.0)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/ckmstart_back2.png')
print('Back 2 pressed')
