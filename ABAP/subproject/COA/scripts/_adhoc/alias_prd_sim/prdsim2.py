import json,sys
S=sys.argv[1]; sys.path.insert(0,S); from sapc import C
c=C(); rt=lambda *a: (c.rt(*a).get('rows') or [])
d=json.load(open(S+'/prdsim1.json'))
src=json.load(open('/data/Projects/SAP/ABAP/subproject/COA/outputs/alias_mapping_20261111/prd_alias_to_material_sample.json'))
planc={}
def plan(m):
    if m in planc: return planc[m]
    res={}
    for mm in [m,'JR'+m[2:]]:
        for r in rt('MAPL',['PLNNR'],f"MATNR = '{mm}' AND PLNTY = 'Q' AND LOEKZ = ' '",30):
            for p in rt('PLMK',['VERWMERKM','KURZTEXT','LOEKZ'],f"PLNTY = 'Q' AND PLNNR = '{r['PLNNR']}'",400):
                if not p['LOEKZ'].strip(): res.setdefault(p['VERWMERKM'].strip(),p['KURZTEXT'].strip())
            break
    planc[m]=res; return res
def lastlot(m):
    l=rt('QALS',['PRUEFLOS'],f"MATNR = '{m}' AND ART = 'Z04'",3000)
    return max(x['PRUEFLOS'] for x in l) if l else None
def norm(t): return ''.join(t.upper().split())
def tr(mic,bmat,PB,PA):
    if mic in PB: return mic,'EXACT'
    if len(mic)==8:
        n=mic[0]+bmat[2:5]+mic[4:]
        if n in PB: return n,'RULE'
        h=[x for x in PB if len(x)==8 and x[0]==mic[0] and x[4:]==mic[4:]]
        if len(h)==1: return h[0],'SUFFIX'
    t=norm(PA.get(mic,''))
    h=[x for x,tx in PB.items() if t and norm(tx)==t]
    if len(h)==1: return h[0],'DESC'
    return None,'NONE'
out={}
for alias,o in d.items():
    if o['status']!='DIFF': continue
    am=o['amat']
    zm=rt('ZMAP_COA',['MIC','DELETION'],f"MATNR = '{am}'",200)
    lot=lastlot(am)
    amics=[r['VERWMERKM'].strip() for r in rt('QAMV',['VERWMERKM'],f"PRUEFLOS = '{lot}'",200)] if lot else []
    PA=plan(am)
    mapsrc='ZMAP_COA' if zm else ('LOT' if amics else 'PLAN-S')
    mapping=[r['MIC'].strip() for r in zm if r['DELETION'].strip()!='X'] or amics or [m for m in PA if m.startswith('S')]
    for bm,batches in src[alias].items():
        PB=plan(bm)
        # batch's own Z04 lot from sample batches
        blot=None
        for ch in batches:
            l=rt('QALS',['PRUEFLOS'],f"MATNR = '{bm}' AND CHARG = '{ch}' AND ART = 'Z04'",3)
            if l: blot=max(x['PRUEFLOS'] for x in l); bch=ch; break
        lmics={}
        if blot:
            for r in rt('QAMV',['VERWMERKM','MERKNR'],f"PRUEFLOS = '{blot}'",200): lmics[r['VERWMERKM'].strip()]=r['MERKNR']
            vals={r['MERKNR']:r for r in rt('QAMR',['MERKNR','MITTELWERT','CODE1','ANZWERTG'],f"PRUEFLOS = '{blot}'",200)}
        rows=[]
        for m in mapping:
            n,how=tr(m,bm,PB,PA)
            inlot = n in lmics if (n and blot) else None
            hasval=None
            if inlot:
                v=vals.get(lmics[n]); hasval=bool(v and (v['CODE1'].strip() or int(v['ANZWERTG'] or 0)>0))
            rows.append((m,n,how,inlot,hasval))
        k=f"{alias}|{am}->{bm}"
        out[k]={'mapsrc':mapsrc,'alias_lot':lot,'batch_lot':blot,'plan_alias':len(PA),'plan_batch':len(PB),'rows':rows,'desc':{m:PA.get(m,'') for m in mapping}}
        nok=sum(1 for r in rows if r[1]); ninlot=sum(1 for r in rows if r[3]); nval=sum(1 for r in rows if r[4])
        print(f"{k:28} map={mapsrc:8}({len(mapping)}) plan A/B={len(PA)}/{len(PB)} lotB={blot} terjemah={nok} adaDiLot={ninlot} adaNilai={nval}",flush=True)
        for r in rows:
            if not r[1] or r[3] is False: print('     ',r, PA.get(r[0],''))
json.dump(out,open(S+'/prdsim2.json','w'),indent=1)
