import pyrfc
from decimal import Decimal

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

headdata = {
    'MATERIAL': 'SRAJII',
    'ACCOUNT_VIEW': 'X'
}

valdata = {
    'VAL_AREA': '0001',
    'VAL_CLASS': '3100',
    'PRICE_CTRL': 'S',
    'STD_PRICE': Decimal('100.00'),
    'PRICE_UNIT': Decimal('1')
}

valdata_x = {
    'VAL_AREA': '0001',
    'VAL_CLASS': 'X',
    'PRICE_CTRL': 'X',
    'STD_PRICE': 'X',
    'PRICE_UNIT': 'X'
}

print("Calling BAPI_MATERIAL_SAVEDATA...")
res = conn.call('BAPI_MATERIAL_SAVEDATA',
                HEADDATA=headdata,
                VALUATIONDATA=valdata,
                VALUATIONDATAX=valdata_x)

print("Return:", res.get('RETURN'))
conn.call('BAPI_TRANSACTION_COMMIT', WAIT='X')

# Check MBEW
res_mbew = conn.call('RFC_READ_TABLE', QUERY_TABLE='MBEW',
                     FIELDS=[{'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'BWKEY'}, {'FIELDNAME': 'BKLAS'}],
                     OPTIONS=[{'TEXT': "MATNR = 'SRAJII'"}],
                     ROWCOUNT=5)
print("MBEW records:", res_mbew['DATA'])

conn.close()
