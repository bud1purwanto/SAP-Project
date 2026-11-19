import pyrfc

params = {
    'ashost': '192.168.1.199',
    'sysnr': '01',
    'client': '130',
    'user': 'TRSTABAP',
    'passwd': 'supporter'
}

try:
    conn = pyrfc.Connection(**params)
    res = conn.call('STFC_CONNECTION', REQUTEXT='Hello SAP S4')
    print('SUCCESS:', res['ECHOTEXT'])
    conn.close()
except Exception as e:
    print('ERROR:', e)
