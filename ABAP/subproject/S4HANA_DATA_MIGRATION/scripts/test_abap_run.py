import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

code = [
    "REPORT ztemp_run.",
    "UPDATE marc SET beskz = 'E', dismm = 'ND' WHERE matnr = 'JRAAAI' AND werks = '1000'.",
    "IF sy-subrc = 0.",
    "  COMMIT WORK AND WAIT.",
    "  WRITE: / 'OK'.",
    "ENDIF."
]

try:
    res = conn.call('RFC_ABAP_INSTALL_AND_RUN', PROGRAM=code)
    print("RFC_ABAP_INSTALL_AND_RUN result:", res)
except Exception as e:
    print("RFC_ABAP_INSTALL_AND_RUN error:", e)
