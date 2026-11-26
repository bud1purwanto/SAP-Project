*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T459A_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM T459A_SELECT                                             *
*---------------------------------------------------------------------*
*       Die Steuertabelle für die Bedarfsübergabe wird gelesen.       *
*---------------------------------------------------------------------*
FORM t459a_select USING ts_bedae LIKE t459a-bedae
                        ts_error TYPE c
                        ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_bedae NE t459a-bedae.

  IF ts_bedae EQ space.
    CLEAR t459a.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM t459a WHERE bedae EQ ts_bedae.
  IF sy-subrc NE 0.
    CLEAR t459a.
    ts_subrc = sy-subrc.
    IF ts_error EQ charx OR v50agl-sammelgang EQ charx.
* internes Fehlerhandling
      PERFORM message_handling(sapmv50a) USING cvbap-posnr
                                               '374'
                                               'E'
                                               'VL'
                                                ts_bedae
                                                space
                                                space
                                                space.
    ENDIF.
  ENDIF.

ENDFORM.                    "T459A_SELECT
*eject