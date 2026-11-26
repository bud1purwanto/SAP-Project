
*---------------------------------------------------------------------*
*       FORM FCODE_ITCO                                               *
*---------------------------------------------------------------------*
*       Compress item on overview screen                               *
*---------------------------------------------------------------------*
FORM FCODE_ITCO.
  IF ITEM_DETAIL_COUNTER > 0 AND ITEM_DETAIL_COUNTER < 7.
    ITEM_DETAIL_COUNTER = ITEM_DETAIL_COUNTER - 1.
    CASE ITEM_DETAIL_COUNTER.

      WHEN '0'.                        " item detail line 2
        ITEM_DETAIL_SCREEN = '4800'.

      WHEN '1'.                        " item detail line 4
        ITEM_DETAIL_SCREEN = '4801'.

      WHEN '2'.                        " item detail line 6
        ITEM_DETAIL_SCREEN = '4802'.

      WHEN '3'.                        " item detail line 8
        ITEM_DETAIL_SCREEN = '4803'.

      WHEN '4'.                        " item detail line 10
        ITEM_DETAIL_SCREEN = '4804'.

      WHEN '5'.                        " item detail line 12
        ITEM_DETAIL_SCREEN = '4805'.

      WHEN '6'.                        " item detail line 14
        ITEM_DETAIL_SCREEN = '4806'.
    ENDCASE.

  ENDIF.
ENDFORM.