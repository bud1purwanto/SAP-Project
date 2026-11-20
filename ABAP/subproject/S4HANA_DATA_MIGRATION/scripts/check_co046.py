import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

# Let's check T100 for CO 046
res = conn.call('RFC_READ_TABLE', QUERY_TABLE='T100', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'ARBGB'}, {'FIELDNAME': 'MSGNR'}, {'FIELDNAME': 'TEXT'}],
    OPTIONS=[{'TEXT': "ARBGB = 'CO' AND MSGNR = '046' AND SPRSL = 'E'"}]
)
for r in res.get('DATA', []):
    print("T100:", r.get('WA'))
