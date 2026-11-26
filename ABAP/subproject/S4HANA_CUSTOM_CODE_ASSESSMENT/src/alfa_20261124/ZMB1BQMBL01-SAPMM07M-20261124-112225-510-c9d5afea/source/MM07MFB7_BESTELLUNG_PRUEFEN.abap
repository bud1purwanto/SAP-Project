*eject
*---------------------------------------------------------------------*
*       FORM BESTELLUNG_PRUEFEN                                       *
*---------------------------------------------------------------------*
*       Die Bestellung wird geprueft.                                 *
*---------------------------------------------------------------------*

* wrong account assignment objects in cancellation document:   "n1620153

* MAA2: avoid error M7 437 during posting GR or releasing a    "n1617736
* SES in IS-OIL or IS-A systems;                               "n1617736
* -> reduce the effort for the IS ENHANCEMENTS                 "n1617736
*---------------------------------------------------------------------*

FORM bestellung_pruefen USING b_ebeln LIKE  mseg-ebeln
                              b_ebelp LIKE  mseg-ebelp
                              b_lfbja LIKE  mseg-lfbja
                              b_lfbnr LIKE  mseg-lfbnr
                              b_lfpos LIKE  mseg-lfpos
                              b_shkzg LIKE  mseg-shkzg
                              b_werks LIKE  mseg-werks
                              b_kzwes LIKE vm07m-kzwes
                              b_nachl LIKE rm07m-xsbdl
                              e_pos_not_valid TYPE c.
  DATA: consi_active      TYPE xfeld.                       " 663537
  DATA: any_confirmation,
        lines_wueb TYPE sy-tabix,
        l_rc       TYPE sy-subrc,
        nohead_rc  TYPE sy-subrc,
        i_ok_code  TYPE t063o-ok_code,             "#EC NEEDED "n1617736
        e_xstor    TYPE vm07m-xstor,
        h_fuss     LIKE fuss.
  DATA: BEGIN OF lt_lifnr OCCURS 0,                         "1002634
           ebeln LIKE mseg-ebeln,                           "1002634
           lifnr LIKE mseg-lifnr,                           "1002634
        END OF lt_lifnr.                                    "1002634
  DATA: l_sc_comp TYPE i VALUE 0.                           "1351147
*MAA DEV
  DATA: lt_accounting       TYPE accounting_t,
        lt_accounting_cr    TYPE accounting_cr_t,
        lt_accounting_dc    TYPE accounting_t,
        lt_accounting_dc_cr TYPE accounting_cr_t.

  DATA : lt_xaccounting_out            TYPE  accounting_t,  "MAA2
         lt_xaccounting_out_mb         TYPE  accounting_t.  "MAA2

  DATA: ls_goitem           TYPE goitem.
*MAA DEV

* begin -------------------------------------------------MAA2--"n1617736
* define local MAA2 working areas                              "n1617736
  DATA : lv_flag_maa_active            TYPE  abap_bool,
         lv_flag_read_no_po_data       TYPE  abap_bool,
         lv_flag_po_with_maa           TYPE  abap_bool,
         lv_xhistma_initial            TYPE  xhistma,       "#EC NEEDED
         lv_subrc_save                 TYPE  sy-subrc,
         lv_ebelp(06)                  TYPE  c,

         ls_po_key_save                TYPE  cl_mmim_maa_2=>ts_po_key,
         ls_po_key                     TYPE  cl_mmim_maa_2=>ts_po_key.

  FIELD-SYMBOLS : <ls_xebefu>          LIKE  LINE OF xebefu.
* end ---------------------------------------------------MAA2--"n1617736

  STATICS: rc_kbefu TYPE sy-subrc.

*----------------------------------------------------------------------*

  CLEAR: pos_not_valid, e_pos_not_valid.

  IF NOT anf_bild IS INITIAL.
    SET CURSOR FIELD 'RM07M-EBELN'.
  ELSE.
    IF NOT sy-stepl IS INITIAL.
      SET CURSOR FIELD 'RM07M-EBELN' LINE sy-stepl.
    ENDIF.
  ENDIF.
  IF NOT xaktiv IS INITIAL.
    CHECK NOT b_ebeln IS INITIAL.
  ENDIF.
  CLEAR vw.
  IF NOT t158-trtyp = h.
    vw = x.
  ENDIF.
  IF NOT kbefu-ebeln = b_ebeln OR NOT rc_kbefu IS INITIAL.
    CALL FUNCTION 'ME_READ_HEADER_GOODS_RECEIPT'
      EXPORTING
        ebeln         = b_ebeln
        display       = vw
      IMPORTING
        kbefu         = kbefu
      EXCEPTIONS
        not_activ     = 01
        not_found     = 02
        wrong_type    = 03
        error_message = 04.
    rc_kbefu = sy-subrc.
    nohead_rc = sy-subrc.
    IF t158-trtyp = h.
      IF NOT rc_kbefu IS INITIAL.
        CASE rc_kbefu.
          WHEN 1.
            PERFORM naco_ermitteln_v4(sapfm07m) USING 'M7' '031'
                    b_ebeln kbefu-loekz space space.
          WHEN 2.
            MESSAGE e030 WITH b_ebeln.
          WHEN 3.
            MESSAGE e032 WITH b_ebeln.
          WHEN 4.
            DESCRIBE TABLE wueb LINES lines_wueb.
            IF lines_wueb <> 0 AND b_ebeln = wueb-ebeln.
              CLEAR lines_wueb.
              pos_not_valid = 'X'.
              IF xmbwl IS NOT INITIAL.                    "1633165
                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              ELSE.
                MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              ENDIF.
            ELSE.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          WHEN OTHERS.
            MESSAGE e030 WITH b_ebeln.
        ENDCASE.
      ENDIF.
      CHECK pos_not_valid IS INITIAL.

      IF NOT kbefu-bwaer = mseg-waers
        AND NOT mseg-waers IS INITIAL
        AND NOT kbefu-bwaer IS INITIAL.
        CALL FUNCTION 'FI_TYPE_OF_RATE_CHECK'
          EXPORTING
            i_blart = mkpf-blart
            i_kurst = t003-kurst
            i_waers = kbefu-bwaer
            i_hwaer = mseg-waers.
      ENDIF.
      LOOP AT ymseg WHERE kzbew = b
                   AND  ( NOT lifnr = kbefu-lifnr
                           OR lifnr IS INITIAL ).
        IF ymseg-lifnr IS INITIAL.
          LOOP AT ydm07m WHERE zeild = ymseg-zeile.
            IF NOT ydm07m-reswk = kbefu-reswk.
              l_rc = rc_kbefu.
              rc_kbefu = 2.
              PERFORM naco_ermitteln_v1(sapfm07m) USING 'M7' '159'
                                                         ydm07m-reswk.
              rc_kbefu = l_rc.
            ENDIF.
          ENDLOOP.
          IF NOT sy-subrc IS INITIAL.
            rc_kbefu = 2.
            MESSAGE e001 WITH 'YDM07M' ymseg-zeile space space."n1617736
          ENDIF.
        ELSE.
* begin note 663537 - Fashion
          PERFORM check_consi_procg  CHANGING consi_active.
* begin note 1327320
*          IF ( CONSI_ACTIVE IS INITIAL OR ymseg-sobkz <> K OR
*               fuss-kzzug is initial and t156n-xstor is initial ).
          IF NOT ( consi_active IS NOT INITIAL AND
                   ymseg-sobkz = 'K'           AND
                   kbefu-reswk IS NOT INITIAL ).
* end note 1327320
* end note 663537 - Fashion
*           item with different vendor found                    "1002634
            l_rc = rc_kbefu.
            rc_kbefu = 2.
*           issue M7107 only once per new PO/LIFNR              "1002634
            READ TABLE lt_lifnr WITH KEY                    "1002634
              ebeln = b_ebeln lifnr = ymseg-lifnr.          "1002634
            IF NOT sy-subrc = 0.                            "1002634
              MOVE: b_ebeln TO lt_lifnr-ebeln,              "1002634
                    ymseg-lifnr TO lt_lifnr-lifnr.          "1002634
              APPEND lt_lifnr.                              "1002634
              PERFORM naco_ermitteln_v1(sapfm07m)
                      USING 'M7' '107' ymseg-lifnr.
            ENDIF.                                          "1002634
            rc_kbefu = l_rc.
          ENDIF.                                            " 663537
        ENDIF.
      ENDLOOP.
      IF xmigo = space.
*     Im Falle der MIGO reicht obiger LOOP über YMSEG. Ansonsten
*     erfolgt die Prüfung eher zu früh, da im MB_CREATE bereits vorab
*     die FUSS aufgebaut wird und dort z. B. noch kein RESWK drin steht.
*     Dies resultiert aus der Tatsache, daß RESWK nicht in IMSEG.
        LOOP AT fuss WHERE kzbew = b
           AND ( NOT lifnr = kbefu-lifnr OR NOT reswk = kbefu-reswk )
           AND ( NOT lifnr IS INITIAL OR NOT reswk IS INITIAL ).
          IF NOT fuss-lifnr = kbefu-lifnr.
* begin note 663537 - Fashion
            PERFORM check_consi_procg  CHANGING consi_active.
* begin note 1327320
*            IF ( CONSI_ACTIVE IS INITIAL OR fuss-sobkz <> K  OR
*                 fuss-kzzug is initial and fuss-xstor is initial ).
            IF NOT ( consi_active IS NOT INITIAL AND
                     fuss-sobkz = 'K'            AND
                     kbefu-reswk IS NOT INITIAL ).
* end note 1327320
* end note 663537 - Fashion

              l_rc = rc_kbefu.
              rc_kbefu = 2.
              PERFORM naco_ermitteln_v1(sapfm07m) USING 'M7' '107'
                                                         fuss-lifnr.
              rc_kbefu = l_rc.
            ENDIF.                                          " 663537
          ELSE.
            l_rc = rc_kbefu.
            rc_kbefu = 2.
            PERFORM naco_ermitteln_v1(sapfm07m) USING 'M7' '159'
                                                       fuss-reswk.
            rc_kbefu = l_rc.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
  CHECK t158-trtyp = h OR
        mseg-matnr IS INITIAL AND NOT nohead_rc = 2.
  IF am07m-lifnr IS INITIAL.
    am07m-lifnr = kbefu-lifnr.
  ENDIF.
  IF am07m-reswk IS INITIAL.
    am07m-reswk = kbefu-reswk.
  ENDIF.
* begin of Outsourced Manufacturing EhP 4          note 1351147
  IF gv_mm_om1_sfws_sc_active = abap_true.
    IF mseg-ebeln IS NOT INITIAL AND mseg-sobkz = o.
      l_sc_comp = 1.
    ENDIF.
  ENDIF.
* end of Outsourced Manufacturing EhP 4          note 1351147
**********************************************************************
**** Begin of country exit for India
**********************************************************************
  SELECT SINGLE land1 FROM t001w INTO t001w-land1
                               WHERE werks = b_werks.
  IF sy-subrc EQ 0.

    CALL FUNCTION 'SAP_TO_ISO_COUNTRY_CODE'
      EXPORTING
        sap_code    = t001w-land1
      IMPORTING
        iso_code    = t005-intca
      EXCEPTIONS
        not_found   = 1
        no_iso_code = 2
        OTHERS      = 3.
*has to be changed, not correct for migo!!!!          .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'SXC_EXIT_CHECK_ACTIVE'
        EXPORTING
          exit_name  = 'MB_CIN_MM07MFB7'
          flt_val    = t005-intca
        EXCEPTIONS
          not_active = 1
          OTHERS     = 2.
      IF sy-subrc = 0.
        CALL METHOD cl_exithandler=>get_instance
          EXPORTING
            exit_name              = 'MB_CIN_MM07MFB7'
            null_instance_accepted = x
          CHANGING
            instance               = mb_grpopup.
        IF NOT mb_grpopup IS INITIAL.
          CALL METHOD mb_grpopup->mb_cin_grpopup
            EXPORTING
              flt_val = t005-intca
              y_mkpf  = mkpf
              y_rm07m = rm07m.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
***********************************************************************
**** End of country exit for India
**********************************************************************

  CLEAR: i_ok_code, e_xstor.

  IF vm07m-xstor = 2.
    e_xstor = x.
  ENDIF.
  DATA: l_mblnr TYPE mblnr,
        l_mjahr TYPE mjahr,
        l_mblpo TYPE mblpo.
  IF NOT mseg-smbln IS INITIAL.
    l_mblnr = mseg-smbln.
    l_mblpo = mseg-smblp.
    l_mjahr = mseg-sjahr.
  ELSE.
    l_mblnr = mseg-mblnr.
    l_mblpo = mseg-zeile.
    l_mjahr = mseg-mjahr.
  ENDIF.

  IF cl_ops_switch_check=>mm_sfws_sit( ) IS NOT INITIAL.
*   SIT: Store outbound delivery reference...
    IF h_liefk IS INITIAL AND rm07m-vbelp IS INITIAL
    AND ( mseg-kdauf IS NOT INITIAL OR mseg-mat_kdauf IS NOT INITIAL )
    AND cl_mm_im_sit_info=>get_sit_info_item(
            iv_ebeln = b_ebeln
            iv_ebelp = b_ebelp ) IS NOT INITIAL.
      IF mseg-kdauf IS NOT INITIAL.                         "1554198
        cl_mm_im_sit_info=>set_delivery( iv_vbeln = mseg-kdauf
                                         iv_posnr = mseg-kdpos ).
      ELSE.
        cl_mm_im_sit_info=>set_delivery( iv_vbeln = mseg-mat_kdauf
                                         iv_posnr = mseg-mat_kdpos ).
      ENDIF.
    ENDIF.
  ENDIF.


* begin -------------------------------------------------MAA2--"n1617736
* special MAA2 handling before reading the PO item data        "n1617736

* check whether the business function multi account assignment is active
  lv_flag_maa_active = cl_ops_switch_check=>mm_sfws_maa( ).

  IF  lv_flag_maa_active = abap_true  AND " MAA function active
      ( xmbwl = abap_true OR vm07m-xstor = '2' ) AND " called by MB_CREATE_GOODS_MOVEMENT
      xeksel[] IS INITIAL.                " no array selection

*   fill key stucture
    CALL METHOD go_mmim_maa_2->fill_po_key
      EXPORTING
        iv_shkzg     = b_shkzg
        iv_ebeln     = b_ebeln
        iv_ebelp     = b_ebelp
        iv_lfbnr     = b_lfbnr
        iv_lfbja     = b_lfbja
        iv_lfpos     = b_lfpos
        iv_charg     = mseg-charg
        iv_vbeln_vl  = h_liefk     " consider deliveries, too
        iv_vbelp_vl  = rm07m-vbelp
        iv_xstor     = vm07m-xstor "instead of e_xstor
        iv_sjahr     = l_mjahr
        iv_smbln     = l_mblnr
        iv_smblp     = l_mblpo
        iv_maa_urzei = mseg-maa_urzei
        iv_r_mblnr   = fuss-r_mblnr " MIGO return delivery     "n1620153
        iv_r_mjahr   = fuss-r_mjahr                            "n1620153
      CHANGING
        cs_po_key    = ls_po_key.

*   analyze the key data for reading the PO items
*   if is only on PO item required, look in the buffer table
*   and provide data of this PO item if found
*   ( KBEFU is read before -> no need for replacing )
    CALL METHOD go_mmim_maa_2->po_buffer_search_data
      EXPORTING
        is_po_key               = ls_po_key
      CHANGING
        cv_flag_error           = gv_flag_error
        ct_message_log          = gt_message_log
        cv_flag_read_no_po_data = lv_flag_read_no_po_data
        cs_po_key_save          = ls_po_key_save
        ct_ebefu                = xebefu[]
        ct_ekbnk                = xekbnk[]
        ct_ekbnk_kdm            = xekbnk_kdm[]
        ct_ebefu_cr             = xebefu_cr[]
        ct_ekbnk_cr             = xekbnk_cr[]
        ct_xaccounting          = lt_accounting[]
        ct_xaccounting_cr       = lt_accounting_cr[]
        ct_xaccounting_dc       = lt_accounting_dc[]
        ct_xaccounting_dc_cr    = lt_accounting_dc_cr[].

    IF  gv_flag_error = abap_true.
      PERFORM              send_maa_error_message.
    ENDIF.
  ENDIF.
* end ---------------------------------------------------MAA2--"n1617736

ENHANCEMENT-SECTION     BESTELLUNG_PRUEFEN_03 SPOTS ES_SAPMM07M.

  IF lv_flag_read_no_po_data = abap_false.                  "n1617736
*   the PO item data have to be read                        "n1617736
*   carry out this function module as usual
    CALL FUNCTION 'ME_READ_ITEM_GOODS_RECEIPT'
      EXPORTING
        ebeln              = b_ebeln
        ebelp              = b_ebelp
        i_werks            = b_werks
        kzwes              = b_kzwes
        lfbnr              = b_lfbnr
        lfgja              = b_lfbja
        lfpos              = b_lfpos
        shkzg              = b_shkzg
        i_vbeln            = h_liefk
        i_vbelp            = rm07m-vbelp
        budat              = mkpf-budat
        xebefu_flag        = xebefu_flag
        display            = vw
        xstor              = e_xstor
        xfbcall            = xmbwl
        i_kurstyp          = t003-kurst
        i_smbln            = l_mblnr
        i_smblp            = l_mblpo
        i_sjahr            = l_mjahr
        i_bldat            = mkpf-bldat
        i_pabnum           = wueb-pabnum
        i_pabpos           = wueb-pabpos
        i_pkkey            = wueb-pkkey
        i_welfbnr          = b_nachl
        i_etens            = vm07m-etens
        i_process          = l_sc_comp
        i_gr_charg         = mseg-charg
        i_gr_erfmg         = mseg-erfmg
        i_gr_erfme         = mseg-erfme
        i_gr_bpmng         = mseg-bpmng
        i_read_for_cancel  = read_for_cancel
      IMPORTING
        e_fcode            = i_ok_code
        e_mblmg            = dm07m-mblmg
        e_mblbm            = dm07m-mblbm
      TABLES
        xebefu             = xebefu
        xekbnk             = xekbnk
        xekbnk_kdm         = xekbnk_kdm                     "N1027899
        teksel             = xeksel
        xebefu_cr          = xebefu_cr
        xekbnk_cr          = xekbnk_cr
        xaccounting        = lt_accounting            "MAA-DEV
        xaccounting_dc     = lt_accounting_dc         "MAA-DEV
        xaccounting_cr     = lt_accounting_cr         "MAA-DEV
        xaccounting_dc_cr  = lt_accounting_dc_cr      "MAA-DEV
        xaccounting_srv    = xaccounting_srv                "MAA2
        xaccounting_srv_cr = xaccounting_srv_cr             "MAA2
      CHANGING
        c_conf             = any_confirmation
      EXCEPTIONS
        not_found_any      = 01       "ohne Pos - keinen gefun.
        not_found_one      = 02       "mit Pos - Pos nicht da
        not_valid_any      = 03       "ohne Pos - keine guelt.
        not_valid_one      = 04.      "mit Pos - Pos nicht gültig

*   save SY-SUBRC set by ME_READ_ITEM_GOODS_RECEIPT            "n1617736
    MOVE : sy-subrc          TO  lv_subrc_save.                "n1617736
  ENDIF.                                                       "n1617736

END-ENHANCEMENT-SECTION.

* begin -------------------------------------------------MAA2--"n1617736
* special MAA2 handling after reading the PO item data         "n1617736

  IF     NOT lt_accounting[] IS INITIAL.
    MOVE  abap_true                    TO  lv_flag_po_with_maa.
  ELSEIF NOT xaccounting_srv[] IS INITIAL.
    MOVE  abap_true                    TO  lv_flag_po_with_maa.
  ENDIF.

  IF lv_flag_maa_active      = abap_true  AND " MAA function active
     lv_flag_read_no_po_data = abap_false AND " PO item data read
     lv_subrc_save           IS INITIAL   AND " PO item data found
     lv_flag_po_with_maa     = abap_true.     " PO item with MAA

*   Step 1 : MAA2 nomal PO with MAA data -> sort account assignment tables
*   -------------------------------------------------------------------*
    IF NOT lt_accounting[] IS INITIAL.
      CALL METHOD go_mmim_maa_2->sort_xaccounting_tables
        CHANGING
          ct_xaccounting       = lt_accounting[]
          ct_xaccounting_cr    = lt_accounting_cr[]
          ct_xaccounting_dc    = lt_accounting_dc[]
          ct_xaccounting_dc_cr = lt_accounting_dc_cr[].
    ENDIF.

*   Step 1 : MAA2 save the data of these PO item in the buffer table
*            called by MB_CREATE_GOODS_MOVEMENT
*   -------------------------------------------------------------------*
    IF     xmbwl                = abap_true  AND
       NOT ls_po_key_save-ebeln IS INITIAL.      " buffer key is filled

      CALL METHOD go_mmim_maa_2->po_buffer_save
        EXPORTING
          is_po_key             = ls_po_key_save
          is_kbefu              = kbefu
          it_ebefu              = xebefu[]
          it_ekbnk              = xekbnk[]
          it_ekbnk_kdm          = xekbnk_kdm[]
          it_ebefu_cr           = xebefu_cr[]
          it_ekbnk_cr           = xekbnk_cr[]
          it_xaccounting        = lt_accounting[]
          it_xaccounting_cr     = lt_accounting_cr[]
          it_xaccounting_dc     = lt_accounting_dc[]
          it_xaccounting_dc_cr  = lt_accounting_dc_cr[]
          is_t003               = t003
        CHANGING
          ct_xaccounting_out    = lt_xaccounting_out[]
          ct_xaccounting_srv    = xaccounting_srv[]
          ct_xaccounting_cr_srv = xaccounting_srv_cr[]
          cv_flag_error         = gv_flag_error
          ct_message_log        = gt_message_log.

      IF  gv_flag_error = abap_true.
        PERFORM                        send_maa_error_message.
      ENDIF.

*     replace original table XACCOUNTING by the tables with BPBMG
      MOVE  lt_xaccounting_out[]       TO  lt_accounting[].
    ENDIF.


*   Step 2 : MAA2 : save all found PO items with MAA when called by
*            MB* transactions
*   -------------------------------------------------------------------*
    IF  xmbwl = abap_false.

      LOOP AT xebefu                   ASSIGNING  <ls_xebefu>
        WHERE  xhistma <> lv_xhistma_initial                " only MAA PO items
          AND  pstyp   =  cl_mmim_maa_2=>gc_pstyp_0_normal. " normal PO items

        REFRESH                        lt_xaccounting_out_mb.

*       fill  key stucture
        CALL METHOD go_mmim_maa_2->fill_po_key
          EXPORTING
            iv_shkzg     = b_shkzg
            iv_ebeln     = <ls_xebefu>-ebeln
            iv_ebelp     = <ls_xebefu>-ebelp
            iv_lfbnr     = <ls_xebefu>-lfbnr "b_lfbnr "xebefu already filtered by mseg
            iv_lfbja     = <ls_xebefu>-lfbja "b_lfbja
            iv_lfpos     = <ls_xebefu>-lfpos "b_lfpos
            iv_charg     = mseg-charg
            iv_vbeln_vl  = <ls_xebefu>-vbeln_vl     " consider deliveries, too
            iv_vbelp_vl  = <ls_xebefu>-vbelp_vl
            iv_xstor     = vm07m-xstor "instead of e_xstor
            iv_sjahr     = l_mjahr
            iv_smbln     = l_mblnr
            iv_smblp     = l_mblpo
            iv_maa_urzei = mseg-maa_urzei
          CHANGING
            cs_po_key    = ls_po_key.

*       select MAA PO items and save their data in the global buffer table
        CALL METHOD go_mmim_maa_2->po_buffer_save_mb
          EXPORTING
            is_po_key            = ls_po_key
            is_kbefu             = kbefu
            is_ebefu             = <ls_xebefu>
            it_ekbnk             = xekbnk[]
            it_ekbnk_kdm         = xekbnk_kdm[]
            it_ebefu_cr          = xebefu_cr[]
            it_ekbnk_cr          = xekbnk_cr[]
            it_xaccounting       = lt_accounting[]
            it_xaccounting_cr    = lt_accounting_cr[]
            it_xaccounting_dc    = lt_accounting_dc[]
            it_xaccounting_dc_cr = lt_accounting_dc_cr[]
            is_t003              = t003
          CHANGING
            ct_xaccounting_out    = lt_xaccounting_out_mb[]
            cv_flag_error        = gv_flag_error
            ct_message_log       = gt_message_log.

        IF  gv_flag_error = abap_true.
          PERFORM                      send_maa_error_message.
          EXIT.    " error detected -> leave this LOOP
        ENDIF.

        APPEND LINES OF lt_xaccounting_out_mb  TO  lt_xaccounting_out.
      ENDLOOP.
    ENDIF.

*   replace original table XACCOUNTING by the tables with BPBMG
    MOVE  lt_xaccounting_out[]         TO  lt_accounting[].
  ENDIF.

* restore SY-SUBRC set by ME_READ_ITEM_GOODS_RECEIPT
  MOVE  lv_subrc_save                  TO  sy-subrc.
* end ---------------------------------------------------MAA2--"n1617736

  def_break 'ME_READ_ITEM_GOODS_RECEIPT'.                   "#EC *
  BREAK-POINT ID mb_me_read_item_goods_receipt.

  IF t158-trtyp = h.
    CASE sy-subrc.
      WHEN 1.
        MESSAGE e033 WITH b_ebeln.
      WHEN 2.
        WRITE  b_ebelp       TO  lv_ebelp  NO-ZERO.            "n1617736
        MESSAGE i036         WITH b_ebeln lv_ebelp.            "n1617736
        pos_not_valid = 'X'.
        e_pos_not_valid = 'X'.
      WHEN 3.
        WRITE  b_ebelp       TO  lv_ebelp  NO-ZERO.            "n1617736
        MESSAGE e036         WITH b_ebeln lv_ebelp.            "n1617736
      WHEN 4.
        IF mseg-kzbew = 'O' AND vm07m-xstor = '2'.          "1153281
*         allow cancel posting for subsequential adjustment    "1153281
        ELSE.                                               "1153281
          WRITE  b_ebelp     TO  lv_ebelp  NO-ZERO.            "n1617736
          MESSAGE i036       WITH b_ebeln lv_ebelp.            "n1617736
          pos_not_valid = 'X'.                              "1153281
          e_pos_not_valid = 'X'.                            "1153281
        ENDIF.                                              "1153281
      WHEN OTHERS.

ENHANCEMENT-POINT MM07MFB7_BESTELLUNG_PRUEFEN_03 SPOTS ES_SAPMM07M.

    ENDCASE.
ENHANCEMENT-POINT BESTELLUNG_PRUEFEN_04 SPOTS ES_SAPMM07M STATIC.

ENHANCEMENT-POINT BESTELLUNG_PRUEFEN_02 SPOTS ES_SAPMM07M.
*   object might not yet be created when there are several calls
    IF g_assert IS BOUND.
*     assertion, to be used in background mainly
      IF g_assert->debug_auth = x.
        g_assert->as_me_read_item_goods_receipt(
          EXPORTING
            i_ebeln     = b_ebeln
            i_werks     = b_werks
            i_lfbnr     = b_lfbnr
            i_lfbja     = b_lfbja
            i_lfpos     = b_lfpos
            i_shkzg     = b_shkzg
            i_ebefu     = xebefu[]
            i_ebefu_cr  = xebefu_cr[]
            i_ekbnk     = xekbnk[]
            i_ekbnk_cr  = xekbnk_cr[] ).
      ENDIF.
    ENDIF.

*- begin ------------------------------------------------- EhP4 MAA-DEV

* the L_ACCOUNTING* tables countain the MAA data of one or several "MAA2
* PO items, the global XACCOUNTING* tables could contain duplicate
* entries -> find and delete such duplicates for normal MAA PO items
*----------------------------------------------------------------

    IF NOT lt_accounting[]   IS INITIAL AND
           xaccounting_srv[] IS INITIAL.
*     this is a GR item with MAA
*     add always all MAA lines from the PO into the global tables
      APPEND LINES OF lt_accounting[]       TO xaccounting[].
      APPEND LINES OF lt_accounting_cr[]    TO xaccounting_cr[].
      APPEND LINES OF lt_accounting_dc[]    TO xaccounting_dc[].
      APPEND LINES OF lt_accounting_dc_cr[] TO xaccounting_dc_cr[].

      CALL METHOD go_mmim_maa_2->sort_xaccounting_tables
        CHANGING
          ct_xaccounting       = xaccounting[]
          ct_xaccounting_cr    = xaccounting_cr[]
          ct_xaccounting_dc    = xaccounting_dc[]
          ct_xaccounting_dc_cr = xaccounting_dc_cr[].

      DELETE ADJACENT DUPLICATES FROM    xaccounting
        COMPARING  ebeln ebelp lfbja lfbnr lfpos stunr zaehk zekkn.

      DELETE ADJACENT DUPLICATES FROM    xaccounting_cr
        COMPARING  ebeln ebelp lfbja lfbnr lfpos stunr zaehk zekkn curtp.

      IF NOT xaccounting_dc[] IS INITIAL.
        DELETE ADJACENT DUPLICATES FROM  xaccounting_dc
          COMPARING  ebeln ebelp stunr zaehk zekkn.

        DELETE ADJACENT DUPLICATES FROM  xaccounting_dc_cr
          COMPARING  ebeln ebelp stunr zaehk curtp zekkn.
      ENDIF.
    ENDIF.                                                  "MAA2
*-- Services
    IF NOT xaccounting_srv[] IS INITIAL.
*---- Add Acc-data from services
      PERFORM mb_maa_srv_complete
                               USING b_ebeln
                                     b_ebelp
                                     b_lfbja
                                     b_lfbnr
                                     b_lfpos
                                     xaccounting_srv[]
                                     xaccounting_srv_cr[]
                            CHANGING xaccounting[]
                                     xaccounting_cr[].
    ENDIF.

* --- begin ------------------------------------------------"MAA2
*   check the consistency of the MAA PO data and XACCOUNTING tables
    IF  lv_flag_maa_active = abap_true.
      DATA : lv_flag_maa_value_set   TYPE  abap_bool.

      LOOP AT xebefu                 ASSIGNING  <ls_xebefu>
              WHERE  xhistma <> lv_xhistma_initial.      " only MAA PO items
*         check the data of all found PO items
        CALL METHOD go_mmim_maa_2->check_maa_consistency
          EXPORTING
            is_xebefu             = <ls_xebefu>
            it_xekbnk             = xekbnk[]
            it_xaccounting        = xaccounting[]
            it_xaccounting_cr     = xaccounting_cr[]
            it_xaccounting_dc     = xaccounting_dc[]
            it_xaccounting_dc_cr  = xaccounting_dc_cr[]
          CHANGING
            cv_flag_error         = gv_flag_error
            cv_flag_maa_value_set = lv_flag_maa_value_set
            ct_message_log        = gt_message_log.

        IF  gv_flag_error = abap_true.
          PERFORM                    send_maa_error_message.
          EXIT.
        ENDIF.
      ENDLOOP.

*     save the MAA if there is at least one MAA item called by transaction MIGO
      IF  lv_flag_maa_value_set = abap_true  AND
          NOT  xmigo            IS INITIAL.

        MOVE-CORRESPONDING mseg  TO ls_goitem.      "#EC ENHOK "n1617736
        MOVE-CORRESPONDING vm07m TO ls_goitem.      "#EC ENHOK "n1617736
        MOVE-CORRESPONDING dm07m TO ls_goitem.      "#EC ENHOK "n1617736
        ls_goitem-ebeln = b_ebeln.
        ls_goitem-ebelp = b_ebelp.

        CALL FUNCTION 'MB_MAA_VALUE_SET'
          EXPORTING
            iaccounting = xaccounting[]
            igoitem     = ls_goitem
            iebefu      = xebefu[].
      ENDIF.
    ENDIF.                                                  "MAA2
* --- end --------------------------------------------------"MAA2

* MAA-DEV
*- end   ------------------------------------------------- EhP4 MAA-DEV


*   Cat-Ford Release 2: Redirection of scheduling agreements
*   User CMD - Transport AC0K049219
*   Check if additional actions in update task along statistical GR
*   are necessary

    CALL FUNCTION 'MB_CHECK_REDIR_SA'
      IMPORTING
        e_f_redirsa_necessary = g_f_redirsa_necessary
      TABLES
        it_ebefux             = xebefu[]
      EXCEPTIONS
        konnr_not_in_ekko     = 1
        OTHERS                = 2.
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

*   Hinweis, wenn Einstieg über Bestellung und es liegen aber
*   Bestätigungen vor
    IF NOT any_confirmation IS INITIAL AND h_liefk IS INITIAL AND
       ( mseg-shkzg = s AND vm07m-retpo IS INITIAL ).
      PERFORM naco_ermitteln_v4(sapfm07m) USING 'M7' '243'
                                          b_ebeln b_ebelp space space.
    ENDIF.
  ENDIF.

  IF vm07m-xstor = 1  OR  vm07m-xstor = 2.
    DATA h_lines LIKE sy-tabix.
    DESCRIBE TABLE xebefu LINES h_lines.
    IF h_lines > 1  AND  ( NOT xebefu-upvor IS INITIAL  OR
                           xebefu-uptyp = uptyp_vas ).
* more than one line and subitems -> check whether VAS is used
      PERFORM vas_bestellpos_storno.
    ENDIF.
  ENDIF.
  IF NOT b_ebeln IS INITIAL AND
     NOT b_ebelp IS INITIAL AND
     NOT h_liefk IS INITIAL.
    PERFORM upos_eliminieren.
  ENDIF.
  IF cl_ops_switch_check=>ops_sfws_sc_advret1( ) = abap_true.
* don't condsider FLS return POs in IM-transactions
    IF im_process <> 'L'.
      DELETE xebefu WHERE fls_rsto <> space.
    ENDIF.
  ENDIF.
* begin of Outsourced Manufacturing EhP 4
  IF xmbwl IS INITIAL.
    DELETE xebefu WHERE co_order <> space.
    IF sy-subrc = 0.
      MESSAGE e078(migo).
    ENDIF.
  ENDIF.
* end of Outsourced Manufacturing EhP 4
* for rebate in kind (naturalrabatt): delete xebefu if fuss is already
* filled with the rebate in kind-position                =>  note 312761
  LOOP AT xebefu WHERE uptyp NE space.
    IF ( xebefu-uptyp EQ uptyp_nre OR xebefu-uptyp EQ uptyp_nra )
      AND xebefu-upvor IS INITIAL.
      h_fuss = fuss.
      LOOP AT fuss WHERE lfbnr = xebefu-lfbnr AND
                   ebeln = xebefu-ebeln AND
                   ebelp = xebefu-ebelp AND
                   uptyp = xebefu-uptyp AND
                   upvor = xebefu-upvor AND
                   uebpo = xebefu-uebpo.
        IF sy-subrc = 0.
          DELETE xebefu.
          EXIT.
        ENDIF.
      ENDLOOP.
      fuss = h_fuss.
    ENDIF.
  ENDLOOP.
* only GR based IR/ cancellation (XEBEFU-LFBNR not initial):
* after batch split in the outbound delivery, items that are no longer
* required have to be eliminated; flag XSPLIT for item split is
* generally not set for XMBWL = X
  IF NOT xsplit IS INITIAL.
    DATA: h_mseg LIKE mseg.
    DATA: BEGIN OF t_vbfa OCCURS 0.
            INCLUDE STRUCTURE vbfa.
    DATA: END OF t_vbfa.
    LOOP AT xebefu.
      CHECK NOT xebefu-lfbnr IS INITIAL.
      READ TABLE t_vbfa WITH KEY vbelv = wueb-vbeln
                                 posnv = wueb-vbelp.
      IF sy-subrc <> 0.
        IF rm07m-xvers IS INITIAL.
          SELECT * FROM vbfa APPENDING TABLE t_vbfa
                             WHERE vbelv EQ wueb-vbeln
                             AND   posnv EQ wueb-vbelp.
        ELSE.
          SELECT * FROM vbfa APPENDING TABLE t_vbfa
                             WHERE vbelv EQ xvepwe-vbeln
                             AND   posnv EQ xvepwe-posnr.
        ENDIF.
      ENDIF.
*     with SD document flow
      IF sy-subrc = 0.
        IF rm07m-xvers IS INITIAL.
          READ TABLE t_vbfa WITH KEY vbelv = wueb-vbeln
                                     posnv = wueb-vbelp
                                     vbeln = xebefu-lfbnr
                                     posnn = xebefu-lfpos.
        ELSE.
          READ TABLE t_vbfa WITH KEY vbelv = xvepwe-vbeln
                                     posnv = xvepwe-posnr
                                     vbeln = xebefu-lfbnr
                                     posnn = xebefu-lfpos.
        ENDIF.
        IF NOT sy-subrc IS INITIAL.
          DELETE xebefu.
        ENDIF.
      ELSE.
*     without SD document flow
        SELECT SINGLE * FROM mseg INTO h_mseg
                        WHERE mblnr EQ xebefu-lfbnr
                        AND   mjahr EQ xebefu-lfbja
                        AND   zeile EQ xebefu-lfpos.
        IF sy-subrc IS INITIAL.
          IF rm07m-xvers IS INITIAL AND
             wueb-charg NE h_mseg-charg OR
             NOT rm07m-xvers IS INITIAL AND
             xvepwe-charg NE h_mseg-charg.
            DELETE xebefu.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Check that for postings into blocked stock there is no stock
* transfer line present. Before CSFG, BSAKZ was on the header level,
* now it's an item field. We are not checking this condition
* on the item level because we do not know how to react for mixed
* cases.
  IF NOT t156-kzwes IS INITIAL.                             "sdp462
    READ TABLE xebefu WITH KEY bsakz = t TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.                                        "sdp462
      IF cl_mm_im_sit_info=>get_sit_info_item(              "SIT
                            iv_ebeln = b_ebeln              "SIT
                            iv_ebelp = b_ebelp ) <> 'X'.    "SIT
        MESSAGE e011.                                       "sdp462
      ENDIF.
    ENDIF.                                                  "sdp462
  ENDIF.                                                    "sdp462

ENDFORM.                    "bestellung_pruefen