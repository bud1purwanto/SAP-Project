import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Click Background Processing checkbox at (24, 484)
run('export DISPLAY=:99; xdotool mousemove 24 484 click 1')
time.sleep(0.5)

# Take screenshot
run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/ckmstart_uncheck.png')
print('Uncheck clicked')
