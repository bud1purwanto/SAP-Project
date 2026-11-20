import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

orderdata = {
    'MATERIAL': 'JRAAAI',
    'PLANT': '1000',
    'ORDER_TYPE': 'PI01',
    'QUANTITY': 100.0,
    'QUANTITY_UOM': 'KG',
    'PROD_VERSION': '0002',
    'BASIC_START_DATE': '20231115',
    'BASIC_END_DATE': '20231120',
    'STORAGE_LOCATION': '1813'
}

try:
    res = conn.call('BAPI_PROCORD_CREATE', ORDERDATA=orderdata)
    print("Result:", res)
    order_no = res.get('ORDER_NUMBER')
    ret = res.get('RETURN', {})
    print("RETURN TYPE:", ret.get('TYPE'))
    print("RETURN MESSAGE:", ret.get('MESSAGE'))
    
    if order_no:
        print("Calling BAPI_TRANSACTION_COMMIT...")
        c_res = conn.call('BAPI_TRANSACTION_COMMIT', WAIT='X')
        print("Commit result:", c_res)
        print(f"SUCCESS! Process Order created: {order_no}")
except Exception as e:
    print("Exception:", e)
