import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='DD28J',
                FIELDS=[{'FIELDNAME': 'VIEWNAME'}, {'FIELDNAME': 'LTAB'}, {'FIELDNAME': 'LFIELD'}, {'FIELDNAME': 'RTAB'}, {'FIELDNAME': 'RFIELD'}],
                OPTIONS=[{'TEXT': "VIEWNAME = 'CPURORDITEMMONI'"}],
                ROWCOUNT=20)

print(f"DD28J joins for CPURORDITEMMONI:")
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
