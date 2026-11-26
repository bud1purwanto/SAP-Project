FUNCTION z_idoc_input_ztrn_po.
*"----------------------------------------------------------------------
*" Latihan IDoc inbound - interface standar FM input IDoc
*"  IMPORTING
*"     VALUE(INPUT_METHOD) LIKE  BDWFAP_PAR-INPUTMETHD
*"     VALUE(MASS_PROCESSING) LIKE  BDWFAP_PAR-MASS_PROC
*"  EXPORTING
*"     VALUE(WORKFLOW_RESULT) LIKE  BDWFAP_PAR-RESULT
*"     VALUE(APPLICATION_VARIABLE) LIKE  BDWFAP_PAR-APPL_VAR
*"     VALUE(IN_UPDATE_TASK) LIKE  BDWFAP_PAR-UPDATETASK
*"     VALUE(CALL_TRANSACTION_DONE) LIKE  BDWFAP_PAR-CALLTRANS
*"  TABLES
*"      IDOC_CONTRL STRUCTURE  EDIDC
*"      IDOC_DATA STRUCTURE  EDIDD
*"      IDOC_STATUS STRUCTURE  BDIDOCSTAT
*"      RETURN_VARIABLES STRUCTURE  BDWFRETVAR
*"      SERIALIZATION_INFO STRUCTURE  BDI_SER
*"----------------------------------------------------------------------
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
          APPEND ls_log TO lt_log.            "tampung dulu, tulis setelah valid
      ENDCASE.
    ENDLOOP.

* Validasi dulu, baru tulis DB: IDoc error tidak boleh meninggalkan data
    IF lv_err IS INITIAL.
      MODIFY ztrn_po_log FROM TABLE lt_log.   "tabel Z milik latihan
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
ENDFUNCTION.
