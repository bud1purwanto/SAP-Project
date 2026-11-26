*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_MV50AF0S01                              *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  spe_ich_delivery_update
*&---------------------------------------------------------------------*
*       Update delivery after receipt of messages from the ICH
*       portal
*----------------------------------------------------------------------*
FORM spe_ich_delivery_update  TABLES   it_vbpok           STRUCTURE vbpok
                              USING    value(it_verko)    TYPE vsep_t_verko
                                       value(it_verpo)    TYPE vsep_t_verpo
                                       is_delivery_update TYPE /spe/ret_delivery_update
                                       value(it_delivery_batch) TYPE /spe/batch_spljoi_t "v_XAN-SPM
                                       value(it_delivery_sernr) TYPE /spe/sernr_spljoi_t "^_XAN-SPM
                              CHANGING cf_rcode           TYPE sysubrc.

  DATA: lf_complete           TYPE c,
        ls_vbpok              TYPE vbpok,
        lf_no_lfimg_check_all TYPE c,
        lf_msgtxt             TYPE c.

* Update confirmed deliveries with partner and packing data and new status
  LOOP AT xlikp WHERE updkz EQ updkz_new.

    slikp-tabix = sy-tabix.

    MOVE-CORRESPONDING xlikp TO likp.
    MOVE-CORRESPONDING xlikp TO likpd.                      "#EC ENHOK

    PERFORM spe_update_delivery_header USING    it_verko
                                                it_verpo
                                                is_delivery_update
                                                it_delivery_batch[] "v_XAN-SPM
                                                it_delivery_sernr[] "^_XAN-SPM
                                       CHANGING cf_rcode.
    IF cf_rcode NE 0.
      RETURN.
    ENDIF.

  ENDLOOP.

* No new delivery found in internal tables?
  IF sy-subrc NE 0.
*   ASN refers to complete original delivery or ASN cancels original delivery
    lf_complete = charx.
  ENDIF.

  LOOP AT xlikp WHERE updkz CA ' U'.

    slikp-tabix = sy-tabix.

    MOVE-CORRESPONDING xlikp TO likp.
    MOVE-CORRESPONDING xlikp TO likpd.                      "#EC ENHOK
    PERFORM likp_bearbeiten_vorbereiten(sapfv50k).

*   Close completed items
    LOOP AT xlips WHERE vbeln EQ xlikp-vbeln
                    AND updkz NE updkz_delete.
      ilips-tabix = sy-tabix.
      slips-tabix = sy-tabix.
      READ TABLE it_vbpok INTO ls_vbpok
                          WITH KEY spe_auth_number = xlips-spe_auth_number.
      CHECK sy-subrc EQ 0.
* MP close RMA if no lfimg is left
      IF ls_vbpok-spe_auth_complet NE space or
         xlips-lfimg               EQ 0.

        lf_no_lfimg_check_all = v50agl-no_lfimg_check_all.
        v50agl-no_lfimg_check_all = charx.

*       Set completion indicator and set delivery quantity to zero
        PERFORM lips_bearbeiten_vorbereiten(sapfv50p).
        lips-lfimg = 0.
        lips-lgmng = 0.
        lips-lfimg_flo = 0.
        lips-lgmng_flo = 0.
        lips-spe_auth_complet = charx.
        PERFORM lips_bearbeiten(sapfv50p).

        v50agl-no_lfimg_check_all = lf_no_lfimg_check_all.

      ENDIF.
    ENDLOOP.
    PERFORM likp_bearbeiten(sapfv50k).
*   Convert original delivery to a confirmed one
*    if lf_complete ne space.
*      perform spe_update_delivery_header using    it_verko
*                                                  it_verpo
*                                                  is_delivery_update
*                                         changing cf_rcode.
*      if cf_rcode ne 0.
*        return.
*      endif.
*    endif.

  ENDLOOP.

ENDFORM.                    " spe_ich_delivery_update