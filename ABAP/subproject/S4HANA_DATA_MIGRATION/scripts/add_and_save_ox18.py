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

print('Pressing F5 for New Entries...')
run('xdotool key F5')
time.sleep(1.2)

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

print('Pressing Return to validate...')
run('xdotool key Return')
time.sleep(2.0)

# Capture validation screen
run('ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y /data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox18_validated.png')

print('Saving with Ctrl+S...')
run('xdotool key ctrl+s')
time.sleep(1.5)

print('Confirming TR dialog with Return...')
run('xdotool key Return')
time.sleep(2.0)

# Capture final saved screen
run('ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y /data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox18_final_saved.png')
print('Finished!')
