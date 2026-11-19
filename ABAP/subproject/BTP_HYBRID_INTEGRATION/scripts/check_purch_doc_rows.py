import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

try:
    res = conn.call('RFC_READ_TABLE', QUERY_TABLE='IMMPURCHASINGDOC',
                    FIELDS=[{'FIELDNAME': 'PURCHASINGDOCUMENT'}, {'FIELDNAME': 'PURCHASINGDOCUMENTCATEGORY'}],
                    OPTIONS=[{'TEXT': "PURCHASINGDOCUMENT = '4500000001'"}],
                    ROWCOUNT=5)
    print("IMMPURCHASINGDOC for 4500000001:", res['DATA'])
except Exception as e:
    print("Error:", e)

try:
    res_item = conn.call('RFC_READ_TABLE', QUERY_TABLE='IMMPURGDOCITEM',
                         FIELDS=[{'FIELDNAME': 'PURCHASINGDOCUMENT'}, {'FIELDNAME': 'PURCHASINGDOCUMENTITEM'}],
                         OPTIONS=[{'TEXT': "PURCHASINGDOCUMENT = '4500000001'"}],
                         ROWCOUNT=5)
    print("IMMPURGDOCITEM for 4500000001:", res_item['DATA'])
except Exception as e:
    print("Error:", e)

conn.close()
