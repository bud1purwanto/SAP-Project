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

    # 1. Clear & set Client to 130
    run(f"xdotool mousemove --window {win_id} 175 150 click 1")
    time.sleep(0.2)
    run("xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete")
    time.sleep(0.2)
    run("xdotool type --delay 60 '130'")
    time.sleep(0.3)

    # 2. Clear & set User to TRSTABAP
    run(f"xdotool mousemove --window {win_id} 175 207 click 1")
    time.sleep(0.2)
    run("xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete")
    time.sleep(0.2)
    run("xdotool type --delay 60 'TRSTABAP'")
    time.sleep(0.3)

    # 3. Clear & set Password to supporter
    run(f"xdotool mousemove --window {win_id} 175 265 click 1")
    time.sleep(0.2)
    run("xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete")
    time.sleep(0.2)
    run("xdotool type --delay 60 'supporter'")
    time.sleep(0.3)

    # 4. Clear & set Language to EN
    run(f"xdotool mousemove --window {win_id} 175 335 click 1")
    time.sleep(0.2)
    run("xdotool key End BackSpace BackSpace BackSpace BackSpace Delete Delete Delete")
    time.sleep(0.2)
    run("xdotool type --delay 60 'EN'")
    time.sleep(0.3)

    # 5. Capture pre-submit screenshot
    sock = "/home/abap/.cache/cua-driver/cua-driver-sap.sock"
    cmd_shot = f"/home/abap/.local/bin/cua-driver --socket {sock} call get_window_state '{{\"pid\":11474,\"window_id\":{win_id},\"screenshot_out_file\":\"/tmp/pre_enter.png\"}}'"
    run(cmd_shot)
    run("cp /tmp/pre_enter.png /data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/05_pre_enter.png")

    # 6. Press Enter
    run("xdotool key Return")
    time.sleep(4)

    # 7. Capture post-submit screenshot
    cmd_shot2 = f"/home/abap/.local/bin/cua-driver --socket {sock} call get_window_state '{{\"pid\":11474,\"window_id\":{win_id},\"screenshot_out_file\":\"/tmp/post_enter.png\"}}'"
    run(cmd_shot2)
    run("cp /tmp/post_enter.png /data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/06_post_enter.png")

if __name__ == '__main__':
    main()
