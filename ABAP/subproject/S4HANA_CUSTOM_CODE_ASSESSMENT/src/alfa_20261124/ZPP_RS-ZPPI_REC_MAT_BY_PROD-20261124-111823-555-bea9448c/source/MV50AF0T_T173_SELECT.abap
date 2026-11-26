*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T173_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM T173_SELECT                                              *
*---------------------------------------------------------------------*
*       Temperaturbedingung                                           *
*       aus Tuninggründen wird nur die Texttabelle gelesen            *
*---------------------------------------------------------------------*
FORM t173_select USING ts_vsart LIKE t173t-vsart
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_vsart NE t173t-vsart.

  IF ts_vsart EQ space.
    CLEAR: t173t.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM t173t WHERE spras EQ sy-langu
                               AND vsart EQ ts_vsart.

  IF sy-subrc NE 0.
    ts_subrc = 0.
    CLEAR t173t.
  ENDIF.

ENDFORM.                    "T173_SELECT