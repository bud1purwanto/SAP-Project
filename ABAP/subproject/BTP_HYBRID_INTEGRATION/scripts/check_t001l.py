import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='T001L',
                FIELDS=[{'FIELDNAME': 'WERKS'}, {'FIELDNAME': 'LGORT'}, {'FIELDNAME': 'LGOBE'}],
                ROWCOUNT=20)

print(f"T001L rows ({len(res['DATA'])}):")
for r in res['DATA']:
    print(' ', r['WA'])

# Check MAKT for SRAJII
res_makt = conn.call('RFC_READ_TABLE', QUERY_TABLE='MAKT',
                     FIELDS=[{'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'SPRAS'}, {'FIELDNAME': 'MAKTX'}],
                     OPTIONS=[{'TEXT': "MATNR = 'SRAJII'"}],
                     ROWCOUNT=5)
print(f"MAKT rows for SRAJII ({len(res_makt['DATA'])}):")
for r in res_makt['DATA']:
    print(' ', r['WA'])

conn.close()
