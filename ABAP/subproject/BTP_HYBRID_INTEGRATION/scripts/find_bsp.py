import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE',
    QUERY_TABLE='TADIR',
    DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'PGMID'}, {'FIELDNAME': 'OBJECT'}, {'FIELDNAME': 'OBJ_NAME'}, {'FIELDNAME': 'DEVCLASS'}],
    OPTIONS=[{'TEXT': "OBJECT = 'WAPA' AND OBJ_NAME LIKE 'MM_PUR%'"}],
    ROWCOUNT=30
)

print("BSP Applications (WAPA):")
for r in res['DATA']:
    print(r['WA'])
