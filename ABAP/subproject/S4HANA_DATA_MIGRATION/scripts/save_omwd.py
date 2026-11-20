import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Press Ctrl+s
run('export DISPLAY=:99; xdotool key ctrl+s')
time.sleep(1.0)

# Press Return to confirm TR prompt if any
run('export DISPLAY=:99; xdotool key Return')
time.sleep(1.0)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/omwd_saved.png')
print('OMWD saved')
