*---------------------------------------------------------------------*
*       FORM CONTAINER_IMPORT                                         *
*---------------------------------------------------------------------*
*       In Zusammenhang mit Funktionsbaustein                         *
*       SD_ORDER_CREATE_DIALOG werden bei VA01 etc. Daten aus dem     *
*       Memory importiert.                                            *
*---------------------------------------------------------------------*
FORM container_import.

  DATA da_subrc.
  data  da_no_dialog type c.

  if call_bapi = charx.
     call function 'DIALOG_GET_STATUS'
        importing
           dialog_status = da_no_dialog.
     if da_no_dialog is initial .
        dialog_bapi = charx.
     endif.
  endif.

  CLEAR dialog_processed.
  CLEAR dialog_check.

  IF sy-calld NE space.
    IF i_vbakkom IS INITIAL.

      IMPORT i_vbakkom   i_vbakkomx
             ix_vbapkom  ix_vbapkomx
             ix_vbepkom  ix_vbepkomx
             ix_vbpakom
             ix_komfkzm
             ix_konvkom  ix_konvkomx
             sales_cfgs_ref
             sales_cfgs_inst
             sales_cfgs_part_of
             sales_cfgs_value
             sales_cfgs_blob
             i_vbakkom_ref
             partneraddresses
             synchronous
             i_posnr
             message_type
             FROM MEMORY ID container_sales_doc
                  IGNORING STRUCTURE BOUNDARIES.
      da_subrc = sy-subrc.

      IF da_subrc = 0 AND
         NOT i_vbakkom IS INITIAL.
        IF t180-trtyp = charh.
          vbak-auart = i_vbakkom-auart.

          IF NOT i_vbakkom-vkorg IS INITIAL.
            vbak-vkorg = i_vbakkom-vkorg.
          ENDIF.
          IF NOT i_vbakkom-vtweg IS INITIAL.
            vbak-vtweg = i_vbakkom-vtweg.
          ENDIF.
          IF NOT i_vbakkom-spart IS INITIAL.
            vbak-spart = i_vbakkom-spart.
          ENDIF.
          IF NOT i_vbakkom-vkbur IS INITIAL.
            vbak-vkbur = i_vbakkom-vkbur.
          ENDIF.
          IF NOT i_vbakkom-vkgrp IS INITIAL.
            vbak-vkgrp = i_vbakkom-vkgrp.
          ENDIF.
        ELSE.
          vbak-vbeln = i_vbakkom-vbeln.
        ENDIF.
      ENDIF.
    ELSE.
      CLEAR: display_text_popup,
             suppress_av_dialog.
    ENDIF.
* dialog will be processed, use VBAK data for
* order creation instead of I_VBAKKOM
    IF da_subrc = 0 AND i_vbakkom-auart IS INITIAL.
      dialog_processed = charx.
    ENDIF.

  ENDIF.

ENDFORM.                    "CONTAINER_IMPORT