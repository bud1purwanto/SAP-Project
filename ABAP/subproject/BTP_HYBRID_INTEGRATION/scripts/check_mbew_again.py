import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='MBEW',
                FIELDS=[{'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'BWKEY'}, {'FIELDNAME': 'BKLAS'}],
                OPTIONS=[{'TEXT': "MATNR = 'SRAJII'"}],
                ROWCOUNT=10)

print(f"MBEW records for SRAJII ({len(res['DATA'])}):")
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
