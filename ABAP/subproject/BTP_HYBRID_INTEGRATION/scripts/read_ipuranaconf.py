import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='IPURANACONF', ROWCOUNT=5)
print("IPURANACONF fields:", [f['FIELDNAME'] for f in res['FIELDS']])
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
