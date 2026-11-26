*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVLG_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVLG_SELECT                                              *
*---------------------------------------------------------------------*
*       Gewichtsgruppe der Lieferung und zugehöriger Text             *
*---------------------------------------------------------------------*
FORM tvlg_select USING ts_grulg LIKE tvlgt-grulg
                       ts_error TYPE c
                       ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_grulg NE tvlgt-grulg.

  IF ts_grulg = space.
    CLEAR:  tvlgt.
    EXIT.
  ENDIF.


  SELECT SINGLE * FROM tvlgt WHERE spras = sy-langu
                               AND grulg = ts_grulg.
  IF sy-subrc NE 0.
    ts_subrc = 0.
    CLEAR:  tvlgt.
  ENDIF.

ENDFORM.                    "TVLG_SELECT
*eject