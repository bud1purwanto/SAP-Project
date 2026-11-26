*----------------------------------------------------------------------*
*   INCLUDE MV45AI0F_FAUF_STATUS_MAINTAIN                              *
*----------------------------------------------------------------------*
MODULE FAUF_STATUS_MAINTAIN.
  IF NOT VBEP-AUFNR IS INITIAL.
    PERFORM FAUF_STATUS_MAINTAIN(SAPFV45E) USING VBEP-AUFNR.
  ENDIF.
  FCODE = FCODE_GLEICHE_SEITE.
ENDMODULE.