*---------------------------------------------------------------------*
*       MODULE TVROT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen der Route                                               *
*---------------------------------------------------------------------*
MODULE TVROT_SELECT OUTPUT.

  PERFORM TVROT_SELECT USING VBAP-ROUTE
                             SPACE
                             SY-SUBRC.

ENDMODULE.