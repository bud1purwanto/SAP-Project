import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

print('Activating ADB window...')
run('xdotool search --name "ADB (1) (130)" windowactivate --sync')
time.sleep(0.5)

# Click Row 3 (Plant 1000 CoCd)
print('Editing Row 3 (Plant 1000)...')
run('xdotool mousemove 35 312 click 1')
time.sleep(0.2)
run('xdotool key --delay 50 ctrl+a BackSpace')
time.sleep(0.1)
run("xdotool type --delay 50 '9999'")
time.sleep(0.3)

# Click Row 4 (Plant 2000 CoCd)
print('Editing Row 4 (Plant 2000)...')
run('xdotool mousemove 35 347 click 1')
time.sleep(0.2)
run('xdotool key --delay 50 ctrl+a BackSpace')
time.sleep(0.1)
run("xdotool type --delay 50 '9999'")
time.sleep(0.3)

# Press Enter to validate
print('Pressing Enter...')
run('xdotool key Return')
time.sleep(1.5)

# Take screenshot
out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox18_modified.png'
run(f'ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}')
print('Done!')
