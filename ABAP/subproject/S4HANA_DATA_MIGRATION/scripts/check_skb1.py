import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')
opt = "BUKRS = '9999' AND SAKNR = '0000399999'"
res = conn.call('RFC_READ_TABLE', QUERY_TABLE='SKB1', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'BUKRS'}, {'FIELDNAME': 'SAKNR'}, {'FIELDNAME': 'WAERS'}, {'FIELDNAME': 'XSALH'}],
    OPTIONS=[{'TEXT': opt}],
    ROWCOUNT=10
)
for r in res.get('DATA', []):
    print(r.get('WA'))
