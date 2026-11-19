import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='FUPARAREF', 
                FIELDS=[{'FIELDNAME': 'FUNCNAME'}, {'FIELDNAME': 'PARAMETER'}, {'FIELDNAME': 'STRUCTURE'}], 
                OPTIONS=[{'TEXT': "STRUCTURE = 'LFM1'"}], ROWCOUNT=50)

print(f"Functions with structure LFM1 ({len(res['DATA'])} found):")
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
