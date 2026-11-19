import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='DD26S',
                FIELDS=[{'FIELDNAME': 'VIEWNAME'}, {'FIELDNAME': 'TABNAME'}, {'FIELDNAME': 'FORTABNAME'}],
                OPTIONS=[{'TEXT': "VIEWNAME = 'PPURORDITEMMNTR'"}],
                ROWCOUNT=20)

print(f"DD26S base tables for PPURORDITEMMNTR ({len(res['DATA'])}):")
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
