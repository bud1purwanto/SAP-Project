import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Title is focused
run('export DISPLAY=:99; xdotool type "Fix SKB1 Currency"')
time.sleep(0.3)

# Click Type dropdown at (200, 270)
run('export DISPLAY=:99; xdotool mousemove 200 270 click 1')
time.sleep(0.3)
run('export DISPLAY=:99; xdotool type 1')
time.sleep(0.3)

# Click Save button at (895, 980)
run('export DISPLAY=:99; xdotool mousemove 895 980 click 1')
time.sleep(1.5)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/se38_saved_attrs.png')
print('Attrs saved')
