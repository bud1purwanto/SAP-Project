import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# From Row 4 Company Name, press Tab twice
run('export DISPLAY=:99; xdotool key Tab; sleep 0.2; xdotool key Tab; sleep 0.2; xdotool type 0001')
time.sleep(0.5)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/omwd_tabbed.png')
print('Tabbed')
