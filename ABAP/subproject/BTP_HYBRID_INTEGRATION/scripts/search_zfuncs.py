import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')
res = conn.call('RFC_READ_TABLE', QUERY_TABLE='TFDIR', FIELDS=[{'FIELDNAME': 'FUNCNAME'}], OPTIONS=[{'TEXT': "FUNCNAME LIKE 'Z%'"}], ROWCOUNT=50)
print('Custom Z functions:', [r['WA'].strip() for r in res['DATA']])
conn.close()
