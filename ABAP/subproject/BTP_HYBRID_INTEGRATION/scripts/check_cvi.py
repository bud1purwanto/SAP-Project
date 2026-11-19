import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='CVI_VEND_LINK', 
                FIELDS=[{'FIELDNAME': 'PARTNER_GUID'}, {'FIELDNAME': 'CLIENT'}, {'FIELDNAME': 'VENDOR'}], 
                OPTIONS=[{'TEXT': "VENDOR = '0000100000'"}])
print("CVI_VEND_LINK:", res['DATA'])

conn.close()
