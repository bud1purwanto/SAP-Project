*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVTA_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVTA_SELECT                                              *
*---------------------------------------------------------------------*
*       Verkaufsbereiche lesen                                        *
*---------------------------------------------------------------------*
FORM tvta_select USING ts_vkorg LIKE tvta-vkorg
                       ts_vtweg LIKE tvta-vtweg
                       ts_spart LIKE tvta-spart.

  CHECK: ts_vkorg NE tvta-vkorg OR
         ts_vtweg NE tvta-vtweg OR
         ts_spart NE tvta-spart.

  SELECT SINGLE * FROM tvta WHERE vkorg EQ ts_vkorg
                            AND   vtweg EQ ts_vtweg
                            AND   spart EQ ts_spart.
  IF sy-subrc NE 0.
    CLEAR tvta.
    PERFORM message_handling(sapmv50a) USING cvbap-posnr
                                             '316'
                                             'E'
                                             'VL'
                                              ts_vkorg
                                              ts_vtweg
                                              ts_spart
                                              space.
  ENDIF.

ENDFORM.                    "TVTA_SELECT
*eject