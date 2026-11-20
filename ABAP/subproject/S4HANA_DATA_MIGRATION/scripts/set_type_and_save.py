import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Focus is on Status, press Shift+Tab to reach Type
run('export DISPLAY=:99; xdotool key shift+Tab')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool type 1')
time.sleep(0.3)

# Press Return to validate type selection
run('export DISPLAY=:99; xdotool key Return')
time.sleep(0.5)

# Press Ctrl+s to Save
run('export DISPLAY=:99; xdotool key ctrl+s')
time.sleep(1.5)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/se38_package_popup.png')
print('Type set and saved')
