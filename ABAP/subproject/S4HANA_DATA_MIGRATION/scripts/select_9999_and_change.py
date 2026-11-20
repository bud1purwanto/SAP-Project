import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Press Return to accept 9999 dropdown
run('export DISPLAY=:99; xdotool key Return')
time.sleep(0.5)

# Click pencil (Change) icon at (296, 223)
run('export DISPLAY=:99; xdotool mousemove 296 223 click 1')
time.sleep(1.5)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/fs00_account_details.png')
print('FS00 details loaded')
