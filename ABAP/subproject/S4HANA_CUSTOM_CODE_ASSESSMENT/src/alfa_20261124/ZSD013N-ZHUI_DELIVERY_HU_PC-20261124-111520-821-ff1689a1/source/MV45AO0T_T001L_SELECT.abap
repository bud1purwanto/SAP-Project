*eject.
*---------------------------------------------------------------------*
*       MODULE T001L_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen des Lagertextes                                         *
*---------------------------------------------------------------------*
MODULE T001L_SELECT OUTPUT.

  PERFORM T001L_SELECT USING VBAP-WERKS
                             VBAP-LGORT
                    CHANGING SY-SUBRC.
  IF SY-SUBRC NE 0.
    SET CURSOR FIELD 'VBAP-LGORT' LINE SY-STEPL.
    MESSAGE E366 WITH VBAP-LGORT
                      VBAP-WERKS.
  ENDIF.

ENDMODULE.