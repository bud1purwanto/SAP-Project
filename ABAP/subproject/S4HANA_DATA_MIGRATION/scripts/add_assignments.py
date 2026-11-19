import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

print('Pressing F5 for New Entries...')
run('xdotool key F5')
time.sleep(1.0)

# In New Entries, cursor starts at Row 1 CoCd
print('Entering Row 1: 9999 1000...')
run('xdotool type --delay 60 "9999"')
time.sleep(0.2)
run('xdotool key Tab')
time.sleep(0.2)
run('xdotool type --delay 60 "1000"')
time.sleep(0.2)
run('xdotool key Tab')
time.sleep(0.2)

print('Entering Row 2: 9999 2000...')
run('xdotool type --delay 60 "9999"')
time.sleep(0.2)
run('xdotool key Tab')
time.sleep(0.2)
run('xdotool type --delay 60 "2000"')
time.sleep(0.2)
run('xdotool key Tab')
time.sleep(0.2)

print('Entering Row 3: 0003 0003...')
run('xdotool type --delay 60 "0003"')
time.sleep(0.2)
run('xdotool key Tab')
time.sleep(0.2)
run('xdotool type --delay 60 "0003"')
time.sleep(0.2)
run('xdotool key Return')
time.sleep(1.5)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox18_new_entries_filled.png'
run(f'ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}')
print('Done!')
