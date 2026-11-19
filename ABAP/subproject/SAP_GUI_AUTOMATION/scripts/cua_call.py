import json
import os
import sys
import subprocess

def main():
    if len(sys.argv) < 2:
        print("Usage: cua_call.py <tool_name> [json_args_or_key_val]")
        sys.exit(1)
    
    tool = sys.argv[1]
    args = {}
    if len(sys.argv) > 2:
        raw = sys.argv[2]
        try:
            args = json.loads(raw)
        except Exception:
            for item in sys.argv[2:]:
                if '=' in item:
                    k, v = item.split('=', 1)
                    if v.isdigit():
                        args[k] = int(v)
                    elif v.lower() == 'true':
                        args[k] = True
                    elif v.lower() == 'false':
                        args[k] = False
                    else:
                        args[k] = v

    sock = "/home/abap/.cache/cua-driver/cua-driver-sap.sock"
    cmd = ["/home/abap/.local/bin/cua-driver", "--socket", sock, "call", tool, json.dumps(args)]
    env = dict(os.environ)
    env["DISPLAY"] = ":99"
    res = subprocess.run(cmd, capture_output=True, text=True, env=env)
    print(res.stdout)
    if res.stderr:
        print(res.stderr, file=sys.stderr)
    sys.exit(res.returncode)

if __name__ == '__main__':
    main()
