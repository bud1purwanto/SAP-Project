import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Click inside Program box
run('export DISPLAY=:99; xdotool mousemove 180 255 click 1')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool key ctrl+a BackSpace; xdotool type ZFIX_SKB1_CURR')
time.sleep(0.3)

# Click Create button at (318, 255)
run('export DISPLAY=:99; xdotool mousemove 318 255 click 1')
time.sleep(1.5)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/se38_attrs.png')
print('Create clicked')
