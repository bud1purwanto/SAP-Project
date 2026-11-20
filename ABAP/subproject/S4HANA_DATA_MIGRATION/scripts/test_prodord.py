import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

print("=== TESTING BAPI_PRODORD_CREATE ===")
orderdata = {
    'MATERIAL': 'JRAAAI',
    'PLANT': '1000',
    'ORDER_TYPE': 'PP01',
    'BASIC_START_DATE': '20231115',
    'BASIC_END_DATE': '20231120',
    'QUANTITY': 100.0,
    'PROD_VERSION': '0001'
}

res = conn.call('BAPI_PRODORD_CREATE', ORDERDATA=orderdata)
print("ORDER_NUMBER:", res.get('ORDER_NUMBER'))
print("ORDER_TYPE:", res.get('ORDER_TYPE'))
ret = res.get('RETURN', {})
print(f"RETURN: [{ret.get('TYPE')}] {ret.get('MESSAGE')} (ID: {ret.get('ID')} NUM: {ret.get('NUMBER')})")
