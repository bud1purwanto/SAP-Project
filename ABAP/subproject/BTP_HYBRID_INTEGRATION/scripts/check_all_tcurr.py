import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='TCURR',
                FIELDS=[{'FIELDNAME': 'KURST'}, {'FIELDNAME': 'FCURR'}, {'FIELDNAME': 'TCURR'}],
                ROWCOUNT=100)

pairs = set()
for r in res['DATA']:
    pairs.add(r['WA'].strip())

print(f"Currency pairs in TCURR ({len(pairs)}):")
for p in sorted(list(pairs))[:25]:
    print(' ', p)

conn.close()
