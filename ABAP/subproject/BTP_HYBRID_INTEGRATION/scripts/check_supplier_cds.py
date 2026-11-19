import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

try:
    res = conn.call('RFC_READ_TABLE', QUERY_TABLE='I_SUPPLIER_CDS',
                    FIELDS=[{'FIELDNAME': 'SUPPLIER'}, {'FIELDNAME': 'SUPPLIERNAME'}],
                    OPTIONS=[{'TEXT': "SUPPLIER = '0000100000'"}],
                    ROWCOUNT=5)
    print("I_SUPPLIER_CDS for 0000100000:", res['DATA'])
except Exception as e:
    print("Error querying I_SUPPLIER_CDS:", e)

conn.close()
