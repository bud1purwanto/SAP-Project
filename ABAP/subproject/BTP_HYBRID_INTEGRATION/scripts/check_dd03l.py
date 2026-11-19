import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='DD03L',
                FIELDS=[{'FIELDNAME': 'TABNAME'}, {'FIELDNAME': 'FIELDNAME'}, {'FIELDNAME': 'POSITION'}],
                OPTIONS=[{'TEXT': "TABNAME = 'CPURORDITEMMONI'"}],
                ROWCOUNT=15)

print(f"CPURORDITEMMONI fields in DD03L:")
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
