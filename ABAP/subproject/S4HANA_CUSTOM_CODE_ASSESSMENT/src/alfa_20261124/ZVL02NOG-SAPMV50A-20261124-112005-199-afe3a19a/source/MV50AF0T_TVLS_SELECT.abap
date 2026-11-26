*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVLS_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVLS_SELECT                                              *
*---------------------------------------------------------------------*
*       Liefersperre und zugehörigen Text lesen                       *
*---------------------------------------------------------------------*
FORM tvls_select USING ts_lifsp LIKE tvls-lifsp
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_lifsp NE tvls-lifsp.

  IF ts_lifsp = space.
    CLEAR: tvls, tvlst.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM tvls WHERE lifsp = ts_lifsp.
  IF sy-subrc NE 0.
    CLEAR: tvls, tvlst.
    IF ts_error NE space.
      SET CURSOR FIELD 'LIKP-LIFSP'.
      MESSAGE e387 WITH ts_lifsp.
    ELSE.
      ts_subrc = 4.
      EXIT.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM tvlst WHERE spras = sy-langu
                               AND lifsp = ts_lifsp.
  IF sy-subrc NE 0.
    ts_subrc = 0.
    CLEAR: tvlst.
  ENDIF.

ENDFORM.                    "TVLS_SELECT
*eject