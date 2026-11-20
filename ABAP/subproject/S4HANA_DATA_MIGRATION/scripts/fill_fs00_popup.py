import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Focus is on account box
run('export DISPLAY=:99; xdotool type 399999')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool key Tab')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool type 9999')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool key Return')
time.sleep(1.5)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/fs00_main.png')
print('FS00 main loaded')
