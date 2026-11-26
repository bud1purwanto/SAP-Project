
*---------------------------------------------------
*------------------*
*       FORM FCODE_HECO                                               *
*---------------------------------------------------
*------------------*
*       Compress header on overview screen                            *
*---------------------------------------------------
*------------------*
FORM FCODE_HECO.
  IF HEADER_DETAIL_COUNTER > 0 AND HEADER_DETAIL_COUNTER < 7.
    HEADER_DETAIL_COUNTER = HEADER_DETAIL_COUNTER - 1.
    CASE HEADER_DETAIL_COUNTER.

      WHEN '0'.                        " header detail line 2
        HEADER_DETAIL_SCREEN = '4800'.

      WHEN '1'.                        " header detail line 4
        HEADER_DETAIL_SCREEN = '4801'.

      WHEN '2'.                        " header detail line 6
        HEADER_DETAIL_SCREEN = '4802'.

      WHEN '3'.                         " header detail line 8
        HEADER_DETAIL_SCREEN = '4803'.

      WHEN '4'.                         " header detail line 10
        HEADER_DETAIL_SCREEN = '4804'.

      WHEN '5'.                          " header detail line 12
        HEADER_DETAIL_SCREEN = '4805'.

      WHEN '6'.                          " header detail line 14
        HEADER_DETAIL_SCREEN = '4806'.
    ENDCASE.

  ENDIF.

ENDFORM.