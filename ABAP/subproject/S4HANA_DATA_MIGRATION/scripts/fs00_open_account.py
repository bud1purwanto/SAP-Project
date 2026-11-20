import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# G/L Account is focused
run('export DISPLAY=:99; xdotool type 399999')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool key Tab')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool type 9999')
time.sleep(0.3)

# Click pencil (Change) icon at (296, 223)
run('export DISPLAY=:99; xdotool mousemove 296 223 click 1')
time.sleep(1.5)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/fs00_account_opened.png')
print('FS00 account opened')
