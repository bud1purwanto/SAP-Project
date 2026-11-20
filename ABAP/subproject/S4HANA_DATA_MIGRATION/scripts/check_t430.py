import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='T430', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'STEUS'}],
    OPTIONS=[{'TEXT': "STEUS IN ('PI01', 'PI02', 'ZP02', 'PP01')"}]
)
for r in res.get('DATA', []):
    print("T430 ADB 130:", r.get('WA'))
