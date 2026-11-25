"""Push program latihan ke S/4 ADB ($TMP) lewat gateway (write_program = Z_RFC_PROGRAM_UPDATE),
lalu syntax check dengan SIW_RFC_SYNTAX_CHECK. Usage: python3 s4_push_check.py file.abap ..."""
import json, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
g = {}; exec(open(os.path.join(HERE, 'gw.py')).read().split('calls = json.loads')[0], g)
rpc = g['rpc']; n = [100]
def call(tool, args):
    n[0] += 1
    r = rpc('tools/call', {'name': tool, 'arguments': args}, n[0])
    res = r.get('result', r)
    txt = '\n'.join(c.get('text', '') for c in res.get('content', [])) if isinstance(res, dict) else str(res)
    try: return json.loads(txt)
    except Exception: return {'raw': txt}
print(call('set_active_server', {'server': 'S4-HANA'}).get('sid'))
for f in sys.argv[1:]:
    name = os.path.basename(f)[:-5]
    lines = [l.rstrip() for l in open(f).read().rstrip('\n').split('\n')]
    r = call('write_program', {'parameters': {'IV_PROGRAM_NAME': name, 'IV_PACKAGE': '$TMP', 'IV_CORRNUMBER': ' ',
                                              'IT_SOURCE': [{'LINE': l} for l in lines]}})
    rr = r.get('result', r)
    c = {} if 1 else call('call_function', {'function_name': 'SIW_RFC_SYNTAX_CHECK',
                               'parameters': {'I_OBJECT': 'PROG', 'I_OBJNAME': name}})
    cr = c.get('result', c)
    print('==', name, '| push:', rr.get('EV_SUCCESS'), str(rr.get('EV_MESSAGE', rr.get('error', '')))[:120].strip(),
          '| syntax:', (str(cr.get('E_SYNTAXERROR', '')).strip() or 'OK') if isinstance(cr, dict) else cr,
          '|', json.dumps(cr.get('E_STR_EXCEPTION', ''))[:150] if isinstance(cr, dict) and cr.get('E_STR_EXCEPTION', {}) and any(cr['E_STR_EXCEPTION'].values()) else '')
