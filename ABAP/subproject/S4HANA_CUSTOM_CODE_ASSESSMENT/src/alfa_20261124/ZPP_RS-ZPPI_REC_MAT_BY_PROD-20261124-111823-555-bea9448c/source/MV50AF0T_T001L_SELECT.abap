*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T001L_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM T001L_SELECT                                             *
*---------------------------------------------------------------------*
*       Lagertabelle lesen                                            *
*---------------------------------------------------------------------*
FORM t001l_select USING ts_werks LIKE t001l-werks
                        ts_lgort LIKE t001l-lgort
                        ts_error TYPE c
                        ts_subrc LIKE sy-subrc.

  ts_subrc = 0.

  CHECK: ts_werks NE t001l-werks OR
         ts_lgort NE t001l-lgort.

  IF ts_lgort = space.
    CLEAR: t001l.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM t001l WHERE werks = ts_werks
                               AND lgort = ts_lgort.

  IF sy-subrc NE 0.
    CLEAR t001l.
    IF ts_error EQ charx.
      SET CURSOR FIELD 'LIPS-LGORT' LINE sy-stepl.
      MESSAGE e366 WITH ts_lgort
                        ts_werks.
    ELSE.
      ts_subrc = sy-subrc.
    ENDIF.
  ENDIF.

ENDFORM.                    "T001L_SELECT
*eject