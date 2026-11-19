import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

for fn in ['BAPI_XBP_NEW_LOGON', 'BAPI_XBP_LOGON']:
    try:
        res = conn.call('RFC_GET_FUNCTION_INTERFACE', FUNCNAME=fn)
        params = [(p['PARAMETER'], p['PARAMCLASS'], p['TABNAME']) for p in res['PARAMS']]
        print(f"{fn}: {params}")
    except Exception as e:
        print(f"{fn}: error {e}")

conn.close()
