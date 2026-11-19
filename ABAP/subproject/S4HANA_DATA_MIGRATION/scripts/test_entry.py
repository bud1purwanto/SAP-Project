import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

print('Shift+Tab back to CoCd...')
run('xdotool key --delay 50 shift+Tab')
time.sleep(0.2)
print('Typing 9999 in Row 1 CoCd...')
run('xdotool type --delay 60 "9999"')
time.sleep(0.2)
print('Tab to Plnt...')
run('xdotool key Tab')
time.sleep(0.2)
print('Typing 1000 in Row 1 Plnt...')
run('xdotool type --delay 60 "1000"')
time.sleep(0.2)
print('Pressing Tab...')
run('xdotool key Tab')
time.sleep(0.5)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox18_test_entry1.png'
run(f'ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}')
print('Done!')
