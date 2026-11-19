import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_PROGRAM_CHECK_SYNTAX', SOURCE_NAME='Z_TEST_CHAIN_V2')
print("Syntax check:", res['ERROR_MESSAGE'])

conn.close()
