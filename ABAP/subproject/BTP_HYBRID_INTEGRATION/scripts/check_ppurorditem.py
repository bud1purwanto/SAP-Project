import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='PPURORDITEM',
                FIELDS=[{'FIELDNAME': 'PURCHASEORDER'}, {'FIELDNAME': 'PURCHASEORDERITEM'}, {'FIELDNAME': 'PURCHASINGORGANIZATION'}],
                ROWCOUNT=20)

print(f"PPURORDITEM rows ({len(res['DATA'])}):")
for r in res['DATA']:
    print(' ', r['WA'])

res_enh = conn.call('RFC_READ_TABLE', QUERY_TABLE='PPOITEMENH',
                    FIELDS=[{'FIELDNAME': 'PURCHASEORDER'}, {'FIELDNAME': 'PURCHASEORDERITEM'}],
                    ROWCOUNT=20)
print(f"PPOITEMENH rows ({len(res_enh['DATA'])}):")
for r in res_enh['DATA']:
    print(' ', r['WA'])

conn.close()
