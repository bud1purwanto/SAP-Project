import sys,json,collections; S=sys.argv[1]; sys.path.insert(0,S); from sapc import C
c=C(); P='Production AIX'
import time
def rt(t,f,w,rc):
    for k in range(6):
        try: return c.call('read_table',{'server':P,'table':t,'fields':f,'where':w,'rowcount':rc}).get('rows') or []
        except Exception as e:
            print('retry',k,t,str(e)[:60],flush=True); time.sleep(5*(k+1))
    return []
def win(lo,hi): return rt('AUSP',['OBJEK','ATWRT','KLART'],[f"OBJEK >= '{lo:018d}' AND OBJEK < '{hi:018d}'"," AND ATINN = '0000000844'"],20000)
TH=51282577; STEP=20000; rows=[]; empty=0; i=0; lo=TH
while empty<3:
    r=win(lo,lo+STEP)
    rows+= [x for x in r if x['KLART']=='023']
    empty = empty+1 if not r else 0
    if i%10==0: print('win',i,lo,len(r),'kept',len(rows),flush=True)
    lo+=STEP*5; i+=1
print('last window',lo,'rows',len(rows),flush=True)
json.dump(rows,open(S+'/recent_ausp.json','w'))
byal=collections.defaultdict(list)
for x in rows: byal[x['ATWRT'].strip()].append(x['OBJEK'])
print('unique alias',len(byal),flush=True)
samp={}
for a,objs in sorted(byal.items(),key=lambda kv:-len(kv[1])):
    objs=sorted(objs); k=min(15,len(objs)); pick=[objs[int(j*len(objs)/k)] for j in range(k)]
    mats=collections.Counter(); ex={}
    for o in pick:
        r=rt('INOB',['OBJEK'],[f"CUOBJ = '{o}'"],1)
        if r:
            m=r[0]['OBJEK'][:18].strip(); mats[m]+=1; ex.setdefault(m,r[0]['OBJEK'][18:].strip())
    samp[a]={'count':len(objs),'mats':dict(mats),'ex':ex}
    print('A',a,len(objs),dict(mats),flush=True)
# creation date check on a few batches
dates=[]
for a in list(samp)[:5]:
    for m,b in samp[a]['ex'].items():
        r=rt('MCH1',['ERSDA'],[f"MATNR = '{m}' AND CHARG = '{b}'"],1)
        if r: dates.append((a,m,b,r[0]['ERSDA']))
print('DATES',dates)
json.dump(samp,open(S+'/recent_samp.json','w'),indent=1)
print('DONE')
