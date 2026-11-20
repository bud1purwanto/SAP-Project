import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Click Row 3 (Plant 1000) at X=410, Y=251
run('export DISPLAY=:99; xdotool mousemove 410 251 click 1')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool type 0001')
time.sleep(0.3)

# Click Row 4 (Plant 2000) at X=410, Y=279
run('export DISPLAY=:99; xdotool mousemove 410 279 click 1')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool type 0001')
time.sleep(0.3)

# Take screenshot before pressing Return to verify text entered
run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/omwd_typed_perfect.png')
print('Typed perfect')
