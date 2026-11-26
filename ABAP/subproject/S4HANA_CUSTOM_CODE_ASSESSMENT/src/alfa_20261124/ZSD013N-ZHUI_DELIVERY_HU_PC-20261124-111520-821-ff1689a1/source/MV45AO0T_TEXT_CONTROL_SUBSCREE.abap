*----------------------------------------------------------------------*
*   INCLUDE MV45AO0T_TEXT_CONTROL_SUBSCREE                             *
*----------------------------------------------------------------------*

MODULE TEXT_CONTROL_SUBSCREEN_PBO OUTPUT.

  IF NOT TVAK-TDID IS INITIAL.
    TEXT_CONTROL_DYNNR = 4952.
  ELSE.
    TEXT_CONTROL_DYNNR = 4951.
  ENDIF.

ENDMODULE.