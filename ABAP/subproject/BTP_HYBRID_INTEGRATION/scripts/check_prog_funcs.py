import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='TFDIR',
                FIELDS=[{'FIELDNAME': 'FUNCNAME'}],
                OPTIONS=[{'TEXT': "FMODE = 'R' AND FUNCNAME LIKE '%PROGRAM%'"}],
                ROWCOUNT=50)

print("Remote functions with PROGRAM:")
for r in res['DATA']:
    print(' ', r['WA'].strip())

conn.close()
