import os
import sys, json, yaml, urllib.request
c=yaml.safe_load(open('/home/abap/.hermes/config.yaml'))['mcp_servers'][__import__('os').environ.get('SRV','MCP Email')]
url=c['url']; H=dict(c.get('headers') or {}); H.update({'Content-Type':'application/json','Accept':'application/json, text/event-stream'})
sid=None
def post(msg):
    global sid
    h=dict(H)
    if sid: h['Mcp-Session-Id']=sid
    r=urllib.request.urlopen(urllib.request.Request(url,json.dumps(msg).encode(),h),timeout=120)
    sid=r.headers.get('Mcp-Session-Id') or sid
    body=r.read().decode()
    if not body.strip(): return None
    if body.lstrip().startswith('{'): return json.loads(body)
    out=None
    for line in body.splitlines():
        if line.startswith('data:'):
            d=json.loads(line[5:]); 
            if 'id' in d: out=d
    return out
post({'jsonrpc':'2.0','id':1,'method':'initialize','params':{'protocolVersion':'2025-03-26','capabilities':{},'clientInfo':{'name':'client','version':'1'}}})
post({'jsonrpc':'2.0','method':'notifications/initialized'})
if sys.argv[1]=='list':
    r=post({'jsonrpc':'2.0','id':2,'method':'tools/list'})
    for t in r['result']['tools']: print(t['name'], json.dumps(t.get("inputSchema",{}).get("properties",{}))[:int(os.environ.get("W","300"))])
else:
    r=post({'jsonrpc':'2.0','id':2,'method':'tools/call','params':{'name':sys.argv[1],'arguments':json.loads(sys.argv[2])}})
    res=r.get('result',r)
    for x in res.get('content',[]) if isinstance(res,dict) else []:
        print(x.get('text',x))
    if not isinstance(res,dict) or 'content' not in res: print(json.dumps(res)[:5000])
