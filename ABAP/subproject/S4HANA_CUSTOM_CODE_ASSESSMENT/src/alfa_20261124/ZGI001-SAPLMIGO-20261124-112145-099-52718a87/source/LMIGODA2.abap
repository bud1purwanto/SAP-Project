*----------------------------------------------------------------------*
*   INCLUDE LMIGODA2                                                   *
*   Detail tabstrip account implementation
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_account IMPLEMENTATION.

************************************************************************
* PBO: determine the account subscreen.
************************************************************************
  METHOD pbo.
    CALL METHOD super->pbo.
    CALL METHOD account_send.
  ENDMETHOD.                    "pbo

************************************************************************
* PAI before call to subscreen of CO.
************************************************************************
  METHOD pai.
    DATA: lt_coblf  TYPE STANDARD TABLE OF coblf,
          ls_cobl   TYPE cobl.
    CALL METHOD super->pai.
* Call double click handler of accounting block if :
* a) OKCODE = OK_PICK ( = F2 or double click)
* b) The current tab is the accounting block
* c) The cursor is currently not within a field known to MIGO.
*    Note that the CURSOR is cleared at the beginning of PAI.
    IF okcode = 'OK_PICK' AND ts_goitem-activetab = 'OK_GOITEM_ACCOUNT'
       AND lcl_migo_cursor=>oref_screenobject IS INITIAL.
      CALL FUNCTION 'COBL_FCODE_SET'
        EXPORTING
          fcode = 'COBL_PICK'.
    ENDIF.

    CALL FUNCTION 'COBL_SEND_PAI'
      EXPORTING
        cobl_pai     = ls_cobl
        check_always = ' '
        check_not    = 'X'
      TABLES
        icoblf       = lt_coblf.
*    ENDIF.
  ENDMETHOD.                    "pai

************************************************************************
* PAI: Receive data from ACCOUTINGBLOCK
************************************************************************
  METHOD pai_detail_account_receive.
    DATA: ls_cobl     TYPE cobl,
          ls_gocobl   TYPE gocobl,
            l_cancelled   TYPE abap_bool,
            ls_conv_error TYPE bapiret2.
* If the accounting block is used to enter data, the entered data
* are received and written back into GOITEM.
* Remark: The coding is also executed if only KONTO is visible.
* No problem, as in this case LS_COBL should be empty.
    IF goitem-xaccount      = abap_true AND
       goitem-xaccount_disp = abap_false.
      CALL FUNCTION 'COBL_RECEIVE'
        IMPORTING
          ecobl            = ls_cobl
          esc_used         = l_cancelled
          conversion_error = ls_conv_error.

*/Earmarked Dunds Document.
* Extension for reading accounting based details
* on entering (input field) earmarked funds document in
* accounting tab. !! Processed using "CHECK" or "POST"
* function in MIGO

      IF cl_psm_core_switch_check=>PSM_FM_GI_EF_CORE_NOT_REV( ) IS NOT INITIAL.
        IF gv_error = 'X'.
          CLEAR gv_error.
          RETURN.
        ENDIF.
        IF ls_cobl-kblnr IS NOT INITIAL.
          ls_cobl-hkont = goitem-konto.

          DATA: lt_trwin TYPE TABLE OF funit,
                ls_trwin TYPE funit,
                l_excp type ref to cx_fmef_msg.

          CALL FUNCTION 'RWIN_CHECK'
            EXPORTING
              gjahr         = ls_cobl-gjahr
              process       = 'BELEGPOS'
              event         = 'PRUEFEN '
            TABLES
              tkomp         = lt_trwin
            EXCEPTIONS
              error_message = 0
              OTHERS        = 0.


          LOOP AT lt_trwin INTO ls_trwin.

            CALL FUNCTION ls_trwin
              EXPORTING
                i_cobl        = ls_cobl
              IMPORTING
                e_cobl        = ls_cobl
              EXCEPTIONS
                error_message = 1.

            IF sy-subrc IS NOT INITIAL.
              gv_error = 'X'.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ENDLOOP.
          goitem-konto = ls_cobl-hkont.
        ENDIF.
      ENDIF.
*\Earmarked Dunds Document.

      IF l_cancelled = abap_false.
        IF ls_conv_error-type <> space.                     "426642
          MESSAGE ID ls_conv_error-id TYPE 'S'              "426642
          NUMBER ls_conv_error-number                       "426642
          WITH ls_conv_error-message_v1                     "426642
          ls_conv_error-message_v2                          "426642
          ls_conv_error-message_v3                          "426642
          ls_conv_error-message_v4.                         "426642
        ENDIF.                                              "426642
        MOVE-CORRESPONDING ls_cobl   TO ls_gocobl.
        MOVE-CORRESPONDING ls_gocobl TO goitem.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "pai_detail_account_receive

************************************************************************
* PAI: determine the account subscreen
************************************************************************
  METHOD account_send.
    DATA: ls_cobl        TYPE cobl,
          ls_gocobl      TYPE gocobl,
          l_fieldname    TYPE migo_fieldname,
          l_coblname     TYPE migo_fieldname,               "382998
          l_goitemname   TYPE migo_fieldname,               "382998
          l_status       TYPE migo_fs_status,
          lt_fields      TYPE ty_t_fieldname,
          ls_coblf       TYPE coblf,
          lt_coblf       TYPE STANDARD TABLE OF coblf,
          ls_gohead      TYPE gohead,
          ls_mtcom       TYPE mtcom,                        "650421
          ls_mtcor       TYPE mtcor,                        "650421
          ls_mbefu       TYPE mbefu,                        "650421
          ls_control     TYPE lcl_migo_kernel=>ty_s_control. "431091

    FIELD-SYMBOLS: <f> TYPE ANY.
* Fields to test: In DISPLAY, we show all fields which are filled
* with data --> loop over all relevant fields.
* In INPUT, we only show the fields which are ready for input -->
* get fields for the movement type.
    IF goitem-xaccount_disp = abap_true.
      lt_fields =
      cl_mmim_migo_move_fields=>t_gocobl1_fields.
    ELSE.
      CALL METHOD cl_mmim_migo_move_fields=>get_cobl_fields
        EXPORTING
          i_bwart   = goitem-bwart
        IMPORTING
          et_fields = lt_fields.
    ENDIF.
* Fill LS_COBL from MIGO data
    CALL METHOD lcl_migo_globals=>kernel->header_get
      IMPORTING
        e_gohead = ls_gohead.
    MOVE-CORRESPONDING ls_gohead TO ls_cobl.
    MOVE-CORRESPONDING goitem    TO ls_gocobl.
    MOVE-CORRESPONDING ls_gocobl TO ls_cobl.

*--Display Funded Program in MM Screens
    FIELD-SYMBOLS <measure> TYPE fm_measure.
    ASSIGN COMPONENT 'MEASURE' OF STRUCTURE ls_cobl TO <measure>.
    IF sy-subrc EQ 0 AND <measure> IS INITIAL.
      <measure> = cl_fm_funded_prog_util_appl=>get_measure_from_po(
                                                                           iv_refbn = goitem-ebeln
                                                                           iv_rfpos = goitem-ebelp
                                                                           "IV_RFKNT = lv_rfknt
                                                                         ).
    ENDIF.

* Determine the fields to be shown.

    IF cl_psm_core_switch_check=>PSM_FM_GI_EF_CORE_NOT_REV( ) IS NOT INITIAL.
      APPEND 'FIPOS' TO lt_fields.
      APPEND 'FISTL' TO lt_fields.
      APPEND 'FKBER' TO lt_fields.
      APPEND 'GEBER' TO lt_fields.
      APPEND 'BUDGET_PD' TO lt_fields.
      APPEND 'GRANT_NBR' TO lt_fields.
    ENDIF.

    LOOP AT lt_fields INTO l_fieldname.
      CLEAR ls_coblf.
      ls_coblf-fdnam  = l_fieldname.
      ls_coblf-active = c_mod_on.

*   Access field content.
      CONCATENATE 'LS_COBL-' l_fieldname INTO l_coblname.   "382998
      ASSIGN (l_coblname) TO <f>.                           "382998
      CHECK sy-subrc = 0.                                   "382998
      IF goitem-xaccount_disp = abap_true.
*     In DISPLAY, show the field if filled.
        IF NOT <f> IS INITIAL.
          ls_coblf-output = c_mod_on.
          APPEND ls_coblf TO lt_coblf.
        ENDIF.
      ELSE.
*     In INPUT, show it if in the list (depending on BWART, see above)
        ls_coblf-input  = c_mod_on.
        ls_coblf-output = c_mod_on.
*     If the cursor is to be set on this field...
        IF lcl_migo_cursor=>dynnr =  sy-dynnr    AND
           lcl_migo_cursor=>field CS l_fieldname.
          ls_coblf-cupos = c_mod_on.
        ENDIF.
*     Required fields are marked for easier identification.
*     Needs to look as in LMIGOSMC (MAIN).
        CONCATENATE 'GOITEM-' l_fieldname INTO l_goitemname. "382998
        IF <f> IS INITIAL AND                               "382998
           lcl_migo_screenmodification=>get_required(       "382998
             i_field          = l_goitemname                "382998
             i_global_counter = goitem-global_counter       "382998
           ) = abap_true.                                   "382998
          ls_coblf-intens = '1'.                            "382998
        ENDIF.                                              "382998
*     Check MIGO-fieldselection if the field is 'input'. If not on
*    'input', the field should not appear on accounting subscreen. This
*     means the APPEND should not happen.
        CALL METHOD lcl_migo_screenmodification=>get
          EXPORTING
            i_field          = l_goitemname
            i_global_counter = goitem-global_counter
          RECEIVING
            r_status         = l_status.

* /Earmarked Funds Fields to be shown on screen 1013
        IF cl_psm_core_switch_check=>PSM_FM_GI_EF_CORE_NOT_REV( ) IS NOT INITIAL.
* Although the field gets status '0' it should be displayed
* for Earmarked Funds Document reasons (precondition: field has a value).
          IF ( l_goitemname = 'GOITEM-FIPOS' AND goitem-fipos IS NOT INITIAL ) OR
             ( l_goitemname = 'GOITEM-FISTL' AND goitem-fistl IS NOT INITIAL ) OR
             ( l_goitemname = 'GOITEM-FKBER' AND goitem-fkber IS NOT INITIAL ) OR
             ( l_goitemname = 'GOITEM-GEBER' AND goitem-geber IS NOT INITIAL ) OR
             ( l_goitemname = 'GOITEM-BUDGET_PD' AND goitem-budget_pd IS NOT INITIAL ) OR
             ( l_goitemname = 'GOITEM-GRANT_NBR' AND goitem-grant_nbr IS NOT INITIAL ).

            l_status = lcl_migo_screenmodification=>c_visible.

* Field gets status that it can be seen. No INPUT!
            ls_coblf-input = c_mod_off_blank.
          ENDIF.
        ENDIF.
* \Earmarked Funds Fields to be shown on screen 1013
* For cancellations of material docs, the Earmarked Funds number should
* not be editable.
        IF goitem-kblnr IS NOT INITIAL or
          goitem-kblpos IS NOT INITIAL.
            IF godynpro-action = 'A03' and godynpro-refdoc = 'R02'.
              l_status = lcl_migo_screenmodification=>c_visible.
            ENDIF.
        ENDIF.

        IF l_status <> lcl_migo_screenmodification=>c_invisible.
          APPEND ls_coblf TO lt_coblf.
        ENDIF.
      ENDIF.
    ENDLOOP.

* For profitability analysis, BUKRS and GJAHR need to be filled.
* GJAHR is derived from plant-CC and posting date, BUKRS
* with the same odd logic as in MM07MFK0.
* This correction makes the PA run. It does not fill all the
* fields as MM07MFK0 (MATNR, WEKRS). In the design of MIGO,
* only accounting fields and the absolutely necessaty data (BUDAT...)
* should be transferred to CO.
* That's the reason for the filter LS_GOCOBL above.
    IF goitem-sobkz = o AND goitem-parent <> space.         "650421
      ls_mtcom-kenng = 'MBEFU'.                             "650421
      ls_mtcom-matnr = goitem-matnr.                        "650421
      ls_mtcom-werks = goitem-werks.                        "650421
      CALL FUNCTION 'MATERIAL_READ'                         "650421
           EXPORTING
                schluessel   = ls_mtcom
           IMPORTING
                matdaten     = ls_mbefu
                return       = ls_mtcor.
      MOVE-CORRESPONDING ls_mbefu TO ls_cobl.               "650421

*If 543's field status is opened, then PRCTR should be taken from"985618
*101 line ( goitem ) instead of material master.                 "985618
*Check field PRCTR                                               "985618
      READ TABLE lt_coblf INTO ls_coblf                     "985618
                 WITH KEY fdnam = 'PRCTR'.                  "985618
      IF sy-subrc IS INITIAL.                               "985618
        IF ls_coblf-output = c_mod_on.                      "985618
          ls_cobl-prctr = goitem-prctr.                     "985618
        ENDIF.                                              "985618
      ENDIF.                                                "985618
    ENDIF.                                                  "650421

    IF ls_cobl-bukrs IS INITIAL.                            "381370
      ls_cobl-bukrs = goitem-bukrs_for_stock.               "381370
    ENDIF.                                                  "381370
    CALL FUNCTION 'FI_PERIOD_DETERMINE'                     "381370
      EXPORTING                                             "381370
        i_budat              = ls_gohead-budat              "381370
        i_bukrs              = goitem-bukrs_for_stock       "381370
      IMPORTING                                             "381370
        e_gjahr              = ls_cobl-gjahr                "381370
      EXCEPTIONS                                            "381370
        OTHERS               = 1.                           "381370
    IF sy-subrc <> 0.                                       "381370
      CLEAR ls_cobl-gjahr.                                  "381370
    ENDIF.                                                  "381370

*  COBL needs those fields in order to make the decission which detail
*  screen for profitability segment is the right one
    ls_control = lcl_migo_globals=>kernel->mode_get( ).     "431091
    ls_cobl-vorgn   = ls_control-rw_vorgn.                  "431091
    ls_cobl-awtyp   = ls_control-rw_vorgn.                  "431091

*  COBL-MATNR is filled for reading the characteristics of
*  the profitability segment in PBO
    IF ls_cobl-matnr IS INITIAL.                            "938580
      ls_cobl-matnr = goitem-matnr.                         "859976
    ENDIF.                                                  "859976

*--Display Funded Program in MM Screens
    IF NOT cl_fm_funded_prog_util_appl=>is_measure_active( )  IS INITIAL.
      ls_coblf-fdnam    = 'MEASURE'.
      ls_coblf-input     = '0'.
      ls_coblf-required  = '0'.
      ls_coblf-output    = '1'.
      ls_coblf-intens    = '0'.
      ls_coblf-invisible = '0'.
      IF goitem-kblnr IS NOT INITIAL or
        goitem-kblpos IS NOT INITIAL.
        ls_coblf-active    = '1'.
      ELSE.
        ls_coblf-active    = '0'.
      ENDIF.
      APPEND ls_coblf TO lt_coblf.
    ENDIF.

    " For OLC the VORNR_AUF field is displayed instead of the VORNR field
    IF cl_erp_co_olc_sw_check=>erp_co_olc( ) EQ 'X'.
      " Make sure that AUFNR is enabled.
      FIELD-SYMBOLS <vornr> TYPE coblf.
      DATA ls_aufnr_coblf TYPE coblf.
      READ TABLE lt_coblf INTO ls_aufnr_coblf WITH KEY fdnam = 'AUFNR'.
      IF sy-subrc EQ 0.
        " The entry exists for AUFNR, if NPLNR exists then we need VORNR and VORNR_AUF
        READ TABLE lt_coblf TRANSPORTING NO FIELDS WITH KEY fdnam = 'NPLNR'.
        IF sy-subrc EQ 0.
          ls_aufnr_coblf-fdnam = 'VORNR_AUF'.
          APPEND ls_aufnr_coblf TO lt_coblf.
        ELSE.
          " No NPLNR so replace VORNR with VORNR_AUF
          READ TABLE lt_coblf ASSIGNING <vornr> WITH KEY fdnam = 'VORNR'.
          IF sy-subrc EQ 0.
            <vornr>-fdnam = 'VORNR_AUF'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

* Determine the correct CO screen number depending on shown fields.
* Even if LT_COBLF is empty, CO knows how to handle this.
    ls_cobl-process = 'BELEGPOS'.
    ls_cobl-event   = 'PRUEFEN'.
    CALL FUNCTION 'COBL_SEND_PBO'
      EXPORTING
        dclass = 'STD1'
        icobl  = ls_cobl
      IMPORTING
        dynnr  = g_cobl_subscreen
        progn  = g_cobl_progn
      TABLES
        icoblf = lt_coblf.
  ENDMETHOD.                    "account_send

ENDCLASS.                    "lcl_migo_detail_account IMPLEMENTATION