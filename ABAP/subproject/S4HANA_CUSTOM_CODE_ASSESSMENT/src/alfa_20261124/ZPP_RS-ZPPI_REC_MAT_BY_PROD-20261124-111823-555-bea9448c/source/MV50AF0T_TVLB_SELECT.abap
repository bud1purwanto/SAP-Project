*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVLB_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVLB_SELECT                                              *
*---------------------------------------------------------------------*
*       Versandbedingung und Text lesen                               *
*---------------------------------------------------------------------*
FORM tvsb_select USING ts_vsbed LIKE tvsb-vsbed
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_vsbed NE tvsb-vsbed.

  IF ts_vsbed = space.
    CLEAR: tvsb, tvsbt.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM tvsb WHERE vsbed = ts_vsbed.
  IF sy-subrc NE 0.
    CLEAR: tvsb, tvsbt.
    IF ts_error NE space.
      SET CURSOR FIELD 'LIKP-VSBED'.
      MESSAGE e389 WITH ts_vsbed.
    ELSE.
      ts_subrc = 4.
      EXIT.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM tvsbt WHERE spras = sy-langu
                               AND vsbed = ts_vsbed.
  IF sy-subrc NE 0.
    ts_subrc = 0.
    CLEAR:  tvsbt.
  ENDIF.

ENDFORM.                    "TVSB_SELECT
*eject