*----------------------------------------------------------------------*
* LMIGOKR2                                                             *
* Kernel implementation reservations                                   *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* METHOD reservation_data_get.
*----------------------------------------------------------------------
* This method is calling ldb MMIMMRKPFRESB via function ldb_process.
* A single reservation is read.
*----------------------------------------------------------------------
METHOD reservation_data_get.
  DATA: lt_callback  TYPE TABLE OF ldbcb,
          lt_selection TYPE TABLE OF rsparams,
          ls_callback  TYPE ldbcb,
          ls_selection TYPE rsparams.

* Fill callback structure.
  CLEAR ls_callback.
  ls_callback-ldbnode = 'RKPF'.
  ls_callback-get     = 'X'.
  ls_callback-cb_prog = sy-repid.
  ls_callback-cb_form = 'RKPF_GET_SEARCH'.
  APPEND ls_callback TO lt_callback.
  CLEAR ls_callback.
  ls_callback-ldbnode  = 'RESB'.
  ls_callback-get      = 'X'.
  ls_callback-cb_prog  = sy-repid.
  ls_callback-cb_form  = 'RESB_GET_SEARCH'.
  APPEND ls_callback TO lt_callback.

  DEFINE def_fill.
    if not &1 is initial.
      clear ls_selection.
      ls_selection-kind    = &2.
      ls_selection-selname = &3.
      ls_selection-sign    = 'I'.
      ls_selection-option  = 'EQ'.
      ls_selection-low     = &1.
      append ls_selection to lt_selection.
    endif.
  END-OF-DEFINITION.
  def_fill i_res_number 'S' 'RSNUM'.
  def_fill i_res_item   'S' 'RSPOS'.
  def_fill i_res_type   'S' 'RSART'.
  def_fill 'X'     'P' 'P_OPEN'.
  def_fill 'X'     'P' 'P_CANCEL'.
  def_fill 'X'     'P' 'P_ISSUES'.
  def_fill 'X'     'P' 'P_RECEIP'.
* Ensure that reservations with FI indicator set will be read    "659410
  if s_defaults-propose_all_items = abap_true.              "659410
    def_fill 'X' 'P' 'P_SELALL'.                            "659410
  endif.                                                    "659410
* If all reservations are to be read (for display material document
* etc), the database also has to return reservations which are
* not postable in MM-IM.
  IF i_all = abap_true.                                     "355296
    def_fill 'X' 'P' 'P_CLOSED'.                            "355296
  ENDIF.                                                    "355296

  CALL FUNCTION 'LDB_PROCESS'
    EXPORTING
      ldbname    = 'MMIMRKPFRESB'
    TABLES
      callback   = lt_callback
      selections = lt_selection
    EXCEPTIONS
      OTHERS     = 4.
  IF sy-subrc <> 0.
    def_msg_add oref_doc_log sy-msgty sy-msgid sy-msgno
                             sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* callback routins can be found in lmigore1:
* Form RKPF_GET_SEARCH
* Form RESB_GET_SEARCH

ENDMETHOD.                    "reservation_data_get
*----------------------------------------------------------------------*
* METHOD reservation_read.
*----------------------------------------------------------------------
* Reads a single reservation (using ldb MMIMRKPFRESB) and fills data
* from RKPF and RESB in GOITEM
*----------------------------------------------------------------------*
METHOD reservation_read.
  CLEAR:   pt_reservation_header,
           pt_reservation_item.

  CHECK NOT i_res_number IS INITIAL.            "note 361153

  CALL METHOD reservation_data_get
    EXPORTING
      i_res_number = i_res_number
      i_res_item   = i_res_item
      i_res_type   = i_res_type.

* pt_reservation_header is filled by method reservation_header_receive
* pt_reservation_items is filled by method reservation_items_receive
* both are used by function ldb_process as callback routins

  CALL METHOD reservation_data_fill
    EXPORTING
      it_resheader = pt_reservation_header
      it_resitem   = pt_reservation_item.

ENDMETHOD.                    "reservation_read

*----------------------------------------------------------------------*
* METHOD reservation_header_receive.
*----------------------------------------------------------------------
* This method receives the reservation data from the call back routins
* of function ldb_process. Called from FORM RKPF_GET_SEARCH
*----------------------------------------------------------------------
METHOD reservation_header_receive.

  APPEND is_resheader TO pt_reservation_header.

ENDMETHOD.                    "reservation_header_receive

*----------------------------------------------------------------------*
* METHOD reservation_header_receive.
*----------------------------------------------------------------------
* This method receives the reservation data from the call back routins
* of function ldb_process. Called from FORM RESB_GET_SEARCH
*----------------------------------------------------------------------
METHOD reservation_items_receive.

  APPEND is_resitem TO pt_reservation_item.

ENDMETHOD.                    "reservation_items_receive
*----------------------------------------------------------------------*
* METHOD reservation_data_fill
*----------------------------------------------------------------------
* it_resheader / it_resheader contain the reservation data found by
* ldb mmimrkpfresb. This method transfers the data from it_resheader /
* it_resheader into table pt_goitem.

*----------------------------------------------------------------------
METHOD reservation_data_fill.

  DATA: ls_resheader TYPE ty_s_resheader,
        ls_resitem   TYPE ty_s_resitem,
        l_open_quantity TYPE rbefu-offen,
        l_rc         LIKE sy-subrc.

  LOOP AT it_resheader INTO ls_resheader.
    LOOP AT it_resitem
         INTO ls_resitem
         WHERE rsnum = ls_resheader-rsnum.

*Begin of Note 965465
*Migo should not offer 543 reservation in case of GI against order
  IF ls_resitem-bdart = 'BB' AND s_control-refdoc = 'R08'
         AND NOT s_action-create is INITIAL.
           continue.
  ENDIF.
*End of Note 965465

*Begin of Note 534257
*    In case of reservation bdart 'AR' check for AFFW entries
*    same check for orders in method ORDER_RESERVATION_READ (LMIGOKO5)
      IF ls_resitem-bdart = 'AR' AND s_control-refdoc = 'R09'
         AND NOT s_action-create is INITIAL.
        CALL FUNCTION 'CO_FW_CHECK_AFFW_BY_RSNUM'
          EXPORTING
            I_RSNUM     = ls_resitem-rsnum
            I_RSPOS     = ls_resitem-rspos
          EXCEPTIONS
            INPUT_ERROR = 1
            NOT_FOUND   = 2
            OTHERS      = 3.
*     If AFFW entry exits sy-subrc = 0
        IF sy-subrc = 0.
          CALL FUNCTION 'MB_CHECK_T160M'
            EXPORTING
              I_ARBGB = 'M7'
              i_msgnr = '397'
              i_nolog = 'X'
            IMPORTING
              RC      = l_rc.
          CASE l_rc.
            WHEN '01'.
              MESSAGE W397(m7) WITH ls_resitem-rsnum ls_resitem-rspos.
              CALL METHOD oref_doc_log->message_add
                EXPORTING
                  i_msgty = w
                  i_msgid = 'M7'
                  i_msgno = '397'
                  i_msgv1 = ls_resitem-rsnum
                  i_msgv2 = ls_resitem-rspos.
            WHEN '02'.
              MESSAGE S397(M7) WITH ls_resitem-rsnum ls_resitem-rspos.
              CALL METHOD oref_doc_log->message_add
                EXPORTING
                  i_msgty = e
                  i_msgid = 'M7'
                  i_msgno = '397'
                  i_msgv1 = ls_resitem-rsnum
                  i_msgv2 = ls_resitem-rspos.
              CONTINUE.
          ENDCASE.
        ENDIF.
      ENDIF.
*End of Note 534257

*    Take only reservation items with open quantity > 0 or      "409754
*    or flag 'propose all items' is set (->default settings)    "409754
      l_open_quantity = ls_resitem-bdmng - ls_resitem-enmng."409754
      CHECK l_open_quantity > 0 OR                          "409754
            s_defaults-propose_all_items = abap_true.       "409754

      CALL METHOD reservation_goitem_fill
        EXPORTING
          is_resheader = ls_resheader
          is_resitem   = ls_resitem.
    ENDLOOP.
  ENDLOOP.
  DATA: l_autyp  type aufk-autyp.                           " 948510
*     Check header of production order for '+'              " 948510
  if not ls_resheader-aufnr is initial.                     " 948510
    select single autyp into l_autyp from aufk              " 948510
                        where aufnr = ls_resitem-aufnr.     " 948510
    if l_autyp = '10'.                                      " 948510
      call function 'CO_SF_HEADER_GOODS_ISSUE'              " 948510
        EXPORTING                                           " 948510
          aufnr = ls_resheader-aufnr.                       " 948510
    endif.                                                  " 948510
  endif.                                                    " 948510
  CALL METHOD status_derive.
ENDMETHOD.                    "reservation_data_fill

*----------------------------------------------------------------------*
* METHOD reservation_goitem_fill
*----------------------------------------------------------------------
* mapping of reservation data from structures ls_resheader / ls_resitem
* into ls_goitem
*----------------------------------------------------------------------
METHOD reservation_goitem_fill.
  DATA: ls_goitem       TYPE goitem,
        ls_cobl_old     TYPE cobl,                              "1651459
        ls_cobl_new     TYPE cobl,                              "1651459
        ls_gohead       TYPE gohead,                            "1651459
        ls_control      TYPE lcl_migo_kernel=>ty_s_control,     "1651459
        l_open_quantity TYPE mb_erfmg,
        l_rc            TYPE abap_bool,
        l_pspnr         TYPE grpga-grpnr.                   "795141


ENHANCEMENT-POINT MIGOKR2_04 SPOTS ES_SAPLMIGO STATIC .

  MOVE-CORRESPONDING is_resheader TO ls_goitem.
  MOVE-CORRESPONDING is_resitem TO ls_goitem.

* Item text default
  IF ls_goitem-sgtxt IS INITIAL.                            "605496
    ls_goitem-sgtxt = is_resitem-potx1.                     "605496
  ENDIF.                                                    "605496
* special treatment for fields with conflict between RKPF and RESB
* resb-pspel may be empty while rkpf-ps_psp_pnr is filled and vice versa
  IF is_resitem-pspel IS INITIAL.
    ls_goitem-ps_psp_pnr = is_resheader-ps_psp_pnr.
  ELSE.
    ls_goitem-ps_psp_pnr = is_resitem-pspel.
  ENDIF.

* Special stock identifier / accounting fields from reservation.
* Important for transfer postings:
* We have to remember the original content from the reservation,
* because the user can enter a special stock (e.g. 'E') and then we
* have to move the content from the account field (e.g. GOITEM-KDAUF)
* to the special stock identifier (e.g. GOITEM-UMMAT-KDAUF).
  ls_goitem-res_pspnr = ls_goitem-ps_psp_pnr.
  ls_goitem-res_kdauf = is_resitem-kdauf.
  ls_goitem-res_kdpos = is_resitem-kdpos.
  ls_goitem-res_lifnr = is_resitem-lifnr.
  ls_goitem-res_kunnr = is_resheader-kunnr.
ENHANCEMENT-POINT LMIGOKR2_04 SPOTS ES_SAPLMIGO .

* special stock sales order and project
* handle values for subscreen stock_identifier
  IF is_resitem-sobkz = e AND NOT is_resitem-kdauf IS INITIAL.
    ls_goitem-mat_kdauf = is_resitem-kdauf.
    ls_goitem-mat_kdpos = is_resitem-kdpos.
    CLEAR: ls_goitem-kdauf, ls_goitem-kdpos.
  ENDIF.
  IF is_resitem-sobkz = q AND NOT ls_goitem-ps_psp_pnr IS INITIAL.
    ls_goitem-mat_pspnr = ls_goitem-ps_psp_pnr.
    CLEAR ls_goitem-ps_psp_pnr.
*> Start of note 795141

*  In case of valuated project stock(s) check, whether grouping is
*  active ...
ENHANCEMENT-SECTION     LMIGOKR2_01 SPOTS ES_SAPLMIGO.
    IF is_resitem-kzbws = 'M'.
      CLEAR l_pspnr.
      CALL FUNCTION 'GRPG_FIND_GRPNR_WITH_MATNR'
        EXPORTING
          i_pspnr              = ls_goitem-mat_pspnr
          i_werks              = is_resitem-werks
          i_matnr              = is_resitem-matnr
        IMPORTING
          e_grpnr              = l_pspnr
        EXCEPTIONS
          wrong_input          = 1
          no_valid_grpnr_found = 2.
      IF sy-subrc is initial and NOT l_pspnr IS INITIAL.
        ls_goitem-mat_pspnr = l_pspnr.
      ENDIF.
    ENDIF.
END-ENHANCEMENT-SECTION.
*> End of note 795141
  ENDIF.
* The original SOBKZ of the reservation needs to be kept in order
* to distinguish reservations with own SOBKZ (must not be changed
* in MIGO) and reservations without SOBKZ but manually entered in MIGO.
  ls_goitem-res_sobkz = is_resitem-sobkz.                   "381405
  SELECT SINGLE umsok FROM t156b
                      INTO  ls_goitem-res_umsok
                      WHERE bwart = is_resitem-bwart AND
                            sobkz = is_resitem-sobkz.
* resb-aufnr may be empty while rkpf-aufnr is filled
  IF is_resitem-aufnr IS INITIAL.
    ls_goitem-aufnr = is_resheader-aufnr.
  ELSE.
    ls_goitem-aufnr = is_resitem-aufnr.
  ENDIF.
* resb-aufnr may contain a network when rkpf-nplnr is filled
  IF NOT ls_goitem-nplnr IS INITIAL.
    CLEAR ls_goitem-aufnr.
  ENDIF.

* some rkpf/resb fields have to be mapped into goitem fields with
* different names. Not necessary for prctr (no pprct).
  ls_goitem-gsber     = is_resheader-pargb.
  ls_goitem-bukrs     = is_resheader-parbu.
*  ls_goitem-resuser   = is_resheader-usnam.
*  call method reservation_user_get
*                exporting is_resheader-usname.
  CALL METHOD lcl_migo_buffer=>name_and_phone_get
    EXPORTING
      i_usnam = is_resheader-usnam
    IMPORTING
      e_exnam = ls_goitem-res_adrname
      e_telnr = ls_goitem-res_telusername.
* GOITEM-MEINS is the unit from material master. The unit from the
* reservation is on another screeen and therefore should have a
* separate name.
  ls_goitem-meins_res = is_resitem-meins.
* no automatic account assignment during goods movement if the account
* was manually entered in the reservation (resb-ktoma = 'X')
  IF is_resitem-ktoma <> space.
    ls_goitem-konto   = is_resitem-saknr.
  ENDIF.
  ls_goitem-batch_from_refdoc = is_resitem-charg.
* Begin of note 532005
* Read material master in order to get valuation cat. This is necessary
* as batch in reservation could be a valuation type rather than a real
* batch.
  IF NOT ls_goitem-matnr IS INITIAL.
    CALL METHOD material_read
      CHANGING
        cs_goitem = ls_goitem.
  ENDIF.
  IF NOT ls_goitem-bwtty IS INITIAL AND ls_goitem-xchpf IS INITIAL.
    ls_goitem-bwtar = ls_goitem-bwtor = is_resitem-charg.
  ENDIF.
* End of note 532005
* quantity proposal
  l_open_quantity = is_resitem-bdmng - is_resitem-enmng.
  IF l_open_quantity < 0 OR is_resitem-kzear = x.
    l_open_quantity = 0.
  ENDIF.
  ls_goitem-menge = l_open_quantity.
ENHANCEMENT-SECTION     LMIGOKR2_02 SPOTS ES_SAPLMIGO.
* clear quantity for unit conversion (not in line_check)
  CLEAR ls_goitem-erfmg.
  IF is_resitem-erfme = is_resitem-meins.
    ls_goitem-erfmg = l_open_quantity.
  ELSE.
    CALL METHOD unit_conversion
      EXPORTING
        i_called_by_reservation = abap_true
      CHANGING
        cs_goitem               = ls_goitem.
  ENDIF.
END-ENHANCEMENT-SECTION.
ENHANCEMENT-POINT LMIGOKR2_03 SPOTS ES_SAPLMIGO.
  CALL METHOD defaults_merge
    CHANGING
      cs_goitem = ls_goitem.

* "I belong to a reservation"-flag
  ls_goitem-xresitem = abap_true.

  CALL METHOD reservation_transfer
    EXPORTING
      is_resitem = is_resitem
    IMPORTING
      e_rc       = l_rc
    CHANGING
      cs_goitem  = ls_goitem.

* Derive profitability segment (PAOBJNR) for goods movement with"1651459
* reference to reservation                                      "1651459
* MB* : PAOBJNR is derived in subroutine RES_POSITIONEN_UEBERNEHMEN_01
*       (Include MM07MFR0_RES_POSITIONEN_UEBE02)
* MIGO: PAOBJNR is derived in method RESERVATION_GOITEM_FILL
*       (Include LMIGOKR2)
* BAPI: The correct PAOBJNR has to be filled in the import table
*       GOODSMVT_ITEM field PROFIT_SEGM_NO. NO new derivation.
  IF NOT ls_goitem-paobjnr IS INITIAL.            "1651459
    SELECT COUNT(*) FROM resb WHERE rsnum = is_resheader-rsnum. "1651459
*   The profitability segment number (PAOBJNR) is stored in the
*   reservation header table (RBKPF). The PAOBJNR can contain attributes
*   of items (e.g. material number) hence it should be derived on item
*   level to avoid inconsistent PAOBJNR in case the reservation contains
*   more than one item.
    IF sy-dbcnt > 1.                                            "1651459
      CALL METHOD lcl_migo_globals=>kernel->header_get          "1651459
        IMPORTING e_gohead = ls_gohead.                         "1651459

      MOVE-CORRESPONDING ls_gohead TO ls_cobl_old.              "1651459
      MOVE-CORRESPONDING ls_goitem TO ls_cobl_old.              "1651459

      CALL METHOD lcl_migo_globals=>kernel->mode_get            "1651459
        RECEIVING rs_control = ls_control.                      "1651459

      ls_cobl_old-vorgn = ls_control-rw_vorgn.                  "1651459
      ls_cobl_old-awtyp = 'MKPF'.                               "1651459

*     GJAHR is necessary in order to determine whether the profitability
*     analysis (TKA00-ERGBR) is active in fm K_KOKRS_READ
      CALL FUNCTION 'FI_PERIOD_DETERMINE'                       "1651459
        EXPORTING                                               "1651459
          i_budat              = ls_gohead-budat                "1651459
          i_bukrs              = ls_goitem-bukrs                "1651459
        IMPORTING                                               "1651459
          e_gjahr              = ls_cobl_old-gjahr              "1651459
        EXCEPTIONS                                              "1651459
          OTHERS               = 1.                             "1651459
      IF sy-subrc = 0.                                          "1651459
*       Clear PAOBJNR in order to ensure that none of the old PAOBJNR
*       attributes are reused for the new PAOBJNR
        CLEAR: ls_cobl_old-paobjnr.                             "1651459
        CALL FUNCTION 'COPA_PROFITABILITY_SEGMENT'              "1651459
          EXPORTING                                             "1651459
            dialog                   = ' '                      "1651459
            i_cobl                   = ls_cobl_old              "1651459
          IMPORTING                                             "1651459
            e_cobl                   = ls_cobl_new              "1651459
          EXCEPTIONS                                            "1651459
            ERROR_MESSAGE            = 1                        "1651459
            OTHERS                   = 2.                       "1651459
        IF sy-subrc = 0.                                        "1651459
          ls_goitem-paobjnr = ls_cobl_new-paobjnr.              "1651459
        ENDIF.                                                  "1651459
      ENDIF.                                                    "1651459
    ENDIF.                                                      "1651459
  ENDIF.                                                        "1651459

  CHECK l_rc IS INITIAL.
  CALL METHOD line_modify
    EXPORTING
      i_line            = 0
      i_authority_check = abap_true
      i_status_delayed  = abap_true
    CHANGING
      cs_goitem         = ls_goitem.

ENDMETHOD.                    "reservation_goitem_fill

************************************************************************
* Read reservation data for a single MSEG line and merge them
* into GOITEM. This is only to be done for fields which are not
* already in MSEG.
* New with note 355296.
************************************************************************
METHOD reservation_fill_matdoc.
  DATA:
    ls_header TYPE rkpf,
    ls_item   TYPE resb,
    ls_goitem TYPE goitem.
  CLEAR: pt_reservation_header,
         pt_reservation_item.
  CALL METHOD reservation_data_get
    EXPORTING
      i_res_number = is_mseg-rsnum
      i_res_item   = is_mseg-rspos
      i_res_type   = is_mseg-rsart
      i_all        = abap_true.
* The result can only be a single header and a single item.
* If the read fails, the structures are initial and so the displayed
* data.
  READ TABLE pt_reservation_header INTO ls_header INDEX 1.
  READ TABLE pt_reservation_item   INTO ls_item   INDEX 1.
  ls_goitem = is_goitem.
* Fill data
  CALL METHOD lcl_migo_buffer=>name_and_phone_get
    EXPORTING
      i_usnam = ls_header-usnam
    IMPORTING
      e_exnam = ls_goitem-res_adrname
      e_telnr = ls_goitem-res_telusername.
  ls_goitem-meins_res = ls_item-meins.
  ls_goitem-bdter     = ls_item-bdter.
  ls_goitem-bdmng     = ls_item-bdmng.
  ls_goitem-enmng     = ls_item-enmng.
  ls_goitem-vmeng     = ls_item-vmeng.
  IF s_control-action = 'A02' AND s_control-refdoc = 'R02'  "939014
     AND NOT ls_item-werks = is_mseg-werks                  "939014
     AND NOT ls_item-werks IS INITIAL.                      "939014
    ls_goitem-werks    = ls_item-werks.                     "939014
    ls_goitem-lgort    = ls_item-lgort.                     "933014
  ENDIF.                                                    "939014
  es_goitem = ls_goitem.
ENDMETHOD.                    "reservation_fill_matdoc
************************************************************************
* METHOD reservation_transfer does some extra work for transfer
* reservations:
*  - check if combination of migo_mode and reservation is allowd (e.g.
*    transfer res. in GI mode) and switch to migo_mode GT if necessary
*    and allowed.
*  - goitem-matnr is filled from matnr because it is not possible to
*    do transfers from one material to another when posting to a
*    reservation (no ummat in rkpf or resb)
*  - umwrk might not be filled in some reservations (only 541 is known
*    yet) --> umwrk is filled from werks
*  - field umsok is not contained in rkpf or resb, therefore we have to
*    set it here according to table t156b
*  - ummat_* fields are filled from the corresponding accounting fields
*    by METHOD special_stock_identifier_set. reason:
*    if there is a reservation for a mvt with an umsok mb1* will use the
*    kdauf/ps_psp_pnr of the reservation as the mat_kdauf/mat_pspnr of
*    the receiving side and MIGO should behave the same.
************************************************************************
METHOD reservation_transfer.
  DATA:
  ls_migo_t156 TYPE migo_t156,
  l_t160m_check TYPE sy-subrc.

  CALL METHOD lcl_migo_buffer=>move_type_get
    EXPORTING
      i_move       = is_resitem-bwart
    IMPORTING
      es_migo_t156 = ls_migo_t156
    EXCEPTIONS
      OTHERS       = 1.

* fill the transfer fields
  IF NOT ls_migo_t156-xtransfer_mvt IS INITIAL.
    cs_goitem-ummat = is_resitem-matnr.
    IF cs_goitem-umwrk IS INITIAL.
      cs_goitem-umwrk = is_resitem-werks.
    ENDIF.
    SELECT SINGLE umsok FROM t156b
                        INTO  cs_goitem-umsok
                        WHERE bwart = cs_goitem-bwart AND
                              sobkz = cs_goitem-sobkz.
    CALL METHOD special_stock_identifier_set
      CHANGING
        cs_goitem = cs_goitem.
  ENDIF.

  IF s_action-migo_mode = 'GT' AND
     ls_migo_t156-xtransfer_mvt IS INITIAL.
*   This coding is used when a non transfer reservation is entered
*   during transfer for reservation. according to the customizing
*   of message migo 059 we reject the reservation or we accept the
*   reservation. migo_mode to stays 'GT'. -> see longtext of
*   message 059.
    CALL FUNCTION 'MB_CHECK_T160M'
      EXPORTING
        i_arbgb = 'MIGO'
        i_msgnr = '059'
        i_nolog = x
      IMPORTING
        rc      = l_t160m_check.
    IF l_t160m_check = 1.
      CALL METHOD oref_doc_log->message_add
        EXPORTING
          i_msgty = w
          i_msgid = 'MIGO'
          i_msgno = '059'
          i_msgv1 = is_resitem-rsnum
          i_msgv2 = is_resitem-rspos.
      e_rc = abap_true.
      EXIT.
    ENDIF.
  ELSEIF s_action-migo_mode <> 'GT' AND
         NOT ls_migo_t156-xtransfer_mvt IS INITIAL.
*   This coding is used when a transfer reservation is entered
*   during gi or gr for reservation. according to the customizing
*   of message migo 059 we reject the reservation or we accept the
*   reservation and switch migo_mode to 'GT'. -> see longtext of
*   message 059.
    CALL FUNCTION 'MB_CHECK_T160M'
      EXPORTING
        i_arbgb = 'MIGO'
        i_msgnr = '059'
        i_nolog = x
      IMPORTING
        rc      = l_t160m_check.
    IF l_t160m_check = 1.
      CALL METHOD oref_doc_log->message_add
        EXPORTING
          i_msgty = w
          i_msgid = 'MIGO'
          i_msgno = '059'
          i_msgv1 = is_resitem-rsnum
          i_msgv2 = is_resitem-rspos.
      e_rc = abap_true.
      EXIT.
    ENDIF.
*   The transfer reservation has been accepted:
*   set MIGO_MODE to 'GT'
    CALL METHOD mode_set
      EXPORTING
        is_control      = s_control
        i_unconditional = abap_true
        i_transfer      = abap_true.
  ENDIF.

ENDMETHOD.                    "reservation_transfer