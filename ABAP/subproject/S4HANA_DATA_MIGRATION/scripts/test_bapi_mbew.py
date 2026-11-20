import pyrfc
from decimal import Decimal

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

headdata = {
    'MATERIAL': 'RPV-HC401BF',
    'ACCOUNT_VIEW': 'X'
}

valdata = {
    'VAL_AREA': '1000',
    'VAL_CLASS': '3000',
    'PRICE_CTRL': 'V',
    'MOVING_PR': Decimal('125'),
    'PRICE_UNIT': Decimal('1')
}

valdatax = {
    'VAL_AREA': '1000',
    'VAL_CLASS': 'X',
    'PRICE_CTRL': 'X',
    'MOVING_PR': 'X',
    'PRICE_UNIT': 'X'
}

print('Calling BAPI_MATERIAL_SAVEDATA...')
res = conn.call('BAPI_MATERIAL_SAVEDATA', HEADDATA=headdata, VALUATIONDATA=valdata, VALUATIONDATAX=valdatax)
print('RETURN:', res.get('RETURN'))

ret_type = res.get('RETURN', {}).get('TYPE')
if ret_type in ['S', 'I', 'W', '']:
    print('Calling BAPI_TRANSACTION_COMMIT...')
    c_res = conn.call('BAPI_TRANSACTION_COMMIT', WAIT='X')
    print('Commit result:', c_res)
else:
    print('Failed, not committing.')
