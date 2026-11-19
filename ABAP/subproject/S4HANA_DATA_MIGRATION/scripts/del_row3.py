import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

print('Clicking Row 3 selector at 12, 305...')
run('xdotool mousemove --sync 12 305 click 1')
time.sleep(0.5)

print('Pressing Shift+F2 to delete...')
run('xdotool key shift+F2')
time.sleep(1.0)

print('Pressing Return on Delete anyway dialog...')
run('xdotool key Return')
time.sleep(1.0)

print('Pressing Return on Information dialog...')
run('xdotool key Return')
time.sleep(1.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox18_del_row3_done.png'
run(f'ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}')
print('Done!')
