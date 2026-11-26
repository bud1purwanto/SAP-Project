*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVKOV_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVKOV_SELECT                                             *
*---------------------------------------------------------------------*
*       Umschluesselung VTWEG gemaess Tabelle TVKOV                   *
*---------------------------------------------------------------------*
FORM tvkov_select USING ts_vkorg LIKE tvkov-vkorg
                        ts_vtweg LIKE tvkov-vtweg
                        ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_vkorg NE tvkov-vkorg OR
         ts_vtweg NE tvkov-vtweg.

  SELECT SINGLE * FROM tvkov WHERE vkorg EQ ts_vkorg
                             AND   vtweg EQ ts_vtweg.
  IF sy-subrc NE 0.
    ts_subrc = sy-subrc.
    CLEAR tvkov.
    PERFORM message_handling(sapmv50a) USING posnr_low
                                             '318'
                                             'E'
                                             'VL'
                                             ts_vkorg
                                             ts_vtweg
                                             space
                                             space.
  ENDIF.

ENDFORM.                    "TVKOV_SELECT
*eject