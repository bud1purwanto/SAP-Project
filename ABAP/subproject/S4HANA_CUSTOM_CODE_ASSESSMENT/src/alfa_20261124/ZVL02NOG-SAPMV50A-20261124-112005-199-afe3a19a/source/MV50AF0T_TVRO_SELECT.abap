*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVRO_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVRO_SELECT                                              *
*---------------------------------------------------------------------*
*       Route lesen                                                   *
*---------------------------------------------------------------------*
FORM tvro_select USING ts_route LIKE tvro-route
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_route NE tvro-route.

  IF ts_route = space.
    CLEAR: tvro, tvrot.
    EXIT.
  ENDIF.

* generischer zugriff
  SELECT SINGLE * FROM tvro WHERE route = ts_route.

  IF sy-subrc NE 0.
    CLEAR: tvro, tvrot.
    IF ts_error = charx.
* internes Fehlerhandling
      SET CURSOR FIELD 'LIKP-ROUTE'.
      MESSAGE e388 WITH ts_route.
    ELSE.
* externes Fehlerhandling
      ts_subrc = sy-subrc.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM tvrot WHERE spras = sy-langu
                               AND route = ts_route.

  IF sy-subrc NE 0.
    ts_subrc = 0.
    CLEAR: tvrot.
  ENDIF.

ENDFORM.                    "TVRO_SELECT
*eject