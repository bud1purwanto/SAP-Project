import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

print('Typing Name 1 for Plant 1000...')
run('xdotool key --delay 50 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 50 "Pabrik Waru (Trias Sentosa)"')
time.sleep(0.2)

print('Tab to Name 2...')
run('xdotool key Tab')
time.sleep(0.1)
run('xdotool key --delay 50 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 50 "Sidoarjo"')
time.sleep(0.2)

print('Opening Address screen with Shift+F5...')
run('xdotool key shift+F5')
time.sleep(1.5)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox10_1000_address.png'
run(f'ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}')
print('Done!')
