*&---------------------------------------------------------------------*
*&  Include           MV45AILO_LORD_LPAYSP_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LORD_LPAYSP_SET_PROVIDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lord_lpaysp_set_provider .
  DATA: lf_prov_changed TYPE abap_bool.

  IF vbak-sppaym EQ cv_sppaym01.
    gr_paysp = cl_sls_paysp_integration=>get_instance(
      iv_read_only = 'X' ).
    IF gr_paysp IS BOUND.
*     Set Provider
      CALL METHOD gr_paysp->set_provider
        EXPORTING
          iv_document_id   = vbak-vbeln
          iv_provider      = gs_lpaysp_data-ps_provider
        IMPORTING
          ef_prov_changed  = lf_prov_changed
        EXCEPTIONS
          provider_invalid = 1
          OTHERS           = 2.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        message_collect_lord.
      ENDIF.
*     if the provider has been changed a pricing should be triggered
*      to allow determination of provider specific conditions
      IF lf_prov_changed EQ abap_true.
        PERFORM preisfindung_gesamt USING charc.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " LORD_LPAYSP_SET_PROVIDER

*&---------------------------------------------------------------------*
*&      Form  LORD_REVOKE_PAYSP_REL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lord_revoke_paysp_rel .

  PERFORM vbak_bearbeiten_vorbereiten IN PROGRAM sapfv45k.

  IF vbak-sppaym EQ cv_sppaym01.
    CLEAR: vbak-sppaym.
*   the refresh of sppaym will trigger the initiation of PAYSP data
    PERFORM vbak_bearbeiten IN PROGRAM sapfv45k.
*   in case the revoke could be carried out sppaym is still empty and
*     a new pricing has to be triggered
    IF vbak-sppaym IS INITIAL.
      PERFORM preisfindung_gesamt USING charc.
    ENDIF.
  ENDIF.

ENDFORM.                    " LORD_REVOKE_PAYSP_REL

*&---------------------------------------------------------------------*
*&      Form  LORD_PAYSP_UPDATE_FROM_CONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lord_paysp_update_from_cont USING ur_data.

  DATA: ls_paysp_hl     TYPE paysp_hl,
        ls_paysp_hl_old TYPE paysp_hl.

  DATA: lf_data_changed TYPE flag,
        lv_msgtxt       TYPE string.

  gr_paysp = cl_sls_paysp_integration=>get_instance( ).
  IF gr_paysp IS BOUND.
*   Call Integration Class
    CALL METHOD gr_paysp->update_from_container
      EXPORTING
        iv_document_id     = vbak-vbeln
      IMPORTING
        ev_data_changed    = lf_data_changed
      EXCEPTIONS
        change_not_allowed = 1
        provider_invalid   = 2
        empty_container    = 3
        OTHERS             = 4.

    IF sy-subrc <> 0.
      ur_data = charx.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                INTO lv_msgtxt.
      message_collect_lord.
    ENDIF.

    IF lf_data_changed EQ abap_true.
      r185d-dataloss = 'X'.
      IF vbak-xblnr IS INITIAL.
*     Check wheter XBLNR should be set
        CALL METHOD gr_paysp->get_data_single
          EXPORTING
            iv_document_id  = vbak-vbeln
          IMPORTING
            es_paysp_hl     = ls_paysp_hl
            es_paysp_hl_old = ls_paysp_hl_old.

        IF NOT ls_paysp_hl-reference_id     IS INITIAL AND
               ls_paysp_hl_old-reference_id IS INITIAL.
          vbak-xblnr = ls_paysp_hl-reference_id.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.


ENDFORM.                    " LORD_PAYSP_UPDATE_FROM_CONT