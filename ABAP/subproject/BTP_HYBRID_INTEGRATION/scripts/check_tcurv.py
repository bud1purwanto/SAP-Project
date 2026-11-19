import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='TCURV',
                FIELDS=[{'FIELDNAME': 'KURST'}, {'FIELDNAME': 'XINVR'}, {'FIELDNAME': 'BWAER'}],
                ROWCOUNT=20)

print(f"TCURV count ({len(res['DATA'])}):")
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
