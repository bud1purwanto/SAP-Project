REPORT ztrain_idoc_in_mock.
TYPES: BEGIN OF ztrn_e1pohdr,
         ebeln(10) TYPE c, bsart(4) TYPE c, lifnr(10) TYPE c,
         bedat(8) TYPE c, waers(5) TYPE c,
       END OF ztrn_e1pohdr,
       BEGIN OF ztrn_e1poitm,
         ebelp(5) TYPE c, matnr(18) TYPE c, txz01(40) TYPE c,
         menge(17) TYPE c, meins(3) TYPE c, netwr(17) TYPE c,
       END OF ztrn_e1poitm.
TYPES: BEGIN OF ztrn_po_log,
         docnum TYPE edi_docnum, ebeln TYPE ebeln, ebelp TYPE ebelp,
         matnr TYPE matnr, menge(17) TYPE c, erdat TYPE sy-datum,
         erzet TYPE sy-uzeit,
       END OF ztrn_po_log.
DATA: gt_log TYPE STANDARD TABLE OF ztrn_po_log.
FORM z_idoc_input_ztrn_po
  TABLES idoc_contrl STRUCTURE edidc
         idoc_data STRUCTURE edidd
         idoc_status STRUCTURE bdidocstat
         return_variables STRUCTURE bdwfretvar
         serialization_info STRUCTURE bdi_ser
  USING input_method LIKE bdwfap_par-inputmethd
        mass_processing LIKE bdwfap_par-mass_proc
  CHANGING workflow_result LIKE bdwfap_par-result
           application_variable LIKE bdwfap_par-appl_var
           in_update_task LIKE bdwfap_par-updatetask
           call_transaction_done LIKE bdwfap_par-calltrans.
  DATA: ls_hdr TYPE ztrn_e1pohdr,
        ls_itm TYPE ztrn_e1poitm,
        ls_log TYPE ztrn_po_log,
        lt_log TYPE STANDARD TABLE OF ztrn_po_log,
        lv_err TYPE c.

  LOOP AT idoc_contrl.
    CLEAR: lv_err, lt_log, ls_hdr.
    LOOP AT idoc_data WHERE docnum = idoc_contrl-docnum.
      CASE idoc_data-segnam.
        WHEN 'ZTRN_E1POHDR'.
          ls_hdr = idoc_data-sdata.
          IF ls_hdr-ebeln IS INITIAL.
            lv_err = 'X'.
          ENDIF.
        WHEN 'ZTRN_E1POITM'.
          ls_itm = idoc_data-sdata.
          CLEAR ls_log.
          ls_log-docnum = idoc_contrl-docnum.
          ls_log-ebeln  = ls_hdr-ebeln.
          ls_log-ebelp  = ls_itm-ebelp.
          ls_log-matnr  = ls_itm-matnr.
          ls_log-menge  = ls_itm-menge.
          ls_log-erdat  = sy-datum.
          ls_log-erzet  = sy-uzeit.
          APPEND ls_log TO lt_log.
      ENDCASE.
    ENDLOOP.

    IF lv_err IS INITIAL.
      APPEND LINES OF lt_log TO gt_log.
    ENDIF.

    CLEAR idoc_status.
    idoc_status-docnum = idoc_contrl-docnum.
    IF lv_err = 'X'.
      idoc_status-status = '51'.              "error -> bisa diproses ulang BD87
      idoc_status-msgty  = 'E'.
      idoc_status-msgid  = '00'.
      idoc_status-msgno  = '398'.
      idoc_status-msgv1  = 'Nomor PO kosong di segmen header'.
      workflow_result    = '99999'.
    ELSE.
      idoc_status-status = '53'.              "sukses diposting
      idoc_status-msgty  = 'S'.
      idoc_status-msgid  = '00'.
      idoc_status-msgno  = '398'.
      idoc_status-msgv1  = 'PO'.
      idoc_status-msgv2  = ls_hdr-ebeln.
      idoc_status-msgv3  = 'tercatat di ZTRN_PO_LOG'.
      workflow_result    = '0'.
    ENDIF.
    APPEND idoc_status.

    return_variables-wf_param = 'Processed_IDOCs'.
    return_variables-doc_number = idoc_contrl-docnum.
    APPEND return_variables.
  ENDLOOP.
ENDFORM.
