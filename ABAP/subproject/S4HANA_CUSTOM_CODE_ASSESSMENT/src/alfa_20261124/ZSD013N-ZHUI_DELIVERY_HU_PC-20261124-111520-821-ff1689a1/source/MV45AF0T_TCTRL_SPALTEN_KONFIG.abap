*&---------------------------------------------------------------------*
*&      Form  TCTRL_SPALTEN_KONFIG.
*&---------------------------------------------------------------------*
*       Im Tablecontrol werden bestimmte Spalten angepaßt.
*----------------------------------------------------------------------*
FORM tctrl_spalten_konfig TABLES us_column STRUCTURE tctrl_column
                          USING us_name
                                us_invisible
                                us_vislength.

  READ TABLE us_column
             WITH KEY screen-name = us_name.
  IF sy-subrc = 0.
    us_column-invisible = us_invisible.
    IF not us_vislength is initial.
      us_column-vislength     = us_vislength.
    Else.
      us_column-vislength     = us_column-screen-length.
    ENDIF.
    MODIFY us_column INDEX sy-tabix.
  ENDIF.

ENDFORM.