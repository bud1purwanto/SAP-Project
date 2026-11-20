import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='WBCROSSGT', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'INCLUDE'}, {'FIELDNAME': 'NAME'}],
    OPTIONS=[{'TEXT': "NAME = 'CO046'"}]
)
for r in res.get('DATA', []):
    print("WBCROSSGT:", r.get('WA'))
