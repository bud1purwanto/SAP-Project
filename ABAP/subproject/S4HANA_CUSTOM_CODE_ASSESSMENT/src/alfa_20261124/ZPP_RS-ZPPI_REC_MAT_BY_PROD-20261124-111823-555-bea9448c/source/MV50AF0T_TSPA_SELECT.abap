*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TSPA_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TSPA_SELECT                                              *
*---------------------------------------------------------------------*
*       Sparte und zugehörigen Text lesen                             *
*---------------------------------------------------------------------*
FORM tspa_select USING ts_spart LIKE tspa-spart
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_spart NE tspa-spart.

  IF ts_spart EQ space.
    CLEAR: tspa, tspat.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM tspa WHERE spart EQ ts_spart.
  IF sy-subrc NE 0.
    CLEAR: tspa, tspat.
    IF ts_error NE space.
      MESSAGE e315 WITH ts_spart.
    ELSE.
      ts_subrc = 4.
      EXIT.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM tspat WHERE spras EQ sy-langu
                               AND spart EQ ts_spart.
  IF sy-subrc NE 0.
    ts_subrc = 0.
    CLEAR:  tspat.
  ENDIF.

ENDFORM.                    "TSPA_SELECT
*eject