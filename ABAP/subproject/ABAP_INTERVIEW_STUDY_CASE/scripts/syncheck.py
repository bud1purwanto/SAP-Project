"""Syntax check source ABAP di server tanpa menyimpan program (program sementara via
RFC_ABAP_INSTALL_AND_RUN + SYNTAX-CHECK). Usage: python3 syncheck.py <server: sandbox|s4> file.abap ..."""
import json, subprocess, sys, os
HERE = os.path.dirname(os.path.abspath(__file__))

def build(src_lines):
    p = ['REPORT ztmp_sc.', 'DATA: s TYPE STANDARD TABLE OF string,',
         '      l TYPE string, m TYPE string, n TYPE i, w TYPE string,',
         '      c(60) TYPE c.']
    for line in src_lines:
        p.append('CLEAR l.')
        pos = 0
        while pos < len(line):
            chunk = line[pos:pos + 25]
            esc = chunk.replace("'", "''")
            p.append("c = '" + esc + "'.")
            p.append('CONCATENATE l c(%d) INTO l RESPECTING BLANKS.' % len(chunk))
            pos += 25
        p.append('APPEND l TO s.')
    p += ['SYNTAX-CHECK FOR s MESSAGE m LINE n WORD w',
          '  PROGRAM sy-repid.',
          "IF sy-subrc = 0. WRITE / 'SYNTAX OK'.",
          "ELSE. WRITE: / 'SYNTAX ERROR line', n. WRITE: / w.",
          '  WRITE: / m. ENDIF.']
    for x in p: assert len(x) <= 72, x
    return p

def run(server, prog):
    rows = [{'LINE': x} for x in prog]
    if server == 's4':
        code = open(os.path.join(HERE, 'gw.py')).read().split('calls = json.loads')[0]
        g = {}; exec(code, g)
        g['rpc']('tools/call', {'name': 'set_active_server', 'arguments': {'server': 'S4-HANA'}}, 2)
        r = g['rpc']('tools/call', {'name': 'install_and_run_abap', 'arguments': {'parameters': {'PROGRAM': rows, 'WRITES': []}}}, 3)
        res = r.get('result', r)
        txt = '\n'.join(c.get('text', '') for c in res.get('content', [])) if isinstance(res, dict) else str(res)
        try:
            d = json.loads(txt); d = d.get('result', d)
            return d.get('ERRORMESSAGE', ''), [w['ZEILE'] for w in d.get('WRITES', [])]
        except Exception: return txt[:1500], []
    js = """import { serverManager } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tools/query-tools.js';
let inp=''; process.stdin.on('data',d=>inp+=d); process.stdin.on('end',async()=>{
await serverManager.loadConfig(); await serverManager.setActiveServer('sandbox-new');
let r; try { r = await call_function({function_name:'RFC_ABAP_INSTALL_AND_RUN',parameters:{PROGRAM:JSON.parse(inp),WRITES:[]}}); } catch(e) { r = {ERRORMESSAGE: 'EXC '+(e.message||JSON.stringify(e))}; }
console.log(JSON.stringify(r.result||r)); process.exit(0);});"""
    out = subprocess.run(['node', '--input-type=module', '-e', js], input=json.dumps(rows), capture_output=True, text=True)
    try:
        d = json.loads(out.stdout.strip().splitlines()[-1])
        return d.get('ERRORMESSAGE', ''), [w['ZEILE'] for w in d.get('WRITES', [])]
    except Exception: return (out.stdout + out.stderr)[:1500], []

server = sys.argv[1]
for f in sys.argv[2:]:
    src = [l.rstrip('\n') for l in open(f)]
    err, w = run(server, build(src))
    print('==', server, os.path.basename(f), '|', err.strip(), '|', ' / '.join(x.strip() for x in w if x.strip()))
