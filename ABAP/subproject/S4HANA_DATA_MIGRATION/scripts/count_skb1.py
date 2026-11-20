import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')
opt = "BUKRS = '9999'"
res = conn.call('RFC_READ_TABLE', QUERY_TABLE='SKB1', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'SAKNR'}, {'FIELDNAME': 'WAERS'}],
    OPTIONS=[{'TEXT': opt}]
)
rows = res.get('DATA', [])
print('Total accounts in 9999:', len(rows))
eur_count = sum(1 for r in rows if 'EUR' in r.get('WA'))
print('Accounts with EUR:', eur_count)
