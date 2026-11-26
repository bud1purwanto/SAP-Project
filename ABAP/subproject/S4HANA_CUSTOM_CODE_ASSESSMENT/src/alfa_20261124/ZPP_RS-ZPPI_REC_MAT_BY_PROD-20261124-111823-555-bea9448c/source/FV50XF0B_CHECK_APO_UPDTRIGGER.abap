*&---------------------------------------------------------------------*
*&  Include           FV50XF0B_CHECK_APO_UPDTRIGGER                    *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  FORM CHECK_APO_UPDTRIGGER                                          *
*&---------------------------------------------------------------------*

FORM check_apo_updtrigger
  USING
    iv_vbeln TYPE vbeln_vl
    iv_posnr TYPE posnr_vl
  CHANGING
    ev_update TYPE xfeld.

* This FORM checks if any non-requirement relevant change has been done
* that requires an update to APO. The update is mainly needed for TP/VS
* which requires some of the header and item fields for planning (see
* also FV50XF0B_SHIP_INFO_TO_ATPFIELD).
* The update can also be triggered according to customer logic.

* There are two different calls for this FORM:
* - If iv_posnr is empty the check is only done on header level
* - If iv_posnr is filled the check is done on item level

  STATICS: d_dlv_check_apo_upd TYPE REF TO dlv_check_apo_upd.

  IF d_dlv_check_apo_upd IS INITIAL.
    TRY.
        GET BADI d_dlv_check_apo_upd.
      CATCH cx_badi_not_implemented.
    ENDTRY.
  ENDIF.

  CLEAR ev_update.
  IF iv_posnr IS INITIAL.
*   Check header changes
    READ TABLE ylikp WITH KEY vbeln = iv_vbeln.
    IF sy-subrc IS INITIAL.
      IF xlikp-inco1 NE ylikp-inco1 OR
         xlikp-inco2 NE ylikp-inco2 OR
         xlikp-vsbed NE ylikp-vsbed OR
         xlikp-lprio NE ylikp-lprio OR
         xlikp-vstel NE ylikp-vstel OR
         xlikp-route NE ylikp-route OR
         xlikp-autlf NE ylikp-autlf OR
         xlikp-lifsk NE ylikp-lifsk OR
         xlikp-btgew NE ylikp-btgew OR
         xlikp-gewei NE ylikp-gewei OR
         xlikp-volum NE ylikp-volum OR
         xlikp-voleh NE ylikp-voleh OR
         xlikp-lfdat NE ylikp-lfdat OR
         xlikp-lfuhr NE ylikp-lfuhr.
*     header fields relevant for TP/VS
        ev_update = gc_true.
      ENDIF.
    ENDIF.
*   Check status changes
    READ TABLE xvbuk WITH KEY vbeln = iv_vbeln.
    READ TABLE yvbuk WITH KEY vbeln = iv_vbeln.
    IF sy-subrc IS INITIAL.
      IF xvbuk-trsta NE yvbuk-trsta.
        ev_update = gc_true.
      ENDIF.
    ENDIF.

* Call BAdI
    IF NOT d_dlv_check_apo_upd IS INITIAL AND
           ev_update           IS INITIAL.
      CALL BADI d_dlv_check_apo_upd->check_apo_updtrigger
        EXPORTING
          iv_vbeln  = iv_vbeln
          iv_posnr  = iv_posnr
          xlikp     = xlikp
          ylikp     = ylikp
          xvbuk     = xvbuk
          yvbuk     = yvbuk
          xlips     = xlips
          ylips     = ylips
        CHANGING
          ev_update = ev_update.
    ENDIF.

  ELSE.
*   Check item changes
    READ TABLE ylips
       WITH KEY vbeln = iv_vbeln
                posnr = iv_posnr.
    IF sy-subrc IS INITIAL.
      IF xlips-uebto NE ylips-uebto OR
         xlips-untto NE ylips-untto.
        ev_update = gc_true.
      ENDIF.
    ENDIF.

* Call BAdI
    IF NOT d_dlv_check_apo_upd IS INITIAL AND
           ev_update           IS INITIAL.
      CALL BADI d_dlv_check_apo_upd->check_apo_updtrigger
        EXPORTING
          iv_vbeln  = iv_vbeln
          iv_posnr  = iv_posnr
          xlikp     = xlikp
          ylikp     = ylikp
          xvbuk     = xvbuk
          yvbuk     = yvbuk
          xlips     = xlips
          ylips     = ylips
        CHANGING
          ev_update = ev_update.
    ENDIF.
  ENDIF.

ENDFORM.                    "check_apo_updtrigger