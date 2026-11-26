*eject.
*---------------------------------------------------------------------*
*       MODULE T683U_SELECT
*---------------------------------------------------------------------*
*       Lesen der Text zum Kalkulationsschema                         *
*---------------------------------------------------------------------*
MODULE T683U_SELECT OUTPUT.

  PERFORM T683U_SELECT USING 'A'
                             'V'
                             VBAK-KALSM
                             SY-SUBRC.

ENDMODULE.