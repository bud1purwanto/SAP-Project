import yaml,os,json,time,urllib.request,urllib.error
class C:
    def __init__(s,name='MCP SAP'):
        c=yaml.safe_load(open(os.path.expanduser('~/.hermes/config.yaml')))['mcp_servers'][name]
        s.url=c['url'];s.H={'Content-Type':'application/json','Accept':'application/json, text/event-stream',**c.get('headers',{})};s.sid=None;s.i=0
        s._rpc('initialize',{'protocolVersion':'2025-03-26','capabilities':{},'clientInfo':{'name':'client','version':'1'}})
        s._rpc('notifications/initialized',notify=True)
    def _rpc(s,m,p=None,notify=False):
        b={'jsonrpc':'2.0','method':m}
        if p is not None:b['params']=p
        if not notify:s.i+=1;b['id']=s.i
        h=dict(s.H)
        if s.sid:h['Mcp-Session-Id']=s.sid
        for k in range(8):
            try:
                r=urllib.request.urlopen(urllib.request.Request(s.url,json.dumps(b).encode(),h),timeout=180);break
            except urllib.error.HTTPError as e:
                if e.code==429: time.sleep(5*(k+1));continue
                raise
        else: raise RuntimeError('429 persist')
        s.sid=r.headers.get('Mcp-Session-Id') or s.sid
        t=r.read().decode()
        if notify:return
        for l in t.splitlines():
            if l.startswith('data:'):t=l[5:]
        return json.loads(t)
    def call(s,name,args):
        r=s._rpc('tools/call',{'name':name,'arguments':args})
        txt=''.join(c.get('text','') for c in r.get('result',{}).get('content',[]))
        try:return json.loads(txt)
        except Exception:return {'raw':txt,'err':r.get('error')}
    def rt(s,table,fields,where,rc=100,server='Production AIX'):
        time.sleep(0.4)
        for k in range(6):
            try: return s.call('read_table',{'server':server,'table':table,'fields':fields,'where':[where] if where else [],'rowcount':rc})
            except Exception as e:
                print('retry',k,str(e)[:50],flush=True); time.sleep(5*(k+1))
        return {}
