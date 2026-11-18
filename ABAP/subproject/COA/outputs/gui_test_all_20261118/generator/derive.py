import json, re, subprocess, collections, sys
S='/tmp/claude-1000/-data-Projects-SAP-ABAP/f652a661-609b-4c79-b0c2-40d8b6bf2445/scratchpad'
C='/data/Projects/SAP/ABAP/subproject/COA'
def rfc(table, fields, lots, extra=None):
    out=[]
    lots=sorted(lots)
    for i in range(0,len(lots),12):
        ch=lots[i:i+12]
        wh=["PRUEFLOS IN ("+",".join("'%s'"%x for x in ch[j:j+3])+")"+(" OR" if j+3<len(ch) else "") for j in range(0,len(ch),3)]
        r=subprocess.run(['node',C+'/scripts/mt_rt.mjs',table,fields]+wh+['--rows','8000'],capture_output=True,text=True,cwd=C)
        out+=[[x.strip() for x in l.split('|')] for l in r.stdout.splitlines() if '|' in l]
    return out
txt=open(S+'/dbg/all_dbg.txt').read().split('\n### ')
DO={}
for blk in txt:
    blk=blk.lstrip('# ').strip()
    do=blk.split('\n')[0].strip()
    rows=[];B=[];D=[];X=[]
    for l in blk.split('\n')[1:]:
        if l.startswith('#B|'): B.append(l.split('|')[1:])
        elif l.startswith('#D|'): D.append(l.split('|')[1:])
        elif l.startswith('#X|'): X.append(l.split('|')[1:])
        elif l.startswith('|'): rows.append(l.split('|')[1:])
    DO[do]=dict(rows=rows,B=B,D=D,X=X)
dk=collections.defaultdict(list)   # (K,I,M)->lots
for do,d in DO.items():
    for k,i,m,l in d['D']:
        k=k.strip();i=i.strip();m=m.strip();l=l.strip()
        if l not in dk[(k,i,m)]: dk[(k,i,m)].append(l)
res={}
for do,d in DO.items():
    mic_rows=collections.OrderedDict()
    for r in d['rows']:
        mic_rows[r[1]]=dict(do=do,mic=r[1],val=r[2].strip(),rep=r[3].strip(),src=collections.OrderedDict())
    xm={}
    for x in d['X']:
        v,ch,bm,mic,ins=[t.strip() for t in x]
        xm[bm]=mic
    for b in d['B']:
        _,batch,lmic,ins,merk,cm=[x.strip() for x in b]
        mic=xm.get(lmic,lmic)
        if mic not in mic_rows:
            c=[k for k in mic_rows if k[-4:]==lmic[-4:] and k[:1]==lmic[:1]]
            if len(c)==1: mic=c[0]
        if mic not in mic_rows: continue
        if ins in mic_rows[mic]['src']: continue
        kind='JR'
        if ('JS',ins,lmic) in dk: grp=(dk[('JS',ins,lmic)][-1],)
        elif ('JR',ins,lmic) in dk: grp=(ins,)
        elif ('SR',ins,merk) in dk: grp=tuple(dk[('SR',ins,merk)]); kind='SR'
        else: grp=(ins,) if ins and not set(ins)<=set('0') else ()
        mic_rows[mic]['src'][ins]=dict(grp=grp,merk=merk,cm=cm,lmic=lmic,kind=kind)
    res[do]=mic_rows
lots=set()
for do,m in res.items():
    for r in m.values():
        for k,v in r['src'].items(): lots|=set(v['grp'])
print(len(lots),'lot efektif')
qals=rfc('QALS','PRUEFLOS,WERK,MATNR,CHARG,ENSTEHDAT,ART',lots)
qamv=rfc('QAMV','PRUEFLOS,MERKNR,VERWMERKM,KURZTEXT',lots)
qamr=rfc('QAMR','PRUEFLOS,MERKNR,MITTELWERT,ANZWERTG',lots)
Q={r[0]:dict(plant=r[1],mat=r[2],batch=r[3],date=r[4],art=r[5]) for r in qals}
V={(r[0],r[1]):(r[2],r[3]) for r in qamv}
VM={}
for r in qamv: VM.setdefault((r[0],r[2]),r[1])
A={(r[0],r[1]):(float(r[2]),float(r[3])) for r in qamr}
out=[]
for do,m in res.items():
    for mic,r in m.items():
        srcs=[]
        for ins,v in r['src'].items():
            ls=[]
            for lot in v['grp']:
                merk=v['merk'] if (lot,v['merk']) in V else VM.get((lot,v['lmic']),v['merk'])
                kt=V.get((lot,merk),('',''))[1]
                mv=A.get((lot,merk))
                ls.append(dict(lot=lot,merknr=merk,text=kt,mean=(mv[0] if mv and mv[1]>0 else None)))
            srcs.append(dict(ins=ins,lots=ls,cm=v['cm'],kind=v['kind']))
        out.append(dict(do=do,mic=mic,val=r['val'],srcs=srcs))
json.dump(dict(rows=out,qals=Q),open(S+'/data2.json','w'))
bad=0
for o in out:
    vals=[]
    for sc in o['srcs']:
        ms=[l['mean'] for l in sc['lots'] if l['mean'] is not None]
        if ms: vals.append(sum(ms)/len(ms))
    if vals:
        avg=sum(vals)/len(vals); dec=len(o['val'].split('.')[1]) if '.' in o['val'] else 0
        if abs(avg-float(o['val']))>0.5*10**-dec+1e-9: bad+=1; print('BEDA',o['do'],o['mic'],round(avg,4),o['val'],[(sc['ins'],[(l['lot'],l['mean']) for l in sc['lots']]) for sc in o['srcs']][:4])
    else: print('NOMEAN',o['do'],o['mic'],o['val'])
print('bad',bad,len(out))
