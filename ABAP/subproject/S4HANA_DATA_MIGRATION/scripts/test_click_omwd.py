import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Click Row 3 Val.Grpg Code at (355, 278)
run('export DISPLAY=:99; xdotool mousemove 355 278 click 1')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool type 0001')
time.sleep(0.3)

# Click Row 4 Val.Grpg Code at (355, 308)
run('export DISPLAY=:99; xdotool mousemove 355 308 click 1')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool type 0001')
time.sleep(0.3)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/omwd_clicked.png')
print('Clicked OMWD')
