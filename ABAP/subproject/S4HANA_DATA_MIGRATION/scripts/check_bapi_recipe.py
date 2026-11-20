import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

desc = conn.get_function_description('BAPI_ROUTING_CREATE')
print("BAPI_ROUTING_CREATE parameters:")
for p in desc.parameters:
    print(p['name'], p['direction'])
