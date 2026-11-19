import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='DDDDLCODES',
                FIELDS=[{'FIELDNAME': 'NAME'}, {'FIELDNAME': 'NUM'}, {'FIELDNAME': 'CODE'}],
                OPTIONS=[{'TEXT': "NAME = 'C_PURCHASEORDERITEMMONI'"}],
                ROWCOUNT=30)

print(f"DDDDLCODES rows: {len(res['DATA'])}")
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
