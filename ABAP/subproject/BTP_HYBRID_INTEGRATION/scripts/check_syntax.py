import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_PROGRAM_CHECK_SYNTAX', PROGRAM='Z_DEBUG_QUERY')
print("Syntax check Z_DEBUG_QUERY:", res)

conn.close()
