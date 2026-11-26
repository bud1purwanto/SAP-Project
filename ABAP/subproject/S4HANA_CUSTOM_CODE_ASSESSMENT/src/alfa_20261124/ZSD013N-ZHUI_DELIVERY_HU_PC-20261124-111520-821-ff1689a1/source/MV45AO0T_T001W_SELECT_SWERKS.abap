*eject.
*---------------------------------------------------------------------*
*       MODULE T001W_SELECT_SWERKS.                                   *
*---------------------------------------------------------------------*
*       Lesen des Werkstextes                                         *
*---------------------------------------------------------------------*
MODULE T001W_SELECT_SWERKS OUTPUT.

  PERFORM T001W_SELECT USING RV45A-S_WERKS
                             SPACE
                             SY-SUBRC.

ENDMODULE.