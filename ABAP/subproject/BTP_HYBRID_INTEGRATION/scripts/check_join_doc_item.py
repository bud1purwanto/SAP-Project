import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='DD26S',
                FIELDS=[{'FIELDNAME': 'VIEWNAME'}, {'FIELDNAME': 'TABNAME'}, {'FIELDNAME': 'FORTABNAME'}],
                OPTIONS=[{'TEXT': "VIEWNAME = 'IMMPURCHORDRITEM'"}],
                ROWCOUNT=10)

print("DD26S for IMMPURCHORDRITEM:")
for r in res['DATA']:
    print(' ', r['WA'])

# Check what field connects IMMPURGDOCITEM and I_SUPPLIER_CDS
# In IMMPURGDOCITEM:
res_doc_item = conn.call('RFC_READ_TABLE', QUERY_TABLE='IMMPURGDOCITEM',
                         FIELDS=[{'FIELDNAME': 'PURCHASINGDOCUMENT'}, {'FIELDNAME': 'SUPPLIER'}, {'FIELDNAME': 'PURCHASINGDOCUMENTCATEGORY'}, {'FIELDNAME': 'PURCHASINGDOCUMENTTYPE'}],
                         OPTIONS=[{'TEXT': "PURCHASINGDOCUMENT = '4500000001'"}],
                         ROWCOUNT=5)
print("IMMPURGDOCITEM fields for 4500000001:")
for r in res_doc_item['DATA']:
    print(' ', r['WA'])

conn.close()
