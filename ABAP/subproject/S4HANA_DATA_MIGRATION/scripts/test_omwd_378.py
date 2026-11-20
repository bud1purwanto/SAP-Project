import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Click Row 3 Val.Grpg Code at (378, 251)
run('export DISPLAY=:99; xdotool mousemove 378 251 click 1')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool type 0001')
time.sleep(0.3)

# Click Row 4 Val.Grpg Code at (378, 279)
run('export DISPLAY=:99; xdotool mousemove 378 279 click 1')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool type 0001')
time.sleep(0.3)

# Take screenshot
run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/omwd_378.png')
print('Clicked 378')
