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
    popup_id = "29377543"
    run(f"xdotool windowactivate --sync {popup_id}")
    time.sleep(0.5)

    # 1. Click Radio 2: "Continue with this logon, without ending any other logons"
    # Click at x=20, y=350 (or text at x=100, y=350)
    run(f"xdotool mousemove --window {popup_id} 100 350 click 1")
    time.sleep(0.5)

    # 2. Click Enter button with green checkmark at x=1365, y=862
    run(f"xdotool mousemove --window {popup_id} 1365 862 click 1")
    time.sleep(6)

    # 3. Check windows
    sock = "/home/abap/.cache/cua-driver/cua-driver-sap.sock"
    cmd_win = f"/home/abap/.local/bin/cua-driver --socket {sock} call list_windows '{{}}'"
    run(cmd_win)

    # 4. Find active SAP GUI window and capture screenshot
    # Check if a new window is open or ADB (1) (130) is now Easy Access
    cmd_shot = f"/home/abap/.local/bin/cua-driver --socket {sock} call get_desktop_state '{{}}'"
    # Or capture via xwd/import or cua-driver
    run(f"/home/abap/.local/bin/cua-driver --socket {sock} call get_window_state '{{\"pid\":11474,\"window_id\":29377504,\"screenshot_out_file\":\"/tmp/sap_easy_access.png\"}}'")
    run("cp /tmp/sap_easy_access.png /data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/12_sap_easy_access.png")

if __name__ == '__main__':
    main()
