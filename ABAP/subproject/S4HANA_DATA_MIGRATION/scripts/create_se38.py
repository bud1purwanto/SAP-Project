import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Program box is focused
run('export DISPLAY=:99; xdotool type ZFIX_SKB1_CURR')
time.sleep(0.3)

# Click Create button at (318, 255)
run('export DISPLAY=:99; xdotool mousemove 318 255 click 1')
time.sleep(1.5)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/se38_attributes.png')
print('Create clicked')
