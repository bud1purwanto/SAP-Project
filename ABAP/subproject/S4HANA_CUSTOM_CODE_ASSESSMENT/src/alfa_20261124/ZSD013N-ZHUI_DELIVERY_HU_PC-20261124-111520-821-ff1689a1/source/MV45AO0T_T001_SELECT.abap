*eject.
*---------------------------------------------------------------------*
*       MODULE T001_SELECT                                            *
*---------------------------------------------------------------------*
*       Lesen des Buchungskreises                                     *
*---------------------------------------------------------------------*
MODULE T001_SELECT OUTPUT.

  IF VBAK-BUKRS_VF IS INITIAL.
    PERFORM T001_SELECT USING TVKO-BUKRS
                              SPACE
                              SY-SUBRC.
  ELSE.
    PERFORM T001_SELECT USING VBAK-BUKRS_VF
                              SPACE
                              SY-SUBRC.
  ENDIF.

ENDMODULE.