import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='AUFK', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'AUFNR'}, {'FIELDNAME': 'AUART'}, {'FIELDNAME': 'AUTYP'}, {'FIELDNAME': 'WERKS'}],
    OPTIONS=[{'TEXT': "AUFNR = '000001000000'"}]
)
print("AUFK:", res.get('DATA'))
