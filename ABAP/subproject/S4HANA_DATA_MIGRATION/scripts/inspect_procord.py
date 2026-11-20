import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

aufnr = '000001000001'

print("=== 1. AUFK (Order Header) ===")
res = conn.call('RFC_READ_TABLE', QUERY_TABLE='AUFK', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'AUFNR'}, {'FIELDNAME': 'AUART'}, {'FIELDNAME': 'AUTYP'}, {'FIELDNAME': 'KTEXT'}, {'FIELDNAME': 'WERKS'}, {'FIELDNAME': 'BUKRS'}],
    OPTIONS=[{'TEXT': f"AUFNR = '{aufnr}'"}]
)
for r in res.get('DATA', []):
    print("AUFK:", r.get('WA'))

print("\n=== 2. AFKO (PP Order Header Details) ===")
res = conn.call('RFC_READ_TABLE', QUERY_TABLE='AFKO', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'AUFNR'}, {'FIELDNAME': 'GLTRP'}, {'FIELDNAME': 'GSTRP'}, {'FIELDNAME': 'GAMNG'}, {'FIELDNAME': 'GMEIN'}, {'FIELDNAME': 'PLNBEZ'}, {'FIELDNAME': 'PLNTY'}, {'FIELDNAME': 'PLNNR'}, {'FIELDNAME': 'PLNAL'}, {'FIELDNAME': 'STLAL'}],
    OPTIONS=[{'TEXT': f"AUFNR = '{aufnr}'"}]
)
for r in res.get('DATA', []):
    print("AFKO:", r.get('WA'))

print("\n=== 3. RESB (Order Components / BOM Explosion) ===")
res = conn.call('RFC_READ_TABLE', QUERY_TABLE='RESB', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'RSNUM'}, {'FIELDNAME': 'RSPOS'}, {'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'WERKS'}, {'FIELDNAME': 'LGORT'}, {'FIELDNAME': 'BDMNG'}, {'FIELDNAME': 'MEINS'}],
    OPTIONS=[{'TEXT': f"AUFNR = '{aufnr}'"}]
)
for r in res.get('DATA', []):
    print("RESB:", r.get('WA'))

print("\n=== 4. AFVC (Order Operations / Recipe Phases) ===")
# First get AUFPL from AFKO
res_afko = conn.call('RFC_READ_TABLE', QUERY_TABLE='AFKO', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'AUFPL'}],
    OPTIONS=[{'TEXT': f"AUFNR = '{aufnr}'"}]
)
aufpl = res_afko.get('DATA', [{}])[0].get('WA', '').strip()
print("AUFPL:", aufpl)

if aufpl:
    res_afvc = conn.call('RFC_READ_TABLE', QUERY_TABLE='AFVC', DELIMITER='|',
        FIELDS=[{'FIELDNAME': 'AUFPL'}, {'FIELDNAME': 'APLZL'}, {'FIELDNAME': 'VORNR'}, {'FIELDNAME': 'STEUS'}, {'FIELDNAME': 'ARBID'}, {'FIELDNAME': 'LTXA1'}, {'FIELDNAME': 'PVZKN'}],
        OPTIONS=[{'TEXT': f"AUFPL = '{aufpl}'"}]
    )
    for r in res_afvc.get('DATA', []):
        print("AFVC:", r.get('WA'))
