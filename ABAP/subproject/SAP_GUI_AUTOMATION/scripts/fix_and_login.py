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

    # 1. Clear Logon Language (currently focused with blue border)
    run("xdotool key End BackSpace BackSpace BackSpace Delete Delete")
    time.sleep(0.3)

    # 2. Shift+Tab twice to reach User box
    run("xdotool key shift+Tab")
    time.sleep(0.3)
    run("xdotool key shift+Tab")
    time.sleep(0.3)

    # 3. Clear User field completely and type TRSTABAP
    run("xdotool key Home")
    run("xdotool key Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete")
    run("xdotool key End")
    run("xdotool key BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace")
    time.sleep(0.2)
    run("xdotool type --delay 60 'TRSTABAP'")
    time.sleep(0.3)

    # 4. Tab to Password field
    run("xdotool key Tab")
    time.sleep(0.3)
    run("xdotool key Home")
    run("xdotool key Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete Delete")
    run("xdotool key End")
    run("xdotool key BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace")
    time.sleep(0.2)
    run("xdotool type --delay 60 'supporter'")
    time.sleep(0.3)

    # Capture pre-enter
    sock = "/home/abap/.cache/cua-driver/cua-driver-sap.sock"
    cmd_shot = f"/home/abap/.local/bin/cua-driver --socket {sock} call get_window_state '{{\"pid\":11474,\"window_id\":{win_id},\"screenshot_out_file\":\"/tmp/pre_enter3.png\"}}'"
    run(cmd_shot)
    run("cp /tmp/pre_enter3.png /data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/07_pre_enter3.png")

    # 5. Press Enter to login!
    run("xdotool key Return")
    time.sleep(5)

    # 6. Capture post-login
    cmd_shot2 = f"/home/abap/.local/bin/cua-driver --socket {sock} call get_window_state '{{\"pid\":11474,\"window_id\":{win_id},\"screenshot_out_file\":\"/tmp/post_enter3.png\"}}'"
    run(cmd_shot2)
    run("cp /tmp/post_enter3.png /data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/08_post_enter3.png")

if __name__ == '__main__':
    main()
