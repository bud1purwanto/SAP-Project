*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T683C_SELECT                                      *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  T683C_SELECT
*&---------------------------------------------------------------------*
*       Suchschema zur Chargenfindung ermitteln                        *
*----------------------------------------------------------------------*
FORM t683c_select USING ts_vkorg LIKE t683c-vkorg
                        ts_vtweg LIKE t683c-vtweg
                        ts_spart LIKE t683c-spart
                        ts_auart LIKE t683c-auart
                        ts_error TYPE c
                        ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_vkorg NE t683c-vkorg OR
         ts_vtweg NE t683c-vtweg OR
         ts_spart NE t683c-spart OR
         ts_auart NE t683c-auart.


  SELECT SINGLE * FROM t683c WHERE vkorg = ts_vkorg
                               AND vtweg = ts_vtweg
                               AND spart = ts_spart
                               AND auart = ts_auart.

  IF sy-subrc <> 0.
    CLEAR t683c.
    ts_subrc = sy-subrc.
    IF ts_error = charx.
*     internes Fehlerhandling
      PERFORM message_handling(sapmv50a) USING posnr_low
                                               '151'
                                               'E'
                                               'VL'
                                               ts_vkorg
                                               ts_vtweg
                                               ts_spart
                                               ts_auart.
    ENDIF.
  ENDIF.

ENDFORM.                               " T683C_SELECT