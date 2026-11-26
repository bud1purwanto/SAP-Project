*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T001W_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM T001W_SELECT                                             *
*---------------------------------------------------------------------*
*       Werkstabelle lesen                                            *
*---------------------------------------------------------------------*
FORM t001w_select USING ts_werks LIKE t001w-werks
                        ts_error TYPE c
                        ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_werks NE t001w-werks.

  IF ts_werks EQ space.
    CLEAR: t001w.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM t001w WHERE werks EQ ts_werks.

  IF sy-subrc NE 0.
    CLEAR t001w.
    IF ts_error EQ charx OR v50agl-sammelgang EQ charx.
      ts_subrc = sy-subrc.
* internes Fehlerhandling
      PERFORM message_handling(sapmv50a) USING cvbap-posnr
                                               '326'
                                               'E'
                                               'VL'
                                                ts_werks
                                                space
                                                space
                                                space.
    ELSE.
* externes Fehlerhandling
      ts_subrc = sy-subrc.
    ENDIF.
  ENDIF.

ENDFORM.                    "T001W_SELECT
*eject