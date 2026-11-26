*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T30BT_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM T30BT_SELECT                                             *
*---------------------------------------------------------------------*
*       Text zu Tor ermitteln                                         *
*---------------------------------------------------------------------*
FORM t30bt_select USING i_lgnum LIKE t30bt-lgnum
                        i_lgtor LIKE t30bt-lgtor.

  CHECK i_lgnum NE t30bt-lgnum OR
        i_lgtor NE t30bt-lgtor.

  SELECT SINGLE * FROM t30bt WHERE spras = sy-langu AND
                                   lgnum = i_lgnum AND
                                   lgtor = i_lgtor.

  IF sy-subrc NE 0.
    CLEAR t30bt.
  ENDIF.

ENDFORM.                    "T30BT_SELECT