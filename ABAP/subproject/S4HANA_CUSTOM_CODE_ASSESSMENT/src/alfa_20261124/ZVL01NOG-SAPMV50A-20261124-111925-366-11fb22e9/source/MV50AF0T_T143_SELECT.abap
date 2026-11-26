*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T143_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM T143_SELECT                                              *
*---------------------------------------------------------------------*
*       Temperaturbedingung                                           *
*       aus Tuninggründen wird nur die Texttabelle gelesen            *
*---------------------------------------------------------------------*
FORM t143_select USING ts_tempb LIKE t143t-tempb
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_tempb NE t143t-tempb.

  IF ts_tempb EQ space.
    CLEAR: t143t.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM t143t WHERE spras EQ sy-langu
                               AND tempb EQ ts_tempb.

  IF sy-subrc NE 0.
    ts_subrc = 0.
    CLEAR t143t.
  ENDIF.

ENDFORM.                    "T143_SELECT
*eject