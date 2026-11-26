*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T30C_SELECT                                       *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  T30C_SELECT
*&---------------------------------------------------------------------*
*       Text zu Bereitstellungszone im Lager
*----------------------------------------------------------------------*
FORM t30c_select USING ts_lgnum LIKE t30c-lgnum
                       ts_lgbzo LIKE t30c-lgbzo
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_lgnum NE t30c-lgnum  OR
         ts_lgbzo NE t30c-lgbzo.

  IF ts_lgnum = space   OR
     ts_lgbzo = space.
    CLEAR: t30c, t30ct.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM t30c WHERE lgnum = ts_lgnum  AND
                                  lgbzo = ts_lgbzo.
  IF sy-subrc NE 0.
    CLEAR: t30c, t30ct.
    IF ts_error NE space.
      SET CURSOR FIELD 'LIKP-LGBZO'.
      MESSAGE e398 WITH ts_lgbzo ts_lgnum.
    ELSE.
      ts_subrc = 4.
      EXIT.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM t30ct WHERE spras = sy-langu
                               AND lgnum = ts_lgnum
                               AND lgbzo = ts_lgbzo.
  IF sy-subrc NE 0.
    CLEAR:  t30ct.
    ts_subrc = 0.
  ENDIF.

ENDFORM.                               " T30C_SELECT