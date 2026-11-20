import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Click on the word  Background at (60, 473)
run('export DISPLAY=:99; xdotool mousemove 60 473 click 1')
time.sleep(0.5)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/ckmstart_click_label.png')
print('Clicked label')
