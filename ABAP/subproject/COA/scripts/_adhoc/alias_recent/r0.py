import sys,json,collections,time; S=sys.argv[1]; sys.path.insert(0,S); from sapc import C
c=C()
def rt(t,f,w,rc):
    for k in range(6):
        try: return c.call('read_table',{'server':'Production AIX','table':t,'fields':f,'where':w,'rowcount':rc}).get('rows') or []
        except Exception as e: print('retry',k,str(e)[:50],flush=True); time.sleep(5*(k+1))
    return []
r=json.load(open(S+'/recent_ausp.json'))
byal=collections.defaultdict(list)
for x in r: byal[x['ATWRT'].strip()].append(x['OBJEK'])
cnt=collections.Counter({a:len(v) for a,v in byal.items()}); tot=sum(cnt.values())
top=[];acc=0
for a,v in cnt.most_common():
    top.append(a); acc+=v
    if acc/tot>=0.95: break
src={}; mcount={}
for a in top:
    objs=sorted(byal[a]); k=min(8,len(objs)); pick=[objs[int(j*len(objs)/k)] for j in range(k)]
    mats=collections.defaultdict(list)
    for o in pick:
        i=rt('INOB',['OBJEK'],[f"CUOBJ = '{o}'"],1)
        if i: mats[i[0]['OBJEK'][:18].strip()].append(i[0]['OBJEK'][18:].strip())
    src[a]=dict(mats); mcount[a]={m:len(b) for m,b in mats.items()}
    print('A',a,cnt[a],mcount[a],flush=True)
json.dump(src,open(S+'/recent_src.json','w'),indent=1)
json.dump(cnt.most_common(),open(S+'/recent_cnt.json','w'))
print('DONE0')
