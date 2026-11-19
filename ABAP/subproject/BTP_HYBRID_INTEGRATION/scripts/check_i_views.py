import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='DDLDEPENDENCY',
                FIELDS=[{'FIELDNAME': 'DDLNAME'}, {'FIELDNAME': 'OBJECTNAME'}, {'FIELDNAME': 'OBJECTTYPE'}],
                OPTIONS=[{'TEXT': "DDLNAME = 'I_PURCHASEORDER' OR DDLNAME = 'I_PURCHASEORDERITEM'"}],
                ROWCOUNT=10)

print(f"SQL Views for I_PurchaseOrder & I_PurchaseOrderItem:")
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
