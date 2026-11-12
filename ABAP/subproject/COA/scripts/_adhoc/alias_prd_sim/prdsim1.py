import json,sys
S=sys.argv[1]; sys.path.insert(0,S); from sapc import C
c=C(); rt=lambda *a: (c.rt(*a).get('rows') or [])
src=json.load(open('/data/Projects/SAP/ABAP/subproject/COA/outputs/alias_mapping_20261111/prd_alias_to_material_sample.json'))
maktc={}
def makt(m):
    if m not in maktc:
        r=rt('MAKT',['MAKTX'],f"MATNR = '{m}' AND SPRAS = 'E'",1); maktc[m]=r[0]['MAKTX'].strip() if r else ''
    return maktc[m]
out={}
for alias,mats in src.items():
    a=alias.replace("'","''")
    o={'batch_mats':list(mats),'via':'','amat':''}
    cw=rt('CAWNT',['ATZHL'],f"ATINN = '0000000811' AND ATWTB = '{a}'",2)
    if cw:
        cv=rt('CAWN',['ATWRT'],f"ATINN = '0000000811' AND ATZHL = '{cw[0]['ATZHL']}'",1)
        if cv:
            code=cv[0]['ATWRT'].strip(); o['code']=code
            bm=list(mats)[0]; cand='SR'+code+bm[-1]
            if rt('MARA',['MATNR'],f"MATNR = '{cand}'",1): o['amat']=cand; o['via']='ZZCODE'
    if not o['amat']:
        bm=list(mats)[0]; t=makt(bm); pre=t.rsplit(' ',1)[0]+' ' if ' ' in t else ''
        q=(pre+alias).upper().replace("'","''")
        r=rt('MAKT',['MATNR'],f"MAKTG = '{q}' AND SPRAS = 'E'",5)
        r=[x['MATNR'].strip() for x in r if x['MATNR'].startswith('SR')]
        if r: o['amat']=r[0]; o['via']='MAKT'; o['makt_hits']=r
    o['batch_makt']={m:makt(m) for m in mats}
    if o['amat']: o['amat_makt']=makt(o['amat'])
    st='NOCONV' if not o['amat'] else ('SAME' if set(mats)=={o['amat']} else 'DIFF')
    o['status']=st; out[alias]=o
    print(f"{alias:16} {st:6} {o['via']:6} {o['amat']:8} batch={[(m,o['batch_makt'][m]) for m in mats]}",flush=True)
json.dump(out,open(S+'/prdsim1.json','w'),indent=1)
