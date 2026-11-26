*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_LEBA                                        *
*----------------------------------------------------------------------*
FORM fcode_leba.

  DATA: lf_posnr LIKE lips-posnr,
        lf_posnr_text(6) TYPE c,
        lf_vbeln_text(10) TYPE c.

  FIELD-SYMBOLS: <ls_vbup> LIKE LINE OF xvbup.

  CASE taxi_screen_group.
    WHEN c_taxi_scrgrp_item.
      lf_posnr = gs_lips_main-posnr.
    WHEN c_taxi_scrgrp_batch.
      lf_posnr = gs_lips_chsp-posnr.
    WHEN OTHERS.
      lf_posnr = xlips-posnr.
  ENDCASE.

  READ TABLE xvbup ASSIGNING <ls_vbup>
                   WITH KEY vbeln = likp-vbeln
                            posnr = lf_posnr.
  CHECK sy-subrc EQ 0.
  IF <ls_vbup>-pdsta EQ space.
    WRITE lf_posnr   TO lf_posnr_text NO-ZERO.
    WRITE likp-vbeln TO lf_vbeln_text NO-ZERO.
    CONDENSE: lf_posnr_text, lf_vbeln_text.
    MESSAGE i678 WITH lf_posnr_text lf_vbeln_text.
    EXIT.
  ENDIF.

  CALL FUNCTION 'LE_POD_DISPLAY_ITEMS'
       EXPORTING
            if_vbeln               = likp-vbeln
            if_posnr               = lf_posnr
            if_vbtyp               = likp-vbtyp
       TABLES
            it_xlips               = xlips
       EXCEPTIONS
            no_delivery_item_found = 1
            no_pod_item_found      = 2
            OTHERS                 = 3.

  IF sy-subrc EQ 2.
    MESSAGE i731.
  ENDIF.

ENDFORM.