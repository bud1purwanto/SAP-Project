import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

print("=== CHECKING PLKO FOR JRAAAI ===")
res_plko = conn.call('RFC_READ_TABLE', QUERY_TABLE='PLKO', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'PLNTY'}, {'FIELDNAME': 'PLNNR'}, {'FIELDNAME': 'PLNAL'}, {'FIELDNAME': 'KTEXT'}, {'FIELDNAME': 'WERKS'}, {'FIELDNAME': 'STATU'}],
    OPTIONS=[{'TEXT': "PLNTY = '2' AND PLNNR = 'JRAAAI'"}]
)
for r in res_plko.get('DATA', []):
    print("PLKO:", r.get('WA'))

print("\n=== CHECKING MAPL FOR JRAAAI ===")
res_mapl = conn.call('RFC_READ_TABLE', QUERY_TABLE='MAPL', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'WERKS'}, {'FIELDNAME': 'PLNTY'}, {'FIELDNAME': 'PLNNR'}, {'FIELDNAME': 'PLNAL'}],
    OPTIONS=[{'TEXT': "PLNTY = '2' AND MATNR = 'JRAAAI'"}]
)
for r in res_mapl.get('DATA', []):
    print("MAPL:", r.get('WA'))

print("\n=== CHECKING PLAS FOR JRAAAI ===")
res_plas = conn.call('RFC_READ_TABLE', QUERY_TABLE='PLAS', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'PLNTY'}, {'FIELDNAME': 'PLNNR'}, {'FIELDNAME': 'PLNAL'}, {'FIELDNAME': 'PLNKN'}, {'FIELDNAME': 'ZAEHL'}],
    OPTIONS=[{'TEXT': "PLNTY = '2' AND PLNNR = 'JRAAAI'"}]
)
for r in res_plas.get('DATA', []):
    print("PLAS:", r.get('WA'))

print("\n=== CHECKING PLPO FOR JRAAAI ===")
res_plpo = conn.call('RFC_READ_TABLE', QUERY_TABLE='PLPO', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'PLNTY'}, {'FIELDNAME': 'PLNNR'}, {'FIELDNAME': 'PLNKN'}, {'FIELDNAME': 'VORNR'}, {'FIELDNAME': 'ARBID'}, {'FIELDNAME': 'STEUS'}, {'FIELDNAME': 'PVZKN'}],
    OPTIONS=[{'TEXT': "PLNTY = '2' AND PLNNR = 'JRAAAI'"}]
)
for r in res_plpo.get('DATA', []):
    print("PLPO:", r.get('WA'))

print("\n=== CHECKING MKAL FOR JRAAAI ===")
res_mkal = conn.call('RFC_READ_TABLE', QUERY_TABLE='MKAL', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'WERKS'}, {'FIELDNAME': 'VERID'}, {'FIELDNAME': 'TEXT1'}, {'FIELDNAME': 'PLNTY'}, {'FIELDNAME': 'PLNNR'}, {'FIELDNAME': 'ALNAL'}, {'FIELDNAME': 'STLAL'}],
    OPTIONS=[{'TEXT': "MATNR = 'JRAAAI' AND WERKS = '1000'"}]
)
for r in res_mkal.get('DATA', []):
    print("MKAL:", r.get('WA'))
