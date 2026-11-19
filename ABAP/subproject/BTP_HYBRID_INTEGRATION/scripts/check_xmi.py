import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_GET_FUNCTION_INTERFACE', FUNCNAME='BAPI_XMI_LOGON')
params = [(p['PARAMETER'], p['PARAMCLASS'], p['TABNAME']) for p in res['PARAMS']]
print("BAPI_XMI_LOGON:", params)

conn.close()
