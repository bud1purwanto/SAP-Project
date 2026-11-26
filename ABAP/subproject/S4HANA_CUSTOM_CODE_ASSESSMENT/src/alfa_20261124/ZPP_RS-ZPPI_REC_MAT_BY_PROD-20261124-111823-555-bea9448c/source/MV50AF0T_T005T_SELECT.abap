*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T005T_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM T005t_SELECT                                             *
*---------------------------------------------------------------------*
*       Länderbezeichnung lesen                                       *
*---------------------------------------------------------------------*
FORM t005t_select USING ts_land1 LIKE t005t-land1
                        ts_error TYPE c
                        ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_land1 NE t005t-land1.

  IF ts_land1 = space.
    CLEAR: t005t.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM t005t WHERE spras = sy-langu
                               AND land1 = ts_land1.

  IF sy-subrc NE 0.
    ts_subrc = sy-subrc.
    CLEAR: t005t.
    IF ts_error EQ charx OR v50agl-sammelgang EQ charx.
      PERFORM message_handling(sapmv50a) USING cvbap-posnr
                                               '279'
                                               'I'
                                               'VL'
                                                ts_land1
                                                sy-langu
                                                space
                                                space.

    ENDIF.
  ENDIF.

ENDFORM.                    "T005T_SELECT
*eject