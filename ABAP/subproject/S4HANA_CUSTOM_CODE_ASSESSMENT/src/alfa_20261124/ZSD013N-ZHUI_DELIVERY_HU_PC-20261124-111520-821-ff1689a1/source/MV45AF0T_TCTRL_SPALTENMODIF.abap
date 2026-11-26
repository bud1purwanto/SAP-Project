*&---------------------------------------------------------------------*
*&      Form  TCTRL_SPALTENMODIF.
*&---------------------------------------------------------------------*
*       Im Tablecontrol werden bestimmte Spalten ausgeblendet.
*----------------------------------------------------------------------*
FORM TCTRL_SPALTENMODIF TABLES US_COLUMN STRUCTURE TCTRL_COLUMN
                        USING US_NAME
                              US_INVISIBLE.

  READ TABLE US_COLUMN
             WITH KEY SCREEN-NAME = US_NAME.
  IF SY-SUBRC = 0.
    US_COLUMN-INVISIBLE = US_INVISIBLE.
    MODIFY US_COLUMN INDEX SY-TABIX.
  ENDIF.

ENDFORM.