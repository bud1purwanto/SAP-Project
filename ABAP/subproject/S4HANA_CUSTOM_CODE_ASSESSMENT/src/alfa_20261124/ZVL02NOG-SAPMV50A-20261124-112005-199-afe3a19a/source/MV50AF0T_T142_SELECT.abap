*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T142_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM T142_SELECT                                              *
*---------------------------------------------------------------------*
*       Raumbedingung lesen                                           *
*       aus Tuninggründen wird nur die Texttabelle gelesen            *
*---------------------------------------------------------------------*
FORM t142_select USING ts_raube LIKE t142t-raube
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_raube NE t142t-raube.

  IF ts_raube EQ space.
    CLEAR: t142t.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM t142t WHERE spras EQ sy-langu
                               AND raube EQ ts_raube.

  IF sy-subrc NE 0.
    ts_subrc = 0.
    CLEAR t142t.
  ENDIF.

ENDFORM.                    "T142_SELECT
*eject