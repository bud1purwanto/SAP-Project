*&---------------------------------------------------------------------*
*&      Module  J_1B_TX_TAX_PROC_SET  OUTPUT
*&---------------------------------------------------------------------*
MODULE j_1b_tx_tax_proc_set OUTPUT.

  PERFORM j_1b_tax_proc_set.             "Note 205012

ENDMODULE.                             " J_1B_TX_TAX_PROC_SET  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  J_1B_TX_CALCULATE_INIT
*&---------------------------------------------------------------------*
FORM j_1b_tx_calculate_init.

  CHECK brazil     = x.
  CALL FUNCTION 'J_1B_IM_TX_CALCULATE_INIT'
    EXPORTING
      i_mseg = mseg.

ENDFORM.                               " J_1B_TX_CALCULATE_INIT
* begin of note 886530
*&---------------------------------------------------------------------*
*&      Form  J_1B_TX_NBM_CODE_SAVE
*&---------------------------------------------------------------------*
FORM j_1b_tx_nbm_code_save.

  CHECK brazil     = x.
  CALL FUNCTION 'J_1B_IM_TX_NBM_CODE_SAVE'
       EXPORTING
            i_mseg = mseg.

ENDFORM.                               " J_1B_TX_NBM_CODE_SAVE
* end of note 886530
*---------------------------------------------------------------------*
*       FORM J_1B_TX_CANCEL
*---------------------------------------------------------------------*
FORM j_1b_tx_cancel.

  CHECK brazil      = x.
  CHECK t158-trtyp  = h.
* check if cancel
  CHECK vm07m-xstor = zwei.

* set tax data for cancel action
  CALL FUNCTION 'J_1B_IM_NF_CANCEL_TAXES'
    EXPORTING
      i_mkpf = mkpf                                         "688999
      i_mseg = mseg
      i_t001 = t001                                         "688999
    EXCEPTIONS
      OTHERS = 1.

ENDFORM.                               " J_1B_TX_CANCEL
*---------------------------------------------------------------------*
*       FORM J_1B_NF_DOCUMENT_GENERATE
*---------------------------------------------------------------------*
FORM j_1b_nf_document_generate.

  DATA: lv_tfill TYPE sy-tfill.                        "note 599294

  CHECK brazil     = x.
  IF NOT mbval IS INITIAL.
    MESSAGE e324.
  ENDIF.

*--> zmseg and xmseg might have different lines      "note 599294
*--> which leads to error 8B150 when the item values "note 599294
*--> for comparison of material_values and           "note 599294
*--> current_values are read from YDM07M in form     "note 599294
*--> create_nota_fiscal                              "note 599294
  DESCRIBE TABLE zmseg LINES lv_tfill.               "note 599294
  DESCRIBE TABLE xmseg LINES sy-tfill.               "note 599294
  lv_tfill = lv_tfill - sy-tfill.                    "note 599294

  CALL FUNCTION 'J_1B_IM_NF_DOCUMENT_GENERATE'
       EXPORTING
            i_mkpf   = mkpf
            i_tfill  = lv_tfill                      "note 599294
       TABLES
            i_ymseg  = ymseg
*del        i_xmseg  = zmseg              "note 523094
            i_xmseg  = xmseg              "note 523094
* here is the ZMSEG missing (it has the best information)
* xmseg,ymseg have old data -> don't use them
*           i_yvm07m = yvm07m    "yvm07m has not all data
            i_yvm07m = zvm07m
*           i_ydm07m = ydm07m    "ydm07m has not all data
            i_ydm07m = zdm07m
            i_xmkpf  = xmkpf.

ENDFORM.                               " J_1B_NF_DOCUMENT_GENERATE

*---------------------------------------------------------------------*
*       FORM J_1B_NF_DOCUMENT_SAVE
*---------------------------------------------------------------------*
FORM j_1b_nf_document_save.

  CHECK brazil     = x.
  CALL FUNCTION 'J_1B_IM_NF_DOCUMENT_SAVE'
    TABLES
      i_zmseg  = zmseg
      i_xmkpf  = xmkpf
      i_xmseg  = xmseg
      i_xvm07m = xvm07m
      i_ymbuz  = ymbuz
      i_zdm07m = zdm07m
      i_acchd  = xacchd                    "note 364543
      i_accit  = xaccit                    "note 364543
      i_acccr  = xacccr.                   "note 364543

  CALL FUNCTION 'J_1B_IM_NF_REFRESH'.      "note 918296

* initialize posting string for taxes                      "note 1016392
  DELETE x156w WHERE bustw = mseg-bustw                    "note 1016392
                 AND cnt02 >= 50                           "note 1016392
                 AND cnt02 <= 90.                          "note 1016392

ENDFORM.                               " J_1B_NF_DOCUMENT_SAVE

*---------------------------------------------------------------------*
*       FORM J_1B_NF_DOCUMENT_FUNCTION
*---------------------------------------------------------------------*
FORM j_1b_nf_document_function.
  DATA: active TYPE c,                 "component active
        l_msg  LIKE fimsg,
        BEGIN OF ini_companies OCCURS 1,           "initiating companies
           bukrs LIKE mseg-bukrs,
        END OF ini_companies.

  IF t158-trtyp = h.
    CHECK brazil = x.
  ELSE.
    CLEAR active.
    REFRESH: ini_companies.
    LOOP AT ymseg.
      ini_companies-bukrs = ymseg-bukrs.
      COLLECT ini_companies.
    ENDLOOP.

    LOOP AT ini_companies.
      CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
        EXPORTING
          bukrs                = ini_companies-bukrs
          component            = 'BR'
        EXCEPTIONS
          component_not_active = 4.
      IF sy-subrc = 0.
        active = 'X'.
      ENDIF.
    ENDLOOP.
    CHECK active = 'X'.
  ENDIF.

  CALL FUNCTION 'J_1B_IM_NF_DOCUMENT_FUNCTION'
    EXPORTING
      i_mkpf         = mkpf
    TABLES
      i_ymseg        = ymseg
      i_yvm07m       = yvm07m
      i_ydm07m       = ydm07m
    CHANGING
      i_msg          = l_msg
    EXCEPTIONS
      error_handling = 1.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE ID     l_msg-msgid
            TYPE   l_msg-msgty
            NUMBER l_msg-msgno
            WITH   l_msg-msgv1 l_msg-msgv2 l_msg-msgv3 l_msg-msgv4.
  ENDIF.

ENDFORM.                               " J_1B_NF_DOCUMENT_FUNCTION

*---------------------------------------------------------------------*
*       FORM J_1B_NF_DOCUMENT_FUNC_CHECK
*---------------------------------------------------------------------*
FORM j_1b_nf_document_func_check.
  DATA: active TYPE c,                 "component active.
        BEGIN OF ini_companies OCCURS 1,           "initiating companies
           bukrs LIKE mseg-bukrs,
        END OF ini_companies.

  IF t158-trtyp = h.
    IF brazil IS INITIAL.
      excl-funktion = 'J1BA'.
      APPEND excl.
    ENDIF.
    CHECK brazil = x.
* Transfer via SD/MM
*del IF ( NOT storno IS INITIAL ) AND ( sy-dynnr = '0221' ).
*--- storno is also set for return deliveries. In this case ---
*--- the NF button must appear! Exclusion via TCODE         ---
    IF sy-tcode = 'MBST'.
      excl-funktion = 'J1BA'.
      APPEND excl.
* check NF relevance of movement type,
* which has to be cancelled
      CALL FUNCTION 'J_1B_IM_NFREL'
        EXCEPTIONS
          not_nfrel = 1
          OTHERS    = 2.
      IF sy-subrc IS INITIAL.
* do not allow the navigation
        excl-funktion = 'SELE'.
        APPEND excl.
        excl-funktion = 'SELN'.
        APPEND excl.
        excl-funktion = 'SEUE'.
        APPEND excl.
        excl-funktion = 'SP  '.
        APPEND excl.
        IF sy-dynnr = '0421'.            "1506904
          excl-funktion = 'SETN'.        "1506904
          APPEND excl.                   "1506904
        ENDIF.
      ENDIF.
    ENDIF.
*
  ELSE.
    CLEAR active.
    REFRESH: ini_companies.
    LOOP AT ymseg.
      ini_companies-bukrs = ymseg-bukrs.
      COLLECT ini_companies.
    ENDLOOP.

    LOOP AT ini_companies.
      CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
        EXPORTING
          bukrs                = ini_companies-bukrs
          component            = 'BR'
        EXCEPTIONS
          component_not_active = 4.
      IF sy-subrc = 0.
        active = 'X'.
      ENDIF.
    ENDLOOP.
    IF active IS INITIAL.
      excl-funktion = 'J1BA'.
      APPEND excl.
    ENDIF.
    CHECK active = 'X'.
  ENDIF.

  CALL FUNCTION 'J_1B_IM_NF_DOCUMENT_FUNC_CHECK'
    EXPORTING
      i_mkpf                = mkpf
    TABLES
      i_ymseg               = ymseg
      i_yvm07m              = yvm07m
      i_ydm07m              = ydm07m
    EXCEPTIONS
      function_not_relevant = 4
      OTHERS                = 8.
  IF sy-subrc <> 0.
    excl-funktion = 'J1BA'.
    APPEND excl.
  ENDIF.

ENDFORM.                               " J_1B_NF_DOCUMENT_FUNC_CHECK

*---------------------------------------------------------------------*
*       FORM J_1B_ERROR_CONTROL
*---------------------------------------------------------------------*
* this is a call back function only
FORM j_1b_error_control.

  fcode_next = 'AB'.

ENDFORM.                               " J_1B_ERROR_CONTROL

*&---------------------------------------------------------------------*
*&      Module  J_1B_TX_TAX_CODE_CHECK  INPUT
*&---------------------------------------------------------------------*
MODULE j_1b_tx_tax_code_check INPUT.

  CHECK brazil     = x.
  CHECK t158-trtyp = h.
  CALL FUNCTION 'J_1B_IM_TX_TAX_CODE_CHECK'
    EXPORTING
      i_mkpf  = mkpf
      i_mseg  = mseg
      i_dm07m = dm07m
      i_vm07m = vm07m
      i_t156  = t156.

ENDMODULE.                             " J_1B_TX_TAX_CODE_CHECK  INPUT

*&---------------------------------------------------------------------*
*&      Module  J_1B_NF_COMPARISON_CLEAR  INPUT
*&---------------------------------------------------------------------*
MODULE j_1b_nf_comparison_clear INPUT.

  CHECK brazil     = x.
  CHECK t158-trtyp = h.
  CALL FUNCTION 'J_1B_IM_NF_COMPARISON_CLEAR'
    EXPORTING
      i_mkpf  = mkpf
      i_mseg  = mseg
      i_dm07m = dm07m
      i_vm07m = vm07m.

ENDMODULE.                             " J_1B_NF_COMPARISON_CLEAR  INPUT

*&---------------------------------------------------------------------*
*&      Module  J_1B_NF_EXBASE_CHECK  INPUT
*&---------------------------------------------------------------------*
MODULE j_1b_nf_exbase_check INPUT.

  CHECK brazil     = x.
  CHECK t158-trtyp = h.
  CHECK mseg-smbln IS INITIAL.                              "note 212177
  CALL FUNCTION 'J_1B_IM_NF_EXBASE_CHECK'
    EXPORTING
      i_mkpf          = mkpf
      i_mseg          = mseg
      i_dm07m         = dm07m
      i_vm07m         = vm07m
    EXCEPTIONS
      exbase_required = 1.
  IF sy-subrc = 1.
    SET CURSOR FIELD 'MSEG-J_1BEXBASE'.
    MESSAGE e288(8b).
*   Enter an alternative base
  ENDIF.



ENDMODULE.                             " J_1B_NF_EXBASE_CHECK  INPUT

*&---------------------------------------------------------------------*
*&      Module  J_1B_TX_MWSKZ_CHECK  INPUT
*&---------------------------------------------------------------------*
MODULE j_1b_tx_mwskz_check INPUT.

  DATA: company LIKE t001-bukrs.

  CHECK brazil     = x.
  CHECK t158-trtyp = h.
  IF mseg-bukrs IS INITIAL.
***** find company code based on plant
    CALL FUNCTION 'J_1B_COMPANY_DETERMINE'
      EXPORTING
        plant   = mseg-werks
      IMPORTING
        company = company
      EXCEPTIONS
        OTHERS  = 8.
  ELSE.
    company = mseg-bukrs.
  ENDIF.

  CALL FUNCTION 'J_1B_IM_TX_TAX_PROC_SET'
    EXPORTING
      i_mkpf    = mkpf
      i_mseg    = mseg
      i_dm07m   = dm07m
      i_vm07m   = vm07m
      i_company = company
    IMPORTING
      i_dm07m   = dm07m.
  CALL FUNCTION 'J_1B_IM_TX_MWSKZ_CHECK'
    EXPORTING
      i_mkpf         = mkpf
      i_mseg         = mseg
      i_dm07m        = dm07m
      i_vm07m        = vm07m
    EXCEPTIONS
      mwskz_required = 1.
  IF sy-subrc = 1.
     IF sy-batch = ' ' AND sy-binpt = ' '.   "1553494
      SET CURSOR FIELD 'MSEG-MWSKZ'.         "1553494
      MESSAGE e289(8b).                      "1553494
*     Enter a tax code
    ELSE.                                    "1553494
      MESSAGE w289(8b).                      "1553494
    ENDIF.                                   "1553494
  ENDIF.

ENDMODULE.                             " J_1B_TX_MWSKZ_CHECK  INPUT
*&---------------------------------------------------------------------*
*&      Module  J_1B_TX_CANCEL  INPUT
*&---------------------------------------------------------------------*
MODULE j_1b_tx_cancel INPUT.

  PERFORM j_1b_tx_cancel.

ENDMODULE.                             " J_1B_TX_CANCEL  INPUT
*&---------------------------------------------------------------------*
*&      Module  J_1B_SET_MD_NUMBER  INPUT
*&---------------------------------------------------------------------*
MODULE j_1b_set_md_docnum INPUT.

  DATA: old_budat TYPE mkpf-budat.

  CHECK brazil     = x.

* Automatically determine tax code in case of goods receipt of stock
* transfer or returns of stock transfer
  IF fcode = 'SU' OR fcode = 'SUU'
    OR fcode = 'RL' OR fcode = 'SSR'
    OR fcode = 'KL'.                                  "note 967968
*   Switch tax code from incoming to outgoing and vice versa.
    CALL FUNCTION 'J_1B_IM_SWITCH_TAXCODE_IN_OUT'
      EXPORTING
        i_fcode  = fcode
      TABLES
        t_imitem = fuss[].

* Put NF number, series, subseries in XBLNR of the material
* document of the goods receipt that is going to be posted.
* Is the referenced material document a return of stock transfer?
* If yes, sy-subrc <> 0.
    CALL FUNCTION 'J_1B_IM_NF_CHECK_RETURN_MD'
      EXPORTING
        i_mseg    = mseg
        i_fcode   = fcode
      IMPORTING
        e_budat   = old_budat
        e_xblnr   = mkpf-xblnr
      EXCEPTIONS
        return_nf = 1
        OTHERS    = 2.

    IF sy-subrc = 1.
*     Goods receipt of a return of stock transfer.

*     In case of returns of stock transfers,
*     set a flag in the function group where the Brazilian tax
*    calculation is done which indicates that "ship-from" and "ship-to"
*     have to be swapped. Store the date of the original document.
      CALL FUNCTION 'J_1B_SET_SF_ST_SWAP_FLAG'
        EXPORTING
          i_flag = 'X'
          i_date = old_budat.

*     Store the number and year of the material document of the
*     goods issue in order to determine the price from the original
*     nota fiscal later on.
*     Built in with Note 636984.
      CALL FUNCTION 'J_1B_IM_STORE_RETDOC'
        EXPORTING
          iv_mblnr = mseg-mblnr
          iv_mjahr = mseg-mjahr.

    ELSEIF fcode = 'RL' OR fcode = 'SSR'.
*     Goods Issue of a return of stock transfer

      if not mseg-umwrk is initial.                        "Note 967965
*     See comment above for this function call
      CALL FUNCTION 'J_1B_SET_SF_ST_SWAP_FLAG'
        EXPORTING
          i_flag = 'X'
          i_date = xmkpf-budat.
      endif.                                               "Note 967965
    ENDIF.
  ENDIF.
*Transfer SD/MM - before cancellation.
  IF NOT storno IS INITIAL.

    CALL FUNCTION 'J_1B_IM_TF_PREPARE_CAN'
      EXPORTING
        i_bwart     = mseg-bwart
        i_br_active = brazil
      TABLES
        t_imitem    = fuss[].
  ENDIF.
*
  CALL FUNCTION 'J_1B_IM_TX_SET_MD_DOCNUM'
    EXPORTING
      i_mkpf    = xmkpf
      i_message = space
    EXCEPTIONS
      OTHERS    = 1.

ENDMODULE.                             " J_1B_GET_MD_NUMBER  INPUT
*&---------------------------------------------------------------------*
*&      module  j_1b_set_md_docnum_x  input
*&---------------------------------------------------------------------*
MODULE j_1b_set_md_docnum_x INPUT.

  CHECK brazil     = x.
  CALL FUNCTION 'J_1B_IM_TX_SET_MD_DOCNUM'
    EXPORTING
      i_mkpf    = xmkpf
      i_message = 'X'
    EXCEPTIONS
      OTHERS    = 1.

ENDMODULE.                             " J_1B_SET_MD_DOCNUM_X  INPUT

*&---------------------------------------------------------------------*
*&      Module  J_1B_IM_TF_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE j_1b_im_tf_check INPUT.

  CHECK brazil = x.
  PERFORM j_1b_im_tf_check.

ENDMODULE.                             " J_1B_IM_TF_CHECK  INPUT


*&---------------------------------------------------------------------*
*&      Form  J_1B_IM_TF_CHECK
*&---------------------------------------------------------------------*
* check movement type, delivery doc, transfer order are relevant for
* transfer process via SD/MM
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM j_1b_im_tf_check.

  DATA: l_tf_active(1) TYPE c,
        l_tf_lfsnr LIKE rm07m-lfsnr.

  CHECK brazil = x.
* check movement type
  CALL FUNCTION 'J_1B_IM_TF_BWART_RELEVANT'
    EXPORTING
      i_br_active = brazil
      i_bwart     = rm07m-bwart
    IMPORTING
      e_tf_active = l_tf_active.
  CHECK l_tf_active <> space.

  CALL FUNCTION 'J_1B_IM_TF_CHECK'
    IMPORTING
      e_lfsnr            = l_tf_lfsnr
    TABLES
      t_imitem           = fuss[]
    EXCEPTIONS
      ex_tf_not_relevant = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    PERFORM j_1b_im_tf_error_occurred.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF ( rm07m-lfsnr = fuss-vbeln ) AND ( mkpf-xblnr = fuss-vbeln ).
      rm07m-lfsnr = mkpf-xblnr = l_tf_lfsnr.
    ENDIF.
  ENDIF.


ENDFORM.                               " J_1B_IM_TF_CHECK


*&---------------------------------------------------------------------*
*&      Form  J_1B_IM_TF_ERROR_OCCURRED
*&---------------------------------------------------------------------*
* If error occured reset global variable.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM j_1b_im_tf_error_occurred.
* reset variables
  SET CURSOR FIELD 'RM07M-VBELN'.
  PERFORM fuss_init.
  CLEAR xaktiv.

ENDFORM.                               " J_1B_IM_TF_ERROR_OCCURRED

*&---------------------------------------------------------------------*
*&      Form  J_1B_XACCIT
*&---------------------------------------------------------------------*
*       set tax jurisdiction code (txjcd) and level for txjcd
*       for FI interface
*----------------------------------------------------------------------*
FORM j_1b_xaccit USING    p_xaccit LIKE accit
                          p_brazil LIKE brazil
                          p_cnt02  LIKE t156w-cnt02
                          p_vorsl  LIKE xzcxcm-vorsl.
  DATA: l_level TYPE i.

  CHECK NOT p_brazil IS INITIAL.

  IF   p_cnt02 > 50.
* Brazilian tax item

    IF NOT p_xaccit-txjcd IS INITIAL.

      p_xaccit-txjdp = p_xaccit-txjcd.
* In Brazil tax juristiction level is always 1 -------------"note 214546
      p_xaccit-txjlv = 1.                                   "note 214546
*DEL      CALL FUNCTION 'FI_TAX_GET_TXJCD_LEVELS'           "note 214546
*DEL           EXPORTING                                    "note 214546
*DEL                i_bukrs = p_xaccit-bukrs                "note 214546
*DEL                i_txjcd = p_xaccit-txjcd                "note 214546
*DEL           IMPORTING                                    "note 214546
*DEL                level   = l_level.                      "note 214546
*DEL      IF NOT sy-subrc IS INITIAL.                       "note 214546
*DEL        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno"note214546
*DEL                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4."note214546
*DEL      ELSE.                                             "note 214546
*DEL        p_xaccit-txjlv = l_level.                       "note 214546
*DEL      ENDIF.                                            "note 214546
    ENDIF.

    p_xaccit-taxit = x.

* set KSCHL from tax calculation Brazil
    CALL FUNCTION 'J_1B_IM_TX_TAX_BASE_GET'
      EXPORTING
        i_cnt02 = p_cnt02
      IMPORTING
        kschl   = p_xaccit-kschl.

  ENDIF.

ENDFORM.                               " J_1B_XACCIT

*&---------------------------------------------------------------------*
*&      Form  J_1B_YACCCR
*&---------------------------------------------------------------------*
*       set correct sign for fwbas
*----------------------------------------------------------------------*
FORM j_1b_yacccr USING p_brazil LIKE brazil
                       p_wrbtr  LIKE acccr-wrbtr
                       p_fwbas  LIKE acccr-fwbas.

  CHECK NOT p_brazil IS INITIAL.

* set correct sign
  IF     p_wrbtr < 0.
    IF p_fwbas > 0.
      p_fwbas = p_fwbas * -1.
    ENDIF.
  ELSEIF p_wrbtr > 0.
    IF p_fwbas < 0.
      p_fwbas = p_fwbas * -1.
    ENDIF.
  ENDIF.

ENDFORM.                               " J_1B_YACCCR
*&---------------------------------------------------------------------*
*&      Form  j_1b_im_tf_gi_processing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM j_1b_im_tf_gi_processing USING    p_br_active TYPE c
                                       p_bwart LIKE mseg-bwart
                              CHANGING ps_vm07m LIKE vm07m
                                       ps_mseg LIKE mseg
                                       p_tf_gi_rel TYPE c.

  CHECK NOT p_br_active IS INITIAL.

* check before cancellation Delivery with GI

  CALL FUNCTION 'J_1B_IM_TF_DLVR_CAN_CHECK'
    EXPORTING
      i_dlvryn    = ps_vm07m-vbeln
      i_bwart     = p_bwart
      i_br_active = p_br_active.

  CALL FUNCTION 'J_1B_IM_TF_BWART_GI_REL'
    EXPORTING
      i_br_active    = p_br_active
      i_bwart        = p_bwart
    IMPORTING
      e_tf_gi_active = p_tf_gi_rel.
*
*--> fill delivery document for update of SD document flow
*--> by cancellations of GR document for stock trnasfer orders
*
  DATA: lv_action TYPE goaction.
  IMPORT lv_action FROM MEMORY ID 'J1B_ACTION'.
  CASE lv_action.
    WHEN 'A03'.     "cancel.
      PERFORM get_delivery_note_number(saplj1bn)
                                       USING
                                         ps_mseg-mblnr
                                         ps_mseg-zeile
                                         ps_mseg-ebeln
                                         ps_mseg-ebelp
                                       CHANGING
                                         ps_vm07m-vbeln
                                         ps_vm07m-vbelp.
    WHEN OTHERS.
  ENDCASE.
*
  CHECK NOT p_tf_gi_rel IS INITIAL.

  CALL FUNCTION 'J_1B_IM_TF_GET_GI_TXCD'                    "Note 354133
      EXPORTING
            is_mseg = ps_mseg
      IMPORTING
            es_mseg = ps_mseg.

* Note 309758
* --- Note 357266 -----Delete
*call function 'J_1B_IM_TF_DETERMINE_MAT_PRICE'
*     exporting
*          i_from_plant = ps_mseg-werks
*          i_to_plant   = ps_mseg-umwrk
*     changing
*          c_exbase     = ps_mseg-j_1bexbase.

ENDFORM.                               " j_1b_im_tf_gi_processing
*&---------------------------------------------------------------------*
*&      Form  j_1b_tf_cancel_gi_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XMSEG_BWART  text
*      -->P_BRAZIL  text
*      <--P_J_1B_TF_CAN_GI  text
*----------------------------------------------------------------------*
FORM j_1b_tf_cancel_gi_check USING    p_bwart  LIKE mseg-bwart
                                      p_brazil TYPE c
                             CHANGING p_active TYPE c.
  DATA: l_subrc LIKE sy-subrc,
        l_tf_active(1) TYPE c,
        ls_t156 LIKE t156.
  CHECK p_brazil = x.
  CLEAR p_active.
  CALL FUNCTION 'J_1B_IM_TF_BWART_RELEVANT'
    EXPORTING
      i_br_active = p_brazil
      i_bwart     = p_bwart
    IMPORTING
      e_tf_active = l_tf_active.
  IF NOT l_tf_active IS INITIAL.
    IF t156-bwart <> p_bwart.
      SELECT SINGLE * INTO ls_t156 FROM t156 WHERE bwart = p_bwart.
    ELSE.
      ls_t156 = t156.
    ENDIF.
    IF ( ls_t156-shkzg = 'S' ) AND ( ls_t156-xstbw = 'X' ).
      p_active = 'X'.
      sy-subrc = l_subrc.
    ELSE.
      CLEAR p_active.
      sy-subrc = l_subrc.
    ENDIF.
  ELSE.
    CLEAR p_active.
    sy-subrc = l_subrc.
  ENDIF.

ENDFORM.                               " j_1b_tf_cancel_gi_check


*&---------------------------------------------------------------------*
*&      Form  j_1b_tf_remove_po_mkpf
*&---------------------------------------------------------------------*
*       Remove PO info from material doc. header
*----------------------------------------------------------------------*
FORM j_1b_tf_remove_po_mkpf
  CHANGING ch_mkpf TYPE mkpf.

  ch_mkpf-vgart = 'WA'.
  ch_mkpf-blart = 'WA'.

ENDFORM.                    " j_1b_tf_remove_po_mkpf


*&---------------------------------------------------------------------*
*&      Form  j_1b_tf_remove_po_mseg
*&---------------------------------------------------------------------*
*       Remove PO info from material doc. items
*----------------------------------------------------------------------*
FORM j_1b_tf_remove_po_mseg
  TABLES p_mseg STRUCTURE mseg.

  DATA: wa_mseg TYPE mseg.

  LOOP AT p_mseg INTO wa_mseg.
    CLEAR: wa_mseg-ebeln,
           wa_mseg-ebelp,
           wa_mseg-elikz,
           wa_mseg-kzbew,
           wa_mseg-kzzug.
    MODIFY p_mseg FROM wa_mseg INDEX sy-tabix.
  ENDLOOP.

ENDFORM.                    " j_1b_tf_remove_po_mseg


*&---------------------------------------------------------------------*
*&      Form  J_1B_TAX_PROC_SET
*&---------------------------------------------------------------------*
FORM j_1b_tax_proc_set.

  DATA: company LIKE t001-bukrs.

  CHECK brazil     = x.
  CHECK t158-trtyp = h.

  IF mseg-bukrs IS INITIAL.
***** find company code based on plant
    CALL FUNCTION 'J_1B_COMPANY_DETERMINE'
      EXPORTING
        plant   = mseg-werks
      IMPORTING
        company = company
      EXCEPTIONS
        OTHERS  = 8.
  ELSE.
    company = mseg-bukrs.
  ENDIF.

  CALL FUNCTION 'J_1B_IM_TX_TAX_PROC_SET'
    EXPORTING
      i_mkpf    = mkpf
      i_mseg    = mseg
      i_dm07m   = dm07m
      i_vm07m   = vm07m
      i_company = company
    IMPORTING
      i_dm07m   = dm07m.

ENDFORM.                               " J_1B_TAX_PROC_SET
*&---------------------------------------------------------------------*
*&      Module  J_1BFIFONFGET  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE j_1bfifonfget OUTPUT.

  PERFORM j_1bfifonfget USING mseg.

ENDMODULE.                 " J_1BFIFONFGET OUTPUT
*&---------------------------------------------------------------------*
*&      Form  j_1bfifonfget
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MSEG  text
*----------------------------------------------------------------------*
FORM j_1bfifonfget  USING    p_mseg TYPE mseg.

*  DATA: lv_bukrs TYPE bukrs.
*
*  CHECK brazil = 'X'.
*  CHECK t158-trtyp = h.
*  CHECK NOT p_mseg-matnr IS INITIAL.
*
**-- in certain cases the company code is not filled in MSEG
**-- if this is the case determine it with plant
*  IF p_mseg-bukrs IS INITIAL.
****** find company code based on plant
*    CALL FUNCTION 'J_1B_COMPANY_DETERMINE'
*      EXPORTING
*        plant   = p_mseg-werks
*      IMPORTING
*        company = lv_bukrs
*      EXCEPTIONS
*        OTHERS  = 8.
*  ELSE.
**-- company is a variable in program SAPMM07M
*    lv_bukrs = p_mseg-bukrs.
*  ENDIF.
*
*  CALL FUNCTION 'J_1BFIFONFGET'
*    EXPORTING
*      i_bukrs  = lv_bukrs
*      i_lifnr  = p_mseg-lifnr
*      i_werks  = p_mseg-werks
*      i_bwart  = p_mseg-bwart
*      i_sobkz  = p_mseg-sobkz
*      i_matnr  = p_mseg-matnr
*    CHANGING
*      ch_sgtxt = p_mseg-sgtxt.

ENDFORM.                    " j_1bfifonfget
*&---------------------------------------------------------------------*
*&      Module  J_1BFIFONFCHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE j_1bfifocheck INPUT.

*  PERFORM j_1bfifocheck CHANGING mseg.

ENDMODULE.                 " J_1BFIFOCHECK INPUT
*&---------------------------------------------------------------------*
*&      Module  J_1BSGTXTCHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE j_1bsgtxtcheck INPUT.

*  PERFORM j_1bsgtxtcheck CHANGING mseg.

ENDMODULE.                 " J_1BSGTXTCHECK INPUT
*&---------------------------------------------------------------------*
*&      Form  j_1bfifonfcheck
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MSEG  text
*----------------------------------------------------------------------*
FORM j_1bfifocheck CHANGING p_mseg TYPE mseg.

*  DATA: lv_bukrs TYPE bukrs.
*
*  CHECK brazil = 'X'.
*  CHECK t158-trtyp = h.
*  CHECK NOT p_mseg-matnr IS INITIAL.
*
**-- in certain cases the company code is not filled in MSEG
**-- if this is the case it´s taken from I_BUKRS
*  IF p_mseg-bukrs IS INITIAL.
****** find company code based on plant
*    CALL FUNCTION 'J_1B_COMPANY_DETERMINE'
*      EXPORTING
*        plant   = p_mseg-werks
*      IMPORTING
*        company = lv_bukrs
*      EXCEPTIONS
*        OTHERS  = 8.
*  ELSE.
**-- company is a variable in program SAPMM07M
*    lv_bukrs = p_mseg-bukrs.
*  ENDIF.
*
*  CALL FUNCTION 'J_1BFIFOCHECK'
*    EXPORTING
*      i_bukrs  = lv_bukrs
*      i_lifnr  = p_mseg-lifnr
*      i_werks  = p_mseg-werks
*      i_bwart  = p_mseg-bwart
*      i_sobkz  = p_mseg-sobkz
*      i_matnr  = p_mseg-matnr
*      i_charg  = p_mseg-charg
*      i_meins  = p_mseg-meins
*      i_menge  = p_mseg-menge
*      i_erfme  = p_mseg-erfme
*      i_erfmg  = p_mseg-erfmg
*      i_mblpo  = p_mseg-zeile
*    CHANGING
*      ch_sgtxt = p_mseg-sgtxt
*    EXCEPTIONS
*      NOT_ENOUGH_QUANTITY       = 1
*      OTHERS                    = 2
*                           .
*  IF sy-subrc <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

ENDFORM.                    " j_1bfifonfcheck
*&---------------------------------------------------------------------*
*&      Form  j_1bsgtxtcheck
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MSEG  text
*----------------------------------------------------------------------*
FORM j_1bsgtxtcheck CHANGING p_mseg TYPE mseg.

*  DATA: lv_bukrs TYPE bukrs.
*
*  CHECK brazil = 'X'.
*  CHECK t158-trtyp = h.
*  CHECK NOT p_mseg-sgtxt IS INITIAL.
*
*  CALL FUNCTION 'J_1BSGTXTCHECK'
*    CHANGING
*      ch_sgtxt = p_mseg-sgtxt.

ENDFORM.                    "j_1bsgtxtcheck
*begin of note 1253115
*&---------------------------------------------------------------------*
*&      Module  J_1B_TEST_PO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE J_1B_TEST_PO INPUT.
  PERFORM J_1B_TEST_PO.
ENDMODULE.                 " J_1B_TEST_PO  INPUT
*---------------------------------------------------------------------*
*       FORM J_1B_PO_TEST
*---------------------------------------------------------------------*
FORM J_1B_TEST_PO.

  CHECK brazil      = x.
  IF MSEGK-EBELN IS NOT INITIAL.
*If the PO number don´t exist system gives an error message
    SELECT SINGLE * FROM EKKO WHERE EBELN = MSEGK-EBELN.
    IF SY-SUBRC <> 0.
      MESSAGE E019(06) WITH MSEGK-EBELN RAISING NO_RECORDS_FOUND.
    ENDIF.

  ENDIF.
ENDFORM.                               " J_1B_PO_TEST
*end of note 1253115