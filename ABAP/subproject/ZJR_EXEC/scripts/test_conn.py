import pyrfc
conn = pyrfc.Connection(ashost=192.168.1.199, sysnr=01, client=130, user=TRSTABAP, passwd=supporter)
print(Connected:, conn.alive)
conn.close()
