*eject.
*&---------------------------------------------------------------------*
*&      Module  T605T_SELECT  OUTPUT                                   *
*&---------------------------------------------------------------------*
*       Lesen des Textes zur Geschäftsart                              *
*----------------------------------------------------------------------*
MODULE T605T_SELECT OUTPUT.

  PERFORM TVST_SELECT USING XVBAP-VSTEL
                            SPACE
                            SY-SUBRC.

  IF TVST-ALAND IS INITIAL OR NOT SY-SUBRC IS INITIAL.
    PERFORM T605T_SELECT USING VBAP-EXART
                               XVBAP-WERKS
                               XVBAP-WKLND
                               SY-SUBRC.
  ELSE.
    PERFORM T605T_SELECT USING VBAP-EXART
                               XVBAP-WERKS
                               TVST-ALAND
                               SY-SUBRC.
  ENDIF.
ENDMODULE.                             " T605T_SELECT  OUTPUT