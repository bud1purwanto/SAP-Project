REPORT ztrain_po_print.
* Latihan SmartForms - driver mini untuk form ZTRN_PO_SIMPLE

PARAMETERS: p_ebeln TYPE ekko-ebeln OBLIGATORY,
            p_form  TYPE tdsfname DEFAULT 'ZTRN_PO_SIMPLE'.

DATA: gs_ekko   TYPE ekko,
      gt_ekpo   TYPE STANDARD TABLE OF ekpo,
      gv_name   TYPE lfa1-name1,
      gv_fm     TYPE rs38l_fnam,
      gs_ctrl   TYPE ssfctrlop,
      gs_outopt TYPE ssfcompop.

START-OF-SELECTION.
  SELECT SINGLE * FROM ekko INTO gs_ekko WHERE ebeln = p_ebeln.
  IF sy-subrc <> 0.
    MESSAGE 'PO tidak ditemukan' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  SELECT * FROM ekpo INTO TABLE gt_ekpo
    WHERE ebeln = p_ebeln AND loekz = space.
  SELECT SINGLE name1 FROM lfa1 INTO gv_name
    WHERE lifnr = gs_ekko-lifnr.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = p_form
    IMPORTING
      fm_name            = gv_fm
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
    MESSAGE 'SmartForm tidak ditemukan' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  gs_ctrl-preview   = 'X'.
  gs_ctrl-no_dialog = 'X'.
  gs_outopt-tddest  = 'LP01'.

  CALL FUNCTION gv_fm
    EXPORTING
      control_parameters = gs_ctrl
      output_options     = gs_outopt
      is_ekko            = gs_ekko
      iv_vendor_name     = gv_name
    TABLES
      it_ekpo            = gt_ekpo
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
  ENDIF.
