import json,sys
S=sys.argv[1]; sys.path.insert(0,S); from sapc import C
c=C(); rt=lambda *a: (c.rt(*a).get('rows') or [])
d=json.load(open(S+'/r2.json'))
def q(lot): return {r['VERWMERKM'].strip():(r['KURZTEXT'].strip(),float(r['TOLERANZUN']),float(r['TOLERANZOB'])) for r in rt('QAMV',['VERWMERKM','KURZTEXT','TOLERANZUN','TOLERANZOB'],f"PRUEFLOS = '{lot}'",200)}
res={}
for k,o in d.items():
    if not (o['alias_lot'] and o['batch_lot']): continue
    A=q(o['alias_lot']); B=q(o['batch_lot']); diffs=[]
    for m,n,how,inlot,hv in o['rows']:
        if n and m in A and n in B and (A[m][1:]!=B[n][1:]):
            diffs.append((m,n,A[m][0],A[m][1:],B[n][1:]))
    res[k]=diffs; print(k,'limit beda:',len(diffs),'/',len(o['rows']))
    for x in diffs: print('    ',x)
json.dump(res,open(S+'/r3.json','w'),indent=1)
