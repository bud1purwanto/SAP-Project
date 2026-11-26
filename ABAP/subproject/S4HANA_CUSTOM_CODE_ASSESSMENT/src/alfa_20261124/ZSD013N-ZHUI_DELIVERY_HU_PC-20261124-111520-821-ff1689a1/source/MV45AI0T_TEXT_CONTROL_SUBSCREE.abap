*----------------------------------------------------------------------*
*   INCLUDE MV45AI0T_TEXT_CONTROL_SUBSCREE                             *
*----------------------------------------------------------------------*

MODULE TEXT_CONTROL_SUBSCREEN_PAI INPUT.

  IF NOT TVAK-TDID IS INITIAL.
    TEXT_CONTROL_DYNNR = 4950.
  ELSE.
    TEXT_CONTROL_DYNNR = 0.
  ENDIF.

ENDMODULE.