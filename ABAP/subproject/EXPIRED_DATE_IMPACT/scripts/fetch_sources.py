import sys,json,re,subprocess,os
os.makedirs('abap',exist_ok=True)
seen=set()
def get(name):
    if name in seen: return
    seen.add(name)
    out=subprocess.run(['python3','mcpcall.py','read_program',json.dumps({'server':sys.argv[1],'program_name':name})],capture_output=True,text=True,env=dict(os.environ,SRV='MCP SAP')).stdout
    try: d=json.loads(out[:out.rindex('}')+1]); src=d.get('source','')
    except Exception: print('ERR',name,out[:200]); return
    if not src: print('EMPTY',name,out[:200]); return
    open(f'abap/{name}.abap','w').write(src)
    print(name,src.count('\n'))
    for m in re.finditer(r'^\s*INCLUDE\s+([YZ][A-Z0-9_/]+)\.?',src,re.M|re.I):
        get(m.group(1).upper())
for n in sys.argv[2:]: get(n)
