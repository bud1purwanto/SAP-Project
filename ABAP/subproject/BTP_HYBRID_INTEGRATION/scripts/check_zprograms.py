import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='TRDIR',
                FIELDS=[{'FIELDNAME': 'NAME'}, {'FIELDNAME': 'SUBC'}],
                OPTIONS=[{'TEXT': "NAME LIKE 'Z%'"}],
                ROWCOUNT=50)

print(f"TRDIR Z programs ({len(res['DATA'])}):")
for r in res['DATA']:
    print(' ', r['WA'].strip())

conn.close()
