import sys, json, subprocess

sock = '/home/abap/.cache/cua-driver/cua-driver-sap.sock'
r = subprocess.run(['/home/abap/.local/bin/cua-driver', '--socket', sock, 'call', 'list_windows', '{}'], capture_output=True, text=True)
data = json.loads(r.stdout)
w = [x for x in data.get('windows', []) if 'ADB' in x.get('title', '') and '(130)' in x.get('title', '')][0]
out = sys.argv[1] if len(sys.argv) > 1 else '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/screen.png'
req = json.dumps({'pid': w['pid'], 'window_id': w['window_id'], 'screenshot_out_file': out})
res = subprocess.run(['/home/abap/.local/bin/cua-driver', '--socket', sock, 'call', 'get_window_state', req], capture_output=True, text=True)
state = json.loads(res.stdout)
print('Saved:', out, 'Title:', state.get('title'))