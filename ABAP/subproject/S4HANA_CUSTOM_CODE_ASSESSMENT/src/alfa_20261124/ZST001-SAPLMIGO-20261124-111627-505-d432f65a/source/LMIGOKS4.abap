*----------------------------------------------------------------------*
*   INCLUDE LMIGOKS4                                                   *
*   Routines for screen modification
*----------------------------------------------------------------------*

************************************************************************
* Disabling of fields depending on the MIGO_MODE.
* Called each time the MIGO_MODE has been changed
************************************************************************
METHOD screen_modify_mode.
  DATA: lt_fields     TYPE ty_t_fieldname,
        ls_bwa_fields TYPE tys_migo_move_fields,
        lt_bwa_fields TYPE tyt_migo_move_fields,
        l_fieldname   TYPE migo_fieldname.

ENHANCEMENT-POINT screen_modify_mode_40 SPOTS es_saplmigo STATIC.
  CALL METHOD lcl_migo_screenmodification=>restore
    EXPORTING
      i_mode           = abap_true
      i_global_counter = 0.
  CALL METHOD lcl_migo_screenmodification=>restore
    EXPORTING
      i_mode           = abap_true
      i_global_counter = lcl_migo_screenmodification=>c_item_template.
* CANCEL/DISPLAY: set all visible, after that set specified fields input
  IF s_action-display = abap_true OR s_action-cancel = abap_true.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_inversion      = abap_true
        i_mode           = abap_true
        it_fields        = lcl_migo_screenmodification=>t_buttons
        i_status         = lcl_migo_screenmodification=>c_visible
        i_global_counter = lcl_migo_screenmodification=>c_item_template.
*   Set header input fields to visible only in display/cancel
    CLEAR lt_fields.
    APPEND 'GOHEAD-CREATE_DELIVERY' TO lt_fields.
    APPEND 'GOHEAD-FRBNR'           TO lt_fields.
    APPEND 'GOHEAD-LFSNR'           TO lt_fields.
    APPEND 'GOHEAD-MTSNR'           TO lt_fields.
    APPEND 'GOHEAD-XABLN'           TO lt_fields.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        it_fields        = lt_fields
        i_mode           = abap_true
        i_global_counter = 0
        i_status         = lcl_migo_screenmodification=>c_visible.
    IF s_action-display = abap_true.
*     specified 'input'-fields for DISPLAY
      CALL METHOD lcl_migo_screenmodification=>set
        EXPORTING
          i_fields         = 'GOITEM-ZEILE'
          i_mode           = abap_true
          i_global_counter = lcl_migo_screenmodification=>c_item_template
          i_status         = lcl_migo_screenmodification=>c_input.
      CALL METHOD lcl_migo_screenmodification=>set
        EXPORTING
          i_fields         = 'GODYNPRO-DETAIL_TAKE'
          i_mode           = abap_true
          i_global_counter = lcl_migo_screenmodification=>c_item_template
          i_status         = lcl_migo_screenmodification=>c_invisible.
*     button for docubatch detail always enabled if active for item
      CALL METHOD lcl_migo_screenmodification=>set
        EXPORTING
          i_fields         = 'OK_DOC_BATCH_DETAIL'
          i_mode           = abap_true
          i_global_counter = lcl_migo_screenmodification=>c_item_template
          i_status         = lcl_migo_screenmodification=>c_input.
*     BUDAT/BLDAT/BKTXT as visible in display mode only
      CLEAR lt_fields.
      APPEND 'GOHEAD-BKTXT' TO lt_fields.
      APPEND 'GOHEAD-BLDAT' TO lt_fields.
ENHANCEMENT-POINT screen_modify_mode_01 SPOTS es_saplmigo.
      APPEND 'GOHEAD-BUDAT' TO lt_fields.
      CALL METHOD lcl_migo_screenmodification=>set
        EXPORTING
          it_fields        = lt_fields
          i_mode           = abap_true
          i_global_counter = 0
          i_status         = lcl_migo_screenmodification=>c_visible.
    ELSE.
*     specified 'input'-fields for CANCEL
      CLEAR lt_fields.
      APPEND 'GODYNPRO-DETAIL_TAKE' TO lt_fields.
      APPEND 'GOITEM-GRUND'         TO lt_fields.
      APPEND 'GOITEM-MIGO_ELIKZ'    TO lt_fields.
      APPEND 'GOITEM-SGTXT'         TO lt_fields.
      APPEND 'GOITEM-TAKE_IT'       TO lt_fields.
      APPEND 'GOITEM-ZEILE'         TO lt_fields.
      APPEND 'GOITEM-KZEAR'         TO lt_fields.
      CALL METHOD lcl_migo_screenmodification=>set
        EXPORTING
          it_fields        = lt_fields
          i_mode           = abap_true
          i_global_counter = lcl_migo_screenmodification=>c_item_template
          i_status         = lcl_migo_screenmodification=>c_input.
    ENDIF.
  ENDIF.
* Checkbox create_delivery only in return case
  IF s_action-return = abap_false.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_fields         = 'GOHEAD-CREATE_DELIVERY'
        i_mode           = abap_true
        i_global_counter = 0
        i_status         = lcl_migo_screenmodification=>c_invisible.
  ENDIF.

* Global deactivations
  CLEAR lt_fields.
  CASE s_action-migo_mode.
*---GR for purchase order
    WHEN 'GR'.
      APPEND 'GOITEM-EQUNR'     TO lt_fields.
*     Order fields
      APPEND 'GOITEM-ELIKZ_ORD' TO lt_fields.
      APPEND 'GOITEM-PPS_AUFNR' TO lt_fields.
      APPEND 'GOITEM-PPS_POSNR' TO lt_fields.
*     Reservation fields
      APPEND 'GOITEM-BDMNG'     TO lt_fields.
      APPEND 'GOITEM-BDTER'     TO lt_fields.
      APPEND 'GOITEM-ENMNG'     TO lt_fields.
      APPEND 'GOITEM-KZEAR'     TO lt_fields.
      APPEND 'GOITEM-MEINS_RES' TO lt_fields.
      APPEND 'GOITEM-RSNUM'     TO lt_fields.
      APPEND 'GOITEM-RSPOS'     TO lt_fields.
      APPEND 'GOITEM-SC_ADJUST' TO lt_fields.
ENHANCEMENT-POINT lmigoks4_09 SPOTS es_saplmigo.
      APPEND 'GOITEM-VMENG'     TO lt_fields.
*     Transfer fields
      APPEND 'GOITEM-UMBAR'     TO lt_fields.
      APPEND 'GOITEM-UMCHA'     TO lt_fields.
      APPEND 'GOITEM-UMHSDAT'   TO lt_fields.
      APPEND 'GOITEM-UMLGO'     TO lt_fields.
      APPEND 'GOITEM-UMLGOBE'   TO lt_fields.
      APPEND 'GOITEM-UMLGPBE'   TO lt_fields.
      APPEND 'GOITEM-UMMAKTX'   TO lt_fields.
      APPEND 'GOITEM-UMMAT'     TO lt_fields.
      APPEND 'GOITEM-UMMAT_CUSTNAME'   TO lt_fields.
      APPEND 'GOITEM-UMMAT_KDAUF'      TO lt_fields.
      APPEND 'GOITEM-UMMAT_KDPOS'      TO lt_fields.
      APPEND 'GOITEM-UMMAT_KUNNR'      TO lt_fields.
      APPEND 'GOITEM-UMMAT_LIFNR'      TO lt_fields.
      APPEND 'GOITEM-UMMAT_PSPNR'      TO lt_fields.
      APPEND 'GOITEM-UMMAT_VENDORNAME' TO lt_fields.
      APPEND 'GOITEM-UMNAME1'   TO lt_fields.
      APPEND 'GOITEM-UMSOK'     TO lt_fields.
      APPEND 'GOITEM-UMSOTXT'   TO lt_fields.
      APPEND 'GOITEM-UMVFDAT'   TO lt_fields.
      APPEND 'GOITEM-UMWRK'     TO lt_fields.
      APPEND 'GOITEM-UMZST'     TO lt_fields.

ENHANCEMENT-POINT screen_modify_mode_41 SPOTS es_saplmigo.
      APPEND 'OK_NEW_ITEMS'     TO lt_fields.
*---GI with or w/o reservation or order
    WHEN 'GI'.
*     Common fields PO/order
*     note 488001
*     Order fields cannot be supressed directly dependant on MIGO_MODE
*     due to confirmation postings with VGART = WR. In that case
*     MIGO_MODE is GI although item for GR for order may exist.
*     This is only relevant for displaying material document as
*     material documents with VGART = WR cannot be processed within
*     transaction MIGO except displaying such documents.
      IF s_action-display = abap_false.
        APPEND 'GOITEM-BSMNG'        TO lt_fields.
        APPEND 'GOITEM-BSTME'        TO lt_fields.
        APPEND 'GOITEM-ELIKZ_MATDOC' TO lt_fields.
        APPEND 'GOITEM-KNTTP'        TO lt_fields.
        APPEND 'GOITEM-MIGO_ELIKZ'   TO lt_fields.
        APPEND 'GOITEM-WEMNG'        TO lt_fields.
        APPEND 'GOITEM-ELIKZ_ORD'    TO lt_fields.
        APPEND 'GOITEM-PPS_AUFNR'    TO lt_fields.
        APPEND 'GOITEM-PPS_POSNR'    TO lt_fields.
      ENDIF.
*     PO fields except EBELN EBELP (customizable)
      IF s_control-action = 'A07' AND
         ( s_control-refdoc = 'R10' OR
           ( s_control-refdoc = 'R02' AND
             NOT s_action-copy IS INITIAL
           )
         ).
        APPEND 'GOITEM-EBELN'        TO lt_fields.
        APPEND 'GOITEM-EBELP'        TO lt_fields.
      ENDIF.
      APPEND 'GOITEM-AFNAM'        TO lt_fields.
      APPEND 'GOITEM-AKTNR'        TO lt_fields.
      APPEND 'GOITEM-BPMNG'        TO lt_fields.
      APPEND 'GOITEM-BPRME'        TO lt_fields.
      APPEND 'GOITEM-EAN11_BME'    TO lt_fields.
      APPEND 'GOITEM-EAN11_KON'    TO lt_fields.
      APPEND 'GOITEM-EANME'        TO lt_fields.
      APPEND 'GOITEM-ELIKZ_PO'     TO lt_fields.
      APPEND 'GOITEM-EMATN'        TO lt_fields.
      APPEND 'GOITEM-IDNLF'        TO lt_fields.
      APPEND 'GOITEM-INCO1'        TO lt_fields.
      APPEND 'GOITEM-INCO2'        TO lt_fields.
      APPEND 'GOITEM-LFBNR'        TO lt_fields.
      APPEND 'GOITEM-LICHA'        TO lt_fields.
      APPEND 'GOITEM-LLIEF'        TO lt_fields.
      APPEND 'GOITEM-LSMEH'        TO lt_fields.
      APPEND 'GOITEM-LSMNG'        TO lt_fields.
      APPEND 'GOITEM-MFRNAME'      TO lt_fields.
      APPEND 'GOITEM-MFRNR'        TO lt_fields.
*     note 839854
*     1-step-movements from STO-deliveries have VGART 'WL' and
*     MIGO_MODE 'GI', but contain a GR item -> display sending plant and
*     receiving vendor
      IF s_action-display = abap_false.                     "839854
        APPEND 'GOITEM-EMLIF'        TO lt_fields.
        APPEND 'GOITEM-RECVENDNAME'  TO lt_fields.
        APPEND 'GOITEM-RESWK'        TO lt_fields.
        APPEND 'GOITEM-RESWKNAME'    TO lt_fields.
      ENDIF.                                                "839854
      APPEND 'GOITEM-RETPO'        TO lt_fields.
      APPEND 'GOITEM-SC_ADJUST'    TO lt_fields.
ENHANCEMENT-POINT lmigoks4_10 SPOTS es_saplmigo.
      APPEND 'GOITEM-SUPVENDNAME'  TO lt_fields.
      APPEND 'GOITEM-WAMNG'        TO lt_fields.
      APPEND 'OK_CONTAINER'        TO lt_fields.
      APPEND 'OK_NOT_ORDERED'      TO lt_fields.

*     Transfer fields -> show with STO reference only   "577276 "1120712
      IF NOT s_control-refdoc = 'R01'.                      "1120712
        APPEND 'GOITEM-UMBAR'        TO lt_fields.
        APPEND 'GOITEM-UMCHA'        TO lt_fields.
        APPEND 'GOITEM-UMHSDAT'      TO lt_fields.
        APPEND 'GOITEM-UMLGO'        TO lt_fields.
        APPEND 'GOITEM-UMLGOBE'      TO lt_fields.
        APPEND 'GOITEM-UMLGPBE'      TO lt_fields.
        APPEND 'GOITEM-UMMAKTX'      TO lt_fields.
        APPEND 'GOITEM-UMMAT'        TO lt_fields.
        APPEND 'GOITEM-UMMAT_CUSTNAME'   TO lt_fields.
        APPEND 'GOITEM-UMMAT_KDAUF'      TO lt_fields.
        APPEND 'GOITEM-UMMAT_KDPOS'      TO lt_fields.
        APPEND 'GOITEM-UMMAT_KUNNR'      TO lt_fields.
        APPEND 'GOITEM-UMMAT_LIFNR'      TO lt_fields.
        APPEND 'GOITEM-UMMAT_PSPNR'      TO lt_fields.
        APPEND 'GOITEM-UMMAT_VENDORNAME' TO lt_fields.
        APPEND 'GOITEM-UMNAME1'      TO lt_fields.
        APPEND 'GOITEM-UMSOK'        TO lt_fields.
        APPEND 'GOITEM-UMSOTXT'      TO lt_fields.
        APPEND 'GOITEM-UMVFDAT'      TO lt_fields.
        APPEND 'GOITEM-UMWRK'        TO lt_fields.
        APPEND 'GOITEM-UMZST'        TO lt_fields.
      ENDIF.                                                "1120712

ENHANCEMENT-POINT screen_modify_mode_42 SPOTS es_saplmigo.
*---GR for production order
    WHEN 'GO'.
      APPEND 'GOITEM-EQUNR'       TO lt_fields.
      APPEND 'GOITEM-EXBWR'       TO lt_fields.
      APPEND 'GOITEM-EXVKW'       TO lt_fields.
      APPEND 'GOITEM-KONTO'       TO lt_fields.
*     PO fields except common fields PO/PP order
      APPEND 'GOITEM-AFNAM'       TO lt_fields.
      APPEND 'GOITEM-AKTNR'       TO lt_fields.
      APPEND 'GOITEM-BPMNG'       TO lt_fields.
      APPEND 'GOITEM-BPRME'       TO lt_fields.
      APPEND 'GOITEM-EAN11_BME'   TO lt_fields.
      APPEND 'GOITEM-EAN11_KON'   TO lt_fields.
      APPEND 'GOITEM-EANME'       TO lt_fields.
      APPEND 'GOITEM-EBELN'       TO lt_fields.
      APPEND 'GOITEM-EBELP'       TO lt_fields.
      APPEND 'GOITEM-ELIKZ_PO'    TO lt_fields.
      APPEND 'GOITEM-EMATN'       TO lt_fields.
      APPEND 'GOITEM-EMLIF'       TO lt_fields.
      APPEND 'GOITEM-IDNLF'       TO lt_fields.
      APPEND 'GOITEM-INCO1'       TO lt_fields.
      APPEND 'GOITEM-INCO2'       TO lt_fields.
      APPEND 'GOITEM-LFBNR'       TO lt_fields.
      APPEND 'GOITEM-LICHA'       TO lt_fields.
      APPEND 'GOITEM-LSMEH'       TO lt_fields.
      APPEND 'GOITEM-LSMNG'       TO lt_fields.
      APPEND 'GOITEM-MFRNR'       TO lt_fields.
      APPEND 'GOITEM-MFRNAME'     TO lt_fields.
      APPEND 'GOITEM-RECVENDNAME' TO lt_fields.
      APPEND 'GOITEM-RESWK'       TO lt_fields.
      APPEND 'GOITEM-RESWKNAME'   TO lt_fields.
      APPEND 'GOITEM-RETPO'       TO lt_fields.
      APPEND 'GOITEM-SC_ADJUST'   TO lt_fields.
ENHANCEMENT-POINT lmigoks4_11 SPOTS es_saplmigo.
      "$$
      APPEND 'GOITEM-SUPVENDNAME' TO lt_fields.
      APPEND 'GOITEM-WAMNG'       TO lt_fields.
      APPEND 'OK_CONTAINER'       TO lt_fields.
      APPEND 'OK_NOT_ORDERED'     TO lt_fields.
      APPEND 'OK_NEW_ITEMS'       TO lt_fields.
*     Reservation fields
      APPEND 'GOITEM-BDMNG'       TO lt_fields.
      APPEND 'GOITEM-BDTER'       TO lt_fields.
      APPEND 'GOITEM-ENMNG'       TO lt_fields.
      APPEND 'GOITEM-KZEAR'       TO lt_fields.
      APPEND 'GOITEM-MEINS_RES'   TO lt_fields.
      APPEND 'GOITEM-RSNUM'       TO lt_fields.
      APPEND 'GOITEM-RSPOS'       TO lt_fields.
      APPEND 'GOITEM-VMENG'       TO lt_fields.
*     Special stock fields not used in PP
      APPEND 'GOITEM-CUSTNAME'    TO lt_fields.
      APPEND 'GOITEM-KUNNR'       TO lt_fields.
      APPEND 'GOITEM-LIFNR'       TO lt_fields.
      APPEND 'GOITEM-VENDORNAME'  TO lt_fields.
*     Transfer fields
      APPEND 'GOITEM-UMBAR'       TO lt_fields.
      APPEND 'GOITEM-UMCHA'       TO lt_fields.
      APPEND 'GOITEM-UMHSDAT'     TO lt_fields.
      APPEND 'GOITEM-UMLGO'       TO lt_fields.
      APPEND 'GOITEM-UMLGOBE'     TO lt_fields.
      APPEND 'GOITEM-UMLGPBE'     TO lt_fields.
      APPEND 'GOITEM-UMMAKTX'     TO lt_fields.
      APPEND 'GOITEM-UMMAT'       TO lt_fields.
      APPEND 'GOITEM-UMMAT_CUSTNAME'   TO lt_fields.
      APPEND 'GOITEM-UMMAT_KDAUF'      TO lt_fields.
      APPEND 'GOITEM-UMMAT_KDPOS'      TO lt_fields.
      APPEND 'GOITEM-UMMAT_KUNNR'      TO lt_fields.
      APPEND 'GOITEM-UMMAT_LIFNR'      TO lt_fields.
      APPEND 'GOITEM-UMMAT_PSPNR'      TO lt_fields.
      APPEND 'GOITEM-UMMAT_VENDORNAME' TO lt_fields.
      APPEND 'GOITEM-UMNAME1'     TO lt_fields.
      APPEND 'GOITEM-UMSOK'       TO lt_fields.
      APPEND 'GOITEM-UMSOTXT'     TO lt_fields.
      APPEND 'GOITEM-UMVFDAT'     TO lt_fields.
      APPEND 'GOITEM-UMWRK'       TO lt_fields.
      APPEND 'GOITEM-UMZST'       TO lt_fields.
ENHANCEMENT-POINT screen_modify_mode_43 SPOTS es_saplmigo.
    WHEN 'GS'.
      APPEND 'GOITEM-EQUNR'     TO lt_fields.
*     Order fields
      APPEND 'GOITEM-ELIKZ_ORD' TO lt_fields.
      APPEND 'GOITEM-PPS_AUFNR' TO lt_fields.
      APPEND 'GOITEM-PPS_POSNR' TO lt_fields.
*     Reservation fields
      APPEND 'GOITEM-BDMNG'     TO lt_fields.
      APPEND 'GOITEM-BDTER'     TO lt_fields.
      APPEND 'GOITEM-ENMNG'     TO lt_fields.
      APPEND 'GOITEM-KZEAR'     TO lt_fields.
      APPEND 'GOITEM-MEINS_RES' TO lt_fields.
      APPEND 'GOITEM-RSNUM'     TO lt_fields.
      APPEND 'GOITEM-RSPOS'     TO lt_fields.
      APPEND 'GOITEM-VMENG'     TO lt_fields.
*     Transfer fields
      APPEND 'GOITEM-UMBAR'     TO lt_fields.
      APPEND 'GOITEM-UMCHA'     TO lt_fields.
      APPEND 'GOITEM-UMHSDAT'   TO lt_fields.
      APPEND 'GOITEM-UMLGO'     TO lt_fields.
      APPEND 'GOITEM-UMLGOBE'   TO lt_fields.
      APPEND 'GOITEM-UMLGPBE'   TO lt_fields.
      APPEND 'GOITEM-UMMAKTX'   TO lt_fields.
      APPEND 'GOITEM-UMMAT'     TO lt_fields.
      APPEND 'GOITEM-UMMAT_CUSTNAME'   TO lt_fields.
      APPEND 'GOITEM-UMMAT_KDAUF'      TO lt_fields.
      APPEND 'GOITEM-UMMAT_KDPOS'      TO lt_fields.
      APPEND 'GOITEM-UMMAT_KUNNR'      TO lt_fields.
      APPEND 'GOITEM-UMMAT_LIFNR'      TO lt_fields.
      APPEND 'GOITEM-UMMAT_PSPNR'      TO lt_fields.
      APPEND 'GOITEM-UMMAT_VENDORNAME' TO lt_fields.
      APPEND 'GOITEM-UMNAME1'   TO lt_fields.
      APPEND 'GOITEM-UMSOK'     TO lt_fields.
      APPEND 'GOITEM-UMSOTXT'   TO lt_fields.
      APPEND 'GOITEM-UMVFDAT'   TO lt_fields.
      APPEND 'GOITEM-UMWRK'     TO lt_fields.
      APPEND 'GOITEM-UMZST'     TO lt_fields.
ENHANCEMENT-POINT screen_modify_mode_44 SPOTS es_saplmigo.
*     Header fields
      APPEND 'GODYNPRO-PRINT_TEXT' TO lt_fields.
      APPEND 'GOHEAD-WEVER'        TO lt_fields.
      APPEND 'GOHEAD-XNAPR'        TO lt_fields.
      APPEND 'GOHEAD-FRBNR'        TO lt_fields.
*     Buttons
      APPEND 'OK_NEW_ITEMS'        TO lt_fields.
      APPEND 'OK_CONTAINER'        TO lt_fields.
      APPEND 'OK_NOT_ORDERED'      TO lt_fields.
      APPEND 'OK_EXPAND_BOM'       TO lt_fields.
      APPEND 'OK_GA_ADD_VARIANT'   TO lt_fields.
    WHEN 'GT'.
*     PO fields except common fields PO/PP order
      APPEND 'GOITEM-AFNAM'        TO lt_fields.
      APPEND 'GOITEM-AKTNR'        TO lt_fields.
      APPEND 'GOITEM-BPMNG'        TO lt_fields.
      APPEND 'GOITEM-BPRME'        TO lt_fields.
      APPEND 'GOITEM-EAN11_BME'    TO lt_fields.
      APPEND 'GOITEM-EAN11_KON'    TO lt_fields.
      APPEND 'GOITEM-EANME'        TO lt_fields.
      APPEND 'GOITEM-ELIKZ_PO'     TO lt_fields.
      APPEND 'GOITEM-EMATN'        TO lt_fields.
      APPEND 'GOITEM-EMLIF'        TO lt_fields.
      APPEND 'GOITEM-IDNLF'        TO lt_fields.
      APPEND 'GOITEM-INCO1'        TO lt_fields.
      APPEND 'GOITEM-INCO2'        TO lt_fields.
      APPEND 'GOITEM-LFBNR'        TO lt_fields.
      APPEND 'GOITEM-LICHA'        TO lt_fields.
      APPEND 'GOITEM-LLIEF'        TO lt_fields.
      APPEND 'GOITEM-LSMEH'        TO lt_fields.
      APPEND 'GOITEM-LSMNG'        TO lt_fields.
      APPEND 'GOITEM-MFRNR'        TO lt_fields.
      APPEND 'GOITEM-MFRNAME'      TO lt_fields.
      APPEND 'GOITEM-RECVENDNAME'  TO lt_fields.
      APPEND 'GOITEM-RESWK'        TO lt_fields.
      APPEND 'GOITEM-RESWKNAME'    TO lt_fields.
      APPEND 'GOITEM-RETPO'        TO lt_fields.
      APPEND 'GOITEM-SC_ADJUST'    TO lt_fields.
ENHANCEMENT-POINT lmigoks4_12 SPOTS es_saplmigo.
      "$$
      APPEND 'GOITEM-SUPVENDNAME'  TO lt_fields.
      APPEND 'GOITEM-WAMNG'        TO lt_fields.
      APPEND 'GOITEM-BSMNG'        TO lt_fields.
      APPEND 'GOITEM-BSTME'        TO lt_fields.
      APPEND 'GOITEM-ELIKZ_MATDOC' TO lt_fields.
      APPEND 'GOITEM-KNTTP'        TO lt_fields.
      APPEND 'GOITEM-MIGO_ELIKZ'   TO lt_fields.
      APPEND 'GOITEM-WEMNG'        TO lt_fields.
      APPEND 'GOITEM-ELIKZ_ORD'    TO lt_fields.
      APPEND 'GOITEM-PPS_AUFNR'    TO lt_fields.
      APPEND 'GOITEM-PPS_POSNR'    TO lt_fields.
*     Do not allow to create serial numbers automatic within transfer
*     posting
      APPEND 'GOITEM-XSAUT'        TO lt_fields.

      APPEND 'OK_CONTAINER'        TO lt_fields.
      APPEND 'OK_NOT_ORDERED'      TO lt_fields.
      APPEND 'OK_GA_ADD_VARIANT'   TO lt_fields.
  ENDCASE.

* set fieldselection for buttons
  IF s_action-display = abap_true.
    APPEND 'GOITEM-EQUNR'        TO lt_fields.
    APPEND 'GOITEM-LOGLEVEL'     TO lt_fields.
    APPEND 'GOITEM-MIGO_ELIKZ'   TO lt_fields.
    APPEND 'GOITEM-TAKE_IT'      TO lt_fields.
    APPEND 'OK_CONTAINER'        TO lt_fields.
    APPEND 'OK_DETERMINE_ALL'    TO lt_fields.
    APPEND 'OK_EXPAND_BOM'       TO lt_fields.
    APPEND 'OK_NOT_OK'           TO lt_fields.
    APPEND 'OK_NOT_ORDERED'      TO lt_fields.
    APPEND 'OK_NEW_ITEMS'        TO lt_fields.
    APPEND 'OK_SPLIT_QUANTITY'   TO lt_fields.
    APPEND 'OK_TAKE_VALUE'       TO lt_fields.
    APPEND 'OK_GA_CHANGE_VARIANT' TO lt_fields.
    APPEND 'OK_GA_ADD_VARIANT'    TO lt_fields.
ENHANCEMENT-POINT screen_modify_mode_15 SPOTS es_saplmigo.
  ELSE.
    APPEND 'GOITEM-ELIKZ_MATDOC' TO lt_fields.
  ENDIF.
  IF s_action-cancel = abap_true.
    APPEND 'OK_CONTAINER'        TO lt_fields.
    APPEND 'OK_DETERMINE_ALL'    TO lt_fields.
    APPEND 'OK_EXPAND_BOM'       TO lt_fields.
    APPEND 'OK_NOT_ORDERED'      TO lt_fields.
    APPEND 'OK_NEW_ITEMS'        TO lt_fields.
    APPEND 'OK_SPLIT_QUANTITY'   TO lt_fields.
    APPEND 'OK_GA_CHANGE_VARIANT' TO lt_fields.
    APPEND 'OK_GA_ADD_VARIANT'    TO lt_fields.
ENHANCEMENT-POINT screen_modify_mode_16 SPOTS es_saplmigo.
  ENDIF.
  IF s_action-return = abap_true.
    APPEND 'OK_CONTAINER'        TO lt_fields.
    APPEND 'OK_EXPAND_BOM'       TO lt_fields.
    APPEND 'OK_NOT_ORDERED'      TO lt_fields.
  ENDIF.
  IF s_action-release = abap_true.
    APPEND 'OK_CONTAINER'        TO lt_fields.
    APPEND 'OK_EXPAND_BOM'       TO lt_fields.
    APPEND 'OK_NOT_ORDERED'      TO lt_fields.
  ENDIF.
  IF s_action-place = abap_true.
    APPEND 'OK_CONTAINER'        TO lt_fields.
    APPEND 'OK_EXPAND_BOM'       TO lt_fields.
    APPEND 'OK_NOT_ORDERED'      TO lt_fields.
  ENDIF.
  IF s_action-subsequent = abap_true.
    APPEND 'OK_CONTAINER'        TO lt_fields.
    APPEND 'OK_EXPAND_BOM'       TO lt_fields.
    APPEND 'OK_NOT_ORDERED'      TO lt_fields.
  ENDIF.
  IF s_action-issue = abap_true.
    APPEND 'OK_CONTAINER'        TO lt_fields.
    APPEND 'OK_NOT_ORDERED'      TO lt_fields.
  ENDIF.
  IF s_action-receipt = abap_true AND
     s_control-new_line_mode IS INITIAL.
    APPEND 'OK_EXPAND_BOM'       TO lt_fields.
  ENDIF.
* Button for new items in GI mode can be disabled if reference
* is OTHERS (because the system then always is in new item mode).
  IF NOT s_control-new_line_mode IS INITIAL.
    APPEND 'OK_NEW_ITEMS'        TO lt_fields.
  ENDIF.
ENHANCEMENT-POINT screen_modify_mode_17 SPOTS es_saplmigo.
* Deactivate MIGO toolbar if user has no developer authorization
  AUTHORITY-CHECK OBJECT 'S_DEVELOP'
    ID 'DEVCLASS' DUMMY
    ID 'OBJTYPE'  DUMMY
    ID 'OBJNAME'  DUMMY
    ID 'P_GROUP'  DUMMY
    ID 'ACTVT'    DUMMY.
  IF sy-subrc <> 0.
    APPEND 'G_DUMMY_FIELD'       TO lt_fields.
  endif.
* Depending on MIGO mode, deactivate fields (header fields, MODE)
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      it_fields = lt_fields
      i_mode    = abap_true
      i_status  = lcl_migo_screenmodification=>c_invisible.
* New positions have the same restrictions (MODE)
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      it_fields        = lt_fields
      i_mode           = abap_true
      i_global_counter = lcl_migo_screenmodification=>c_item_template
      i_status         = lcl_migo_screenmodification=>c_invisible.

* Settings for the template. Show only some fields. (WORK)
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      i_inversion      = abap_true
      i_global_counter = lcl_migo_screenmodification=>c_item_template
      i_status         = lcl_migo_screenmodification=>c_invisible.
* Which fields to show for new items
  CLEAR lt_fields.
  APPEND 'GOITEM-BTEXT'      TO lt_fields.
  APPEND 'GOITEM-BWART'      TO lt_fields.
  APPEND 'GOITEM-ERFME'      TO lt_fields.
  APPEND 'GOITEM-ERFMG'      TO lt_fields.
  APPEND 'GOITEM-LGOBE'      TO lt_fields.
  APPEND 'GOITEM-LGORT'      TO lt_fields.
  APPEND 'GOITEM-MAKTX'      TO lt_fields.
  APPEND 'GOITEM-MATNR'      TO lt_fields.
* APPEND 'GOITEM-MIGO_INSMK' TO lt_fields.                     "379521
  APPEND 'GOITEM-NAME1'      TO lt_fields.
  APPEND 'GOITEM-SOBKZ'      TO lt_fields.
  APPEND 'GOITEM-WERKS'      TO lt_fields.
  IF s_action-migo_mode = 'GI'.
    APPEND 'GOITEM-EQUNR'    TO lt_fields.
  ELSEIF s_action-migo_mode = 'GT'.
    APPEND 'GODYNPRO-MAKTX' TO lt_fields.
    APPEND 'GODYNPRO-MATNR' TO lt_fields.
    APPEND 'GODYNPRO-WERKS' TO lt_fields.
    APPEND 'GODYNPRO-NAME1' TO lt_fields.
    APPEND 'GODYNPRO-LGORT' TO lt_fields.
    APPEND 'GODYNPRO-LGOBE' TO lt_fields.
    APPEND 'GODYNPRO-SOBKZ' TO lt_fields.
    APPEND 'GODYNPRO-ERFMG' TO lt_fields.
    APPEND 'GODYNPRO-ERFMG' TO lt_fields.
    APPEND 'GODYNPRO-ERFME' TO lt_fields.
    APPEND 'GODYNPRO-MAT_PSPNR'      TO lt_fields.
    APPEND 'GODYNPRO-MAT_VENDORNAME' TO lt_fields.
    APPEND 'GODYNPRO-MAT_LIFNR'      TO lt_fields.
    APPEND 'GODYNPRO-MAT_CUSTNAME'   TO lt_fields.
    APPEND 'GODYNPRO-MAT_KUNNR'      TO lt_fields.
    APPEND 'GODYNPRO-MAT_KDAUF'      TO lt_fields.
    APPEND 'GODYNPRO-MAT_KDPOS'      TO lt_fields.
    APPEND 'GOITEM-UMMAT_PSPNR'      TO lt_fields.
    APPEND 'GOITEM-UMMAT_VENDORNAME' TO lt_fields.
    APPEND 'GOITEM-UMMAT_LIFNR'      TO lt_fields.
    APPEND 'GOITEM-UMMAT_CUSTNAME'   TO lt_fields.
    APPEND 'GOITEM-UMMAT_KUNNR'      TO lt_fields.
    APPEND 'GOITEM-UMMAT_KDAUF'      TO lt_fields.
    APPEND 'GOITEM-UMMAT_KDPOS'      TO lt_fields.

    APPEND 'GOITEM-UMSOK'            TO lt_fields.
    APPEND 'GOITEM-SOTXT'            TO lt_fields.
    APPEND 'GOITEM-UMSOTXT'          TO lt_fields.

    APPEND 'GODYNPRO-RIGHT_TRANSFER_FRAME' TO lt_fields.
    APPEND 'GODYNPRO-LEFT_TRANSFER_FRAME'  TO lt_fields.
  ENDIF.

* Movement type dependent fields: Use MIGO_CUST_FIELDS.
* It's not necessary to set the REQUIRED-attribute here as
* here only the initial input ability is controlled. When the line
* is copied into the model, the final settings take place.
* The chosen movement type is the one from the defaults.
  CALL METHOD cl_mmim_migo_move_fields=>get_fields
    EXPORTING
      i_bwart   = s_defaults-bwart
    IMPORTING
      et_fields = lt_bwa_fields.
  LOOP AT lt_bwa_fields INTO ls_bwa_fields.
    CONCATENATE 'GOITEM-' ls_bwa_fields-fieldname INTO l_fieldname.
    APPEND l_fieldname TO lt_fields.
  ENDLOOP.
  IF s_control-new_line_mode <> space.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        it_fields        = lt_fields
        i_global_counter = lcl_migo_screenmodification=>c_item_template
        i_status         = lcl_migo_screenmodification=>c_input.
  ENDIF.
* Finally, the field selection on the lower area (status) has to
* be called for a rebuild of the WORK area
  CALL METHOD screen_modify_status.
ENDMETHOD.                    "screen_modify_mode


************************************************************************
* Screenmodifications for a single line of the model. Called
* from LINE_CHECK
************************************************************************
METHOD screen_modify_line.
  DATA: l_status       TYPE migo_fs_status,
        lt_invisible   TYPE ty_t_fieldname,
        lt_visible     TYPE ty_t_fieldname,
        lt_input       TYPE ty_t_fieldname,
        l_account_disp TYPE abap_bool,
        l_fields       TYPE string,
        l_fieldname    TYPE migo_fieldname,
        l_goitemname   TYPE migo_fieldname,
        l_isgoitemname TYPE migo_fieldname,
        lt_migo_fields TYPE tyt_migo_move_fields,
        ls_migo_fields TYPE tys_migo_move_fields,
* The following variables have no effect for the Core Code
* conditions, their value changes only in the switched code.
* This usage makes possible to avoid enh. sections.
        lv_ad_bv_input       VALUE space,   "EHP604 ADSUB GM080403
        lv_ad_batch_visible  VALUE space,   "EHP604 ADSUB GM080403
        lv_ad_val_visible    VALUE space.   "EHP604 ADSUB GM080403

  FIELD-SYMBOLS: <f>   TYPE ANY.

* Rebuild from the current mode settings
  CALL METHOD lcl_migo_screenmodification=>restore
    EXPORTING
      i_global_counter = is_goitem-global_counter
      i_mode           = abap_false.
* TAKE_IT indicatior in cancel mode
  IF s_action-cancel        = abap_true AND
     is_goitem-xcancel_done = abap_true.
    APPEND 'GOITEM-TAKE_IT'       TO lt_visible.
    APPEND 'GODYNPRO-DETAIL_TAKE' TO lt_visible.
  ENDIF.
* Begin of note 569986
  IF ( s_action-cancel        = abap_true
    OR s_action-display       = abap_true )
    AND is_goitem-smbln <> space AND is_goitem-sjahr <> space
    AND is_goitem-smblp <> space.
    APPEND 'GOITEM-EXBWR' TO lt_invisible.
  ENDIF.
* End of note 569986

* Brazil: Cancel only whole material document
  IF s_action-cancel  = abap_true AND
     is_goitem-tax_relevant = x.
    APPEND 'GOITEM-TAKE_IT'       TO lt_visible.
    APPEND 'GODYNPRO-DETAIL_TAKE' TO lt_visible.
  ENDIF.
ENHANCEMENT-POINT screen_modify_mode_45 SPOTS es_saplmigo.

* General disabling of TAKE_IT in these cases:
* - Position is subitem and not subcontracting child
* - Position is not child of BOM (as BOM header is only virtual)
* - In CANCEL-mode: no exception: Subitem --> no modification
ENHANCEMENT-SECTION     screen_modify_mode_18 SPOTS es_saplmigo.
  IF (
       NOT is_goitem-parent IS INITIAL AND
           is_goitem-xlbtype  <> c     AND
           is_goitem-xbomtype <> c     AND
           is_goitem-xsttype  <> c
     )                                        OR
     (
       NOT is_goitem-parent IS INITIAL AND
           s_action-cancel = abap_true
     ).
    APPEND 'GOITEM-TAKE_IT'       TO lt_invisible.
    APPEND 'GODYNPRO-DETAIL_TAKE' TO lt_invisible.
  ENDIF.
END-ENHANCEMENT-SECTION.

ENHANCEMENT-POINT screen_modify_mode_46 SPOTS es_saplmigo STATIC.

ENHANCEMENT-POINT screen_modify_mode_47 SPOTS es_saplmigo.

*______________________________________________________________________
* Special rule for posting with materialdocument as             ERP 10
* template -> s_action-copy = abap_true
  IF s_action-copy = abap_true.
    APPEND 'GOITEM-CHARG'         TO lt_input.
  ENDIF.

*______________________________________________________________________
* Special rule for place in storage -> s_action-place = abap_true
  IF s_action-place = abap_true.
    IF s_action-refdoctype = c_refdoctype_matdoc.
      APPEND 'GOITEM-MATNR'         TO lt_visible.
      APPEND 'GOITEM-MAKTX'         TO lt_visible.
      APPEND 'GOITEM-WERKS'         TO lt_visible.
      APPEND 'GOITEM-NAME1'         TO lt_visible.
      APPEND 'GOITEM-BWART'         TO lt_visible.
    ENDIF.
    APPEND 'GOITEM-CHARG'         TO lt_input.
    APPEND 'GOITEM-SOBKZ'         TO lt_visible.
    APPEND 'GOITEM-MIGO_INSMK'    TO lt_invisible.
  ENDIF.

*______________________________________________________________________
* Special rule: Depending on reference type
  IF c_refdoctype_none = s_action-refdoctype
     OR NOT s_action-copy IS INITIAL "condition will have to be  ERP 10
                                     "extended if copy function
                                     "is to be extended.
     OR ( c_refdoctype_po = s_action-refdoctype
          AND is_goitem-xpoitem = abap_false
          AND is_goitem-kzzug   = abap_false ).
*    the field will remain 'on input'
  ELSE.
    APPEND 'GOITEM-EBELN'      TO lt_visible.
  ENDIF.
*______________________________________________________________________
* Some general rules
* GR for PO
  IF is_goitem-xpoitem = abap_true.
    APPEND 'GOITEM-CUSTNAME'   TO lt_visible.
    APPEND 'GOITEM-MAKTX'      TO lt_visible.
    APPEND 'GOITEM-MATNR'      TO lt_visible.
    APPEND 'GOITEM-NAME1'      TO lt_visible.
    APPEND 'GOITEM-SOBKZ'      TO lt_visible.
    APPEND 'GOITEM-MAT_KDAUF'  TO lt_visible.
    APPEND 'GOITEM-MAT_KDPOS'  TO lt_visible.
    APPEND 'GOITEM-MAT_PSPNR'  TO lt_visible.
    APPEND 'GOITEM-VENDORNAME' TO lt_visible.
    APPEND 'GOITEM-WERKS'      TO lt_visible.
*   Field for external amount must be invisible in case of GR for PO.
*   Field EXBWR must be handled different to GR for order due to the
*   not ordered items which has to allow the input of EXBWR.
    APPEND 'GOITEM-EXBWR'      TO lt_invisible.
*   EBELN for items with reference to a PO should never be
*   on input.
    APPEND 'GOITEM-EBELN'      TO lt_visible.
  ENDIF.
* GI for transport order (mvt 351)
  IF is_goitem-xpoitem = abap_false AND NOT is_goitem-kzzug IS INITIAL.
    APPEND 'GOITEM-CUSTNAME'   TO lt_visible.
    APPEND 'GOITEM-EQUNR'      TO lt_visible.
    APPEND 'GOITEM-MAKTX'      TO lt_visible.
    APPEND 'GOITEM-MATNR'      TO lt_visible.
    APPEND 'GOITEM-NAME1'      TO lt_visible.
    APPEND 'GOITEM-SOBKZ'      TO lt_visible.
    APPEND 'GOITEM-MAT_KDAUF'  TO lt_visible.
    APPEND 'GOITEM-MAT_KDPOS'  TO lt_visible.
    APPEND 'GOITEM-MAT_PSPNR'  TO lt_visible.
    APPEND 'GOITEM-VENDORNAME' TO lt_visible.
    APPEND 'GOITEM-WERKS'      TO lt_visible.

*   Reservation fields
    APPEND 'GOITEM-KZEAR'      TO lt_invisible.
    APPEND 'GOITEM-RSNUM'      TO lt_invisible.
    APPEND 'GOITEM-RSPOS'      TO lt_invisible.
  ENDIF.
* Subcontracting, component consumption
* Begin of Outsourced Manufacturing EhP 4
  IF s_action-sc_comp = abap_true OR is_goitem-xco_order = abap_true.
    APPEND 'GOITEM-EBELN'      TO lt_visible.
    APPEND 'GOITEM-EBELP'      TO lt_visible.
    IF is_goitem-xlbtype IS INITIAL AND is_goitem-bustr = '501'
       AND is_goitem-aufnr IS NOT INITIAL.
      APPEND 'GOITEM-ERFMG'      TO lt_visible.
      APPEND 'GOITEM-ERFME'      TO lt_visible.
ENHANCEMENT-POINT EHP606_LMIGOKS4_01 SPOTS ES_SAPLMIGO .
      APPEND 'GOITEM-MAKTX'      TO lt_visible.
      APPEND 'GOITEM-MATNR'      TO lt_visible.
      APPEND 'GOITEM-NAME1'      TO lt_visible.
      APPEND 'GOITEM-AUFNR'      TO lt_visible.
      APPEND 'GOITEM-SOBKZ'      TO lt_visible.
      APPEND 'GOITEM-CHARG'      TO lt_visible.
      APPEND 'GOITEM-LICHA'      TO lt_visible.
      APPEND 'GOITEM-BWTAR'      TO lt_visible.
      APPEND 'GOITEM-MIGO_INSMK' TO lt_visible.
      APPEND 'GOITEM-TAKE_IT'    TO lt_visible.
      APPEND 'GODYNPRO-DETAIL_TAKE' TO lt_visible.
      APPEND 'GOITEM-LGOBE'      TO lt_input.
    ENDIF.
  ENDIF.
* End of Outsourced Manufacturing EhP 4
* GO
  IF is_goitem-xorditem = abap_true.
    APPEND 'GOITEM-CUSTNAME'   TO lt_visible.
    APPEND 'GOITEM-MAKTX'      TO lt_visible.
    APPEND 'GOITEM-MATNR'      TO lt_visible.
    APPEND 'GOITEM-NAME1'      TO lt_visible.
    APPEND 'GOITEM-SOBKZ'      TO lt_visible.
    APPEND 'GOITEM-MAT_KDAUF'  TO lt_visible.
    APPEND 'GOITEM-MAT_KDPOS'  TO lt_visible.
    APPEND 'GOITEM-MAT_PSPNR'  TO lt_visible.
    APPEND 'GOITEM-VENDORNAME' TO lt_visible.
    APPEND 'GOITEM-WERKS'      TO lt_visible.
  ENDIF.
* GI for reservation
  IF is_goitem-xresitem = abap_true.
    APPEND 'GOITEM-BWART' TO lt_visible.
    APPEND 'GOITEM-MAKTX' TO lt_visible.
    APPEND 'GOITEM-MATNR' TO lt_visible.
    APPEND 'GOITEM-NAME1' TO lt_visible.
    APPEND 'GOITEM-WERKS' TO lt_visible.
*   Transfer reservation:
    APPEND 'GODYNPRO-MAKTX' TO lt_visible.
    APPEND 'GODYNPRO-MATNR' TO lt_visible.
    APPEND 'GODYNPRO-NAME1' TO lt_visible.
    APPEND 'GODYNPRO-WERKS' TO lt_visible.
    APPEND 'GOITEM-UMMAT'   TO lt_visible.
    APPEND 'GOITEM-UMMAKTX' TO lt_visible.
    APPEND 'GOITEM-UMWRK'   TO lt_visible.
    APPEND 'GOITEM-UMNAME1' TO lt_visible.
    APPEND 'GOITEM-UMLGO'   TO lt_visible.
    APPEND 'GOITEM-UMLGOBE' TO lt_visible.
*   Return delivery: reservation fields invisible (because reservation
*   not read)
    IF s_action-return = abap_true.
      APPEND 'GOITEM-BDMNG'     TO lt_invisible.
      APPEND 'GOITEM-BDTER'     TO lt_invisible.
      APPEND 'GOITEM-ENMNG'     TO lt_invisible.
      APPEND 'GOITEM-MEINS_RES' TO lt_invisible.
      APPEND 'GOITEM-VMENG'     TO lt_invisible.
    ENDIF.
*   If SOBKZ in reservation given, it cannot be changed.
    IF NOT is_goitem-res_sobkz IS INITIAL.
      APPEND 'GOITEM-SOBKZ'     TO lt_visible.
      APPEND 'GOITEM-MAT_KDAUF' TO lt_visible.
      APPEND 'GOITEM-MAT_KDPOS' TO lt_visible.
      APPEND 'GOITEM-MAT_PSPNR' TO lt_visible.
*     Transfer reservation
      APPEND 'GODYNPRO-SOBKZ'     TO lt_visible.
      APPEND 'GODYNPRO-MAT_KDAUF' TO lt_visible.
      APPEND 'GODYNPRO-MAT_KDPOS' TO lt_visible.
      APPEND 'GODYNPRO-MAT_PSPNR' TO lt_visible.
    ENDIF.
  ELSE.
*   GI without reservation
    APPEND 'GOITEM-KZEAR' TO lt_invisible.
    APPEND 'GOITEM-RSNUM' TO lt_invisible.
    APPEND 'GOITEM-RSPOS' TO lt_invisible.
  ENDIF.
ENHANCEMENT-POINT EHP604_SCREEN_MODIFY_LINE_02 SPOTS ES_SAPLMIGO.
* BWART input not allow in case of RETPO <> inital.
  IF NOT is_goitem-retpo IS INITIAL.
    APPEND 'GOITEM-BWART' TO lt_visible.
  ENDIF.
* Do not allow to change SOBKZ in return mode
  IF s_action-return = abap_true.
    APPEND 'GOITEM-SOBKZ' TO lt_visible.
  ENDIF.

  IF CL_OPS_SWITCH_CHECK=>LO_MM_SD_SFWS_DM_SC( )  is not initial.
    If s_action-migo_mode = 'GS'.
      DATA: ls_mtcom TYPE mtcom,
            ls_mara  TYPE mara,
            i_matnr  TYPE matnr.
      constants:
       BEGIN OF con_kenng,
          msfcv TYPE mtcom-kenng VALUE 'MSFCV',
          mara  TYPE mtcom-kenng VALUE 'MARA',
          marc  TYPE mtcom-kenng VALUE 'MARC',
          mard  TYPE mtcom-kenng VALUE 'MARD',
        END   OF con_kenng.

      MOVE is_goitem-matnr TO ls_mtcom-matnr.
      MOVE con_kenng-mara TO ls_mtcom-kenng.

      CALL FUNCTION 'MATERIAL_READ'
        EXPORTING
          SCHLUESSEL         = ls_mtcom
        IMPORTING
          MATDATEN           = ls_mara
        EXCEPTIONS
          ACCOUNT_NOT_FOUND  = 1
          BATCH_NOT_FOUND    = 2
          FORECAST_NOT_FOUND = 3
          LOCK_ON_ACCOUNT    = 4.

      IF SY-SUBRC = 0.
        if ls_mara-xchpf is not INITIAL.
          Append 'GOITEM-CHARG' to lt_INPUT.
        endif.
      ENDIF.
    ENDIF.
  ENDIF.

* GS Subsequent adjustment
  IF is_goitem-kzbew = o.
*   Fields for input
    APPEND 'GOITEM-TAKE_IT'       TO lt_input.
    APPEND 'GODYNPRO-DETAIL_TAKE' TO lt_input.
    APPEND 'GOITEM-ZEILE'         TO lt_input.
    APPEND 'GOITEM-GRUND'         TO lt_input.
    APPEND 'GOITEM-SGTXT'         TO lt_input.
    APPEND 'GOITEM-WEMPF'         TO lt_input.
*   Buttons
    APPEND 'OK_LINKED_DOCUMENTS'  TO lt_input.
    APPEND 'OK_PO_HISTORY'        TO lt_input.
*    APPEND 'OK_PURCHASEORDER'    TO lt_input.      "DEL MAA-DEV to be checked
    APPEND 'OK_STOCK_OVERVIEW'    TO lt_input.
*   Set all other fields to visible
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_inversion      = abap_true
        i_one_way        = abap_true
        it_fields        = lt_input
        i_global_counter = is_goitem-global_counter
        i_status         = lcl_migo_screenmodification=>c_visible.
*   Invisible fields
    APPEND 'GOITEM-ANZGEB'     TO lt_invisible.
    APPEND 'GOITEM-BPMNG'      TO lt_invisible.
    APPEND 'GOITEM-BPRME'      TO lt_invisible.
    IF CL_OPS_SWITCH_CHECK=>LO_MM_SD_SFWS_DM_SC( ) is not initial and  s_action-migo_mode = 'GS'.
    if ls_mara-xchpf is INITIAL.
      APPEND 'GOITEM-CHARG'      TO lt_invisible.
    endif.
    endif.
    APPEND 'GOITEM-EXBWR'      TO lt_invisible.
    APPEND 'GOITEM-EXVKW'      TO lt_invisible.
    APPEND 'GOITEM-GEBEH'      TO lt_invisible.
    APPEND 'GOITEM-GRTXT'      TO lt_invisible.
    APPEND 'GOITEM-HSDAT'      TO lt_invisible.
    APPEND 'GOITEM-LGOBE'      TO lt_invisible.
    APPEND 'GOITEM-LGORT'      TO lt_invisible.
    APPEND 'GOITEM-LGPBE'      TO lt_invisible.
    APPEND 'GOITEM-LICHA'      TO lt_invisible.
    APPEND 'GOITEM-LSMEH'      TO lt_invisible.
    APPEND 'GOITEM-LSMNG'      TO lt_invisible.
    APPEND 'GOITEM-MIGO_ELIKZ' TO lt_invisible.
    APPEND 'GOITEM-MIGO_INSMK' TO lt_invisible.
    APPEND 'GOITEM-SC_ADJUST'  TO lt_invisible.
ENHANCEMENT-POINT lmigoks4_13 SPOTS es_saplmigo.
    "$$
    APPEND 'GOITEM-VFDAT'      TO lt_invisible.
    APPEND 'GOITEM-WEANZ'      TO lt_invisible.
    APPEND 'GOITEM-XSAUT'      TO lt_invisible.
    APPEND 'GOITEM-ZUSTD'      TO lt_invisible.
  ENDIF.

*____________ Replacement of screen-group2 _____________________________
*___________________ GOITEM fields _____________________________________

* MAT-Fields: Display special stock identifier fields only if special
*             stock is filled with the correct value
*             (Important for the tableview on screen 0200)
ENHANCEMENT-SECTION     EHP604_SCREEN_MODIFY_LINE_01 SPOTS ES_SAPLMIGO.
  IF is_goitem-sobkz <> e AND is_goitem-sobkz <> t.         "SIT
    APPEND 'GOITEM-MAT_KDPOS'        TO lt_invisible.
    APPEND 'GOITEM-MAT_KDAUF'        TO lt_invisible.
  ENDIF.
  IF is_goitem-sobkz <> q.
    APPEND 'GOITEM-MAT_PSPNR'        TO lt_invisible.
  ENDIF.
  IF is_goitem-sobkz NA 'POKM'.
    APPEND 'GOITEM-MAT_VENDORNAME'   TO lt_invisible.
    APPEND 'GOITEM-MAT_LIFNR'        TO lt_invisible.
  ENDIF.
END-ENHANCEMENT-SECTION.
  IF is_goitem-sobkz NA 'VW'.
    APPEND 'GOITEM-MAT_CUSTNAME'     TO lt_invisible.
    APPEND 'GOITEM-MAT_KUNNR'        TO lt_invisible.
  ENDIF.
ENHANCEMENT-SECTION     EHP604_SCREEN_MODIFY_LINE_05 SPOTS ES_SAPLMIGO.
*  Transfer fields (UMMAT-fields)
  IF is_goitem-umsok <> e AND is_goitem-umsok <> t.         "SIT
    APPEND 'GOITEM-UMMAT_KDPOS'      TO lt_invisible.
    APPEND 'GOITEM-UMMAT_KDAUF'      TO lt_invisible.
  ENDIF.
  IF is_goitem-umsok <> q.
    APPEND 'GOITEM-UMMAT_PSPNR'      TO lt_invisible.
  ENDIF.
  IF is_goitem-umsok NA 'POKM'.
    APPEND 'GOITEM-UMMAT_VENDORNAME' TO lt_invisible.
    APPEND 'GOITEM-UMMAT_LIFNR'      TO lt_invisible.
  ENDIF.
END-ENHANCEMENT-SECTION.
  IF is_goitem-umsok NA 'VW'.
    APPEND 'GOITEM-UMMAT_CUSTNAME'   TO lt_invisible.
    APPEND 'GOITEM-UMMAT_KUNNR'      TO lt_invisible.
  ENDIF.
* No change of special stock ID for sending/receiving except
* for sobkz E/Q, so set UM-fields to display only
  IF is_goitem-sobkz = is_goitem-umsok.
    IF is_goitem-sobkz CA 'POKM'.
      APPEND 'GOITEM-UMMAT_VENDORNAME'   TO lt_visible.
      APPEND 'GOITEM-UMMAT_LIFNR'        TO lt_visible.
    ENDIF.
    IF is_goitem-sobkz CA 'VW'.
      APPEND 'GOITEM-UMMAT_CUSTNAME'     TO lt_visible.
      APPEND 'GOITEM-UMMAT_KUNNR'        TO lt_visible.
    ENDIF.
  ENDIF.
* SOBKZ
  IF s_control-action = 'A01' AND s_control-refdoc = 'R01'
     AND is_goitem-xpoitem IS INITIAL
     AND NOT is_goitem-xautopo IS INITIAL.
    APPEND 'GOITEM-SOBKZ' TO lt_invisible.
  ENDIF.
* EMATN
  IF is_goitem-mprof IS INITIAL.
    APPEND 'GOITEM-EMATN'   TO lt_invisible.
    APPEND 'GOITEM-MFRNAME' TO lt_invisible.
    APPEND 'GOITEM-MFRNR'   TO lt_invisible.
  ENDIF.
* MATBF
  IF is_goitem-matnr = is_goitem-matbf OR
     is_goitem-matbf IS INITIAL.
    APPEND 'GOITEM-MATBF' TO lt_invisible.
  ENDIF.
ENHANCEMENT-POINT EHP604_SCREEN_MODIFY_LINE_06 SPOTS ES_SAPLMIGO .
* BWTAR: we allow input also in case of batch management
  IF is_goitem-bwtty <> space.
*   valuation type is set from reference document
*   but in copy mode, it should be on input                       ERP 10
    IF ( is_goitem-bwtor <> space
       AND s_action-copy = abap_false
       AND lv_ad_bv_input IS INITIAL )                      "GM080403
       OR  lv_ad_val_visible IS NOT INITIAL.                "GM080403
      APPEND 'GOITEM-BWTAR'   TO lt_visible.
      APPEND 'GODYNPRO-BWTAR' TO lt_visible.
    ELSE.
      APPEND 'GOITEM-BWTAR'   TO lt_input.
      APPEND 'GODYNPRO-BWTAR' TO lt_input.
    ENDIF.
  ELSE.
    APPEND 'GOITEM-BWTAR'   TO lt_invisible.
    APPEND 'GODYNPRO-BWTAR' TO lt_invisible.
  ENDIF.
* HSDAT / VFDAT
* (fieldselection for UMHSDAT / UMVFDAT in LMIGOKS6)
* Must be the same logic as in field selection LMIGOKS6 and LMIGOKL4.
  IF is_goitem-xwmhd IS INITIAL OR is_goitem-kzmhd IS INITIAL OR
     is_goitem-kzwes = s.
    APPEND 'GOITEM-HSDAT' TO lt_invisible.
    APPEND 'GOITEM-VFDAT' TO lt_invisible.
  ELSE.
    IF is_goitem-xchpf = abap_false AND is_goitem-mhdrz IS INITIAL.
      APPEND 'GOITEM-HSDAT' TO lt_invisible.
      APPEND 'GOITEM-VFDAT' TO lt_invisible.
    ENDIF.
  ENDIF.
  IF is_goitem-shkzg = 'H' AND s_action-migo_mode = 'GT'.
    APPEND 'GOITEM-HSDAT' TO lt_invisible.
    APPEND 'GOITEM-VFDAT' TO lt_invisible.
  ENDIF.
* EAN11_BME / EAN11_KON / EANME
  IF is_goitem-matnr IS INITIAL
    OR s_action-display = abap_true
    OR s_action-cancel = abap_true.
    APPEND 'GOITEM-EAN11_BME' TO lt_invisible.
    APPEND 'GOITEM-EAN11_KON' TO lt_invisible.
    APPEND 'GOITEM-EANME'     TO lt_invisible.
  ENDIF.
* LSMEH: full product and populated field -> just visible; <LG>
  IF is_goitem-xvgtype = p  AND  NOT is_goitem-lsmeh IS INITIAL.
    APPEND 'GOITEM-LSMEH' TO lt_visible.
  ENDIF.
* ERFME: full product and populated field -> just visible; <LG>
  IF is_goitem-xvgtype = p  AND  NOT is_goitem-erfme IS INITIAL.
    APPEND 'GOITEM-SOBKZ'   TO lt_visible.
    APPEND 'GODYNPRO-SOBKZ' TO lt_visible.
    APPEND 'GOITEM-UMMAKTX' TO lt_visible.
    READ TABLE pt_goitem
      WITH KEY parent    = is_goitem-global_counter
               xvgtype   = c
               TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      APPEND 'GOITEM-ERFME'   TO lt_visible.
      APPEND 'GODYNPRO-ERFME' TO lt_visible.
      APPEND 'GOITEM-MAKTX'   TO lt_visible.
      APPEND 'GODYNPRO-MAKTX' TO lt_visible.
      APPEND 'GOITEM-CHARG'   TO lt_invisible.
      APPEND 'GODYNPRO-UMCHA' TO lt_invisible.
      APPEND 'GOITEM-BWTAR'   TO lt_invisible.
      APPEND 'GODYNPRO-UMBAR' TO lt_invisible.
*      IF is_goitem-expand = c_icon_expand.
*        APPEND 'GOITEM-ERFMG'   TO lt_input.
*        APPEND 'GODYNPRO-ERFMG' TO lt_input.
*      ELSE.
*        APPEND 'GOITEM-ERFMG'   TO lt_visible.
*        APPEND 'GODYNPRO-ERFMG' TO lt_visible.
*      ENDIF.
    ENDIF.
  ENDIF.
* MEINS / MENGE (eg: PO with account assignt).
* stock quantity may be changed in case of product quantity unit
  IF is_goitem-meins IS INITIAL OR
     is_goitem-bwart = '141' OR
     is_goitem-bwart = '142'.
    APPEND 'GOITEM-MEINS' TO lt_invisible.
    APPEND 'GOITEM-MENGE' TO lt_invisible.
  ENDIF.
* Stock quantity: Product quantity unit
  IF s_action-migo_mode <> 'GT'.
    IF is_goitem-xparallel = abap_false
       AND NOT is_goitem-meins IS INITIAL.
      APPEND  'GOITEM-MENGE' TO lt_visible.
    ENDIF.
  ENDIF.
* BPRME BPMNG
ENHANCEMENT-SECTION     lmigoks4_14 SPOTS es_saplmigo.
"$$
  IF is_goitem-bstme = is_goitem-bprme OR is_goitem-bprme IS INITIAL.
    APPEND 'GOITEM-BPMNG' TO lt_invisible.
    APPEND 'GOITEM-BPRME' TO lt_invisible.
  ENDIF.
END-ENHANCEMENT-SECTION.
"$$
* BSTME
* note 432683: order quantity unit should be invisible if no ordered
* quantity is filled as the ordered quantity will be set to invisible
* later on by basis rule: not filled -> invisible
  IF is_goitem-bsmng IS INITIAL.
    APPEND 'GOITEM-BSTME' TO lt_invisible.
  ENDIF.
* WAMME (delivered quantity unit)
  IF is_goitem-wamng IS INITIAL.
    APPEND 'GOITEM-WAMME' TO lt_invisible.
  ENDIF.
* Please do not delete this notice:
* EXVKW: even in GI case selling prices have to be active in plant
* According to our retail specialist VS exvkw only with migo_cust_fields
* In MIGO_CUST_FIELDS not in standard customizing (client 100) but
* retail customers may create an entry 101 EXVKW for example
*  IF is_goitem-xvkbw IS INITIAL AND NOT is_goitem-werks IS INITIAL.
*    CONCATENATE l_fields_v ' GOITEM-EXVKW' INTO l_fields_v.
*  ENDIF.
* MIGO_INSMK
* Begin note 1566863
  IF is_goitem-xstock_type_mvt = x OR s_action-migo_mode = 'GT'.
* End note 1566863
*   all movement types which has stock type already in movement type
*   definition should not show stock type on screen except if already
*   set. This could e.g. be the case during cancellation or
*   display
    IF is_goitem-kzzug = X AND s_action-display = X AND        "1566863
       is_goitem-bsakz = T.                                    "1566863
*     APPEND 'GOITEM-MIGO_INSMK' TO lt_visible.                "1566863
    ELSEIF is_goitem-migo_insmk IS INITIAL.                    "1566863
      APPEND 'GOITEM-MIGO_INSMK' TO lt_invisible.
    ENDIF.
  ELSE.
*   INSMK can be set by PO
    IF is_goitem-kzwes = s.
      APPEND 'GOITEM-MIGO_INSMK' TO lt_invisible.
    ELSEIF ( NOT is_goitem-insnc IS INITIAL AND is_goitem-shkzg = s ).
      APPEND 'GOITEM-MIGO_INSMK' TO lt_visible.
    ENDIF.
  ENDIF.
* LGORT / LGOBE / LGPBE
*  changed according to note 493316:
*  This source assumes that is_goitem-xlort is always set to false if
*  business process is identified as a business process which does not
*  need a storage location. By the way this source assumes that
*  part in line_check with default set of goitem-xlort is already
*  passed by. If this assumptions will be identified as false within
*  the future, we have to make similar IF statements here as in method
*  line_check. Former IF-statement before note 493316 seems to be not
*  complete as e.g. order with account assignment resp. without material
*  number has not been considered.
  IF is_goitem-xlort = abap_false.
    APPEND 'GOITEM-LGOBE' TO lt_invisible.
    APPEND 'GOITEM-LGORT' TO lt_invisible.
    APPEND 'GOITEM-LGPBE' TO lt_invisible.
*   Same procedure for fields on TRANSFER-Tabstrip
    APPEND 'GODYNPRO-LGOBE' TO lt_invisible.
    APPEND 'GODYNPRO-LGORT' TO lt_invisible.
  ENDIF.

* CHARG
  IF ( NOT is_goitem-batch_from_refdoc IS INITIAL
     AND NOT is_goitem-kzwes = s
     AND NOT is_goitem-xchpf IS INITIAL                        "1512451
     AND lv_ad_bv_input IS INITIAL )                        "GM080403
     OR  lv_ad_batch_visible IS NOT INITIAL.                "GM080403
    IF s_action-place =  abap_false AND
       s_action-copy = abap_false.
      if ls_mara-xchpf is not INITIAl." and
*         CL_OPS_SWITCH_CHECK=>LE_SFWS_DM_BT_SC( ) is not initial. "ERP 10
        APPEND 'GOITEM-CHARG'   TO lt_input.
        APPEND 'GODYNPRO-CHARG' TO lt_input.
      else.
        APPEND 'GOITEM-CHARG'   TO lt_visible.
        APPEND 'GODYNPRO-CHARG' TO lt_visible.
      endif.
    ENDIF.
  ELSEIF is_goitem-xchpf = abap_false.
*      OR is_goitem-kzwes = s.                               "SIT
    APPEND 'GOITEM-CHARG'   TO lt_invisible.
    APPEND 'GODYNPRO-CHARG' TO lt_invisible.
  ENDIF.

* DOCUBATCH_CHARG
  IF NOT is_goitem-docubatch_control IS INITIAL AND
     NOT is_goitem-kzwes = s.
*   there are documentary batches active, and we do not post to the
*   goods receipt blocked stock
    IF is_goitem-docubatch_mult_entries = abap_true.
      APPEND 'GOITEM-DOCUBATCH_CHARG' TO lt_visible.
    ELSE.
      APPEND 'GOITEM-DOCUBATCH_CHARG' TO lt_input.
    ENDIF.
* Display material document with documentary batch in MIGO    "1302682
* the button detail documentary batch should not be visisble  "1302682
   IF s_control-action <> 'A04'.                              "1302682
    APPEND 'OK_DOC_BATCH_DETAIL'      TO lt_input.            "1302682
   ELSE.                                                      "1302682
    APPEND 'OK_DOC_BATCH_DETAIL'      TO lt_invisible.        "1302682
   ENDIF.                                                     "1302682
  ELSE.
    APPEND 'GOITEM-DOCUBATCH_CHARG'   TO lt_invisible.
    APPEND 'OK_DOC_BATCH_DETAIL'      TO lt_invisible.
  ENDIF.

* LICHA notes: 309297, 330585
  IF is_goitem-xchpf = abap_false
     OR is_goitem-kzwes = s
     OR s_action-display = abap_true.
    APPEND 'GOITEM-LICHA' TO lt_invisible.
  ELSE.
    IF NOT is_goitem-vendorbatch_from_refdoc IS INITIAL.
      APPEND 'GOITEM-LICHA' TO lt_visible.
    ELSEIF is_goitem-shkzg = h.
      APPEND 'GOITEM-LICHA' TO lt_invisible.
    ENDIF.
  ENDIF.
* MIGO_ELIKZ: in case of 103 or PO is a delivery schedule
  IF is_goitem-kzwes = s OR is_goitem-bstyp = l.
    APPEND 'GOITEM-MIGO_ELIKZ' TO lt_invisible.
  ENDIF.
* In case of non transfer posting, user is forced to enter vendor/
* customer in case of special stock on the partner tabstrip. In case of
* transfer posting, the vendor/customer should be entered on the
* transfer screen. Maybe this should be synchronised some day. In that
* case be aware that MAT-fields will be input twice for stock transfer.
* VENDORNAME: input for special stocks except transfers
  IF is_goitem-sobkz CA 'KOPM'.
    IF s_action-migo_mode <> 'GT'.
      APPEND 'GOITEM-VENDORNAME'     TO lt_input.
      APPEND 'GOITEM-MAT_LIFNR'      TO lt_visible.
      APPEND 'GOITEM-MAT_VENDORNAME' TO lt_visible.
    ELSE.
ENHANCEMENT-SECTION EHP604_SCREEN_MODIFY_LINE_08 SPOTS ES_SAPLMIGO .
      APPEND 'GOITEM-VENDORNAME' TO lt_invisible.
      APPEND 'GOITEM-LIFNR'      TO lt_invisible.
END-ENHANCEMENT-SECTION.
    ENDIF.
  ENDIF.
* CUSTNAME: input for special stocks except transfers
  IF is_goitem-sobkz CA 'VW'.
    IF s_action-migo_mode <> 'GT'.
      APPEND 'GOITEM-CUSTNAME'     TO lt_input.
      APPEND 'GOITEM-MAT_KUNNR'    TO lt_visible.
      APPEND 'GOITEM-MAT_CUSTNAME' TO lt_visible.
    ELSE.
      APPEND 'GOITEM-CUSTNAME' TO lt_invisible.
      APPEND 'GOITEM-KUNNR'    TO lt_invisible.
    ENDIF.
  ENDIF.
* CUSTNAME: visible in PO if filled (eg. Third-party order)
ENHANCEMENT-SECTION EHP604_SCREEN_MODIFY_LINE_09 SPOTS ES_SAPLMIGO .
  IF is_goitem-xpoitem = abap_true AND is_goitem-kunnr IS INITIAL.
    APPEND 'GOITEM-CUSTNAME' TO lt_invisible.
  ENDIF.
END-ENHANCEMENT-SECTION.

* RETPO: only for not ordered
  IF s_action-migo_mode = 'GR' AND is_goitem-xpoitem = abap_false.
    APPEND 'GOITEM-RETPO' TO lt_input.
  ENDIF.
* GEBEH/ANZGEB: depends only on plant (TQSS1-KZGEB)
* No display in display mode as field always empty (no mseg)
  IF is_goitem-kzgeb IS INITIAL OR s_action-display = abap_true.
    APPEND 'GOITEM-ANZGEB' TO lt_invisible.
    APPEND 'GOITEM-GEBEH'  TO lt_invisible.
  ENDIF.
* Authority check for value fields DMBTR and VKWRT
  IF NOT is_goitem-bukrs_for_stock IS INITIAL.
    IF NOT cl_mmim_auth=>check( i_object = 'F_BKPF_BUK'
                                i_value1 = is_goitem-bukrs_for_stock )
       IS INITIAL.
      APPEND 'GOITEM-DMBTR' TO lt_invisible.
ENHANCEMENT-SECTION     lmigoks4_15 SPOTS es_saplmigo.
      "$$
      APPEND 'GOITEM-VKWRT' TO lt_invisible.
END-ENHANCEMENT-SECTION.
      "$$
    ENDIF.
  ENDIF.

* Pushbutton OK_WM_SHOW
  IF is_goitem-tbnum IS INITIAL.
    APPEND 'OK_WM_SHOW' TO lt_invisible.
  ENDIF.
* Pushbutton OK_BATCH_CLASS invisible if KZCLA not set, but we
* are not cancel or display. In cancel or display, the routine
* in LMIGOKB1 will take care that we do not call VB_..., but
* jump to MCS3N for display.
  IF is_goitem-kzcla IS INITIAL AND
     ( s_action-display = abap_false AND s_action-cancel = abap_false ).
    APPEND 'OK_BATCH_CLASS' TO lt_invisible.
  ENDIF.
* Pushbutton OK_INSPLOT
  IF is_goitem-qinspst <> '1' AND is_goitem-qinspst <> '6'.
    APPEND 'OK_INSPLOT' TO lt_invisible.
  ENDIF.
* Pushbutton OK_SHIP_CONS
  IF is_goitem-evers IS INITIAL.
    APPEND 'OK_SHIP_CONS' TO lt_invisible.
  ENDIF.
* Button for linked documents OK_LINKED_DOCUMENTS
  IF is_goitem-xlinks = space.
    APPEND 'OK_LINKED_DOCUMENTS' TO lt_invisible.
  ENDIF.
* Button for stock determination OK_DETERMINE
  IF is_goitem-xdetermination = space.
    APPEND 'OK_DETERMINE'        TO lt_invisible.
    APPEND 'OK_DETERMINE_LEFT'   TO lt_invisible.
  ENDIF.
* Pushbutton EXPAND invisible of no icon
  IF is_goitem-expand IS INITIAL.
    APPEND 'GOITEM-EXPAND' TO lt_invisible.
  ENDIF.
ENHANCEMENT-POINT screen_modify_mode_19 SPOTS es_saplmigo.
* generic articles
  IF NOT is_goitem-xgatype IS INITIAL.
    APPEND 'OK_DETERMINE'         TO lt_invisible.
    APPEND 'GOITEM-MAKTX'         TO lt_visible.
    APPEND 'GOITEM-KONTO'         TO lt_visible.
    APPEND 'GOITEM-ERFME'         TO lt_visible.
    APPEND 'GOITEM-MEINS'         TO lt_visible.
  ENDIF.
* begin of Outsourced Manufacturing EhP 4
  IF is_goitem-xlbtype = C AND s_action-migo_mode = 'GR'
     AND  is_goitem-xco_order = abap_true.
    APPEND 'GOITEM-ERFMG'           TO lt_visible.
    APPEND 'GOITEM-CHARG'           TO lt_visible.
    APPEND 'GOITEM-ERFME'           TO lt_visible.
ENHANCEMENT-POINT EHP606_LMIGOKS4_02 SPOTS ES_SAPLMIGO .
    APPEND 'GOITEM-TAKE_IT'         TO lt_visible.
    APPEND 'GODYNPRO-DETAIL_TAKE'   TO lt_visible.
    APPEND 'GOITEM-KOSTL'           TO lt_visible.
    APPEND 'GOITEM-AUFNR'           TO lt_visible.
    APPEND 'GOITEM-PS_PSP_PNR'      TO lt_visible.
    APPEND 'GOITEM-NPLNR'           TO lt_visible.
    APPEND 'GOITEM-VORNR'           TO lt_visible.
    APPEND 'GOITEM-KDAUF'           TO lt_visible.
    APPEND 'GOITEM-KDPOS'           TO lt_visible.
    APPEND 'GOITEM-KDEIN'           TO lt_visible.
    APPEND 'GOITEM-GSBER'           TO lt_visible.
    APPEND 'GOITEM-BUKRS'           TO lt_visible.
    APPEND 'GOITEM-ANLN1'           TO lt_visible.
    APPEND 'GOITEM-ANLN2'           TO lt_visible.
    APPEND 'GOITEM-PRCTR'           TO lt_visible.
    APPEND 'GOITEM-KONTO'           TO lt_visible.
  ENDIF.
* end of Outsourced Manufacturing EhP 4

* Execution
* start of change for note 718008
* Make the 'batch entry' field display only if the GI is based on Order
* or reservation, and value of Kzech is 1, 2 or 3.
  IF ( NOT is_goitem-aufnr IS INITIAL OR NOT is_goitem-rsnum IS INITIAL )
       AND is_goitem-kzech BETWEEN '1' AND '3'.
    APPEND 'GOITEM-CHARG' TO lt_visible.
* The button 'Classification' in tabstrip 'Batch' is made invisible if
* there is no batch defined already.
    IF is_goitem-charg IS INITIAL.
      APPEND 'OK_BATCH_CLASS' TO lt_invisible.
    ENDIF.
  ENDIF.
* end of change for note 718008

* Order: INPUT, VISIBLE, INVISIBLE
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      i_global_counter = is_goitem-global_counter
      it_fields        = lt_input
      i_status         = lcl_migo_screenmodification=>c_input.
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      i_global_counter = is_goitem-global_counter
      it_fields        = lt_visible
      i_status         = lcl_migo_screenmodification=>c_visible.
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      i_global_counter = is_goitem-global_counter
      it_fields        = lt_invisible
      i_status         = lcl_migo_screenmodification=>c_invisible.
* BEGIN OF MOVEMENT TYPE SPECIFIC MODIFICATION
* Get the complete field selection information for the movement type
  CALL METHOD cl_mmim_migo_move_fields=>get_fields
    EXPORTING
      i_bwart   = is_goitem-bwart
    IMPORTING
      et_fields = lt_migo_fields.
* Operate on all fields depending on the movement type__________________
  LOOP AT cl_mmim_migo_move_fields=>t_all_cust_fields INTO l_fieldname.
*   Check whether the field is relevant for MvT-dependent
*   field selection in the present status of this line.
*   If not (e.g. EBELN for PO-lines), skip this part of fieldselection.
    CHECK lcl_migo_globals=>kernel->screen_modify_field_relevant(
     i_fieldname = l_fieldname
     is_goitem   = is_goitem ) = abap_true OR s_action-migo_mode = 'GT'.

    CONCATENATE 'GOITEM-'    l_fieldname INTO l_goitemname.
    CONCATENATE 'IS_GOITEM-' l_fieldname INTO l_isgoitemname.

*   New status of the field is always DISPLAY,
*   if it is an accouting field or UM-field
*   (also KONTO) and XACCOUNT-DISP is set.
    CLEAR l_account_disp.
    READ TABLE cl_mmim_migo_move_fields=>t_gocobl1_fields
      WITH KEY table_line = l_fieldname
      TRANSPORTING NO FIELDS.
*   Show accounting field... if account assignment from refdoc,
*   accounting field or KONTO and field not initial
    IF NOT is_goitem-xaccount_disp IS INITIAL AND
        ( sy-subrc = 0 OR l_fieldname = 'KONTO' ).
      l_status = lcl_migo_screenmodification=>c_visible.
*     Store this condition because it prevents the field to be removed
*     by the movement type dependent field selection.
      l_account_disp = abap_true.
    ELSE.
*     Get the current status of the field. Using this method,
*     settings from prior parts of the fieldmodification
*     (e.g. all fields no input in display/cancel) are used
*     also here.
      CALL METHOD lcl_migo_screenmodification=>get
        EXPORTING
          i_field          = l_goitemname
          i_global_counter = is_goitem-global_counter
        RECEIVING
          r_status         = l_status.
    ENDIF.

*   Special rule:
*   1) Special stock E: The accounting fields KDAUF/KDPOS/KDEIN should
*                       never be 'on input'.
*   2) Special stock Q: The accounting field PS_PSP_PNR should
*                       never be 'on input'.
    IF ( is_goitem-sobkz = e OR is_goitem-umsok = e ) AND
       ( l_fieldname = 'KDAUF' OR
         l_fieldname = 'KDPOS'  OR
         l_fieldname = 'KDEIN' ) AND
        l_status = lcl_migo_screenmodification=>c_input.
      l_status = lcl_migo_screenmodification=>c_visible.
    ENDIF.
    IF ( is_goitem-sobkz = t OR is_goitem-umsok = t ) AND        "SIT
       ( l_fieldname = 'KDAUF' OR
         l_fieldname = 'KDPOS'  OR
         l_fieldname = 'VBELN'  OR
         l_fieldname = 'POSNR'  OR
         l_fieldname = 'KDEIN' ) AND
        l_status = lcl_migo_screenmodification=>c_input.
      l_status = lcl_migo_screenmodification=>c_visible.
    ENDIF.
    IF ( is_goitem-sobkz = q OR is_goitem-umsok = q ) AND
        l_fieldname = 'PS_PSP_PNR' AND
        l_status = lcl_migo_screenmodification=>c_input.
      l_status = lcl_migo_screenmodification=>c_visible.
    ENDIF.

*   Now that the status of the field is determined:
*   If display and the field is empty --> delete from screen.
    IF l_status = lcl_migo_screenmodification=>c_visible.
      ASSIGN (l_isgoitemname) TO <f>.
      IF <f> IS INITIAL.
        l_status = lcl_migo_screenmodification=>c_invisible.
      ENDIF.
    ENDIF.
*   UM-fields have to be at least visible to make sure that the content
*   will not be cleared.
    IF l_fieldname = 'UMMAKTX' OR l_fieldname = 'UMMAT' OR
       l_fieldname = 'UMNAME1' OR l_fieldname = 'UMWRK' OR
       l_fieldname = 'UMLGOBE' OR l_fieldname = 'UMLGO' OR
       l_fieldname = 'UMCHA'   OR l_fieldname = 'UMBAR'.
      IF l_status = lcl_migo_screenmodification=>c_invisible.
        l_status = lcl_migo_screenmodification=>c_visible.
      ENDIF.
    ENDIF.

*   change as per note 389612
*   Check whether the movement type allows the presence of a field
*   and/or if field is a required field according to field
*   selection per MIGO_CUST_FIELDS.
    READ TABLE lt_migo_fields INTO ls_migo_fields
               WITH KEY fieldname = l_fieldname.
*   If not currently active for the movement type and not shown
*   because it is an accounting field and we are in display mode
*   for the accounting fields...
    IF sy-subrc <> 0
       AND l_account_disp  = abap_false.
*     Field not in the customizing table --> invisible if field has had
*     a chance to be in customizing table. see note 402360
      CALL FUNCTION 'MIGO_CUST_FIELD_ALLOWED'
        EXPORTING
          i_bwart            = is_goitem-bwart
          i_field            = l_fieldname
          i_check_all_fields = x
        EXCEPTIONS
          not_allowed        = 1
          OTHERS             = 2.
      IF sy-subrc = 0.
        l_status = lcl_migo_screenmodification=>c_invisible.
      ENDIF.
    ELSE.
*     If field is only visible, we can just keep it as visible and no
*     more action is necessary. Only input fields may need to be set
*     as required fields.
      IF l_status >= lcl_migo_screenmodification=>c_input.
*       Set l_status to input. Seems to be not necessary as at
*       this point l_status has c_input at maximum. But we will keep
*       this statement as we will be very sure that there are no
*       required fields on any "screens".
        l_status = lcl_migo_screenmodification=>c_input.
*       And maybe set the REQUIRED flag
        IF ls_migo_fields-entry = '+'.
          CALL METHOD lcl_migo_screenmodification=>set_required
            EXPORTING
              i_field          = l_goitemname
              i_global_counter = is_goitem-global_counter.
        ENDIF.
      ENDIF.
    ENDIF.
*   Set the new status of the field
    l_fields = l_goitemname.
*   Set the new status of the field
    IF is_goitem-tax_relevant = x AND s_control-refdoc = 'R02' "1386330
    AND is_goitem-brazil = x AND s_control-action = 'A10'      "1386330
    AND l_fieldname = 'UMWRK'.                                 "1386330
*if Brazil is active, force the field UMWRK to take the above  "1386330
*determined status. This code must ebentually be replaced when "1386330
*we know why the note 804327 hadn't worked anymore?!           "1386330
        CALL METHOD lcl_migo_screenmodification=>set           "1386330
          EXPORTING                                            "1386330
            i_fields         = l_fields                        "1386330
            i_global_counter = is_goitem-global_counter        "1386330
            i_status         = l_status                        "1386330
            i_mode           = abap_true.                      "1386330
    ELSE.                                                      "1386330
        CALL METHOD lcl_migo_screenmodification=>set           "1386330
          EXPORTING                                            "1386330
            i_fields         = l_fields                        "1386330
            i_global_counter = is_goitem-global_counter        "1386330
            i_status         = l_status.                       "1386330
    ENDIF.                                                     "1386330
  ENDLOOP.

* MOVEMENT TYPE SPECIFIC MODIFICATIONS: DEPENDENT FIELDS
* EXVKW: Set the same status for GODYNPRO-field
  CALL METHOD lcl_migo_screenmodification=>get
    EXPORTING
      i_field          = 'GOITEM-EXVKW'
      i_global_counter = is_goitem-global_counter
    RECEIVING
      r_status         = l_status.
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      i_fields         = 'GODYNPRO-EXVKW'
      i_global_counter = is_goitem-global_counter
      i_status         = l_status.
* END OF MOVEMENT TYPE SPECIFIC MODIFICATIONS___________________________

* Method for additional modifications for lines with subitems
  CALL METHOD screen_modify_automatic_lines
    EXPORTING
      is_goitem = is_goitem.
* Basic rules
  CALL METHOD screen_modify_general_rules
    EXPORTING
      is_goitem = is_goitem.
ENDMETHOD.                    "screen_modify_line

************************************************************************
* Screen modification depending on the status of the model,
* e.g. disabling of table control columns if not necessary.
************************************************************************
METHOD screen_modify_status.
  DATA: ls_dynamic TYPE lcl_migo_screenmodification=>ty_s_dynamic,
        lt_dynamic TYPE lcl_migo_screenmodification=>ty_t_dynamic,
        lt_fields  TYPE ty_t_fieldname,
        l_status   TYPE migo_fs_status.
* Complete rebuild starting with the current MODE-settings
  CALL METHOD lcl_migo_screenmodification=>restore
    EXPORTING
      i_mode           = abap_false
      i_global_counter = 0.
* Disabling elements if no lines in model
  IF s_status-lines = 0.
    CLEAR lt_fields.
    APPEND 'OK_EXPAND_BOM'     TO lt_fields.
    APPEND 'OK_NOT_OK'         TO lt_fields.
    APPEND 'OK_SEARCH'         TO lt_fields.
    APPEND 'OK_SEARCH_NEXT'    TO lt_fields.
    APPEND 'OK_SPLIT_QUANTITY' TO lt_fields.
    APPEND 'OK_SORT_DOWN'      TO lt_fields.
    APPEND 'OK_SORT_UP'        TO lt_fields.
    APPEND 'OK_TAKE_VALUE'     TO lt_fields.
ENHANCEMENT-POINT screen_modify_mode_20 SPOTS es_saplmigo.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        it_fields = lt_fields
        i_status  = lcl_migo_screenmodification=>c_visible.
  ENDIF.
* set fieldsel. for header-fields and buttons (except buttons on 0200)
  CALL METHOD screen_modify_general_rules.
* Disabling elements depending on X-fields in S_STATUS
  CLEAR lt_fields.
  DEFINE def_disable.
    if s_status-&1 = abap_false.
      append &2 to lt_fields.
    endif.
  END-OF-DEFINITION.
* Table control columns
  def_disable xloglight 'GOITEM-LOGLEVEL'.
  def_disable xlinks    'OK_LINKED_DOCUMENTS'.
* Buttons
  def_disable xhum      'OK_HUM'.
* Tabstrips
  def_disable xbatch    'TS_GOITEM_BATCH'.
  def_disable xaccount  'TS_GOITEM_ACCOUNT'.
  def_disable ximport   'TS_GOITEM_IMPORT'.
  def_disable xtaxes    'TS_GOITEM_J1B'.
  def_disable xserial   'TS_GOITEM_SERIAL'.
  def_disable xfreight  'TS_GOITEM_FREIGHT'.
  def_disable xpartners 'TS_GOITEM_PARTNERS'.
  def_disable xnast     'TS_GOITEM_NAST'.
  def_disable xorditem  'TS_GOITEM_ORD_DATA'.
  def_disable xstpoitem 'TS_GOITEM_TRANSFER'.
  def_disable xwm       'TS_GOITEM_WM'.
  def_disable ewm       'TS_GOITEM_EWM'.
  def_disable xpo_sc    'TS_GOITEM_PO_SC'.             "Outsourced Manufacturing EhP 4
  def_disable xresitem  'TS_GOITEM_RES'.
  def_disable xext_int  'TS_GOITEM_EXT_INT'.
  IF ( s_status-xpoitem = abap_false AND
       s_status-xstpoitem = abap_false ) OR
       s_status-lines = 0.
    APPEND 'TS_GOITEM_PO_DATA' TO lt_fields.
  ENDIF.
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      it_fields = lt_fields
      i_status  = lcl_migo_screenmodification=>c_invisible.

* Detail locate fields
  IF s_status-lines = 0 AND s_control-new_line_mode = space.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_fields = 'GODYNPRO-DETAIL_ZEILE OK_LOCATE'
        i_status = lcl_migo_screenmodification=>c_invisible.
  ENDIF.

* Dynamic modification of table control columns.
* We first specify the fields that take part in this method.
* Then we ask the fieldselection to deliver highest status
* for all global counters for the given fields.
* According to this, we disable table control columns.
* WHICH fields take part in this process depends on the developers
* mood.
* I will start with the accounting fields from the table control...
  APPEND 'GOITEM-KOSTL'        TO lt_dynamic.
  APPEND 'GOITEM-AUFNR'        TO lt_dynamic.
  APPEND 'GOITEM-PS_PSP_PNR'   TO lt_dynamic.
  APPEND 'GOITEM-NPLNR'        TO lt_dynamic.
  APPEND 'GOITEM-VORNR'        TO lt_dynamic.
  APPEND 'GOITEM-KDAUF'        TO lt_dynamic.
  APPEND 'GOITEM-KDPOS'        TO lt_dynamic.
  APPEND 'GOITEM-KDEIN'        TO lt_dynamic.
  APPEND 'GOITEM-GSBER'        TO lt_dynamic.
  APPEND 'GOITEM-BUKRS'        TO lt_dynamic.
  APPEND 'GOITEM-ANLN1'        TO lt_dynamic.
  APPEND 'GOITEM-ANLN2'        TO lt_dynamic.
  APPEND 'GOITEM-PRCTR'        TO lt_dynamic.
  APPEND 'GOITEM-KONTO'        TO lt_dynamic.
* ...and others
  APPEND 'OK_DETERMINE'        TO lt_dynamic.
  APPEND 'GOITEM-EXPAND'       TO lt_dynamic.
  APPEND 'OK_DOC_BATCH_DETAIL' TO lt_dynamic.
ENHANCEMENT-POINT screen_modify_mode_21 SPOTS es_saplmigo.

ENHANCEMENT-SECTION     SCREEN_MODIFY_23 SPOTS ES_SAPLMIGO.
  APPEND 'OK_GA_CHANGE_VARIANT' TO lt_dynamic.
  APPEND 'OK_GA_ADD_VARIANT'    TO lt_dynamic.
END-ENHANCEMENT-SECTION.
  CALL METHOD lcl_migo_screenmodification=>dynamic_columns
    CHANGING
      ct_dynamic = lt_dynamic.

* Disable all columns which are invisible.
* The visibility of the column MIGO_OK_DETERMINE also controls
* the button for "stock determination all positions".
  CLEAR lt_fields.
  LOOP AT lt_dynamic INTO ls_dynamic
          WHERE status = lcl_migo_screenmodification=>c_invisible.
    APPEND ls_dynamic-name TO lt_fields.
  ENDLOOP.
ENHANCEMENT-SECTION     SCREEN_MODIFY_24 SPOTS ES_SAPLMIGO.
  IF NOT oref_detail IS INITIAL.
*   Set buttons for generic article
    CALL METHOD ga_buttons_fieldselection( oref_detail->current_line ).
  ENDIF.
END-ENHANCEMENT-SECTION.
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      it_fields        = lt_fields
      i_global_counter = 0
      i_status         = lcl_migo_screenmodification=>c_invisible.
* Button "Determine all"
  CALL METHOD lcl_migo_screenmodification=>get
    EXPORTING
      i_field          = 'OK_DETERMINE'
      i_global_counter = 0
    RECEIVING
      r_status         = l_status.
  IF l_status < lcl_migo_screenmodification=>c_visible.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_fields  = 'OK_DETERMINE_ALL'
        i_one_way = abap_true
        i_status  = lcl_migo_screenmodification=>c_visible.
  ENDIF.
ENDMETHOD.                    "screen_modify_status

************************************************************************
* Automatic lines.
* Mostly disabling/hiding fields which are not modifyable in the
* case of automatic lines or their parents.
************************************************************************
METHOD screen_modify_automatic_lines.
  DATA: lt_fields       TYPE ty_t_fieldname,
        lt_invisible    TYPE ty_t_fieldname,
        lt_fields_struc TYPE ty_t_fieldname,
        l_field      TYPE migo_fieldname.
* tied empty -> all fields but 5 must be disabled; <LG>
  IF is_goitem-xvgtype = c.
    APPEND 'GOITEM-SGTXT'     TO lt_fields.
    APPEND 'GOITEM-EXBWR'     TO lt_fields.
    APPEND 'GOITEM-EANME'     TO lt_fields.
    APPEND 'GOITEM-EAN11_KON' TO lt_fields.
    APPEND 'GOITEM-EAN11_BME' TO lt_fields.
    INSERT lines of lcl_migo_screenmodification=>t_buttons
      INTO TABLE lt_fields.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_inversion      = abap_true
        i_one_way        = abap_true
        it_fields        = lt_fields
        i_global_counter = is_goitem-global_counter
        i_status         = lcl_migo_screenmodification=>c_visible.
  ENDIF.
* generic articles
  IF is_goitem-xgatype = p.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_inversion      = abap_true
        i_one_way        = abap_true
        i_global_counter = is_goitem-global_counter
        i_status         = lcl_migo_screenmodification=>c_visible.
    IF s_action-cancel = abap_false.
      APPEND 'GOITEM-TAKE_IT'       TO lt_fields.
      APPEND 'GODYNPRO-DETAIL_TAKE' TO lt_fields.
    ENDIF.
    IF s_action-return = abap_true OR s_action-cancel = abap_true
       OR is_goitem-retpo = abap_true.
      APPEND 'GOITEM-GRUND'         TO lt_fields.
    ENDIF.
    IF is_goitem-xstock_type_mvt IS INITIAL.
      APPEND 'GOITEM-MIGO_INSMK'    TO lt_fields.
    ENDIF.
    APPEND 'GOITEM-LGOBE'         TO lt_fields.
    APPEND 'GODYNPRO-LGOBE'       TO lt_fields.
    APPEND 'GOITEM-SGTXT'         TO lt_fields.
    APPEND 'GOITEM-UMLGOBE'       TO lt_fields.
    APPEND 'GOITEM-ELIKZ_PO'      TO lt_fields.
    APPEND 'GOITEM-SOBKZ'         TO lt_fields.
    APPEND 'GODYNPRO-SOBKZ'       TO lt_fields.
    APPEND 'GOITEM-UMSOK'         TO lt_fields.
    IF is_goitem-sobkz = k.
      APPEND 'GOITEM-VENDORNAME'       TO lt_fields.
      APPEND 'GODYNPRO-MAT_VENDORNAME' TO lt_fields.
    ENDIF.
    IF  s_action-copy = abap_false.
      APPEND 'GOITEM-UMNAME1'       TO lt_fields.
    ENDIF.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_global_counter = is_goitem-global_counter
        it_fields        = lt_fields
        i_status         = lcl_migo_screenmodification=>c_input.
  ENDIF.
  IF is_goitem-xgatype = c.
    CLEAR: lt_fields.
    APPEND 'GOITEM-BWART'         TO lt_fields.
    APPEND 'GOITEM-NAME1'         TO lt_fields.
    APPEND 'GODYNPRO-MAKTX'       TO lt_fields.
    APPEND 'GODYNPRO-NAME1'       TO lt_fields.
    APPEND 'GOITEM-UMNAME1'       TO lt_fields.
    APPEND 'GOITEM-UMMAKTX'       TO lt_fields.
    APPEND 'GOITEM-SOBKZ'         TO lt_fields.
    APPEND 'GODYNPRO-SOBKZ'       TO lt_fields.
    APPEND 'GOITEM-UMSOK'         TO lt_fields.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_global_counter = is_goitem-global_counter
        it_fields        = lt_fields
        i_status         = lcl_migo_screenmodification=>c_visible.
    IF is_goitem-xcancel_done = abap_false.
      CALL METHOD lcl_migo_screenmodification=>set
        EXPORTING
          i_inversion      = abap_false
          i_one_way        = abap_false
          i_fields         = 'GOITEM-TAKE_IT GODYNPRO-DETAIL_TAKE'
          i_global_counter = is_goitem-global_counter
          i_status         = lcl_migo_screenmodification=>c_input.
    ENDIF.
  ENDIF.
* structured articles
  IF ( is_goitem-xsttype = '10' or
       is_goitem-xsttype = '11' or
       is_goitem-xsttype = '12' ) AND
       is_goitem-parent is initial.

    IF s_action-cancel = abap_false or is_goitem-xcancel_done = abap_false.
      APPEND 'GODYNPRO-DETAIL_TAKE' TO lt_fields.
      APPEND 'GOITEM-TAKE_IT'       TO lt_fields.
    ENDIF.
*    if is_goitem-lgort is initial.
    APPEND 'GOITEM-LGOBE'         TO lt_fields.
    APPEND 'GODYNPRO-LGOBE'       TO lt_fields.
*    endif.
    IF s_action-return = abap_true OR s_action-cancel = abap_true
       OR is_goitem-retpo = abap_true.
      APPEND 'GOITEM-GRUND'         TO lt_fields.
    ENDIF.
    APPEND 'GOITEM-GRUND'         TO lt_fields.
    APPEND 'GOITEM-KONTO'         TO lt_fields.
    APPEND 'GOITEM-CHARG'         TO lt_fields.
    APPEND 'GOITEM-SGTXT'         TO lt_fields.
    APPEND 'GOITEM-ELIKZ_PO'      TO lt_fields.
    APPEND 'GOITEM-MIGO_ELIKZ'    TO lt_fields.
    APPEND 'GOITEM-ERFME'         TO lt_fields.
    APPEND 'GOITEM-ERFMG'         TO lt_fields.
    APPEND 'OK_STOCK_OVERVIEW'    TO lt_fields.
    APPEND 'OK_STOCK_OVER_LEFT'   TO lt_fields.
    APPEND 'OK_STOCK_OVER_RIGHT'  TO lt_fields.

*   it is not allowed to change the stock type if the components
*   are expanded.
    IF is_goitem-xstock_type_mvt IS INITIAL.
      READ TABLE pt_goitem
        WITH KEY parent    = is_goitem-global_counter
               xsttype   = c
               TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        APPEND 'GOITEM-MIGO_INSMK'    TO lt_fields.
      endif.
    ENDIF.

    lt_fields_struc[] = lt_fields[].

    APPEND 'GOITEM-VENDORNAME'        TO lt_fields_struc.
    APPEND 'GODYNPRO-MAT_VENDORNAME'  TO lt_fields_struc.
    APPEND 'GOITEM-BWTAR'             TO lt_fields_struc.
    APPEND 'GODYNPRO-BWTAR'           TO lt_fields_struc.
    APPEND 'GOITEM-VENDORNAME'        TO lt_fields_struc.
    APPEND 'GOITEM-UMNAME1'           TO lt_fields_struc.
    APPEND 'GOITEM-UMLGOBE'           TO lt_fields_struc.
    APPEND 'GOITEM-UMWRK'             TO lt_fields_struc.
    APPEND 'GOITEM-UMLGO'             TO lt_fields_struc.
    APPEND 'GOITEM-UMNAME1'           TO lt_fields_struc.
    APPEND 'GOITEM-UMLGOBE'           TO lt_fields_struc.
    APPEND 'GODYNPRO-UMBAR'           TO lt_fields_struc.
    APPEND 'GOITEM-UMBAR'             TO lt_fields_struc.
*Begin of note  1029042 Cost Center not mandatory in MIGO_GI
    APPEND 'GOITEM-KOSTL'             TO lt_fields_struc.
*END   of note  1029042
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_inversion      = abap_true
        i_one_way        = abap_true
        it_fields        = lt_fields_struc
        i_global_counter = is_goitem-global_counter
        i_status         = lcl_migo_screenmodification=>c_visible.

    IF lcl_migo_globals=>retail_consignment_active = abap_true.
      APPEND 'GOITEM-VENDORNAME'  TO lt_fields.
      APPEND 'GODYNPRO-MAT_VENDORNAME' TO lt_fields.
    ENDIF.

    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_global_counter = is_goitem-global_counter
        it_fields        = lt_fields
        i_status         = lcl_migo_screenmodification=>c_input.
  ENDIF.
  IF is_goitem-xsttype = c.
    CLEAR: lt_fields.

    APPEND 'OK_STOCK_OVERVIEW'    TO lt_fields.
    APPEND 'OK_STOCK_OVER_LEFT'   TO lt_fields.
    APPEND 'OK_STOCK_OVER_RIGHT'  TO lt_fields.

    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_inversion      = abap_true
        i_one_way        = abap_true
        i_global_counter = is_goitem-global_counter
        it_fields        = lt_fields
        i_status         = lcl_migo_screenmodification=>c_visible.
    clear: lt_fields.

    APPEND 'GOITEM-UMNAME1'       TO lt_fields.
    APPEND 'GOITEM-UMLGOBE'       TO lt_fields.
    APPEND 'GOITEM-UMWRK'         TO lt_fields.
    APPEND 'GOITEM-UMLGO'         TO lt_fields.

    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_global_counter = is_goitem-global_counter
        it_fields        = lt_fields
        i_status         = lcl_migo_screenmodification=>c_visible.

    clear lt_fields.
    APPEND 'OK_STOCK_OVERVIEW'    TO lt_fields.
    APPEND 'OK_STOCK_OVER_LEFT'   TO lt_fields.
    APPEND 'OK_STOCK_OVER_RIGHT'  TO lt_fields.

    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_inversion      = abap_false
        i_one_way        = abap_true
        it_fields        = lt_fields
        i_global_counter = is_goitem-global_counter
        i_status         = lcl_migo_screenmodification=>c_input.
  ENDIF.
  IF is_goitem-xvastype = c.
    CLEAR: lt_fields.
    APPEND 'GOITEM-ERFME'       TO lt_fields.
    APPEND 'GOITEM-BWART'       TO lt_fields.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_global_counter = is_goitem-global_counter
        it_fields        = lt_fields
        i_status         = lcl_migo_screenmodification=>c_visible.
  ENDIF.
* Value added services
  IF is_goitem-xvastype = p.
    CLEAR: lt_fields.
    APPEND 'GOITEM-ERFMG'       TO lt_fields.
    APPEND 'GOITEM-ERFME'       TO lt_fields.
    APPEND 'GOITEM-BWART'       TO lt_fields.
    IF is_goitem-expand = c_icon_collapse.
      CALL METHOD lcl_migo_screenmodification=>set
        EXPORTING
          i_global_counter = is_goitem-global_counter
          it_fields        = lt_fields
          i_status         = lcl_migo_screenmodification=>c_visible.
    ELSEIF is_goitem-expand = c_icon_expand.
      CALL METHOD lcl_migo_screenmodification=>set
        EXPORTING
          i_global_counter = is_goitem-global_counter
          it_fields        = lt_fields
          i_status         = lcl_migo_screenmodification=>c_input.
    ENDIF.
  ENDIF.
* Bill of materials: Header position only for display. We allow
* modification of TAKE_IT. This is automatically transferred
* to all children.
  IF is_goitem-xbomtype = p.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_inversion      = abap_true
        i_one_way        = abap_true
        i_fields         = 'GOITEM-TAKE_IT GODYNPRO-DETAIL_TAKE'
        i_global_counter = is_goitem-global_counter
        i_status         = lcl_migo_screenmodification=>c_visible.
  ENDIF.

* Items of subcontracting:
  IF is_goitem-xlbtype = c.
    APPEND 'GOITEM-TAKE_IT'       TO lt_fields.
    APPEND 'GODYNPRO-DETAIL_TAKE' TO lt_fields.
    APPEND 'OK_DETERMINE'         TO lt_fields.
    APPEND 'GOITEM-ERFMG'         TO lt_fields.
    APPEND 'GOITEM-ERFME'         TO lt_fields.
    APPEND 'GOITEM-CHARG'         TO lt_fields.
    APPEND 'GOITEM-DOCUBATCH_CHARG' TO lt_fields.
    APPEND 'OK_DOC_BATCH_DETAIL'  TO lt_fields.
    APPEND 'GOITEM-SC_ADJUST'     TO lt_fields.
*   allow 'create serial nos automatically'                      "917833
    IF s_action-migo_mode = 'GR' AND is_goitem-shkzg_migo = '+'. "917833
      APPEND 'GOITEM-XSAUT'       TO lt_fields.             "917833
    ENDIF.                                                  "917833
ENHANCEMENT-POINT lmigoks4_16 SPOTS es_saplmigo.
    "$$
    CASE is_goitem-sobkz.
      WHEN 'E'.
        APPEND 'GOITEM-LGORT'     TO lt_fields.
        APPEND 'GOITEM-LGOBE'     TO lt_fields.
        APPEND 'GOITEM-MAT_KDAUF' TO lt_fields.
        APPEND 'GOITEM-MAT_KDPOS' TO lt_fields.
      WHEN 'Q'.
        APPEND 'GOITEM-LGORT'     TO lt_fields.
        APPEND 'GOITEM-LGOBE'     TO lt_fields.
        APPEND 'GOITEM-MAT_PSPNR' TO lt_fields.
    ENDCASE.
    IF is_goitem-brazil = x AND is_goitem-tax_relevant = x.
      APPEND 'GOITEM-J_1BEXBASE' TO lt_fields.
      APPEND 'GOITEM-MWSKZ' TO lt_fields.
      CALL METHOD oref_nota_fiscal->j_1b_set_subcontr
        EXPORTING
          i_subcontr = abap_true.
    ENDIF.
    APPEND 'GOITEM-BWTAR' TO lt_fields.
*   All fields which are customizeable by movement type
    LOOP AT cl_mmim_migo_move_fields=>t_all_cust_fields INTO l_field.
*     All fields? No, not all fields. Of course there are exceptions.
      IF l_field = 'EBELN'      OR
         l_field = 'EBELP'      OR
         l_field = 'KUNNR'      OR
         l_field = 'CUSTNAME'   OR
         l_field = 'LIFNR'      OR
         l_field = 'VENDORNAME'.
        CONTINUE.
      ENDIF.
      CONCATENATE 'GOITEM-' l_field INTO l_field.
      INSERT l_field INTO TABLE lt_fields.
    ENDLOOP.
*   Buttons for displaying
    INSERT lines of lcl_migo_screenmodification=>t_buttons
      INTO TABLE lt_fields.

*   Making HSDAT/VFDAT open for input if exp. date check is needed.
* note 712891 start
    CLEAR l_field.
    IF  NOT is_goitem-xwmhd IS INITIAL AND NOT is_goitem-kzmhd IS
        INITIAL AND NOT is_goitem-kzwes = s AND NOT is_goitem-mhdrz
          IS INITIAL AND is_goitem-shkzg_migo = '+'.
      l_field = 'GOITEM-HSDAT'.
      INSERT l_field INTO TABLE lt_fields.
      l_field = 'GOITEM-VFDAT' .
      INSERT l_field INTO TABLE lt_fields.
    ENDIF.
* note 712891 end

    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_inversion      = abap_true
        i_one_way        = abap_true
        it_fields        = lt_fields
        i_global_counter = is_goitem-global_counter
        i_status         = lcl_migo_screenmodification=>c_visible.
*   Invisible fields
    APPEND 'GOITEM-ANZGEB' TO lt_invisible.
    APPEND 'GOITEM-GEBEH'  TO lt_invisible.
    APPEND 'GOITEM-LSMEH'  TO lt_invisible.
    APPEND 'GOITEM-LSMNG'  TO lt_invisible.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_global_counter = is_goitem-global_counter
        it_fields        = lt_invisible
        i_status         = lcl_migo_screenmodification=>c_invisible.
  ENDIF.

* for maa items anzgeb can't be split, to be added to accounting screen
  IF NOT is_goitem-xhistma IS INITIAL.                         "MAA2
     APPEND 'GOITEM-ANZGEB' TO lt_invisible.                   "MAA2
     APPEND 'GOITEM-GEBEH'  TO lt_invisible.                   "MAA2
     CALL METHOD lcl_migo_screenmodification=>set              "MAA2
      EXPORTING                                                "MAA2
        i_global_counter = is_goitem-global_counter            "MAA2
        it_fields        = lt_invisible                        "MAA2
        i_status         = lcl_migo_screenmodification=>c_invisible."MAA2
  ENDIF.                                                       "MAA2

ENDMETHOD.                    "screen_modify_automatic_lines

************************************************************************
* Screen modification: general rules (former screen-group3)
* Attention: seperate coding for header and goitem
* 1.) Invisible if initial (old group3=2)
* Other rules are not necessary anymore.
************************************************************************
METHOD screen_modify_general_rules.
  DATA: lt_fields TYPE ty_t_fieldname,
        lt_visible     TYPE ty_t_fieldname,
        lt_input       TYPE ty_t_fieldname.

* RULE 1: Invisible if initial..........................................
* Macro: check header fields
  DEFINE def_check.
    if ps_&1 is initial.
      append '&1' to lt_fields.
    endif.
* Macro: check goitem fields
  END-OF-DEFINITION.
  DEFINE def_check1.
    if is_&1 is initial.
      append '&1' to lt_fields.
    endif.
  END-OF-DEFINITION.

  IF is_goitem IS INITIAL.
*   Header-fields or buttons: No input fields here!!
    def_check  gohead-lifnr.       def_check  gohead-recvendname.
    def_check  gohead-supvendname.
    def_check  gohead-buyer.       def_check  gohead-telnr1.
    def_check  gohead-pousername.  def_check  gohead-telpouser.
    def_check  gohead-vendoradd.   def_check  gohead-vendorname.
    def_check  gohead-vendorzip.
    def_check  gohead-reswk.       def_check  gohead-reswkname.
    def_check  gohead-createdby.   def_check  gohead-telusnam.
    def_check  gohead-cpudt.       def_check  gohead-cputm.
    def_check  gohead-aedat.
    def_check  gohead-tcode2.      def_check  gohead-ttext.
    IF ps_gohead-loglevel IS INITIAL.
      APPEND 'LOGTEXT'         TO lt_fields.
      APPEND 'GOHEAD-LOGLEVEL' TO lt_fields.
    ENDIF.
    IF ps_gohead-mblnr IS INITIAL.
      APPEND 'OK_FI_DOC' TO lt_fields.
    ENDIF.
*   Print fields in display mode
    IF s_control-vgart IS INITIAL.
      APPEND 'GODYNPRO-PRINT_TEXT' TO lt_fields.
      APPEND 'GOHEAD-XNAPR'        TO lt_fields.
      APPEND 'GOHEAD-WEVER'        TO lt_fields.
    ELSE.
*     Icon print always visible if VGART is set
      APPEND 'GODYNPRO-PRINT_TEXT' TO lt_visible.
      IF s_action-create = abap_true.
        APPEND 'GOHEAD-XNAPR' TO lt_input.
        APPEND 'GOHEAD-WEVER' TO lt_input.
      ELSEIF s_action-display = abap_true.
*       Not printed yet: input
        IF ps_gohead-xnapr IS INITIAL.
          APPEND 'GOHEAD-XNAPR' TO lt_input.
          APPEND 'GOHEAD-WEVER' TO lt_input.
*       Already printed: display only
        ELSE.
          APPEND 'GOHEAD-XNAPR' TO lt_visible.
          APPEND 'GOHEAD-WEVER' TO lt_visible.
        ENDIF.
      ENDIF.
    ENDIF.
* End of general rules for header fields ---------------------------
  ELSE.
*   goitem-fields: never enter an input field here!!
    def_check1 goitem-afnam.       def_check1 goitem-afnam_tel.
    def_check1 goitem-wempf_tel.
    def_check1 goitem-aktnr.
    def_check1 goitem-bsmng.       def_check1 goitem-bstme.
    def_check1 goitem-inco1.       def_check1 goitem-inco2.
    def_check1 goitem-lfbnr.       def_check1 goitem-lfpos.
    def_check1 goitem-lgpbe.
    def_check1 goitem-matbf.       def_check1 goitem-matkl.
    def_check1 goitem-qinspst.
    def_check1 goitem-emlif.       def_check1 goitem-recvendname.
    def_check1 goitem-llief.       def_check1 goitem-supvendname.
    def_check1 goitem-reswk.       def_check1 goitem-reswkname.
    def_check1 goitem-retpo.       def_check1 goitem-shkzg_migo.
    def_check1 goitem-lifnr.       def_check1 goitem-kunnr.
    def_check1 goitem-evers.
*   SOBKZ IS an input field --> cannot be here
    def_check1 goitem-umsok.
    def_check1 goitem-wamng.       def_check1 goitem-wamme.
    def_check1 goitem-wemng.
ENHANCEMENT-SECTION     lmigoks4_17 SPOTS es_saplmigo.
    "$$
    def_check1 goitem-dmbtr.       def_check1 goitem-vkwrt.
END-ENHANCEMENT-SECTION.
    "$$
    def_check1 goitem-txjcd.
    def_check1 goitem-res_adrname.
    def_check1 goitem-res_telusername.
    def_check1 goitem-sotxt.
    def_check1 goitem-umsotxt.
    def_check1 goitem-zustd.
    def_check1 goitem-umzst.
    def_check1 goitem-leindt.
  ENDIF.
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      it_fields        = lt_visible
      i_global_counter = is_goitem-global_counter
      i_status         = lcl_migo_screenmodification=>c_visible.
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      it_fields        = lt_fields
      i_global_counter = is_goitem-global_counter
      i_status         = lcl_migo_screenmodification=>c_invisible.
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      it_fields        = lt_input
      i_global_counter = is_goitem-global_counter
      i_status         = lcl_migo_screenmodification=>c_input.

ENDMETHOD.                    "screen_modify_general_rules
************************************************************************
* Checks a field for relevance in the current context of MIGO
* Necessary as some fields are in the MvT-dependent field selection,
* but in some cases this has to be ignored.
************************************************************************
METHOD screen_modify_field_relevant.
  r_relevant = abap_true.
  CASE i_fieldname.
    WHEN 'EBELN' OR 'EBELP'.
      IF is_goitem-xpoitem = abap_true OR
         is_goitem-kzzug   = abap_true OR
         s_action-sc_comp  = abap_true.            "Outsourced Manufacturing EhP 4
        r_relevant = abap_false.
      ENDIF.
    WHEN 'KUNNR' OR 'CUSTNAME'.
      IF is_goitem-xpoitem = abap_true OR
         is_goitem-sobkz CA 'VW'.
        r_relevant = abap_false.
      ENDIF.
    WHEN 'LIFNR' OR 'VENDORNAME'.
      IF is_goitem-xpoitem = abap_true OR
         is_goitem-sobkz CA 'KPOM'.
        r_relevant = abap_false.
      ENDIF.
  ENDCASE.
ENDMETHOD.                    "screen_modify_field_relevant