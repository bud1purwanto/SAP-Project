*eject.
*---------------------------------------------------------------------*
*       MODULE T001W_SELECT_DWERK                                     *
*---------------------------------------------------------------------*
*       Lesen des Werkstextes                                         *
*---------------------------------------------------------------------*
MODULE T001W_SELECT_DWERK OUTPUT.

  PERFORM T001W_SELECT USING RV45A-DWERK
                             SPACE
                             SY-SUBRC.
ENDMODULE.