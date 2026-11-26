*eject.
*---------------------------------------------------------------------*
*       MODULE T178T_SELECT
*---------------------------------------------------------------------*
*       Lesen der Materialgruppe                                      *
*---------------------------------------------------------------------*
MODULE T178T_SELECT OUTPUT.

* Materialgruppe
  PERFORM T178T_SELECT USING VBAP-KONDM
                             SPACE
                             SY-SUBRC.
ENDMODULE.