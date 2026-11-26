*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T30B_SELECT                                       *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  T30B_SELECT
*&---------------------------------------------------------------------*
*       Text zu Toren im Lager
*----------------------------------------------------------------------*
FORM t30b_select USING ts_lgnum LIKE t30bt-lgnum
                       ts_lgtor LIKE t30bt-lgtor
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_lgnum NE t30b-lgnum  OR
         ts_lgtor NE t30b-lgtor.

  IF ts_lgnum = space   OR
     ts_lgtor = space.
    CLEAR: t30b, t30bt.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM t30b WHERE lgnum = ts_lgnum  AND
                                  lgtor = ts_lgtor.
  IF sy-subrc NE 0.
    CLEAR: t30b, t30bt.
    IF ts_error NE space.
      SET CURSOR FIELD 'LIKP-LGTOR'.
      MESSAGE e397 WITH ts_lgtor ts_lgnum.
    ELSE.
      ts_subrc = 4.
      EXIT.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM t30bt WHERE spras = sy-langu
                               AND lgnum = ts_lgnum
                               AND lgtor = ts_lgtor.
  IF sy-subrc NE 0.
    CLEAR:  t30bt.
    ts_subrc = 0.
  ENDIF.

ENDFORM.                               " T30B_SELECT