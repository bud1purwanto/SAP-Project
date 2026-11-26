*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T001K_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM T001K_SELECT                                             *
*---------------------------------------------------------------------*
*       Bewertungskreis lesen                                         *
*---------------------------------------------------------------------*
FORM t001k_select USING ts_bwkey LIKE t001k-bwkey
                        ts_error TYPE c
                        ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_bwkey NE t001k-bwkey.

  IF ts_bwkey EQ space.
    CLEAR: t001k.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM t001k WHERE bwkey EQ ts_bwkey.

  IF sy-subrc NE 0.
    CLEAR t001k.
    IF ts_error EQ charx OR v50agl-sammelgang EQ charx.
      ts_subrc = sy-subrc.
*     internes Fehlerhandling
      PERFORM message_handling(sapmv50a) USING cvbap-posnr
                                               '319'
                                               'E'
                                               'VL'
                                                ts_bwkey
                                                space
                                                space
                                                space.
    ELSE.
*     externes Fehlerhandling
      ts_subrc = sy-subrc.
    ENDIF.
  ENDIF.

ENDFORM.                    "T001K_SELECT
*eject