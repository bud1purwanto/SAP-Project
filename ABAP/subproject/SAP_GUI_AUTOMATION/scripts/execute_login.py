import os
import time
import subprocess

def run(cmd):
    print("RUN:", cmd)
    env = dict(os.environ)
    env["DISPLAY"] = ":99"
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    if res.stdout: print("OUT:", res.stdout.strip())
    if res.stderr: print("ERR:", res.stderr.strip())
    return res

def main():
    win_id = "29377504"
    run(f"xdotool windowactivate --sync {win_id}")
    time.sleep(0.5)

    # 1. Click Client field at (180, 187)
    run("xdotool mousemove 180 187 click 1")
    time.sleep(0.3)
    run("xdotool key ctrl+a BackSpace")
    time.sleep(0.2)
    run("xdotool type --delay 60 '130'")
    time.sleep(0.3)

    # 2. Click User field at (180, 245)
    run("xdotool mousemove 180 245 click 1")
    time.sleep(0.3)
    run("xdotool key ctrl+a BackSpace")
    time.sleep(0.2)
    run("xdotool type --delay 60 'TRSTABAP'")
    time.sleep(0.3)

    # 3. Click Password field at (180, 303)
    run("xdotool mousemove 180 303 click 1")
    time.sleep(0.3)
    run("xdotool key ctrl+a BackSpace")
    time.sleep(0.2)
    run("xdotool type --delay 60 'supporter'")
    time.sleep(0.3)

    # 4. Press Enter
    run("xdotool key Return")
    time.sleep(4)

    # 5. Capture new screenshot
    sock = "/home/abap/.cache/cua-driver/cua-driver-sap.sock"
    cmd_shot = f"/home/abap/.local/bin/cua-driver --socket {sock} call get_window_state '{{\"pid\":11474,\"window_id\":{win_id},\"screenshot_out_file\":\"/tmp/after_login2.png\"}}'"
    run(cmd_shot)
    run("cp /tmp/after_login2.png /data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/04_after_login2.png")

if __name__ == '__main__':
    main()
