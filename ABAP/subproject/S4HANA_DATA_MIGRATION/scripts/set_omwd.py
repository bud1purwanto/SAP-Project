import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Click Row 3 (1000) Val.Grpg Code at X=335, Y=278
run('export DISPLAY=:99; xdotool mousemove 335 278 click 1')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool key ctrl+a BackSpace; xdotool type 0001')
time.sleep(0.3)

# Click Row 4 (2000) Val.Grpg Code at X=335, Y=308
run('export DISPLAY=:99; xdotool mousemove 335 308 click 1')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool key ctrl+a BackSpace; xdotool type 0001')
time.sleep(0.3)

# Press Enter to validate
run('export DISPLAY=:99; xdotool key Return')
time.sleep(0.5)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/omwd_entered.png')
print('OMWD entered')
