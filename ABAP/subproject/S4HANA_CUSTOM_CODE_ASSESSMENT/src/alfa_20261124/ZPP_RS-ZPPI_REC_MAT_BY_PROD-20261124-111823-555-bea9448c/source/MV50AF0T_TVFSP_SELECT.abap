*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVFSP_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVFSP_SELECT                                             *
*---------------------------------------------------------------------*
*       Fakturasperre und zugehörigen Text lesen                      *
*       Aus Performacegründen wird nur Tabelle TVFST gelesen          *
*---------------------------------------------------------------------*
FORM tvfsp_select USING ts_faksp LIKE tvfst-faksp
                        ts_error TYPE c
                        ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_faksp NE tvfst-faksp.

  IF ts_faksp = space.
    CLEAR: tvfst.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM tvfst WHERE spras = sy-langu
                               AND faksp = ts_faksp.
  IF sy-subrc NE 0.
    CLEAR: tvfst.
    ts_subrc = 0.
    IF ts_error NE space.
      SET CURSOR FIELD 'LIKP-FAKSP'.
      MESSAGE e390 WITH ts_faksp.
    ELSE.
      ts_subrc = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    "TVFSP_SELECT
*eject