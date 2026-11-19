import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE',
    QUERY_TABLE='O2PAGCON',
    DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'APPLNAME'}, {'FIELDNAME': 'PAGEKEY'}],
    OPTIONS=[{'TEXT': "LINE LIKE '%MM_PUR_POITEMS_MONI%'"}],
    ROWCOUNT=10
)

print("Found in O2PAGCON:")
for r in res['DATA']:
    print(r['WA'])
