import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Type box is focused. Press Down arrow to select Executable program
run('export DISPLAY=:99; xdotool key Down; sleep 0.2; xdotool key Return')
time.sleep(0.5)

# Click Save button at (895, 980)
run('export DISPLAY=:99; xdotool mousemove 895 980 click 1')
time.sleep(1.5)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/se38_saved_exec.png')
print('Save clicked')
