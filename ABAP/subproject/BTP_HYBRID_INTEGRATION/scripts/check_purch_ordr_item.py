import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

try:
    res = conn.call('RFC_READ_TABLE', QUERY_TABLE='IMMPURCHORDRITEM',
                    FIELDS=[{'FIELDNAME': 'PURCHASEORDER'}, {'FIELDNAME': 'PURCHASEORDERITEM'}, {'FIELDNAME': 'PURCHASEORDERITEMTEXT'}],
                    OPTIONS=[{'TEXT': "PURCHASEORDER = '4500000001'"}],
                    ROWCOUNT=5)
    print("IMMPURCHORDRITEM for 4500000001:", res['DATA'])
except Exception as e:
    print("Error querying IMMPURCHORDRITEM:", e)

conn.close()
