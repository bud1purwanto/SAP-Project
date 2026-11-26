*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVAK_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVAK_SELECT                                              *
*---------------------------------------------------------------------*
*       Auftragsartentabelle lesen                                    *
*       aus dieser Tabelle stammt der Vorschlag der Lieferart         *
*---------------------------------------------------------------------*
FORM tvak_select USING ts-auart LIKE tvak-auart.

  CHECK: ts-auart NE tvak-auart.
  CHECK: ts-auart NE space.                                 "HP_372843

  SELECT SINGLE * FROM tvak WHERE auart EQ ts-auart.

  IF sy-subrc NE 0.
    CLEAR tvak.
    PERFORM message_handling(sapmv50a) USING posnr_low
                                             '312'
                                             'E'
                                             'VL'
                                             ts-auart
                                             space
                                             space
                                             space.
  ENDIF.

ENDFORM.                    "tvak_select
*eject