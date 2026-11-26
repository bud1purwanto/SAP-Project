*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVST_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVST_SELECT                                              *
*---------------------------------------------------------------------*
*       Versandstelle und zugehörigen Text lesen                      *
*---------------------------------------------------------------------*
FORM tvst_select USING ts_vstel LIKE tvst-vstel
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_vstel NE tvst-vstel.

  IF ts_vstel EQ space.
    CLEAR: tvst, tvstt.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM tvst WHERE vstel EQ ts_vstel.
  IF sy-subrc NE 0.
    CLEAR: tvst, tvstt.
    IF ts_error = charx.
      MESSAGE e100 WITH ts_vstel.
      EXIT.
    ELSE.
      ts_subrc = sy-subrc.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM tvstt WHERE spras EQ sy-langu
                               AND vstel EQ ts_vstel.
  IF sy-subrc NE 0.
    ts_subrc = 0.
    CLEAR: tvstt.
  ENDIF.

ENDFORM.                    "TVST_SELECT
*eject