*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVLA_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVLA_SELECT                                              *
*---------------------------------------------------------------------*
*       Ladestelle   und zugehörigen Text lesen                       *
*---------------------------------------------------------------------*
FORM tvla_select USING ts_vstel LIKE tvla-vstel
                       ts_lstel LIKE tvla-lstel
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_lstel NE tvla-lstel  OR
         ts_vstel NE tvla-vstel.

  IF ts_lstel = space   OR
     ts_vstel = space.
    CLEAR: tvla, tvlat.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM tvla WHERE lstel = ts_lstel  AND
                                  vstel = ts_vstel.
  IF sy-subrc NE 0.
    CLEAR: tvla, tvlat.
    IF ts_error NE space.
      SET CURSOR FIELD 'LIKP-LSTEL'.
      MESSAGE e391 WITH ts_lstel.
    ELSE.
      ts_subrc = 4.
      EXIT.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM tvlat WHERE spras = sy-langu
                               AND vstel = ts_vstel
                               AND lstel = ts_lstel.
  IF sy-subrc NE 0.
    CLEAR:  tvlat.
    ts_subrc = 0.
  ENDIF.

ENDFORM.                    "TVLA_SELECT
*eject