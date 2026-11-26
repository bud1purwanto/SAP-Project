*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVCPL_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVCPL_SELECT                                             *
*---------------------------------------------------------------------*
*       Kopiertabelle lesen                                           *
*---------------------------------------------------------------------*
FORM tvcpl_select USING ts_lfarn LIKE tvcpl-lfarn
                        ts_auarv LIKE tvcpl-auarv
                        ts_pstyv LIKE tvcpl-pstyv
                        ts_error TYPE c
                        ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_lfarn NE tvcpl-lfarn OR
         ts_auarv NE tvcpl-auarv OR
         ts_pstyv NE tvcpl-pstyv.

  IF ts_lfarn EQ space AND
     ts_auarv EQ space AND
     ts_pstyv EQ space.
    CLEAR: tvcpl.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM tvcpl WHERE lfarn EQ ts_lfarn AND
                                   auarv EQ ts_auarv AND
                                   pstyv EQ ts_pstyv.

  IF sy-subrc NE 0.
    CLEAR tvcpl.
    ts_subrc = sy-subrc.
    IF ts_error EQ charx.
* internes Fehlerhandling
      PERFORM message_handling(sapmv50a) USING cvbap-posnr
                                               '473'
                                               'E'
                                               'VL'
                                               ts_auarv
                                               ts_lfarn
                                               ts_pstyv
                                               space.
    ENDIF.
  ENDIF.

ENDFORM.                    "TVCPL_SELECT