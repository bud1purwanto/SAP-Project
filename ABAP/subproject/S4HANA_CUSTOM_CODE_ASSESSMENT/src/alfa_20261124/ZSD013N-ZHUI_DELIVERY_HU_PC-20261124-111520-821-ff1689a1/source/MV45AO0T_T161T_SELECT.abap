*---------------------------------------------------------------------*
*       MODULE T161T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen des Einkaufsbelegtyps (Bestellart)                      *
*---------------------------------------------------------------------*
MODULE T161T_SELECT OUTPUT.

  PERFORM T161T_SELECT USING VBEP-BSART
                             VBEP-BSTYP
                             SPACE
                             SY-SUBRC.

ENDMODULE.