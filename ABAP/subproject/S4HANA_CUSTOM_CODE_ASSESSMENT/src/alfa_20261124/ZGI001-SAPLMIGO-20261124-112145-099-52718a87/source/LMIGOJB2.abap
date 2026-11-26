*----------------------------------------------------------------------*
*   INCLUDE LMIGOJB2                                                   *
*----------------------------------------------------------------------*
CLASS lcl_migo_nota_fiscal IMPLEMENTATION.

************************************************************************
* Register the OKCODE which is raised if the menu-button is pressed
************************************************************************
  METHOD constructor.
    DATA: lt_okcodes     TYPE lif_migo_frame=>ty_t_okcodes.

    lif_migo_frame~class_id =  'MIGO_NOTA_FISCAL'.
    APPEND 'OK_J1BA'        TO lt_okcodes.
    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer = me
        it_okcodes    = lt_okcodes.
  ENDMETHOD.                    "constructor

************************************************************************
* Message handler
************************************************************************
  METHOD lif_migo_frame~message_handler.
  ENDMETHOD.                    "lif_migo_frame~message_handler
************************************************************************
* Okcode handler
************************************************************************
  METHOD lif_migo_frame~okcode_handler.
    CASE i_okcode.
      WHEN 'OK_J1BA'.
        CALL METHOD j_1b_nota_fiscal_button.
    ENDCASE.
  ENDMETHOD.                    "lif_migo_frame~okcode_handler

************************************************************************
* Check relevance for brazil
************************************************************************
  METHOD j_1b_relevance_check.
*
    DATA: lv_action TYPE goaction.
*======================================================================
*-- FIFO handling
    IF     NOT cs_goitem-brazil    IS INITIAL
    AND    NOT  godynpro-action = 'A04'.        "display
      CALL FUNCTION 'J_1BFIFOCHECK'
        EXPORTING
          i_bukrs             = cs_goitem-bukrs_for_stock
          i_lifnr             = cs_goitem-mat_lifnr
          i_werks             = cs_goitem-werks
          i_bwart             = cs_goitem-bwart
          i_sobkz             = cs_goitem-sobkz
          i_matnr             = cs_goitem-matnr
          i_charg             = cs_goitem-charg
          i_meins             = cs_goitem-meins
          i_menge             = cs_goitem-menge
          i_erfme             = cs_goitem-erfme
          i_erfmg             = cs_goitem-erfmg
          i_mblpo             = cs_goitem-zeile
        CHANGING
          ch_sgtxt            = cs_goitem-sgtxt
        EXCEPTIONS
          not_enough_quantity = 1
          OTHERS              = 2.
      .
      IF sy-subrc <> 0.
        CALL METHOD oref_doc_log->refresh.
        CALL METHOD oref_doc_log->context_set.
*          EXPORTING
*            i_global_counter = cs_goitem-global_counter.

        CALL METHOD oref_doc_log->message_add
          EXPORTING
            i_msgty = sy-msgty
            i_msgid = sy-msgid
            i_msgno = sy-msgno
            i_msgv1 = sy-msgv1
            i_msgv2 = sy-msgv2
            i_msgv3 = sy-msgv3
            i_msgv4 = sy-msgv4.

        CALL METHOD oref_doc_log->message_exist_single
          EXPORTING
            i_global_counter = cs_goitem-global_counter
          IMPORTING
            e_loglevel       = cs_goitem-loglevel.

        CALL METHOD oref_doc_log->display
        EXPORTING
*            i_item           = abap_true
          i_global_counter = cs_goitem-global_counter.

*        CALL FUNCTION 'MICK_MESSAGE_ADD'
*          EXPORTING
*            i_msgty = sy-msgty
*            i_msgid = sy-msgid
*            i_msgno = sy-msgno
*            i_msgv1 = sy-msgv1
*            i_msgv2 = sy-msgv2
*            i_msgv3 = sy-msgv3
*            i_msgv4 = sy-msgv4.

*        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.
*       CALL METHOD oref_log->messages_delete_for_item
*         exporting i_global_counter = cs_goitem-global_counter.
        CALL METHOD oref_doc_log->refresh.
        CLEAR cs_goitem-loglevel.
      ENDIF.

    ENDIF.
*======================================================================
*
    IF     NOT cs_goitem-brazil    IS INITIAL
       AND NOT is_got156-j_1bnfrel IS INITIAL.
      cs_goitem-tax_relevant = x.
      CALL METHOD j_1b_im_tx_tax_proc_set
        CHANGING
          i_goitem = cs_goitem.
*
      EXPORT lv_action FROM godynpro-action
        TO MEMORY ID 'J1B_ACTION'.
*
      CASE godynpro-action.
*--- goods receipt
        WHEN 'A01'.
          p_nf_button_disabled = abap_false.
*--- check mixed NFs (subcontracting)
          CALL METHOD j_1b_im_nfbutton_check
            EXPORTING
              i_bwart = cs_goitem-bwart.
*--- goods receipt for outbound delivery / stock transfer order
          IF godynpro-refdoc = 'R05'.
            CALL METHOD get_nf_number_from_gi
              EXPORTING
                iv_vbeln = cs_goitem-vbeln
              CHANGING
                cv_xblnr = cv_xblnr.
          ENDIF.
*
*--- returns
        WHEN 'A02'.
          p_nf_button_disabled = abap_false.
*--- check mixed NFs (subcontracting)
          CALL METHOD j_1b_im_nfbutton_check
            EXPORTING
              i_bwart = cs_goitem-bwart.
*---  set refernce item for fugr J1BN
          CALL METHOD set_ref_item
            EXPORTING
              i_mblnr   = cs_goitem-mblnr
              i_zeile   = cs_goitem-zeile
              i_mjahr   = cs_goitem-mjahr
              i_menge   = cs_goitem-menge                 "note 1008878
              i_erfmg   = cs_goitem-erfmg                 "note 1008878
              i_take_it = cs_goitem-take_it
            changing                                      "note 1008878
              c_j_1bexbase = cs_goitem-j_1bexbase.        "note 1008878
*---   NF-e EHP02
          CALL FUNCTION 'J_1B_IM_SWITCH_TAXCODE_MIGO'
            EXPORTING
              i_kalsm        = cs_goitem-kalsm
              i_zeile        = cs_goitem-zeile
              i_action       = godynpro-action
            changing
              ch_mwskz       = cs_goitem-mwskz
          .
*
*--- Do not set Nota Fiscal button by cancel (action = A03) --------
        WHEN 'A03'.

          CALL METHOD cancel_taxes                          "785319
             EXPORTING                                      "785319
               is_header = is_gohead                        "785319
               is_item   = cs_goitem                        "785319
               is_plant  = is_goplant.                      "785319

          p_nf_button_disabled = abap_true.
          cs_goitem-take_it = 'X'.
          EXIT.
*
*--- In display mode show button when BWART is nf-relevant
        WHEN 'A04'.
          p_nf_button_disabled = abap_false.
          EXIT.
*--- Place in storage                              "804327
        when 'A10'.                                "804327
          p_nf_button_disabled = abap_false.       "804327
*                                                  "804327
          CALL FUNCTION 'J_1B_SET_MIGO_UMWRK'      "804327
            EXPORTING                              "804327
              i_zeile       = cs_goitem-zeile      "804327
              i_umwrk       = cs_goitem-umwrk      "804327
                    .                              "804327
*
*---   NF-e EHP02
          CALL FUNCTION 'J_1B_IM_SWITCH_TAXCODE_MIGO'
            EXPORTING
              i_kalsm        = cs_goitem-kalsm
              i_zeile        = cs_goitem-zeile
              i_action       = godynpro-action
            changing
              ch_mwskz       = cs_goitem-mwskz
          .
*
          call method read_original_nf         "1462532
            exporting                          "1462532
              i_mblnr = cs_goitem-mblnr        "1462532
              i_mjahr = cs_goitem-mjahr        "1462532
              i_vbeln = cs_goitem-vbeln        "1462532
            changing                           "1462532
              c_xblnr = cv_xblnr.              "1462532

          exit.                                    "804327
*
        WHEN OTHERS.
          p_nf_button_disabled = abap_false.

*--- check mixed NFs (subcontracting)
          CALL METHOD j_1b_im_nfbutton_check
            EXPORTING
              i_bwart = cs_goitem-bwart.
* begin of note 912088
* get jurisdiction code from Receiving plant when goods transfer
* from plant to plant via transaction MIGO
          if godynpro-action eq 'A08' and not
             cs_goitem-umwrk is initial.
            select single txjcd from t001w into cs_goitem-txjcd
                                where werks eq cs_goitem-umwrk.
          endif.
* end of note 912088
      ENDCASE.
*--> end of insertion note note 767916
*
    ELSE.
      CLEAR cs_goitem-tax_relevant.
    ENDIF.
*
  ENDMETHOD.                    "j_1b_relevance_check

************************************************************************
* Set tax procedure
************************************************************************
  METHOD j_1b_im_tx_tax_proc_set.
    DATA: l_mkpf    TYPE mkpf,
          l_mseg    TYPE mseg,
          l_dm07m   TYPE dm07m,
          l_vm07m   TYPE vm07m,
          l_company TYPE t001-bukrs.

    CHECK     NOT i_goitem-brazil IS INITIAL
          AND     lcl_migo_globals=>kernel->s_action-create = abap_true.

    CLEAR: l_mkpf, l_mseg, l_dm07m, l_vm07m.

    l_mseg-bukrs = i_goitem-bukrs.
    l_mseg-werks = i_goitem-werks.

    IF l_mseg-bukrs IS INITIAL.
***** find company code based on plant
      CALL FUNCTION 'J_1B_COMPANY_DETERMINE'
        EXPORTING
          plant   = l_mseg-werks
        IMPORTING
          company = l_company
        EXCEPTIONS
          OTHERS  = 8.
    ELSE.
      l_company = l_mseg-bukrs.
    ENDIF.

    CALL FUNCTION 'J_1B_IM_TX_TAX_PROC_SET'
      EXPORTING
        i_mkpf    = l_mkpf
        i_mseg    = l_mseg
        i_dm07m   = l_dm07m
        i_vm07m   = l_vm07m
        i_company = l_company
      IMPORTING
        i_dm07m   = l_dm07m.

    i_goitem-kalsm = l_dm07m-kalsm.
  ENDMETHOD.                    "j_1b_im_tx_tax_proc_set

************************************************************************
* Reaction to the menu button NOTA FISCAL
************************************************************************
  METHOD j_1b_nota_fiscal_button.
    DATA: lt_xmseg TYPE lcl_migo_kernel=>ty_t_xmseg,
          l_ok     TYPE abap_bool,
          l_lines  LIKE sy-tfill.

    CALL METHOD lcl_migo_globals=>kernel->document_check
      EXPORTING
        i_enqueue    = abap_true
        i_sim_values = abap_true
        i_error_only = abap_true
      IMPORTING
        e_ok         = l_ok
        et_xmseg     = lt_xmseg.

* IF NOT l_ok IS INITIAL.
* no errors; possibly warnings

    DESCRIBE TABLE lt_xmseg LINES l_lines.

    IF    l_lines > 0
       OR lcl_migo_globals=>kernel->s_action-display = abap_true.
* item value available for NF processing

* Nota Fiscal is already generated when
* METHOD lcl_migo_globals=>kernel->document_check is processed.
* Set indicator in FUGR J1BF to envoid a regeneration when
* FORM routine CREATE_NOTA_FISCAL as called from
* FUNCTION 'J_1B_IM_NF_DOCUMENT_FUNCTION' .
* do not set flag in display mode  otherwise generation
* will be skipped when switch from display to create
      IF NOT godynpro-action = 'A04'.         "display
        CALL FUNCTION 'J_1B_SET_FIRST_CALL_FROM_MIGO'.
      ENDIF.
*
      CALL METHOD nota_fiscal_dialog
        EXPORTING
          i_migo_cancel  = lcl_migo_globals=>kernel->s_action-cancel
          i_migo_display = lcl_migo_globals=>kernel->s_action-display
          i_migo_create  = lcl_migo_globals=>kernel->s_action-create
        CHANGING
          i_t_ymseg = lt_xmseg.
    ENDIF.
* ENDIF.

  ENDMETHOD.                    "j_1b_nota_fiscal_button

************************************************************************
* Start NOTA FISCAL dialog
************************************************************************
  METHOD nota_fiscal_dialog.
    DATA: l_mkpf         TYPE mkpf,
          l_ymseg        TYPE mseg,
          l_migo_cancel  TYPE c,
          l_migo_display TYPE c,
          l_migo_create  TYPE c,
          l_msg          TYPE fimsg,
          ls_yvm07m      TYPE vm07m,
          ls_ydm07m      TYPE dm07m,
          lt_yvm07m      TYPE TABLE OF vm07m,
          lt_ydm07m      TYPE TABLE OF dm07m,
          ls_gohead      TYPE gohead.


    LOOP AT i_t_ymseg INTO l_ymseg.
      ls_yvm07m-zeilv = l_ymseg-zeile.
      ls_yvm07m-bwkey = l_ymseg-werks.
      ls_ydm07m-zeild = l_ymseg-zeile.
      ls_ydm07m-vwere = l_ymseg-dmbtr.
*--- for access with project stock the values are already
*--- set for compere the changes in the nota fiscal. Changes
*--- here leads to a regeneration of the NF and the lost of
*--- manually inserted data
      IF NOT l_ymseg-sobkz = 'Q'.
        ls_ydm07m-vwert = l_ymseg-dmbtr.
      ENDIF.
      APPEND: ls_yvm07m TO lt_yvm07m,
              ls_ydm07m TO lt_ydm07m.
    ENDLOOP.

    CALL METHOD lcl_migo_globals=>kernel->header_get
      IMPORTING
        e_gohead = ls_gohead.

    l_mkpf-xblnr = ls_gohead-xblnr.
    l_mkpf-bktxt = ls_gohead-bktxt.
    l_mkpf-budat = ls_gohead-budat.
    l_mkpf-bldat = ls_gohead-bldat.
    l_mkpf-mblnr = ls_gohead-mblnr.
    l_mkpf-mjahr = ls_gohead-mjahr.

    IF     i_migo_cancel  = abap_true.
      l_migo_cancel = x.
    ELSEIF i_migo_display = abap_true.
      l_migo_display = x.
    ELSEIF i_migo_create  = abap_true.
      l_migo_create = x.
    ENDIF.

    CALL FUNCTION 'J_1B_IM_NF_DOCUMENT_FUNCTION'
      EXPORTING
        i_mkpf         = l_mkpf
        i_migo_cancel  = l_migo_cancel
        i_migo_display = l_migo_display
        i_migo_create  = l_migo_create
      TABLES
        i_ymseg        = i_t_ymseg
        i_yvm07m       = lt_yvm07m
        i_ydm07m       = lt_ydm07m
      CHANGING
        i_msg          = l_msg
      EXCEPTIONS
        error_handling = 1.
    IF NOT sy-subrc IS INITIAL.
*   MESSAGE ID     l_msg-msgid
*           TYPE   l_msg-msgty
*           NUMBER l_msg-msgno
*           WITH   l_msg-msgv1 l_msg-msgv2 l_msg-msgv3 l_msg-msgv4.
    ENDIF.
  ENDMETHOD.                    "nota_fiscal_dialog
******************************************************************
* Note 327205
  METHOD j_1b_set_subcontr.
    p_subcontr = i_subcontr.
  ENDMETHOD.                    "j_1b_set_subcontr

  METHOD j_1b_get_subcontr.
    r_subcontr = p_subcontr.
  ENDMETHOD.                    "j_1b_get_subcontr
*
  METHOD j_1b_nf_button_disabled.
    r_nf_button_disabled = p_nf_button_disabled.
  ENDMETHOD.                    "j_1b_nf_button_disabled

  METHOD j_1b_im_nfbutton_check.
    DATA ls_j_1biv04 TYPE j_1biv04.

    CASE godynpro-refdoc.
      WHEN 'R10'.
        p_nf_button_disabled = abap_false.
      WHEN OTHERS.
*--> non IV relevant but NF relevant items transferred from
*--> material document to IV
*--> HIDE NF-Button when NF in MIGO -> NF is created in IV
        SELECT SINGLE * FROM j_1biv04 INTO ls_j_1biv04
         WHERE bwart = i_bwart.
        IF sy-subrc = 0.
          p_nf_button_disabled = abap_true.
        ELSE.
          p_nf_button_disabled = abap_false.
        ENDIF.
    ENDCASE.
  ENDMETHOD.                    "j_1b_im_nfbutton_check
*
*--------------------------------------------------------
* STOCK-TRANSFER get NF number for incoming from outgoing
*
  METHOD get_nf_number_from_gi.

    DATA: ls_vbfa  TYPE vbfa,
          ls_mseg  TYPE mseg,
          lv_mjahr TYPE gjahr,
          lv_zeile TYPE mblpo.

* begin of note 919816
  DATA: l_smbln type mblnr,
        l_smblp type mblpo,
        l_gidate LIKE sy-datum,
        lv_mblnr type mblnr.

* read actual goods movement date
  SELECT SINGLE wadat_ist INTO l_gidate FROM likp
                          WHERE vbeln = iv_vbeln.
  lv_mjahr = l_gidate(4).
* end of note 919816
*
    CLEAR cv_xblnr.
* Read document flow
* for hte determinaton of the original NF only one entry
* is necesary. The relationship from GI documents to Material
* documents and outgoing NFs is 1:1:1
*
    SELECT * FROM vbfa INTO ls_vbfa
      WHERE vbelv = iv_vbeln
      AND   vbtyp_n = 'R'
      AND   bwart ne '   '.                           "note 881039
* begin of note 919816
*    EXIT.
    MOVE ls_vbfa-vbeln TO l_smbln.
    MOVE ls_vbfa-posnn TO l_smblp.
    IF lv_mjahr IS INITIAL.
      lv_mjahr = ls_vbfa-erdat(4).
    ENDIF.

*   read material document and check if it´s not cancelled

*   if IM doc cancelled
    SELECT SINGLE * FROM mseg INTO ls_mseg WHERE smbln = l_smbln
                                           AND   smblp = l_smblp
                                           AND   sjahr = lv_mjahr.
    IF sy-subrc <> 0.                  " is not cancelled.
*   if IM a cancellation
       select single * from mseg into ls_mseg
                                 where mblnr = l_smbln
                                 and   zeile = l_smblp
                                 and   mjahr = lv_mjahr.
       if sy-subrc = 0
          and ls_mseg-smbln is initial
          and ls_mseg-smblp is initial.
         lv_mblnr = l_smbln.
         lv_zeile = l_smblp.
       endif.
    ENDIF.
* end of note 919816
    ENDSELECT.
*
    CHECK sy-subrc IS INITIAL.
*
* read material document and check if it´s not cancelled
*
*    lv_zeile = ls_vbfa-posnn.                      "note 919816
*    lv_mjahr = ls_vbfa-erdat(4).                   "note 919816
*
    SELECT  SINGLE * FROM mseg INTO ls_mseg
*      WHERE mblnr = ls_vbfa-vbeln                  "note 919816
      WHERE mblnr = lv_mblnr                        "note 919816
      AND   zeile = lv_zeile
      AND   mjahr = lv_mjahr.
*
    IF sy-subrc = 0
    AND ls_mseg-smbln IS INITIAL
    AND ls_mseg-smblp IS INITIAL.
      CALL METHOD read_original_nf
        EXPORTING
          i_mblnr = ls_mseg-mblnr
          i_mjahr = ls_mseg-mjahr
          i_vbeln = iv_vbeln
        CHANGING
          c_xblnr = cv_xblnr.
    ENDIF.

  ENDMETHOD.                    "get_nf_number_from_gi

*  STOCK-TRANSFER read original NF
  METHOD read_original_nf.

    DATA: ls_nflin TYPE j_1bnflin,
          ls_nfdoc TYPE j_1bnfdoc,
          lv_nf_num   TYPE j_1bdocnum,
          lv_refkey   TYPE j_1brefkey.
  data: ls_active   TYPE j_1bnfe_active.               "1146460
*-- select 1st item / reference is on item level
    CONCATENATE i_mblnr i_mjahr INTO lv_refkey.
    SELECT * FROM j_1bnflin INTO ls_nflin
    WHERE reftyp = 'MD'
    AND   refkey = lv_refkey.
      EXIT.
    ENDSELECT.
*-- when reference item found - get external NF number from header
    IF sy-subrc IS INITIAL.
      SELECT SINGLE * FROM j_1bnfdoc INTO ls_nfdoc
      WHERE docnum = ls_nflin-docnum.

*     IF ls_nfdoc-series IS INITIAL.                         "1465512
*       c_xblnr = ls_nfdoc-nfnum.                            "1465512
*     ELSE.                                                  "1465512
*       CONCATENATE ls_nfdoc-nfnum                           "1465512
*                   '-'                                      "1465512
*                   ls_nfdoc-series                          "1465512
*                   ls_nfdoc-subser INTO c_xblnr.            "1465512
*     ENDIF.                                                 "1465512
      CALL FUNCTION 'J_1B_NF_NUMBER_CONDENSE'                "1465512
        EXPORTING                                            "1465512
          nf_number  = ls_nfdoc-nfnum                        "1465512
          series     = ls_nfdoc-series                       "1465512
          subseries  = ls_nfdoc-subser                       "1465512
          nf_number9 = ls_nfdoc-nfenum                       "1465512
        IMPORTING                                            "1465512
          ref_number = c_xblnr.                              "1465512
*
* check if NFe                                                "1146460
     if not ls_nfdoc-nfe is initial.   "NFe                   "1146460
       CALL FUNCTION 'J_1B_NFE_XML_RAED_ACTIVE_TAB'           "1146460
         EXPORTING                                            "1146460
           i_docnum       = ls_nfdoc-docnum                   "1146460
         IMPORTING                                            "1146460
           E_ACTTAB       = ls_active                         "1146460
         EXCEPTIONS                                           "1146460
           NO_ENTRY       = 1                                 "1146460
           OTHERS         = 2                                 "1146460
             .                                                "1146460
       IF sy-subrc <> 0.                                      "1146460
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO    "1146460
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.    "1146460
       ENDIF.                                                 "1146460
*  for authorized NFe docsta is 1                             "1146460
*  if not -> do not allow goods receipt                       "1146460
*  when GI is not in contingency                           "1158064
       if ls_active-docsta <>  '1'                            "1146460
       and ls_active-conting is initial.                   "1158064
         message e077(J1B_NFE) with ls_nfdoc-docnum           "1146460
                                    ls_active-docsta.         "1146460
       endif.                                                 "1146460
     endif.                                                   "1146460
*
    ELSE.
      MESSAGE w374(8b) WITH i_mblnr i_vbeln.
    ENDIF.

* take over NFe fields by GR (place in storage)              "1548300
* when filled in GI                                          "1548300
    IF godynpro-action = 'A10'.                              "1548300
      EXPORT docnum9 FROM ls_active-docnum9                  "1548300
      TO MEMORY ID 'RANDOM_NO'.                              "1548300
      EXPORT authcode FROM ls_active-authcod                 "1548300
      TO MEMORY ID 'J1B_AUTHCODE'.                           "1548300
      EXPORT conting FROM ls_active-conting                  "1548300
      TO MEMORY ID 'J1B_CONTING'.                            "1548300
      EXPORT xmlvers FROM ls_nfdoc-xmlvers                   "1548300
      TO MEMORY ID 'J1B_XMLVERS'.                            "1548300
      EXPORT authdate FROM ls_active-authdate                "1612648
      TO MEMORY ID 'J1B_AUTHDATE_STO'.                       "1612648
      EXPORT authtime FROM ls_active-authtime                "1612648
      TO MEMORY ID 'J1B_AUTHTIME_STO'.                       "1612648
    ENDIF.                                                   "1548300
  ENDMETHOD.                    "read_original_nf

*---------------------
*  R E T U R N S
*---------------------
  METHOD set_ref_item.

    CALL FUNCTION 'J_1B_SET_MIGO_REF_ITEM'
      EXPORTING
        i_mblnr   = i_mblnr
        i_zeile   = i_zeile
        i_mjahr   = i_mjahr
        i_take_it = i_take_it.

* begin of note 1008878
*
  DATA: my_refkey TYPE j_1bnflin-refkey,
        price     TYPE j_1bnflin-netpr,
        l_j_1bexbase LIKE c_j_1bexbase,                         "1621103
        badi_j_1badj TYPE REF TO badi_j_1badj_net_price_return, "1621103
        lv_zeile  LIKE i_zeile.
*
* Refkey = mat. doc. number + year:
  CONCATENATE i_mblnr i_mjahr INTO my_refkey.
  lv_zeile = i_zeile.
*
* Select the unit price from the NF which belongs to the material
* document that is taken as reference for the return delivery
  SELECT SINGLE netpr FROM j_1bnflin INTO price
                     WHERE reftyp = 'MD'  "material document
                     AND   refkey = my_refkey
                     AND   refitm = lv_zeile.

*-- calculate total price when NF item exists
*-- use quantity from NF- in mat doc the value
*-- depends on ERFMG, MENGE
   if sy-subrc is initial.
     if i_erfmg is initial.
       l_j_1bexbase = price * i_menge. "1621103
     else.
       l_j_1bexbase = price * i_erfmg. "1621103
     endif.
   endif.
* end of note 1008878

  TRY.                                    "1621103
    GET BADI badi_j_1badj.                "1621103
    CALL BADI badi_j_1badj->get_net_price "1621103
      EXPORTING                           "1621103
        i_mblnr         = i_mblnr         "1621103
        i_zeile         = i_zeile         "1621103
        i_mjahr         = i_mjahr         "1621103
        i_menge         = i_menge         "1621103
        i_erfmg         = i_erfmg         "1621103
        i_j_1bexbase_nf = l_j_1bexbase    "1621103
      CHANGING                            "1621103
        c_j_1bexbase    = c_j_1bexbase.   "1621103
  CATCH cx_badi_not_implemented.          "1621103
    c_j_1bexbase = l_j_1bexbase.          "1621103
  ENDTRY.                                 "1621103

  ENDMETHOD.                    "set_ref_item
*
*-----------------
* C A N C E L
*
  METHOD cancel_taxes.

    DATA: ls_mkpf TYPE mkpf,
          ls_mseg TYPE mseg,
          ls_t001 TYPE t001.

    MOVE-CORRESPONDING: is_header TO ls_mkpf,
                        is_item   TO ls_mseg,
                        is_plant  TO ls_t001.

* set tax data for cancel action
    CALL FUNCTION 'J_1B_IM_NF_CANCEL_TAXES'
      EXPORTING
        i_mkpf = ls_mkpf
        i_mseg = ls_mseg
        i_t001 = ls_t001
      EXCEPTIONS
        OTHERS = 1.


  ENDMETHOD.                    "cancel_taxes

* note 804327
  METHOD j_1b_check_brazil.

    CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
      EXPORTING
        bukrs                = iv_bukrs
        component            = 'BR'
      EXCEPTIONS
        component_not_active = 02.


    IF sy-subrc IS INITIAL.
      ev_brazil = 'X'.
    ELSE.
      CLEAR ev_brazil.
    ENDIF.

  ENDMETHOD.                    "j_1b_check_brazil

******************************************************************

ENDCLASS.                    "lcl_migo_nota_fiscal IMPLEMENTATION