FUNCTION migo_dialog.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_ACTION) TYPE  GOACTION DEFAULT 'A04'
*"     VALUE(I_REFDOC) TYPE  REFDOC DEFAULT 'R02'
*"     VALUE(I_NOTREE) TYPE  CHAR1 DEFAULT 'X'
*"     VALUE(I_NO_AUTH_CHECK) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_SKIP_FIRST_SCREEN) TYPE  CHAR1 DEFAULT 'X'
*"     VALUE(I_DEADEND) TYPE  CHAR1 DEFAULT 'X'
*"     VALUE(I_OKCODE) TYPE  OKCODE DEFAULT 'OK_GO'
*"     VALUE(I_LEAVE_AFTER_POST) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_NEW_ROLLAREA) TYPE  CHAR1 DEFAULT 'X'
*"     VALUE(I_SYTCODE) TYPE  SYTCODE OPTIONAL
*"     VALUE(I_EBELN) TYPE  EBELN OPTIONAL
*"     VALUE(I_EBELP) TYPE  EBELP OPTIONAL
*"     VALUE(I_MBLNR) TYPE  MBLNR OPTIONAL
*"     VALUE(I_MJAHR) TYPE  MJAHR OPTIONAL
*"     VALUE(I_ZEILE) TYPE  MBLPO OPTIONAL
*"     VALUE(I_TRANSPORT) TYPE  TKNUM OPTIONAL
*"     VALUE(I_ORDER_NUMBER) TYPE  AUFNR OPTIONAL
*"     VALUE(I_ORDER_ITEM) TYPE  CO_POSNR OPTIONAL
*"     VALUE(I_TRANSPORT_MEANS) TYPE  TRATY OPTIONAL
*"     VALUE(I_TRANSPORTIDENT) TYPE  TRAID OPTIONAL
*"     VALUE(I_INBOUND_DELIV) TYPE  VBELN_VL OPTIONAL
*"     VALUE(I_OUTBOUND_DELIV) TYPE  VBELN OPTIONAL
*"     VALUE(I_RESERVATION_NUMB) TYPE  RSNUM OPTIONAL
*"     VALUE(I_RESERVATION_ITEM) TYPE  RSPOS OPTIONAL
*"     VALUE(EXT) TYPE  EXT_MIGO_DIALOG OPTIONAL
*"  EXCEPTIONS
*"      ILLEGAL_COMBINATION
*"----------------------------------------------------------------------

**                                  begin note 373801
**MIGO not yet allowed for retail-customers
**first check whether this is a retail-system
*  DATA: p_retail(1).
*  DATA: s_sysdef  TYPE tsysdef.
*
*  CLEAR p_retail.
*
*  CALL FUNCTION 'SYSTEM_SWITCH_GET'
*       IMPORTING
*            sysdef = s_sysdef
*       EXCEPTIONS
*            error  = 1
*            OTHERS = 2.
*  IF sy-subrc <> 0.
*    MESSAGE e020(systemswitch).
*  ELSE.
*    IF s_sysdef-sysdef EQ '01'.
** Yes, we're retail
*      p_retail = 'X'.
*    ENDIF.
*  ENDIF.
*
*  IF p_retail = 'X'.
**we're retail -> use the old transactions
*    DATA: l_tcode TYPE tcode,
*          l_vgart TYPE vgart.
*
*    l_tcode = 'MIGO'.                                 " note 398723
**   set a default value to avoid a short dump later on
*    IF i_refdoc = 'R02'.                              "Material
*document
*        CASE i_action.
*          WHEN 'A01'. l_tcode = 'MB01'.
*          WHEN 'A02'. l_tcode = 'MBRL'.
*          WHEN 'A03'. l_tcode = 'MBST'.
*          WHEN 'A04'. l_tcode = 'MB03'.
*          WHEN 'A05'. l_tcode = 'MBSF'.
*          WHEN 'A06'. l_tcode = 'MBNL'.
*          WHEN 'A07'. l_tcode = 'MB0A'.               " note 398723
*        ENDCASE.
**** begin note 398723
*        SET PARAMETER ID 'MBN' FIELD i_mblnr.
*        SET PARAMETER ID 'MJA' FIELD i_mjahr.
*        SET PARAMETER ID 'POS' FIELD i_zeile.
**       do this only in the R02-case
*     ELSEIF i_refdoc = 'R01'.      " purchase order
*        CASE i_action.
*          WHEN 'A01'.
**           goods receipt
*            DATA:
*              BEGIN OF rm07m,
*                ebeln LIKE ekpo-ebeln,
*                ebelp LIKE ekpo-ebelp,
*              END OF rm07m.
**           it's not known here...but we need it for the export
*            l_tcode = 'MB01'.
*            rm07m-ebeln = i_ebeln.
*            rm07m-ebelp = i_ebelp.
*            EXPORT rm07m-ebeln rm07m-ebelp TO MEMORY ID 'FOLGEWE'.
*            SET PARAMETER ID 'BWE' FIELD '101'.
**           prepare the MB01-screen
*        ENDCASE.
*     ENDIF. " i_refdoc
**---* The above coding is based on the current situation. We never know
**---* who calls MIGO in the future. So may be this note has to be
**---* extended...
**** end   note 398723
** Check for authorization TCODE
*      IF i_no_auth_check IS INITIAL.
*        CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
*          EXPORTING
*            tcode   = l_tcode
*          EXCEPTIONS
*            ok        = 0
*            not_ok    = 1
*            OTHERS    = 2.
*        IF sy-subrc NE 0.
*         MESSAGE s172(00) WITH l_tcode.
*         EXIT.
*"626539
*        ENDIF.
*      ENDIF.
**    ENDIF                                            " note 398723
**    SET PARAMETER ID 'MBN' FIELD i_mblnr.            " note 398723
**    SET PARAMETER ID 'MJA' FIELD i_mjahr.            " note 398723
**    SET PARAMETER ID 'POS' FIELD i_zeile.            " note 398723
*    IF i_skip_first_screen IS INITIAL.
*      CALL TRANSACTION l_tcode.
*    ELSE.
*      CALL TRANSACTION l_tcode AND SKIP FIRST SCREEN.
*    ENDIF.
*    EXIT.
**the above coding is (mostly) copied from 4.6B
*  ENDIF.
**                               end note 373801

* Start in new roll area: Recall yourself
  IF NOT i_new_rollarea IS INITIAL.
    SUBMIT mb_call_migo_dialog                                   "317215
      WITH i_action    = i_action                                "317215
      WITH i_refdoc    = i_refdoc                                "317215
      WITH i_notree    = i_notree                                "317215
      WITH i_no_aut    = i_no_auth_check                         "317215
      WITH i_skip_f    = i_skip_first_screen                     "317215
      WITH i_deaden    = i_deadend                               "317215
      WITH i_okcode    = i_okcode                                "317215
      WITH i_leave_    = i_leave_after_post                      "317215
      WITH i_new_ro    = space                                   "317215
      WITH i_sytcod    = sy-tcode                                "317215
      WITH i_ebeln     = i_ebeln                                 "317215
      WITH i_ebelp     = i_ebelp                                 "317215
      WITH i_mblnr     = i_mblnr                                 "317215
      WITH i_mjahr     = i_mjahr                                 "317215
      WITH i_zeile     = i_zeile                                 "317215
      WITH i_transp    = i_transport
      WITH i_ordern    = i_order_number
      WITH i_orderi    = i_order_item
      WITH i_tr_mea    = i_transport_means
      WITH i_tr_ide    = i_transportident
      WITH i_in_del    = i_inbound_deliv
      WITH i_out_de    = i_outbound_deliv
      WITH i_res_nu    = i_reservation_numb
      WITH i_res_it    = i_reservation_item
      WITH i_ext       = ext
      AND RETURN.                                                "317215
    EXIT.
  ENDIF.

* If I_SYTCODE is filled, this if the one from the original
* calling transaction (remember: if we start in a separate
* roll area, SY-TCODE can be anything...), otherwise use the
* current one.
  IF NOT i_sytcode IS INITIAL.
    lcl_migo_globals=>caller_sytcode = i_sytcode.
  ENDIF.

* Check for authorization TCODE
  IF i_no_auth_check IS INITIAL.
    CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
      EXPORTING
        tcode   = 'MIGO'
      EXCEPTIONS
        ok        = 0
        not_ok    = 1
        OTHERS    = 2.
    IF sy-subrc NE 0.
     MESSAGE s172(00) WITH 'MIGO'.
     EXIT.                                                       "626539
    ENDIF.
  ENDIF.
* MIGO call
* ======================================================================
* Check combination of action and refdoc.
  READ TABLE lcl_migo_globals=>t_cust
             WITH KEY action = i_action
                      refdoc = i_refdoc
             TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    RAISE illegal_combination.
  ENDIF.

* Set data for transfer into dynpro 0001.
  lcl_migo_globals=>external_call_action           = i_action.
  lcl_migo_globals=>external_call_refdoc           = i_refdoc.
  lcl_migo_globals=>external_call_okcode           = i_okcode.
  lcl_migo_globals=>external_call_notree           = i_notree.
  lcl_migo_globals=>external_call_deadend          = i_deadend.
  lcl_migo_globals=>external_call_ebeln            = i_ebeln.
  lcl_migo_globals=>external_call_ebelp            = i_ebelp.
  lcl_migo_globals=>external_call_mblnr            = i_mblnr.
  lcl_migo_globals=>external_call_mjahr            = i_mjahr.
  lcl_migo_globals=>external_call_zeile            = i_zeile.
  lcl_migo_globals=>external_call_transport        = i_transport.
  lcl_migo_globals=>external_call_order_number     = i_order_number.
  lcl_migo_globals=>external_call_order_item       = i_order_item.
  lcl_migo_globals=>external_call_transport_means  = i_transport_means.
  lcl_migo_globals=>external_call_transportident   = i_transportident.
  lcl_migo_globals=>external_call_inbound_deliv    = i_inbound_deliv.
  lcl_migo_globals=>external_call_outbound_deliv   = i_outbound_deliv.
  lcl_migo_globals=>external_call_reservation_numb = i_reservation_numb.
  lcl_migo_globals=>external_call_reservation_item = i_reservation_item.
* Set the signal that we are in the first loop over dynpro 0001
* after the call to MIGO_DIALOG. This will cause the data taking
* from the transfer fields to occur.
  lcl_migo_globals=>external_call_active      = abap_true.
  lcl_migo_globals=>external_call_leave_after_post =
                       i_leave_after_post.
  lcl_migo_globals=>external_call_first_round = abap_true.
ENHANCEMENT-POINT EHP604_MIGO_DIALOG_01 SPOTS ES_SAPLMIGO .
* Save the current enqueue state to restore it when leaving MIGO.
* If MIGO is called directly, this is not necessary as the internal
* mode has no locks at this time.
  CALL METHOD lcl_migo_enqueue=>save( 'TRANSACTION_START' ).
* Start MIGO
  CALL SCREEN 0001.

ENDFUNCTION.