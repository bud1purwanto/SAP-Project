import subprocess, time

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

# Press F8
run('export DISPLAY=:99; xdotool key F8')
time.sleep(2.5)

run('export DISPLAY=:99; ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/ckmstart_test_result.png')
print('F8 executed')
