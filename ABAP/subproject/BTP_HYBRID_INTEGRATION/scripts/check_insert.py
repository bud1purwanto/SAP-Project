import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_GET_FUNCTION_INTERFACE', FUNCNAME='RPY_PROGRAM_INSERT')
print("RPY_PROGRAM_INSERT:", res)

conn.close()
