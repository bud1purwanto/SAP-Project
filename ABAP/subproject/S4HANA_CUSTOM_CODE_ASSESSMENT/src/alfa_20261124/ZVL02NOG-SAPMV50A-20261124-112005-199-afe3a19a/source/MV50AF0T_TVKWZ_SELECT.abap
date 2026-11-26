*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVKWZ_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVKWZ_SELECT                                             *
*---------------------------------------------------------------------*
*       Verkaufsorganisationen-Werke-Zuordnung prüfen                 *
*---------------------------------------------------------------------*
FORM tvkwz_select USING us_vkorg LIKE tvkwz-vkorg
                        us_vtweg LIKE tvkwz-vtweg
                        us_werks LIKE tvkwz-werks
                        us_error TYPE c
                        ch_subrc LIKE sy-subrc.

  ch_subrc = 0.
  CHECK: us_vkorg NE tvkwz-vkorg OR
         us_vtweg NE tvkwz-vtweg OR
         us_werks NE tvkwz-werks.

  SELECT SINGLE * FROM tvkwz WHERE vkorg = us_vkorg
                               AND vtweg = us_vtweg
                               AND werks = us_werks.

  IF sy-subrc NE 0.
    CLEAR tvkwz.
    IF us_error = charx OR v50agl-sammelgang EQ charx.
      ch_subrc = sy-subrc.
      PERFORM message_handling(sapmv50a) USING cvbap-posnr
                                               '026'
                                               'E'
                                               'VL'
                                                us_vkorg
                                                us_vtweg
                                                us_werks
                                                space.
    ELSE.
*     externes Fehlerhandling
      ch_subrc = sy-subrc.
    ENDIF.
  ENDIF.

ENDFORM.                    "TVKWZ_SELECT
*eject