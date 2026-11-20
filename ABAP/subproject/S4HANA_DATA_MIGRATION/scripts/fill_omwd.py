import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# We are on Row 4 Val.Grpg Code:
run('export DISPLAY=:99; xdotool type 0001')
time.sleep(0.3)

# Press Up arrow to go to Row 3 Val.Grpg Code
run('export DISPLAY=:99; xdotool key Up')
time.sleep(0.3)

# Type 0001 for Row 3
run('export DISPLAY=:99; xdotool type 0001')
time.sleep(0.3)

# Press Return to validate
run('export DISPLAY=:99; xdotool key Return')
time.sleep(0.5)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/omwd_filled.png')
print('OMWD filled')
