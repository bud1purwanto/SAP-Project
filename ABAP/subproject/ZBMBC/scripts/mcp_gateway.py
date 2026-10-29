"""Panggil MCP gateway (konfigurasi Hermes) via JSON-RPC streamable HTTP.
Usage: python3 mcp_gateway.py "<server>" list
       python3 mcp_gateway.py "<server>" <tool> '<json args>'
"""
import yaml, json, sys, urllib.request, os
cfg = yaml.safe_load(open(os.path.expanduser('~/.hermes/config.yaml')))['mcp_servers'][sys.argv[1]]
URL = cfg['url']
H = {'Content-Type': 'application/json', 'Accept': 'application/json, text/event-stream'}
H.update(cfg.get('headers') or {})
sid = None
n = 0

def rpc(method, params=None, notify=False):
    global sid, n
    body = {'jsonrpc': '2.0', 'method': method}
    if params is not None:
        body['params'] = params
    if not notify:
        n += 1
        body['id'] = n
    h = dict(H)
    if sid:
        h['Mcp-Session-Id'] = sid
    r = urllib.request.urlopen(urllib.request.Request(URL, json.dumps(body).encode(), h), timeout=300)
    sid = r.headers.get('Mcp-Session-Id') or sid
    t = r.read().decode()
    if notify:
        return None
    for line in t.splitlines():
        if line.startswith('data:'):
            t = line[5:]
    return json.loads(t)

rpc('initialize', {'protocolVersion': '2025-03-26', 'capabilities': {}, 'clientInfo': {'name': 'claude', 'version': '1'}})
rpc('notifications/initialized', notify=True)
if sys.argv[2] == 'list':
    for t in rpc('tools/list')['result']['tools']:
        print(t['name'], '|', json.dumps(t.get('inputSchema', {}).get('properties', {}))[:400])
else:
    calls = [(sys.argv[i], json.loads(sys.argv[i + 1])) for i in range(2, len(sys.argv), 2)]
    for name, args in calls:
        res = rpc('tools/call', {'name': name, 'arguments': args})
        for c in res.get('result', {}).get('content', []):
            print(c.get('text', c))
        if 'error' in res:
            print(res['error'])
