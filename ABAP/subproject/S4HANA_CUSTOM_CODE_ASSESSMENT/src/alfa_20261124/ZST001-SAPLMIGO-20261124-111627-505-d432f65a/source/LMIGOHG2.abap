*----------------------------------------------------------------------*
*   INCLUDE LMIGOHG2                                                   *
*   Header tabstrip general implementation
*----------------------------------------------------------------------*
CLASS lcl_migo_header_general IMPLEMENTATION.
*----------------------------------------------------------------------*
* METHOD CONSTRUCTOR
*----------------------------------------------------------------------*
  METHOD constructor.
    DATA: lt_okcodes TYPE lif_migo_frame=>ty_t_okcodes,
          lt_sending   TYPE lif_migo_frame=>ty_t_message_ids."315434

*   screenobject constructor needed to instance variables
    CALL METHOD super->constructor.

    APPEND 'MIGO_OK_OUTPUT'    TO lt_okcodes.
    APPEND 'MIGO_OK_LOGHEADER' TO lt_okcodes.
    APPEND 'HEADER_WEVER_CHANGED'      TO lt_sending.       "315434

ENHANCEMENT-POINT CONSTRUCTOR_02 SPOTS ES_SAPLMIGO.
    lif_migo_frame~class_id = 'MIGO_HEADER_GENERAL'.
    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer = me
        it_okcodes    = lt_okcodes
        it_sending    = lt_sending.                         "315434
  ENDMETHOD.                    "constructor

*----------------------------------------------------------------------*
* METHOD PBO
*----------------------------------------------------------------------*
  METHOD pbo.
    CALL METHOD super->pbo.
*   Set text for print indicator
    CALL METHOD print_text_set.
*   Convert kernel fields to viewer fields. Note that only
*   the right field is filled to ensure that there are no old data
*   in the other field.
    CLEAR: gohead-lfsnr, gohead-mtsnr.
    CASE g_sub_general.
      WHEN 110 OR 111. gohead-lfsnr = gohead-xblnr.
      WHEN OTHERS.     gohead-mtsnr = gohead-xblnr.
    ENDCASE.
  ENDMETHOD.                            "PBO

*----------------------------------------------------------------------*
* METHOD PAI
*----------------------------------------------------------------------*
  METHOD pai.
    CALL METHOD super->pai.
*   set parameter NDR
    CALL METHOD print_parameter_set.
*   Delivery note (lfsnr) and external material slip (mtsnr) are just
*   viewer fields.
    gohead-xblnr = gohead-lfsnr.
    IF NOT gohead-mtsnr IS INITIAL.
      gohead-xblnr = gohead-mtsnr.
    ENDIF.
  ENDMETHOD.                            "PAI
*----------------------------------------------------------------------*
* METHOD PAI_XBLNR (external document number)
* This method is called on request only. If user enters a manual XBLNR
* it has priority over XBLNR from WUEB (GOITEM-VERUR_REFDOC)
*----------------------------------------------------------------------*
  METHOD pai_xblnr.
    gohead-xblnr_manual = abap_true.
  ENDMETHOD.                           "PAI_XBLNR
*----------------------------------------------------------------------*
* METHOD PAI_FRBNR (external bill of lading number)
* This method is called on request only. If user enters a manual FRBNR
* it has priority over FRBNR from WUEB (GOITEM-BOLNR_REFDOC)
*----------------------------------------------------------------------*
  METHOD pai_frbnr.
    gohead-frbnr_manual = abap_true.
  ENDMETHOD.                           "PAI_FRBNR
*----------------------------------------------------------------------*
* METHOD PAI_WEVER (print version) - note 315434
* This method is called on request only. If user changes WEVER manually
* we update the ESDUS defaults in lcl_migo_defaults. Lcl_migo_defaults
* will then send the data to kernel to update s_defaults in kernel.
* Ps_gohead-wever will be changed through normal header_modify.
*----------------------------------------------------------------------*
  METHOD pai_wever.                                         "315434
    def_sms 'HEADER_WEVER_CHANGED' gohead-wever space.
  ENDMETHOD.                           "PAI_WEVER
ENHANCEMENT-POINT LMIGOHG2_01 SPOTS ES_SAPLMIGO STATIC.
*----------------------------------------------------------------------*
* METHOD PRINT_TEXT_SET
*----------------------------------------------------------------------*
* sets text for print indicator depending on gohead-xnapr
*----------------------------------------------------------------------*
  METHOD print_text_set.
    godynpro-print_text = icon_print.
    IF gohead-xnapr IS INITIAL.
      godynpro-print_text+4 = text-h02."inactive
    ELSE.
      godynpro-print_text+4 = text-h01."active
    ENDIF.
  ENDMETHOD.                    "print_text_set

*----------------------------------------------------------------------*
* METHOD PRINT_PARAMETER_SET
*----------------------------------------------------------------------*
* sets parameter NDR from gohead-xnapr after screen change
*----------------------------------------------------------------------*
  METHOD print_parameter_set.
*   In display mode gohead-xnapr is separated from parameter     "307284
*   NDR as it is set from entries in table NAST                  "307284
    CHECK lcl_migo_globals=>kernel->s_action-create = abap_true."307284
    SET PARAMETER ID 'NDR' FIELD gohead-xnapr.
  ENDMETHOD.                    "print_parameter_set

*----------------------------------------------------------------------*
* interfaces
*----------------------------------------------------------------------*
  METHOD lif_migo_frame~okcode_handler.
    CASE i_okcode.
      WHEN 'MIGO_OK_OUTPUT'.
*     Output determination only in display mode. Done by big brother
*     MB_CREATE in creation mode. Note 315434
      IF lcl_migo_globals=>kernel->s_action-display = abap_true."315434
          CALL METHOD lcl_migo_globals=>kernel->output_determination.
      ENDIF.                                                "315434
      WHEN 'MIGO_OK_LOGHEADER'.
        CALL METHOD oref_log->display.
    ENDCASE.
  ENDMETHOD.                    "lif_migo_frame~okcode_handler

  METHOD lif_migo_frame~message_handler.
  ENDMETHOD.                    "lif_migo_frame~message_handler
************************************************************************
* Value help for the date fields according to factory calendar
************************************************************************
  METHOD pov_date.
    DATA: ls_goplant TYPE goplant,
          l_field    TYPE fname_d,
          l_date     TYPE sydatum.
    FIELD-SYMBOLS: <date> TYPE sydatum.
*   Get factory calendar of the plant in the default value settings
    IF lcl_migo_globals=>kernel->s_defaults-werks <> space.
      CALL METHOD lcl_migo_buffer=>plant_get
        EXPORTING
          i_plant   = lcl_migo_globals=>kernel->s_defaults-werks
        RECEIVING
          e_goplant = ls_goplant
        EXCEPTIONS
          not_found = 1.
    ENDIF.
*   Call the calendar module
    CALL FUNCTION 'GET_DATE_FROM_CALID'
      EXPORTING
        calid      = ls_goplant-fabkl
        dynnr      = sy-dynnr                                    "786784
        repid      = c_repid
      IMPORTING
        field_name = l_field
        new_date   = l_date.
*   Take value if something has been selected
    IF NOT l_date IS INITIAL.
      ASSIGN (l_field) TO <date>.
      <date> = l_date.
    ENDIF.
  ENDMETHOD.                    "pov_date
ENDCLASS.                    "lcl_migo_header_general IMPLEMENTATION