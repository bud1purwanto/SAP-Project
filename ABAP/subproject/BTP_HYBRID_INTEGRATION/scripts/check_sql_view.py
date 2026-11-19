import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='DDLDEPENDENCY',
                FIELDS=[{'FIELDNAME': 'DDLNAME'}, {'FIELDNAME': 'OBJECTNAME'}, {'FIELDNAME': 'OBJECTTYPE'}],
                OPTIONS=[{'TEXT': "DDLNAME = 'C_PURCHASEORDERITEMMONI'"}],
                ROWCOUNT=10)

print(f"DDLDEPENDENCY rows: {len(res['DATA'])}")
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
