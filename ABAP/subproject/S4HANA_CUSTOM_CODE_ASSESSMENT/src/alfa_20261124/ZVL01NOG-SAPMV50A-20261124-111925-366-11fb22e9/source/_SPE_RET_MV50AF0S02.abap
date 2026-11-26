*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_MV50AF0S02                              *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  spe_scem_delivery_update
*&---------------------------------------------------------------------*
*       Update delivery after receipt of messages from the SCEM
*       portal
*----------------------------------------------------------------------*
FORM spe_scem_delivery_update USING  is_delivery_update  TYPE /spe/ret_delivery_update
                                     it_delivery_lastloc TYPE /spe/ret_carr_del_t
                                     it_flow             TYPE ledspd_flow_t
                                     value(IT_DELIVERY_BATCH) type /SPE/BATCH_SPLJOI_T "v_XAN-SPM
                                     value(IT_DELIVERY_SERNR) type /SPE/SERNR_SPLJOI_T "^_XAN-SPM
                           CHANGING  cf_rcode TYPE sysubrc.

  DATA: lt_verko            TYPE vsep_t_verko,
        lt_verpo            TYPE vsep_t_verpo,
        lf_no_split         TYPE c,
        ls_flow             TYPE ledspd_flow,
        ls_delivery_lastloc TYPE LINE OF /spe/ret_carr_del_t,
        ls_delivery_update  TYPE /spe/ret_delivery_update.

* Any split deliveries?
  LOOP AT xlikp TRANSPORTING NO FIELDS
                WHERE updkz EQ 'I'.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
    lf_no_split = charx.
  ENDIF.

* update splitted and unchanged deliveries with new header information
  LOOP AT xlikp.

    IF NOT ( xlikp-updkz CA 'I ' OR lf_no_split EQ charx ).
      CONTINUE.
    ENDIF.

    slikp-tabix = sy-tabix.

    MOVE-CORRESPONDING xlikp TO likp.
    MOVE-CORRESPONDING xlikp TO likpd.                      "#EC ENHOK

* determine last loc flag for current delivery from internal table:
    IF lf_no_split = charx.
      READ TABLE it_delivery_lastloc INTO ls_delivery_lastloc
                                     WITH KEY delivery_number = xlikp-vbeln.
    ELSE.
* read split flow with new delivery to determine original document number
      READ TABLE it_flow INTO ls_flow
                               WITH KEY vbeln_new = likp-vbeln.
* get last lacation flag of corresponding original delivery
      READ TABLE it_delivery_lastloc INTO ls_delivery_lastloc
                               WITH KEY delivery_number = ls_flow-vbeln.
    ENDIF.
* last location flag of current delivery
    ls_delivery_update               = is_delivery_update.
    ls_delivery_update-last_location = ls_delivery_lastloc-spe_lst_int_locn.

    PERFORM spe_update_delivery_header USING    lt_verko
                                                lt_verpo
                                                ls_delivery_update
                                                IT_DELIVERY_BATCH[] "v_XAN-SPM
                                                IT_DELIVERY_SERNR[] "^_XAN-SPM
                                                CHANGING cf_rcode.
    IF cf_rcode NE 0.
      RETURN.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " spe_scem_delivery_update