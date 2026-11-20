import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')
opt = "KTOPL = 'INT' AND KTOSL = 'BSX' AND BKLAS = '3000'"
res = conn.call('RFC_READ_TABLE', QUERY_TABLE='T030', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'KTOPL'}, {'FIELDNAME': 'KTOSL'}, {'FIELDNAME': 'BWMOD'}, {'FIELDNAME': 'BKLAS'}, {'FIELDNAME': 'KONTS'}],
    OPTIONS=[{'TEXT': opt}]
)
for r in res.get('DATA', []):
    print(r.get('WA'))
