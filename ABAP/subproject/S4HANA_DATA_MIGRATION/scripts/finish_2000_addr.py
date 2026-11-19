import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

print('Shift+Tab to Postal Code...')
run('xdotool key shift+Tab')
time.sleep(0.2)
run('xdotool type --delay 50 "61262"')
time.sleep(0.3)

print('Pressing Return to validate postal code...')
run('xdotool key Return')
time.sleep(1.0)

print('Clicking Enter button at 1240 878 to close Address dialog...')
run('xdotool mousemove 1240 878 click 1')
time.sleep(1.5)

# Back in Plant 2000 detail view
# Focus Name 1 (click at 150, 175)
print('Setting Name 1 and Name 2...')
run('xdotool mousemove 150 175 click 1')
time.sleep(0.2)
run('xdotool key --delay 40 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 40 "Pabrik Krian (Trias Sentosa)"')
time.sleep(0.2)
run('xdotool key Tab')
time.sleep(0.1)
run('xdotool key --delay 40 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 40 "Sidoarjo"')
time.sleep(0.3)

# Save
print('Saving with Ctrl+S...')
run('xdotool key ctrl+s')
time.sleep(1.5)

print('Confirming TR dialog...')
run('xdotool key Return')
time.sleep(2.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox10_2000_final.png'
run(f'ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}')
print('Done!')
