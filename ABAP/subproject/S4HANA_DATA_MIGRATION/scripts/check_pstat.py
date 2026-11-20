import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res_mara = conn.call('RFC_READ_TABLE', QUERY_TABLE='MARA', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'VPSTA'}, {'FIELDNAME': 'PSTAT'}],
    OPTIONS=[{'TEXT': "MATNR = 'JRAAAI'"}]
)
for r in res_mara.get('DATA', []):
    print("MARA PSTAT:", r.get('WA'))

res_marc = conn.call('RFC_READ_TABLE', QUERY_TABLE='MARC', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'WERKS'}, {'FIELDNAME': 'PSTAT'}],
    OPTIONS=[{'TEXT': "MATNR = 'JRAAAI' AND WERKS = '1000'"}]
)
for r in res_marc.get('DATA', []):
    print("MARC PSTAT:", r.get('WA'))
