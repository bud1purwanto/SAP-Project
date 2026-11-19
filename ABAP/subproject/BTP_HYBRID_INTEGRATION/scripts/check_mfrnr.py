import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='EKPO',
                FIELDS=[{'FIELDNAME': 'EBELN'}, {'FIELDNAME': 'MFRNR'}],
                OPTIONS=[{'TEXT': "EBELN = '4500000001'"}],
                ROWCOUNT=1)

print("EKPO-MFRNR:", res['DATA'])

conn.close()
