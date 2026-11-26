*---------------------------------------------------------------------*
*       FORM FCODE_ITEX                                               *
*---------------------------------------------------------------------*
*       Expand item on overview screen                                *
*---------------------------------------------------------------------*
FORM FCODE_ITEX.
  IF ITEM_DETAIL_COUNTER >= 0 AND ITEM_DETAIL_COUNTER < 6.
    ITEM_DETAIL_COUNTER = ITEM_DETAIL_COUNTER + 1.
    CASE ITEM_DETAIL_COUNTER.

      WHEN '0'.                        " item detail line 2
        ITEM_DETAIL_SCREEN = '4800'.

      WHEN '1'.                        " item detail line 4
        ITEM_DETAIL_SCREEN = '4801'.

      WHEN '2'.                        " item detail line 4
        ITEM_DETAIL_SCREEN = '4802'.

      WHEN '3'.
        ITEM_DETAIL_SCREEN = '4803'.

      WHEN '4'.
        ITEM_DETAIL_SCREEN = '4804'.

      WHEN '5'.
        ITEM_DETAIL_SCREEN = '4805'.


      WHEN '6'.
        ITEM_DETAIL_SCREEN = '4806'.
    ENDCASE.

  ENDIF.

ENDFORM.