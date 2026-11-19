import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

# Let's inspect LFA1 data for 0000100000 with fields
res_lfa1 = conn.call('RFC_READ_TABLE', QUERY_TABLE='LFA1', 
                    FIELDS=[{'FIELDNAME': 'LIFNR'}, {'FIELDNAME': 'NAME1'}],
                    OPTIONS=[{'TEXT': "LIFNR = '0000100000'"}])
print("LFA1:", res_lfa1['DATA'])

lfm1_data = {
    'MANDT': '130',
    'LIFNR': '0000100000',
    'EKORG': '0001',
    'WAERS': 'EUR',
    'ZTERM': '0001',
    'VERKF': 'Sales Contact',
    'TELF1': '021-5551234',
    'EKGRP': '001'
}

try:
    print("Calling VENDOR_SAVE...")
    res = conn.call('VENDOR_SAVE', I_LFM1=lfm1_data, SAVE_LFM2='', UPDATE_ME='')
    print("VENDOR_SAVE result:", res)
    conn.call('BAPI_TRANSACTION_COMMIT', WAIT='X')
    print("Committed!")
except Exception as e:
    print("VENDOR_SAVE error:", e)

# Now check LFM1
res_lfm1 = conn.call('RFC_READ_TABLE', QUERY_TABLE='LFM1', 
                     FIELDS=[{'FIELDNAME': 'LIFNR'}, {'FIELDNAME': 'EKORG'}, {'FIELDNAME': 'WAERS'}],
                     OPTIONS=[{'TEXT': "LIFNR = '0000100000'"}])
print("LFM1 count:", len(res_lfm1['DATA']))
for r in res_lfm1['DATA']:
    print("LFM1 row:", r['WA'])

conn.close()
