import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='T024E', FIELDS=[{'FIELDNAME': 'EKORG'}, {'FIELDNAME': 'EKOTX'}, {'FIELDNAME': 'BUKRS'}], ROWCOUNT=20)
print('T024E (Purchasing Orgs):')
for r in res['DATA']:
    print(' ', r['WA'])

res_t001k = conn.call('RFC_READ_TABLE', QUERY_TABLE='T001K', FIELDS=[{'FIELDNAME': 'BWKEY'}, {'FIELDNAME': 'BUKRS'}], ROWCOUNT=20)
print('T001K (Plant Valuation/CoCode):')
for r in res_t001k['DATA']:
    print(' ', r['WA'])

conn.close()
