import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='TCURR',
                FIELDS=[{'FIELDNAME': 'KURST'}, {'FIELDNAME': 'FCURR'}, {'FIELDNAME': 'TCURR'}, {'FIELDNAME': 'GDATU'}, {'FIELDNAME': 'UKURS'}],
                ROWCOUNT=20)

print(f"TCURR count: {len(res['DATA'])}")
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
