import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='DD26S',
                FIELDS=[{'FIELDNAME': 'VIEWNAME'}, {'FIELDNAME': 'TABNAME'}, {'FIELDNAME': 'FORTABNAME'}],
                OPTIONS=[{'TEXT': "VIEWNAME = 'CPURORDITEMMONI'"}],
                ROWCOUNT=20)

print(f"DD26S base tables for CPURORDITEMMONI ({len(res['DATA'])}):")
for r in res['DATA']:
    print(' ', r['WA'])

# Also let's check DD27S (View fields)
res_fields = conn.call('RFC_READ_TABLE', QUERY_TABLE='DD27S',
                       FIELDS=[{'FIELDNAME': 'VIEWFIELD'}, {'FIELDNAME': 'TABNAME'}, {'FIELDNAME': 'FIELDNAME'}],
                       OPTIONS=[{'TEXT': "VIEWNAME = 'CPURORDITEMMONI'"}],
                       ROWCOUNT=50)
print(f"DD27S fields ({len(res_fields['DATA'])}):")
for r in res_fields['DATA'][:20]:
    print(' ', r['WA'])

conn.close()
