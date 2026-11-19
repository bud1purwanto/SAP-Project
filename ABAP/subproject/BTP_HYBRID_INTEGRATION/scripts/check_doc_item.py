import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='DD26S',
                FIELDS=[{'FIELDNAME': 'VIEWNAME'}, {'FIELDNAME': 'TABNAME'}, {'FIELDNAME': 'FORTABNAME'}],
                OPTIONS=[{'TEXT': "VIEWNAME = 'IMMPURGDOCITEM'"}],
                ROWCOUNT=10)

print("DD26S for IMMPURGDOCITEM:")
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
