import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_GET_FUNCTION_INTERFACE', FUNCNAME='RFC_PROGRAM_CHECK_SYNTAX')
print("RFC_PROGRAM_CHECK_SYNTAX params:", [(p['PARAMETER'], p['PARAMCLASS'], p['TABNAME']) for p in res['PARAMS']])

conn.close()
