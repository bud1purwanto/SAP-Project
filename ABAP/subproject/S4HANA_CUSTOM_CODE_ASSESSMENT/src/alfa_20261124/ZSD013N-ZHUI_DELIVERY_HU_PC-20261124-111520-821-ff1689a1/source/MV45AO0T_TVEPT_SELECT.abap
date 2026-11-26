*---------------------------------------------------------------------*e
*       MODULE TVEPT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Einteilungstypentext                                    *
*---------------------------------------------------------------------*
MODULE TVEPT_SELECT OUTPUT.

  PERFORM TVEPT_SELECT USING VBEP-ETTYP
                             SPACE
                             SY-SUBRC.

ENDMODULE.