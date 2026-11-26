*----------------------------------------------------------------------*
*   INCLUDE FV50XF0K_KORR_CHECK_CHP_COLLEC                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  KORR_CHECK_CHP_COLLECT
*&---------------------------------------------------------------------*
*       Sammeln von Chargenhauptpositionen, um später gesammelt
*       alle zugehörigen Chargensplitpositionen verarbeiten (löschen) zu
*       können
*----------------------------------------------------------------------*
FORM KORR_CHECK_CHP_COLLECT TABLES CT_ITEMS TYPE VLKOR_T_ITEMS
                            USING  IS_LIPS  TYPE VLKOR_S_XLIPS.
  IF IS_LIPS-XCHAR NE SPACE.
   CT_ITEMS-OPTION = 'EQ'.
   CT_ITEMS-SIGN   = 'I'.
   CT_ITEMS-LOW    = IS_LIPS-POSNR.
   CT_ITEMS-HIGH   = SPACE.
   COLLECT CT_ITEMS.
 ENDIF.
ENDFORM.                    " KORR_CHECK_CHP_COLLECT