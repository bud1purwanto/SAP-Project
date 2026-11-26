*eject.
*---------------------------------------------------------------------*
*       MODULE T683U_SELECT_KALKU
*---------------------------------------------------------------------*
*       Lesen der Text zum Kalkulationsschema Einzelkalkulation       *
*---------------------------------------------------------------------*
MODULE T683U_SELECT_KALKU OUTPUT.

  PERFORM T683U_SELECT USING 'A'
                             'KA'
                             VBAP-KALSM_K
                             SY-SUBRC.

ENDMODULE.