import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

print("=== CHECKING ORDER HEADER (AFKO) ===")
res_afko = conn.call('RFC_READ_TABLE', QUERY_TABLE='AFKO', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'AUFNR'}, {'FIELDNAME': 'GLTRP'}, {'FIELDNAME': 'GSTRP'}, {'FIELDNAME': 'GAMNG'}, {'FIELDNAME': 'GMEIN'}, {'FIELDNAME': 'PLNBEZ'}],
    OPTIONS=[{'TEXT': "AUFNR = '000001000000'"}]
)
for r in res_afko.get('DATA', []):
    print("AFKO:", r.get('WA'))

print("\n=== CHECKING ORDER RESERVATION & COMPONENTS (RESB) ===")
res_resb = conn.call('RFC_READ_TABLE', QUERY_TABLE='RESB', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'RSNUM'}, {'FIELDNAME': 'RSPOS'}, {'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'BDMNG'}, {'FIELDNAME': 'MEINS'}, {'FIELDNAME': 'LGORT'}],
    OPTIONS=[{'TEXT': "AUFNR = '000001000000'"}]
)
for r in res_resb.get('DATA', []):
    print("RESB Item:", r.get('WA'))

# get AUFPL from AFKO
res_afko_pl = conn.call('RFC_READ_TABLE', QUERY_TABLE='AFKO', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'AUFPL'}],
    OPTIONS=[{'TEXT': "AUFNR = '000001000000'"}]
)
aufpl = res_afko_pl['DATA'][0]['WA'].strip()
print(f"\nRouting Number (AUFPL): {aufpl}")

res_afvc = conn.call('RFC_READ_TABLE', QUERY_TABLE='AFVC', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'AUFPL'}, {'FIELDNAME': 'APLZL'}, {'FIELDNAME': 'VORNR'}, {'FIELDNAME': 'ARBID'}],
    OPTIONS=[{'TEXT': f"AUFPL = '{aufpl}'"}]
)
for r in res_afvc.get('DATA', []):
    print("AFVC Operation:", r.get('WA'))
