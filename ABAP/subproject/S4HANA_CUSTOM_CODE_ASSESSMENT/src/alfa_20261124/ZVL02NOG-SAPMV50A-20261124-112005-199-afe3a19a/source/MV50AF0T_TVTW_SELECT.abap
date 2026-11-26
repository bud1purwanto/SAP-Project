*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVTW_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVTW_SELECT                                              *
*---------------------------------------------------------------------*
*       Vertriebsweg und zugehörigen Text lesen                       *
*---------------------------------------------------------------------*
FORM tvtw_select USING ts_vtweg LIKE tvtw-vtweg
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_vtweg NE tvtw-vtweg.

  IF ts_vtweg EQ space.
    CLEAR: tvtw, tvtwt.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM tvtw WHERE vtweg EQ ts_vtweg.
  IF sy-subrc NE 0.
    CLEAR: tvtw, tvtwt.
    IF ts_error NE space.
      MESSAGE e314 WITH ts_vtweg.
    ELSE.
      ts_subrc = 4.
      EXIT.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM tvtwt WHERE spras EQ sy-langu
                               AND vtweg EQ ts_vtweg.
  IF sy-subrc NE 0.
    ts_subrc = 0.
    CLEAR:  tvtwt.
  ENDIF.

ENDFORM.                    "TVTW_SELECT
*eject