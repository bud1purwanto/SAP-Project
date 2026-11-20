import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

print("=== CHECKING PLKO FOR GROUP 50000002 ===")
res_plko = conn.call('RFC_READ_TABLE', QUERY_TABLE='PLKO', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'PLNTY'}, {'FIELDNAME': 'PLNNR'}, {'FIELDNAME': 'PLNAL'}, {'FIELDNAME': 'KTEXT'}, {'FIELDNAME': 'WERKS'}, {'FIELDNAME': 'STATU'}],
    OPTIONS=[{'TEXT': "PLNNR = '50000002'"}]
)
for r in res_plko.get('DATA', []):
    print("PLKO:", r.get('WA'))

print("\n=== CHECKING MAPL FOR GROUP 50000002 ===")
res_mapl = conn.call('RFC_READ_TABLE', QUERY_TABLE='MAPL', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'WERKS'}, {'FIELDNAME': 'PLNTY'}, {'FIELDNAME': 'PLNNR'}, {'FIELDNAME': 'PLNAL'}],
    OPTIONS=[{'TEXT': "PLNNR = '50000002'"}]
)
for r in res_mapl.get('DATA', []):
    print("MAPL:", r.get('WA'))

print("\n=== CHECKING PLPO FOR GROUP 50000002 ===")
res_plpo = conn.call('RFC_READ_TABLE', QUERY_TABLE='PLPO', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'PLNTY'}, {'FIELDNAME': 'PLNNR'}, {'FIELDNAME': 'PLNKN'}, {'FIELDNAME': 'VORNR'}, {'FIELDNAME': 'ARBID'}, {'FIELDNAME': 'STEUS'}],
    OPTIONS=[{'TEXT': "PLNNR = '50000002'"}]
)
for r in res_plpo.get('DATA', []):
    print("PLPO:", r.get('WA'))
