import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='DD03L',
                FIELDS=[{'FIELDNAME': 'FIELDNAME'}, {'FIELDNAME': 'POSITION'}],
                OPTIONS=[{'TEXT': "TABNAME = 'IMMPURGDOCITEM'"}],
                ROWCOUNT=30)

print(f"IMMPURGDOCITEM fields ({len(res['DATA'])}):")
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
