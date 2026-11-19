import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

print('Saving Plant 1000 with Ctrl+S...')
run('xdotool key ctrl+s')
time.sleep(1.5)

print('Confirming TR...')
run('xdotool key Return')
time.sleep(1.5)

# Click Next Entry (Button 7 on toolbar, around x=198, y=142)
print('Clicking Next Entry...')
run('xdotool mousemove 198 99 click 1') # 142 - 43 offset = 99
time.sleep(1.5)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox10_after_save1000.png'
run(f'ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}')
print('Done!')
