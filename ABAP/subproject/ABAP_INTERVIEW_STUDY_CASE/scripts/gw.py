"""Client JSON-RPC ke gateway Hermes MCP SAP. Usage: python3 gw.py '<json list of [tool,args]>'
Semua call dijalankan dalam satu sesi MCP (set_active_server berlaku untuk call berikutnya)."""
import json, os, sys, urllib.request, yaml
cfg = yaml.safe_load(open(os.path.expanduser('~/.hermes/config.yaml')))['mcp_servers']['MCP SAP']
URL, H = cfg['url'], dict(cfg.get('headers') or {})
H.update({'Content-Type': 'application/json', 'Accept': 'application/json, text/event-stream'})
sid = None
def rpc(method, params, id_=1):
    global sid
    h = dict(H)
    if sid: h['Mcp-Session-Id'] = sid
    body = {'jsonrpc': '2.0', 'method': method, 'params': params}
    if id_ is not None: body['id'] = id_
    req = urllib.request.Request(URL, json.dumps(body).encode(), h)
    with urllib.request.urlopen(req, timeout=600) as r:
        sid = r.headers.get('Mcp-Session-Id') or sid
        txt = r.read().decode()
    if not txt.strip(): return None
    if txt.lstrip().startswith('{'): return json.loads(txt)
    out = None
    for line in txt.splitlines():
        if line.startswith('data:'):
            d = json.loads(line[5:])
            if 'result' in d or 'error' in d: out = d
    return out
rpc('initialize', {'protocolVersion': '2025-03-26', 'capabilities': {}, 'clientInfo': {'name': 'cli', 'version': '1'}})
rpc('notifications/initialized', {}, None)
calls = json.loads(sys.argv[1]) if len(sys.argv) > 1 else [['tools/list', None]]
for i, (tool, args) in enumerate(calls):
    if tool == 'tools/list':
        r = rpc('tools/list', {}, 10 + i)
        print([t['name'] for t in r['result']['tools']]); continue
    r = rpc('tools/call', {'name': tool, 'arguments': args or {}}, 10 + i)
    res = r.get('result', r.get('error'))
    if isinstance(res, dict) and 'content' in res:
        print('##', tool); print('\n'.join(c.get('text', '') for c in res['content']))
    else: print('##', tool, json.dumps(res)[:4000])
