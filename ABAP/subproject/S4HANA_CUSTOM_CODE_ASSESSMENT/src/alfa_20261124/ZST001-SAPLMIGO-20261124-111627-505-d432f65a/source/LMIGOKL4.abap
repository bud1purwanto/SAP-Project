*&---------------------------------------------------------------------*
*&  Include           LMIGOKL4                                         *
*&---------------------------------------------------------------------*

************************************************************************
* Check a requested line.
* The method does not really "check" anything (historical name).
* To be more precise, the data are "enriched", e.g. dependent data
* are read and derived.
* LS_GOITEM is necessary. Please do not delete (otherwise the
* data in CS_GOITEM will be destroyed).
************************************************************************
METHOD line_check.
  DATA: ls_mbefu      TYPE mbefu,
        ls_goitem     TYPE goitem,
        ls_displ_mseg TYPE mseg,                "for saving display data
        ls_goplant    TYPE goplant,
        ls_got001l    TYPE got001l,
        ls_got156     TYPE got156,
        ls_migo_t156  TYPE migo_t156,
        ls_govendor   TYPE govendor,
        ls_vendordata TYPE lfa1,
        ls_batch_dark TYPE ty_s_batch_dark,
        lt_fields     TYPE ty_t_fieldname,
        l_fieldname   TYPE migo_fieldname,
        l_fs_name     TYPE migo_fieldname,
        l_status      TYPE migo_fs_status,
        l_mfrnr       TYPE mfrnr,                           "535279
        l_wempf       TYPE wempf,
        l_afnam       TYPE afnam,
        ls_gocobl     TYPE gocobl,
        lt_poitem     TYPE ty_t_poitem,
        ls_poitem     TYPE ty_s_poitem,
        lt_pofreight  TYPE ty_t_pofreight,
        l_res_custname       TYPE migo_custname,
        l_res_vendorname     TYPE migo_vendorname,
        ls_unit_conversion   TYPE ty_s_unit_conversion,
        ls_change_po_elikz   TYPE ty_s_change_po_elikz,
        ls_change_ord_elikz  TYPE ty_s_change_ord_elikz,
        ls_change_res_kzear  TYPE ty_s_change_res_kzear,
        ls_change_batch      TYPE ty_s_change_batch.

  FIELD-SYMBOLS: <f> TYPE any.
  ls_goitem = cs_goitem.
* initialize material master fields
  MOVE-CORRESPONDING ls_mbefu TO cs_goitem.
* read material master
  IF NOT ls_goitem-matnr IS INITIAL.
    MOVE-CORRESPONDING ls_goitem TO ls_displ_mseg.          "670155
    CALL METHOD material_read
      CHANGING
        cs_goitem = ls_goitem.
ENHANCEMENT-POINT lmigokl4_01 SPOTS es_saplmigo.
    IF s_action-display = abap_true.
      MOVE-CORRESPONDING ls_displ_mseg TO ls_goitem.
    ENDIF.
  ENDIF.

* disable automatic fill logic for UM-fields (+ BWTAR) by setting
* indicator that field has been changed manually.
  DEFINE def_set_xfield_manual.
    if is_old_goitem-&1 <> ls_goitem-&1 and
       not is_old_goitem-&1 is initial.
      ls_goitem-x&1_manual = x.
    endif.
  END-OF-DEFINITION.
  def_set_xfield_manual ummaktx.
  def_set_xfield_manual umname1.
  def_set_xfield_manual umlgobe.
  def_set_xfield_manual umcha.
  def_set_xfield_manual umbar.
  def_set_xfield_manual bwtar.

* in case of individual batch valuation we should propose the valuation
* type as batch. This will e.g. be necessary to have no different
* batch number whether pressing classification (new batch) or post.
* see as well if-statement to fill bwtar in fusszeile_we_pruefen
* MM07MFF0... see note 313811
  IF NOT ls_goitem-xchpf IS INITIAL AND NOT ls_goitem-kzbaa IS INITIAL
       AND ls_goitem-charg IS INITIAL.
*  copy val.type to batch only once as proposal                "782011
*  -> allow user to clear for internal numbering               "782011
    IF is_old_goitem IS INITIAL                             "782011
*    don't copy for movement type 121 (subsequent adjustment)  "968166
     AND NOT ls_goitem-kzbew = o.                           "968166
      ls_goitem-charg = ls_goitem-bwtar.
    ENDIF.                                                  "782011
  ENDIF.
* Set valuation type (e.g. with existing one, from batch, ...)
  IF ls_goitem-bwtar IS INITIAL
     AND NOT ls_goitem-bwtty IS INITIAL
     AND ls_goitem-xbwtar_manual IS INITIAL.
    CALL METHOD valuation_type_set
      EXPORTING
        i_matnr     = ls_goitem-matnr
        i_werks     = ls_goitem-werks
        i_lgort     = ls_goitem-lgort
        i_charg     = ls_goitem-charg
        i_sobkz     = ls_goitem-sobkz
        i_mat_kdauf = ls_goitem-mat_kdauf
        i_mat_kdpos = ls_goitem-mat_kdpos
        i_mat_pspnr = ls_goitem-mat_pspnr
        i_kzbaa     = ls_goitem-kzbaa
      IMPORTING
        e_bwtar     = ls_goitem-bwtar.
  ENDIF.

* quantity unit proposals
  IF is_old_goitem-matnr <> ls_goitem-matnr AND
                            NOT is_old_goitem-matnr IS INITIAL.
* User has entered a new material. New material has other stock
* keeping unit (MEINS) or other GI unit (AUSME) than old material.
* . if user enters material quantity (ERFMG) and unit (ERFME) manually
*   we keep it
* . if user enters only material but has forgotten to change ERFME,
*   we clear the quantities
* . the only case where we cannot help the user is the new material has
*   other MEINS/AUSME than old material but user wants the same ERFME.
*   We still clear ERFMG, so he has to enter it a second time
    IF ( is_old_goitem-ausme <> ls_goitem-ausme OR
                   is_old_goitem-meins <> ls_goitem-meins )
                 AND is_old_goitem-erfme = ls_goitem-erfme.
      CLEAR: ls_goitem-erfme, ls_goitem-erfmg, ls_goitem-menge.
    ENDIF.
ENHANCEMENT-POINT lmigokl4_02 SPOTS es_saplmigo.

  ENDIF.
* new quantity unit proposal from material master.
* if a refdoc is there (PO, reservation) erfme already set
ENHANCEMENT-SECTION     LMIGOKL4_05 SPOTS ES_SAPLMIGO.
  IF ls_goitem-erfme IS INITIAL.
    ls_goitem-erfme = ls_goitem-ausme.
  ENDIF.
END-ENHANCEMENT-SECTION.
  IF ls_goitem-erfme IS INITIAL.
    ls_goitem-erfme = ls_goitem-meins.
  ENDIF.

* ------------ storage location handling - note 329605 ---------------
*              adapted again by note 493316
* Logic: set always storage location as wanted except for the
*        special cases we know that we never want a storage location
*---------------------------------------------------------------------
* This coding replaces field T156SY-XLORT as unknown in MIGO.
* storage location necessary per default
  ls_goitem-xlort = x.
* No storage location if account assignment and normal valuated material
* (non valuated materials with account assignment: GR to storage loc.).
* By the way account assignment with special stock E or Q always needs
* storage location
* Without kzvbr for the account assignment category: GR to    "1286337
* storage loc. so LGORT should be displayed                   "1286337
  IF NOT ls_goitem-knttp IS INITIAL
     AND ( ls_goitem-wertu = x OR ls_goitem-mengu IS INITIAL )
     AND NOT ( ls_goitem-sobkz CA 'EQ' )
     AND NOT ( ls_goitem-kzvbr IS INITIAL ).                "1286337
    ls_goitem-xlort = space.
  ENDIF.
* No storage location if transfer po with account assignment except for
* special stock E, Q
  IF NOT ls_goitem-knttp IS INITIAL AND ( ls_goitem-bsakz = t ) AND
     NOT ( ls_goitem-sobkz CA 'EQ' )
     AND NOT ( ls_goitem-kzvbr IS INITIAL ).                "1286337
    ls_goitem-xlort = space.
  ENDIF.
* Special stock OPTVW: no storage location
* Sobkz = T: new with EHP5
  IF ls_goitem-sobkz CA 'OPTVW'.
    ls_goitem-xlort = space.
  ENDIF.

ENHANCEMENT-POINT EHP604_LINE_CHECK_02 SPOTS ES_SAPLMIGO .

* Mvt 103: never storage location, no exception
  IF ls_goitem-kzwes = s.
    ls_goitem-xlort = space.
  ENDIF.
* No storage location for movement type 121 (subsequent adjustment)
  IF ls_goitem-kzbew = o.
    ls_goitem-xlort = space.
  ENDIF.

* Now clear storage location data based on xlort
  IF ls_goitem-xlort IS INITIAL.
    CLEAR: ls_goitem-lgort,
           ls_goitem-lgobe,
           ls_goitem-lgpbe.
  ENDIF.
* ----------- end of storage location handling - note 329605 ----------

* read plant
  CLEAR ls_goplant.
  CALL METHOD lcl_migo_buffer=>plant_get
    EXPORTING
      i_plant   = ls_goitem-werks
    RECEIVING
      e_goplant = ls_goplant
    EXCEPTIONS
      OTHERS    = 1.
* Check Currency:                                                "538644
* Changes in decimal places are not allowed.
  DATA: l_currdec_old TYPE currdec,
        l_currdec_new TYPE currdec.
  IF is_old_goitem-waers <> ls_goplant-waers AND
     ( NOT ls_goitem-exbwr IS INITIAL OR
       NOT ls_goitem-exvkw IS INITIAL ) AND
     NOT is_old_goitem IS INITIAL.
*     Only if material document will be changed,                 "577841
*     not displayed or cancelled
*  Check if this is the first change of the plant                "913523
*  If yes, then take standard currdec which is '2'               "913523
    IF is_old_goitem-waers IS NOT INITIAL.                  "913523
      CALL FUNCTION 'TCURX_READ'
        EXPORTING
          i_curr    = is_old_goitem-waers
        IMPORTING
          e_currdec = l_currdec_old.
    ELSE.                                                   "913523
      l_currdec_old = '2'.                                  "913523
    ENDIF.                                                  "913523

    CALL FUNCTION 'TCURX_READ'
      EXPORTING
        i_curr    = ls_goplant-waers
      IMPORTING
        e_currdec = l_currdec_new.
    IF l_currdec_new <> l_currdec_old.
*     Change of plant not allowed, because different decimals    "538644
      MESSAGE w064 WITH is_old_goitem-werks l_currdec_old
                        ls_goitem-werks     l_currdec_new.
      ls_goitem-werks = is_old_goitem-werks.
      ls_goitem-name1 = is_old_goitem-name1.
      CLEAR ls_goplant.
    ELSE.
      MOVE-CORRESPONDING ls_goplant TO ls_goitem.
    ENDIF.
  ELSE.
    MOVE-CORRESPONDING ls_goplant TO ls_goitem.
  ENDIF.
* fill country in header (needed for foreign trade)
  IF ps_gohead-land1 IS INITIAL.
    ps_gohead-land1 = ls_goplant-land1.
  ENDIF.
* read storage location
  CLEAR ls_got001l.
  CALL METHOD lcl_migo_buffer=>storage_loc_get
    EXPORTING
      i_plant       = ls_goitem-werks
      i_storage_loc = ls_goitem-lgort
    RECEIVING
      e_storage_loc = ls_got001l
    EXCEPTIONS
      OTHERS        = 1.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING ls_got001l TO ls_goitem.
  ENDIF.

* read transfer
  CALL METHOD transfer_read
    CHANGING
      cs_goitem = ls_goitem.

* change movement type according to SC_ADJUST if SC_ADJUST has been
* changed in the meanwhile.
  IF is_old_goitem-sc_adjust <> ls_goitem-sc_adjust
      AND s_action-cancel  = abap_false
      AND s_action-display = abap_false.
    CALL METHOD mvt_move_component_get
      EXPORTING
        i_sc_adjust = ls_goitem-sc_adjust
        i_shkzg     = ls_goitem-shkzg
      CHANGING
        c_move      = ls_goitem-bwart.
  ENDIF.
* read movement type
  CLEAR: ls_got156,
         ls_migo_t156.
* save all fields which of MSEG which are as well in T156 (so save all
* fields to make an extention more convenient), because during display
* mode we should better show the data of the document
* than displaying the data from T156. For example during
* stock transfers e.g. the debit/credit indicator for the automatic item
* might be different to the debit/credit indicator from the movement
* type.
  MOVE-CORRESPONDING ls_goitem TO ls_displ_mseg.
  CALL METHOD lcl_migo_buffer=>move_type_get
    EXPORTING
      i_move       = ls_goitem-bwart
    IMPORTING
      e_got156     = ls_got156
      es_migo_t156 = ls_migo_t156
    EXCEPTIONS
      not_found    = 1
      OTHERS       = 3.
  MOVE-CORRESPONDING ls_migo_t156 TO ls_goitem.
  MOVE-CORRESPONDING ls_got156    TO ls_goitem.
* write back the MSEG data to ls_goitem which are saved above.
  IF s_action-display = abap_true OR ls_goitem-xsttype = c.
    MOVE-CORRESPONDING ls_displ_mseg TO ls_goitem.
  ENDIF.
* change of movementtype is not allowed when 'block stock indicator'
* will also be changed. Reason: we do not clear fields like MSEG-HSDAT
  IF s_action-display = abap_false AND                      "317823
     is_old_goitem-kzwes <> ls_goitem-kzwes AND
     NOT is_old_goitem-bwart IS INITIAL.
    MESSAGE s044(migo) WITH is_old_goitem-bwart ls_goitem-bwart
       'Blocked stock indicator'(020).
    ls_goitem-bwart = is_old_goitem-bwart.
    CALL METHOD lcl_migo_buffer=>move_type_get
      EXPORTING
        i_move       = ls_goitem-bwart
      IMPORTING
        e_got156     = ls_got156
        es_migo_t156 = ls_migo_t156
      EXCEPTIONS
        not_found    = 1
        OTHERS       = 3.
    MOVE-CORRESPONDING ls_migo_t156 TO ls_goitem.
    MOVE-CORRESPONDING ls_got156    TO ls_goitem.
    IF ls_got156-bustr = '107' OR ls_got156-bustr = '559'.       "SIT
      CLEAR ls_goitem-xlort.
    ENDIF.
  ENDIF.

* Get information if automatic creation of a purchase order      "556499
* or return order is possible (T158B-XKZBEW)
  CALL METHOD lcl_migo_buffer=>auto_po_get
    EXPORTING
      i_tcode   = 'MIGO'
      i_bwart   = ls_goitem-bwart
    IMPORTING
      e_xautopo = ls_goitem-xautopo
    EXCEPTIONS
      not_found = 1.

* INSMK
* check if actual movement type already contains stock type
* information. In that case clear the INSMK field if in creation mode
* except for cancellation.
  IF s_action-create = abap_true AND s_action-cancel = abap_false.
    IF ls_goitem-xstock_type_mvt = x.
      CLEAR: ls_goitem-migo_insmk, ls_goitem-insmk.      "379521, 650835
    ENDIF.
  ENDIF.
* BEGIN OF ACCOUNTING INFORMATION HANDLING

* List of accounting fields for the movement types
  CALL METHOD cl_mmim_migo_move_fields=>get_cobl_fields
    EXPORTING
      i_bwart      = ls_goitem-bwart
      i_with_konto = abap_true
    IMPORTING
      et_fields    = lt_fields.

* The accounting block is in display mode, if
* - MIGO is in display or cancel
* - The item has reference to a document
  ls_goitem-xaccount_disp = abap_false.
  IF s_action-display     = abap_true OR
     s_action-cancel      = abap_true OR
     ls_goitem-xpoitem    = abap_true OR
     ls_goitem-xresitem   = abap_true OR
     ls_goitem-xorditem   = abap_true OR
     ls_goitem-xdelivitem = abap_true OR
     ls_goitem-xco_order  = abap_true OR
     ls_goitem-kzzug      = abap_true.
    ls_goitem-xaccount_disp = abap_true.
  ENDIF.
* The accounting block for this line is shown, if
* - In display mode, any of the accounting fields are filled
* - In input mode, any of the BWART-dependent fields is ready for inp.
  ls_goitem-xaccount = abap_false.
  IF ls_goitem-xaccount_disp = abap_true.
    CLEAR ls_gocobl.
    MOVE-CORRESPONDING ls_goitem TO ls_gocobl.
    IF NOT ls_gocobl       IS INITIAL OR
       NOT ls_goitem-konto IS INITIAL OR
       NOT ls_goitem-mulko IS INITIAL.
      ls_goitem-xaccount = abap_true.
    ENDIF.
  ELSE.
    IF NOT lt_fields IS INITIAL.
      ls_goitem-xaccount = abap_true.
    ENDIF.
  ENDIF.


* Network: Mapping of external/internal representation
* If VORNR is filled, always convert to internal as VORNR is the
* field on screen.
  IF NOT ls_goitem-vornr IS INITIAL.
    IF cl_erp_co_olc_sw_check=>erp_co_olc( ) NE 'X'.
ENHANCEMENT-SECTION     SAPLMIGO_OLC_001 SPOTS ES_SAPLMIGO.
      CALL FUNCTION 'READ_NETWORK_AUFPL_APLZL'
        EXPORTING
          nplnr     = ls_goitem-nplnr
          vornr     = ls_goitem-vornr
        IMPORTING
          aplzl     = ls_goitem-aplzl
          aufpl     = ls_goitem-aufpl
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
END-ENHANCEMENT-SECTION.
    ELSE.
      IF NOT ( ls_goitem-nplnr IS INITIAL ).

        CALL FUNCTION 'READ_NETWORK_AUFPL_APLZL'
          EXPORTING
            nplnr     = ls_goitem-nplnr
            vornr     = ls_goitem-vornr
          IMPORTING
            aplzl     = ls_goitem-aplzl
            aufpl     = ls_goitem-aufpl
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.

        IF sy-subrc <> 0.
          CLEAR: ls_goitem-aplzl, ls_goitem-aufpl.
        ENDIF.

      ELSEIF NOT ( ls_goitem-aufnr IS INITIAL ).

*   Check for operation level costing
        CALL FUNCTION 'CO_SF_NETWORKACTIVITY_CHECK'
          EXPORTING
            aufnr_imp     = ls_goitem-aufnr
            vornr_imp     = ls_goitem-vornr
            iv_order_catg = '30'            " Without this OLC fails for GI
          IMPORTING
            aplzl_exp     = ls_goitem-aplzl
            aufpl_exp     = ls_goitem-aufpl
          EXCEPTIONS
            not_exist     = 1
            vorgang_must  = 2
            vorgang_no    = 3
            error_message = 4
            OTHERS        = 4.

        IF sy-subrc <> 0.
          CLEAR: ls_goitem-aplzl, ls_goitem-aufpl.
        ENDIF.
      ENDIF.
    ENDIF.
    IF sy-subrc <> 0.
      CLEAR: ls_goitem-aplzl, ls_goitem-aufpl.
      IF ls_goitem-nplnr IS INITIAL AND ls_goitem-aufnr IS INITIAL. "n1044037
        CLEAR: ls_goitem-vornr.
      ENDIF.
    ENDIF.
  ENDIF.
* If VORNR is empty, try to derive one from AUFPL/APLZL.
* This will be the case for reading data from material documents,
* maybe also for reservations.
  IF ls_goitem-vornr IS INITIAL AND NOT ls_goitem-aplzl IS INITIAL.
    IF cl_erp_co_olc_sw_check=>erp_co_olc( ) NE 'X'.
ENHANCEMENT-SECTION     SAPLMIGO_OLC_002 SPOTS ES_SAPLMIGO.
      CALL FUNCTION 'READ_NETWORK_NPLNR_VORNR'
        EXPORTING
          aplzl     = ls_goitem-aplzl
          aufpl     = ls_goitem-aufpl
        IMPORTING
          nplnr     = ls_goitem-nplnr
          vornr     = ls_goitem-vornr
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        CLEAR: ls_goitem-nplnr, ls_goitem-vornr.
      ENDIF.
END-ENHANCEMENT-SECTION.
    ELSE.
* First check for network
      CALL FUNCTION 'READ_NETWORK_NPLNR_VORNR'
        EXPORTING
          aplzl     = ls_goitem-aplzl
          aufpl     = ls_goitem-aufpl
        IMPORTING
          nplnr     = ls_goitem-nplnr
          vornr     = ls_goitem-vornr
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
* If not a Network check for OLC order operation
        CALL FUNCTION 'CO_BO_OBJNR_OPR_CONV'
          EXPORTING
            aplzl     = ls_goitem-aplzl
            aufpl     = ls_goitem-aufpl
          IMPORTING
            vornr     = ls_goitem-vornr
            aufnr     = ls_goitem-aufnr
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.
        IF sy-subrc <> 0.
          CLEAR: ls_goitem-aufnr, ls_goitem-vornr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
* END OF ACCOUNTING INFORMATION HANDLING

* read movement type text
  IF ls_goitem-xauto <> x.
    CALL METHOD lcl_migo_buffer=>move_type_text_get
      EXPORTING
        i_move       = ls_goitem-bwart
        i_spec_stock = ls_goitem-sobkz
        i_mov_ind    = ls_goitem-kzbew                      "662816
        i_rec_ind    = ls_goitem-kzzug
        i_consumpt   = ls_goitem-kzvbr
        i_langu      = sy-langu
        i_match      = space
      RECEIVING
        e_move_text  = ls_goitem-btext
      EXCEPTIONS
        OTHERS       = 1.
  ELSE.
    CALL METHOD lcl_migo_buffer=>move_type_text_get
      EXPORTING
        i_move       = ls_goitem-bwart
        i_spec_stock = ls_goitem-umsok
        i_rec_ind    = ls_goitem-kzzug
        i_consumpt   = ls_goitem-kzvbr
        i_langu      = sy-langu
        i_match      = space
      RECEIVING
        e_move_text  = ls_goitem-btext
      EXCEPTIONS
        OTHERS       = 1.
  ENDIF.

* Text for special stock indicators
  CLEAR: ls_goitem-sotxt,
         ls_goitem-umsotxt.
  IF NOT ls_goitem-sobkz IS INITIAL.
    SELECT SINGLE sotxt FROM t148t INTO ls_goitem-sotxt
                          WHERE spras = sy-langu
                            AND sobkz = ls_goitem-sobkz.
  ENDIF.
  IF NOT ls_goitem-umsok IS INITIAL.
    SELECT SINGLE sotxt FROM t148t INTO ls_goitem-umsotxt
                          WHERE spras = sy-langu
                            AND sobkz = ls_goitem-umsok.
  ENDIF.

* reason for movement type TEXT
  IF ls_goitem-grund IS INITIAL.
* remove eventually old texts in case they are no longer needed
    CLEAR ls_goitem-grtxt.
  ELSE.
* reason has been entered. Always read text.
    SELECT SINGLE grtxt INTO ls_goitem-grtxt FROM t157e
                        WHERE spras = sy-langu
                          AND bwart = ls_goitem-bwart
                          AND grund = ls_goitem-grund.
  ENDIF.

* text for vendors and customers --------------------------------
* special handling for vendors as we need the names
*       normal vendor (LIFNR)
  IF ls_goitem-xpoitem = abap_false.
* in case of PO we have to use address and vendordata from PO.
* We always clear lifnr dependent fields and read dependent data
* from buffer
*   CLEAR: ls_goitem-vendorname, ls_goitem-vendorzip,
*          ls_goitem-vendoradd.
* assumes that lifnr is already set
    CALL METHOD lcl_migo_buffer=>vendor_master_get
      EXPORTING
        i_lifnr         = ls_goitem-lifnr
      IMPORTING
        es_vendordata_a = ls_vendordata
      EXCEPTIONS
        not_found       = 1.
    ls_goitem-vendorname = ls_vendordata-name1.
    ls_goitem-vendorzip  = ls_vendordata-pstlz.
    ls_goitem-vendoradd  = ls_vendordata-ort01.
  ENDIF.
* left vendor (MAT_LIFNR)
  CALL METHOD lcl_migo_buffer=>vendor_master_get
    EXPORTING
      i_lifnr         = ls_goitem-mat_lifnr
    IMPORTING
      es_vendordata_a = ls_vendordata
    EXCEPTIONS
      not_found       = 1.
  ls_goitem-mat_vendorname = ls_vendordata-name1.
* right vendor (UMMAT_LIFNR)
  CALL METHOD lcl_migo_buffer=>vendor_master_get
    EXPORTING
      i_lifnr         = ls_goitem-ummat_lifnr
    IMPORTING
      es_vendordata_a = ls_vendordata
    EXCEPTIONS
      not_found       = 1.
  ls_goitem-ummat_vendorname = ls_vendordata-name1.
*       receiving vendor (EMLIF)
  CALL METHOD lcl_migo_buffer=>vendor_master_get
    EXPORTING
      i_lifnr         = ls_goitem-emlif
    IMPORTING
      es_vendordata_a = ls_vendordata
    EXCEPTIONS
      not_found       = 1.
  ls_goitem-recvendname = ls_vendordata-name1.
*       supplying vendor (LLIEF)
  CALL METHOD lcl_migo_buffer=>vendor_master_get
    EXPORTING
      i_lifnr         = ls_goitem-llief
    IMPORTING
      es_vendordata_a = ls_vendordata
    EXCEPTIONS
      not_found       = 1.
  ls_goitem-supvendname = ls_vendordata-name1.
*       manufacturer (MFRNR)
* Get new manaufacturer, if EMATN (HTN-Material) was changed     "535279
  IF is_old_goitem-ematn <> ls_goitem-ematn.
    CALL FUNCTION 'MB_READ_HTN_AND_MATERIAL'
      EXPORTING
        i_ematn     = ls_goitem-ematn
      IMPORTING
        e_mfrnr     = l_mfrnr
      EXCEPTIONS
        no_material = 1
        OTHERS      = 2.
    IF sy-subrc IS INITIAL.
      ls_goitem-mfrnr = l_mfrnr.
    ENDIF.
  ENDIF.
  CALL METHOD lcl_migo_buffer=>vendor_master_get
    EXPORTING
      i_lifnr         = ls_goitem-mfrnr
    IMPORTING
      es_vendordata_a = ls_vendordata
    EXCEPTIONS
      not_found       = 1.
  ls_goitem-mfrname    = ls_vendordata-name1.
* RESWK name for transfer POs
  ls_goitem-reswkname =
     lcl_migo_buffer=>plant_name_get( ls_goitem-reswk ).

* now fill vendor data in header in case of PO. Filter with GOVENDOR
  IF ps_gohead-lifnr IS INITIAL AND ps_gohead-reswk IS INITIAL AND
     ls_goitem-xpoitem = abap_true.
    MOVE-CORRESPONDING ls_goitem TO ls_govendor.
    MOVE-CORRESPONDING ls_govendor TO ps_gohead.
  ENDIF.
* Fill XBLNR and FRBNR in gohead from first item if not manually filled
* Because verur_refdoc and bolnr_refdoc are moved from wueb, they are
* shortened to 16 instead of 35!!
  IF ps_gohead-xblnr_manual = abap_false AND ps_gohead-xblnr IS INITIAL.
    ps_gohead-xblnr = ls_goitem-verur_refdoc.
  ENDIF.
  IF ps_gohead-frbnr_manual = abap_false AND ps_gohead-frbnr IS INITIAL.
    ps_gohead-frbnr = ls_goitem-bolnr_refdoc.
  ENDIF.
* KUNNR name for customer
  CALL METHOD lcl_migo_buffer=>customer_name_get
    EXPORTING
      i_kunnr         = ls_goitem-kunnr
    IMPORTING
      e_customer_name = ls_goitem-custname
    EXCEPTIONS
      not_found       = 1.
* Left customer (MAT_KUNNR)
  CALL METHOD lcl_migo_buffer=>customer_name_get
    EXPORTING
      i_kunnr         = ls_goitem-mat_kunnr
    IMPORTING
      e_customer_name = ls_goitem-mat_custname
    EXCEPTIONS
      not_found       = 1.
* Right customer (UMMAT_KUNNR)
  CALL METHOD lcl_migo_buffer=>customer_name_get
    EXPORTING
      i_kunnr         = ls_goitem-ummat_kunnr
    IMPORTING
      e_customer_name = ls_goitem-ummat_custname
    EXCEPTIONS
      not_found       = 1.
* end of getting names for vendor/customer-----------------------------*
* WEMPF (receiver) -> Fill phone number
* Assume WEMPF is a SAP name. Set upper case to avoid search for
* performance reasons
  l_wempf = ls_goitem-wempf.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE l_wempf TO UPPER CASE.
  CALL METHOD lcl_migo_buffer=>name_and_phone_get
    EXPORTING
      i_usnam = l_wempf
    IMPORTING
      e_telnr = ls_goitem-wempf_tel.
* AFNAM (purchase requisitor) -> Fill phone number
* Assume AFNAM is a sap name. Set upper case to avoid search for
* performance reasons
  l_afnam = ls_goitem-afnam.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE l_afnam TO UPPER CASE.
  CALL METHOD lcl_migo_buffer=>name_and_phone_get
    EXPORTING
      i_usnam = l_afnam
    IMPORTING
      e_telnr = ls_goitem-afnam_tel.
* ---- product quantity unit
  CLEAR ls_goitem-xparallel.
  IF ls_goitem-kzwsm = b.              "temp sw
    CALL METHOD get_xparallel
      EXPORTING
        i_matnr     = ls_goitem-matnr
        i_werks     = ls_goitem-werks
        i_charg     = ls_goitem-charg
        i_kzcla     = ls_goitem-kzcla
      IMPORTING
        e_xparallel = ls_goitem-xparallel.
  ENDIF.
* Unit conversions
* don't call unit conversion in case of product units if the
* entered batch is new and quantity has already been proposed.
* --- this means if xparallel and MENGE are set.
* In addition to that the unit conversion should not be called
* in case of display or cancel.
  IF ( ls_goitem-xparallel = abap_false OR ls_goitem-menge IS INITIAL )
     AND s_action-display = abap_false AND s_action-cancel = abap_false.
    MOVE-CORRESPONDING ls_goitem TO ls_unit_conversion.
    CALL METHOD unit_conversion
      CHANGING
        cs_goitem = ls_goitem.
  ENDIF.
ENHANCEMENT-POINT lmigokl4_03 SPOTS es_saplmigo.
* Debit/credit-indicator.
* in case of cancellation reverse d/c indicator for structured articles
* the d/c indicator for the components has been taken from the document
  IF ls_goitem-xsttype = c AND s_action-cancel = abap_true.
    IF ls_goitem-shkzg = s.
      ls_goitem-shkzg = h.
    ELSE.
      ls_goitem-shkzg = s.
    ENDIF.
  ENDIF.
* BEGIN of note 860850
* Note 978432 not relevant for return delivery
  IF ls_goitem-kzbew = b AND NOT is_old_goitem-shkzg IS INITIAL
    AND is_old_goitem-shkzg <> ls_goitem-shkzg              "1561123
    AND is_old_goitem-bwart <> ls_goitem-bwart
    AND s_action-return NE 'X'                              "978432
    AND s_action-subsequent NE 'X'.                         "1050053
    CLEAR: ls_goitem-lfbnr, ls_goitem-lfpos, ls_goitem-lfbja.
    CALL FUNCTION 'ME_READ_ITEM_GOODS_RECEIPT'
      EXPORTING
        ebeln     = ls_goitem-ebeln
        ebelp     = ls_goitem-ebelp
        i_werks   = ls_goitem-werks
        kzwes     = ls_goitem-kzwes
        lfbnr     = ls_goitem-lfbnr
        lfgja     = ls_goitem-lfbja
        lfpos     = ls_goitem-lfpos
        i_smbln   = ls_goitem-smbln
        i_sjahr   = ls_goitem-sjahr
        i_smblp   = ls_goitem-smblp
        shkzg     = ls_goitem-shkzg
        i_vbeln   = ls_goitem-vbeln
        i_vbelp   = ls_goitem-posnr
        budat     = ps_gohead-budat                      "#EC DOM_EQUAL
*       i_welfbnr = l_welfbnr
*       display   = l_display
        xstor     = s_action-cancel
      TABLES
        xebefu    = lt_poitem
        xekbnk    = lt_pofreight
      EXCEPTIONS
        OTHERS    = 1.
*   begin of 1575619
*    READ TABLE lt_poitem INDEX 1 INTO ls_poitem
*      TRANSPORTING lfbnr lfpos lfbja.
    LOOP AT lt_poitem INTO ls_poitem WHERE retpo IS INITIAL
         AND NOT webre IS INITIAL.
*     Source from LMIGOKP2
      CASE ls_migo_t156-bustr.
       WHEN '101'.
        CHECK NOT ( ls_poitem-wemng IS INITIAL AND ls_got156-shkzg = H ).
       WHEN '103'.
        CHECK NOT ( ls_poitem-wesbs IS INITIAL AND ls_got156-shkzg = H ).
       WHEN '105'.
        CHECK NOT ( ls_poitem-wemng IS INITIAL AND ls_got156-shkzg = H ).
        CHECK NOT ( ls_poitem-wesbs IS INITIAL AND ls_got156-shkzg = S ).
       WHEN '107'.
        CHECK NOT ( ls_poitem-wesbb IS INITIAL AND ls_got156-shkzg = H ).
       WHEN '109'.
        CHECK NOT ( ls_poitem-wemng IS INITIAL AND ls_got156-shkzg = H ).
        CHECK NOT ( ls_poitem-wesbb IS INITIAL AND ls_got156-shkzg = S ).
      ENDCASE.
*     last one wins
    ls_goitem-lfbnr = ls_poitem-lfbnr.
    ls_goitem-lfpos = ls_poitem-lfpos.
    ls_goitem-lfbja = ls_poitem-lfbja.
    ENDLOOP.
*   end of 1575619
  ENDIF.
* END of note 860850

* When reading a material document, this setting seems to be correct.
* If, at a later point in time, MIGO will show structured articles
* some special treatment may be necessary as movement types
* 317-320 post in both directions.
* Remark: RETPO is not considered here. A 101 with RETPO is
* in the first place a goods receipt and will be displayed as +.
* The final material document will have the 161 and show a -.
  CASE ls_goitem-shkzg.
    WHEN 'S'.    ls_goitem-shkzg_migo = '+'.
    WHEN 'H'.    ls_goitem-shkzg_migo = '-'.
    WHEN OTHERS. CLEAR ls_goitem-shkzg_migo.
  ENDCASE.
* Split valuation_______________________________________________________
  IF ls_goitem-bwtty IS INITIAL.
    CLEAR ls_goitem-bwtar.
  ENDIF.
* Batch_________________________________________________________________
  IF ls_goitem-charg <> space AND ls_goitem-bwtty IS INITIAL "600127
    AND s_action-display = abap_true.
* Material was batch managed in the past, material document X
* was posted; archive material and create an new material with
* same material number, batch detail of material document X has
* to be displayed
    ls_goitem-xchpf = x.
  ENDIF.
  IF ls_goitem-xchpf IS INITIAL.
    CLEAR ls_goitem-charg.
  ENDIF.
* Expiration date
* Must be the same logic as in field selection LMIGOKS4 and LMIGOKS6.
  IF ls_goitem-xwmhd IS INITIAL OR ls_goitem-kzmhd IS INITIAL OR
     ls_goitem-kzwes = s.
    CLEAR: ls_goitem-hsdat,
           ls_goitem-vfdat.
  ELSE.
    IF ls_goitem-xchpf = abap_false AND ls_goitem-mhdrz IS INITIAL.
      CLEAR: ls_goitem-hsdat,
             ls_goitem-vfdat.
    ENDIF.
  ENDIF.
  IF ls_goitem-shkzg = 'H' AND s_action-migo_mode = 'GT'.
    CLEAR: ls_goitem-hsdat,
           ls_goitem-vfdat.
  ENDIF.

  IF ls_goitem-umxwmhd IS INITIAL OR ls_goitem-kzmhd IS INITIAL.
    CLEAR: ls_goitem-umhsdat,
           ls_goitem-umvfdat.
  ELSE.
    IF ls_goitem-umxchpf = abap_false AND ls_goitem-ummhdrz IS INITIAL.
      CLEAR: ls_goitem-umhsdat,
             ls_goitem-umvfdat.
    ENDIF.
  ENDIF.
  IF ls_goitem-shkzg = 'S' AND s_action-migo_mode = 'GT'.
    CLEAR: ls_goitem-umhsdat,
           ls_goitem-umvfdat.
  ENDIF.

* Transfer-Reservation:
* If the special stock indicator was not set in the reservation it's
* possible to enter it in MIGO. Then we have to check, if we can use
* the data from the reservation to fill the receiving special stock
* identifier (and vice versa). Example:
* Reservation without special stock indicator but with filled RESB-KDAUF
* We expect that RESB-KDAUF is an accounting field -> GOITEM-KDAUF
* Then the user can enter a special stock (e.g. 'E') and then we
* have to move the content from the account field (e.g. GOITEM-KDAUF)
* to the special stock identifier (e.g. GOITEM-UMMAT-KDAUF).
* (and vice versa).
  IF ls_goitem-xresitem = abap_true AND
     ls_goitem-xtransfer_mvt = x    AND
     ls_goitem-res_umsok IS INITIAL.
*   Sales order:
    IF ls_goitem-res_kdauf IS NOT INITIAL.
      IF ls_goitem-umsok = e AND is_old_goitem-umsok <> e.
        ls_goitem-ummat_kdauf = ls_goitem-res_kdauf.
        ls_goitem-ummat_kdpos = ls_goitem-res_kdpos.
        CLEAR: ls_goitem-kdauf, ls_goitem-kdpos.
      ENDIF.
      IF ls_goitem-umsok <> e AND is_old_goitem-umsok = e.
        ls_goitem-kdauf = ls_goitem-res_kdauf.
        ls_goitem-kdpos = ls_goitem-res_kdpos.
        CLEAR: ls_goitem-ummat_kdauf, ls_goitem-ummat_kdpos.
      ENDIF.
    ENDIF.
*   Project:
    IF ls_goitem-res_pspnr IS NOT INITIAL.
      IF ls_goitem-umsok = q AND is_old_goitem-umsok <> q.
        ls_goitem-ummat_pspnr = ls_goitem-res_pspnr.
        CLEAR ls_goitem-ps_psp_pnr.
      ENDIF.
      IF ls_goitem-umsok <> q AND is_old_goitem-umsok = q.
        ls_goitem-ps_psp_pnr = ls_goitem-res_pspnr.
        CLEAR: ls_goitem-ummat_pspnr.
      ENDIF.
    ENDIF.
*   Vendor:
    IF ls_goitem-res_lifnr IS NOT INITIAL.
*     Get vendor name
      CALL METHOD lcl_migo_buffer=>vendor_master_get
        EXPORTING
          i_lifnr         = ls_goitem-res_lifnr
        IMPORTING
          es_vendordata_a = ls_vendordata
        EXCEPTIONS
          not_found       = 1.
      l_res_vendorname = ls_vendordata-name1.
      IF ls_goitem-umsok CA 'PKMO' AND is_old_goitem-umsok NA 'PKMO'.
        ls_goitem-ummat_lifnr      = ls_goitem-res_lifnr.
        ls_goitem-ummat_vendorname = l_res_vendorname.
        CLEAR: ls_goitem-lifnr, ls_goitem-vendorname.
        IF ls_goitem-umsok = ls_goitem-sobkz.
          ls_goitem-mat_lifnr      = ls_goitem-res_lifnr.
          ls_goitem-mat_vendorname = l_res_vendorname.
        ENDIF.
      ENDIF.
      IF ls_goitem-umsok NA 'PKMO' AND is_old_goitem-umsok CA 'PKMO'.
        ls_goitem-lifnr      = ls_goitem-res_lifnr.
        ls_goitem-vendorname = l_res_vendorname.
        CLEAR: ls_goitem-mat_lifnr, ls_goitem-mat_vendorname,
               ls_goitem-ummat_lifnr, ls_goitem-ummat_vendorname.
      ENDIF.
    ENDIF.
*   Customer:
    IF ls_goitem-res_kunnr IS NOT INITIAL.
*     Get customer name
      CALL METHOD lcl_migo_buffer=>customer_name_get
        EXPORTING
          i_kunnr         = ls_goitem-res_kunnr
        IMPORTING
          e_customer_name = l_res_custname
        EXCEPTIONS
          not_found       = 1.
      IF ls_goitem-umsok CA 'VW' AND is_old_goitem-umsok NA 'VW'.
        ls_goitem-ummat_kunnr    = ls_goitem-res_kunnr.
        ls_goitem-ummat_custname = l_res_custname.
        IF ls_goitem-umsok = ls_goitem-sobkz.
          ls_goitem-mat_kunnr    = ls_goitem-res_kunnr.
          ls_goitem-mat_custname = l_res_custname.
        ENDIF.
        CLEAR: ls_goitem-kunnr, ls_goitem-custname.
      ENDIF.
      IF ls_goitem-umsok NA 'VW' AND is_old_goitem-umsok CA 'VW'.
        ls_goitem-kunnr    = ls_goitem-res_kunnr.
        ls_goitem-custname = l_res_custname.
        CLEAR: ls_goitem-mat_kunnr, ls_goitem-mat_custname,
               ls_goitem-ummat_kunnr, ls_goitem-ummat_custname.
      ENDIF.
    ENDIF.
  ENDIF.
* When a new PO is automatically created in case of a GR         "556499
* for PO SOBKZ has to be cleared. Otherwise the material
* document will be created with the wrong SOBKZ
  IF s_control-action = 'A01' AND s_control-refdoc = 'R01'
     AND ls_goitem-xpoitem IS INITIAL
     AND NOT ls_goitem-xautopo IS INITIAL.
    CLEAR ls_goitem-sobkz.
  ENDIF.
* SPECIAL STOCK INDICATOR HANDLING______________________________________
  IF is_old_goitem-sobkz <> ls_goitem-sobkz.
* only to process if sobkz has changed
* special fields for old special stock indicator needs to be
* reset.
* SIT: SOBKZ = T
    CASE is_old_goitem-sobkz.
      WHEN e OR t.
        CLEAR ls_goitem-mat_kdauf.
        CLEAR ls_goitem-mat_kdpos.
      WHEN q.
        CLEAR ls_goitem-mat_pspnr.
      WHEN p OR k OR m OR o.
* lifnr needs only to be cleared when the new special
* stock indicator doesn't expect a supplier. Otherwise
* it will rest the same. In case of special stock P and
* K it will be searched new with resp. to material
* below.
        IF ls_goitem-sobkz NA 'PKMO'.
          CLEAR: ls_goitem-mat_lifnr,
                 ls_goitem-mat_vendorname.
        ENDIF.
      WHEN v OR w.
        IF ls_goitem-sobkz NA 'VW'.
          CLEAR: ls_goitem-mat_kunnr,
                 ls_goitem-mat_custname.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

ENHANCEMENT-POINT EHP604_LINE_CHECK_03 SPOTS ES_SAPLMIGO .

  ENDIF.
* Same procedure for UMSOK:
  IF is_old_goitem-umsok <> ls_goitem-umsok.
    CASE is_old_goitem-umsok.
      WHEN e OR t.
        CLEAR ls_goitem-ummat_kdauf.
        CLEAR ls_goitem-ummat_kdpos.
      WHEN q.
        CLEAR ls_goitem-ummat_pspnr.
      WHEN p OR k OR m OR o.
        IF ls_goitem-sobkz NA 'PKMO'.
          CLEAR: ls_goitem-ummat_lifnr,
                 ls_goitem-ummat_vendorname.
        ENDIF.
      WHEN v OR w.
        IF ls_goitem-sobkz NA 'VW'.
          CLEAR: ls_goitem-ummat_kunnr,
                 ls_goitem-ummat_custname.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

* Always to process because if lifnr, kunnr entered after sobkz
* Fill the special stock identifier in field MAT_...
* Not in case of transfer postings as in that case, the input
* fields are the MAT-fields.
  IF s_action-migo_mode <> 'GT'.
    CASE ls_goitem-sobkz.
      WHEN p OR k OR m OR o.
*       Strecken-LB with mvt type 101 O: use EMLIF
        IF ls_goitem-xpoitem = abap_true AND ls_goitem-sobkz = o.
          ls_goitem-mat_lifnr      = ls_goitem-emlif.
          ls_goitem-mat_vendorname = ls_goitem-recvendname.
*       In all other cases take LIFNR as MAT_LIFNR
        ELSE.
ENHANCEMENT-SECTION EHP604_LINE_CHECK_04 SPOTS ES_SAPLMIGO .
          ls_goitem-mat_lifnr      = ls_goitem-lifnr.
          ls_goitem-mat_vendorname = ls_goitem-vendorname.
END-ENHANCEMENT-SECTION.
        ENDIF.
      WHEN v OR w.
        ls_goitem-mat_kunnr      = ls_goitem-kunnr.
        ls_goitem-mat_custname   = ls_goitem-custname.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

* Copy MAT_LIFNR/MAT_KUNNR to UMMAT-fields, if sending and receiving
* special stock are the same. Not useful for special stock E/Q, because
* it is possible that UMMAT-field <> MAT-field
  IF ls_goitem-sobkz = ls_goitem-umsok AND ls_goitem-umsok CA 'KOMP'.
    ls_goitem-ummat_lifnr      = ls_goitem-mat_lifnr.
    ls_goitem-ummat_vendorname = ls_goitem-mat_vendorname.
  ENDIF.
  IF ls_goitem-sobkz = ls_goitem-umsok AND ls_goitem-umsok CA 'VW'.
    ls_goitem-ummat_kunnr      = ls_goitem-mat_kunnr.
    ls_goitem-ummat_custname   = ls_goitem-mat_custname.
  ENDIF.

* enrich supplier to goitem in case of special stock
* pipeline. Needs to be done each time, because material number
* might have changed in item line.
  IF ls_goitem-sobkz = p AND ls_goitem-mat_lifnr IS INITIAL.
    CALL METHOD pipe_supplier_get
      EXPORTING
        is_gohead = ps_gohead
      CHANGING
        cs_goitem = ls_goitem.
  ENDIF.
* END OF SPECIAL STOCK INDICATOR HANDLING
* If the TAKE_IT indicator changed, we cascade this information down
* to all subitems
  IF is_old_goitem-take_it <> ls_goitem-take_it.
    CALL METHOD change_takeit_later
      EXPORTING
        i_glc    = ls_goitem-global_counter
        i_takeit = ls_goitem-take_it.
  ENDIF.
* Relevance for taxed. Modifies field TAX_RELEVANT
  CALL METHOD oref_nota_fiscal->j_1b_relevance_check
    EXPORTING
      is_got156  = ls_got156
      is_gohead  = ps_gohead                                "785319
      is_goplant = ls_goplant                               "785319
    CHANGING
      cs_goitem  = ls_goitem
      cv_xblnr   = ps_gohead-xblnr.                         "767916
* Checks for automatic lines
  CALL METHOD line_check_automatic_lines
    EXPORTING
      is_old_goitem = is_old_goitem
    CHANGING
      cs_goitem     = ls_goitem.
* Checks which need the GLC. Mainly external applications.
  CALL METHOD line_check_with_global_counter
    EXPORTING
      is_old_goitem = is_old_goitem
    CHANGING
      cs_goitem     = ls_goitem.
* Stock determination allowed?
  ls_goitem-xdetermination = abap_false.
* For batch managed materials, if either LGORT or CHARG not filled yet.
* Exception: Stock types which do not have a storage location.
  IF ls_goitem-xchpf = abap_true AND
     (
       ls_goitem-charg IS INITIAL OR
       (
         ls_goitem-lgort IS INITIAL AND
         ls_goitem-sobkz NA 'OVW'
       )
     ).
    ls_goitem-xdetermination = abap_true.
  ENDIF.
* Note 397435:
* For split valuated materials, if either LGORT or BWTAR not filled yet.
* Exception: Stock types which do not have a storage location.
  IF NOT ls_goitem-bwtty IS INITIAL AND                     "397435
     (
       ls_goitem-bwtar IS INITIAL OR
       (
         ls_goitem-lgort IS INITIAL AND
         ls_goitem-sobkz NA 'OVW'
       )
     ).
    ls_goitem-xdetermination = abap_true.
  ENDIF.
* For other materials, if LGORT not filled
  IF ls_goitem-xchpf = abap_false AND ls_goitem-bwtty IS INITIAL AND
     (
       ls_goitem-lgort IS INITIAL AND
       ls_goitem-sobkz NA 'OVW'
     ).
    ls_goitem-xdetermination = abap_true.
  ENDIF.
* Need plant, not for retail specials, not for headers of BOMs, not for
* material documents with the exceptions of release blocked stock
* and subsequent delivery,                                      "1641588
* not for subsequent adjustment,....
  IF     ls_goitem-werks IS INITIAL   OR
     NOT ls_goitem-xvgtype IS INITIAL OR
     NOT ls_goitem-xgatype IS INITIAL OR
     NOT ls_goitem-xvastype IS INITIAL OR
     NOT ls_goitem-xcdtype IS INITIAL OR
         ls_goitem-xbomtype = p       OR
         ( ( s_control-refdoc = 'R02' OR s_control-refdoc = 'R03' ) AND
            ( s_control-action <> 'A05' AND
              s_control-action <> 'A06' ) ) OR                  "1641588
         ls_goitem-matnr IS INITIAL   OR
         ls_goitem-kzbew = o          OR
         ls_goitem-xsttype IS NOT INITIAL.
    ls_goitem-xdetermination = abap_false.
  ENDIF.
  IF ( NOT ls_goitem-xvgtype IS INITIAL OR
     NOT ls_goitem-xgatype IS INITIAL OR
     NOT ls_goitem-xsttype IS INITIAL )
     AND s_action-migo_mode = 'GT'.
    ls_goitem-ummat   = ls_goitem-matnr.
    ls_goitem-ummaktx = ls_goitem-maktx.
  ENDIF.
* Generic articles
  IF ( s_action-cancel = abap_true OR s_action-display = abap_true )
    AND NOT ls_goitem-xgatype IS INITIAL.
    CLEAR: ls_goitem-parent, ls_goitem-depth, ls_goitem-expand.
    IF ls_goitem-xgatype = p AND ls_goitem-xcancel_done = abap_false.
      ls_goitem-take_it = abap_true.
    ENDIF.
  ENDIF.
* Structured articles
  IF ( s_action-cancel = abap_true OR s_action-display = abap_true )
    AND NOT ls_goitem-xsttype IS INITIAL.
    IF NOT ls_goitem-parent IS INITIAL.
      CLEAR: ls_goitem-expand.
    ENDIF.
  ENDIF.
* Explosion of structured articles only possible for stock type:
* unrestricted use
  IF ls_goitem-xsttype IS NOT INITIAL AND ls_goitem-xsttype <> c.
    IF ls_migo_t156-xstock_type_mvt = abap_true OR
      NOT ls_goitem-kzwes IS INITIAL.
      CLEAR: ls_goitem-expand.
    ENDIF.
  ENDIF.

*___________Clear quantity in order price units__ note 351994_______
* start of change for note 718008
* Dont allow batch determination if the GI is based on order or
* reservation, and the value of Kzech is 1, 2, or 3.
  IF ( NOT ls_goitem-aufnr IS INITIAL OR NOT ls_goitem-rsnum IS INITIAL )
       AND ls_goitem-kzech BETWEEN '1' AND '3'.
    ls_goitem-xdetermination = abap_false.
  ENDIF.
* end of change for note 718008
* Clear the quantity in order price units, if
* a. quantity in order price unit is required this means:
*     order price unit <> order unit
* b. quantity in order price unit is filled
* c. the quantity in order price units has not been changed
*    (this will make as well sure that the clear will not be
*     performed during the first line_check before output)
* d. the quantity in unit of entry has been changed or the unit of
*    entry has been changed
ENHANCEMENT-SECTION     lmigokl4_04 SPOTS es_saplmigo.
  IF ls_goitem-bprme <> ls_goitem-bstme AND          "cond. a     351994
     NOT ls_goitem-bpmng IS INITIAL AND              "cond. b
     is_old_goitem-bpmng = ls_goitem-bpmng AND       "cond. c
     ( is_old_goitem-erfmg <> ls_goitem-erfmg OR     "cond. d
       is_old_goitem-erfme <> ls_goitem-erfme ).     "cond. d
* clear entry in order price units and issue I or S message.
    CLEAR ls_goitem-bpmng.
    CALL FUNCTION 'MB_CHECK_T160M'
      EXPORTING
        i_arbgb  = 'MIGO'
        i_msgnr  = '045'
        i_msgv1  = ls_goitem-zeile
        i_nolog  = x
        i_output = x.
  ENDIF.
END-ENHANCEMENT-SECTION.

ENHANCEMENT-POINT line_check_01 SPOTS es_saplmigo STATIC.

ENHANCEMENT-POINT line_check_02 SPOTS es_saplmigo.

* ___________Change routines______________________________________
* If a line change has consequences for other lines, it is necessary to
* note the key with which the other lines can be found as well as the
* data that has to be changed. The data is kept by a change_later
* routine. After line_check has been done for all lines (end of loop), a
* routine change_all is called which operates on the complete pt_goitem.

*     Final delivery indicator has been changed------------------
*     make sure, that all related items will be changed later
  IF ls_goitem-migo_elikz <> is_old_goitem-migo_elikz.
*       ELIKZ changed in PO
    IF ls_goitem-xpoitem = abap_true.
      ls_change_po_elikz-ebeln = ls_goitem-ebeln.
      ls_change_po_elikz-ebelp = ls_goitem-ebelp.
      ls_change_po_elikz-migo_elikz = ls_goitem-migo_elikz.
      CALL METHOD change_elikz_later
        EXPORTING
          is_change_po_elikz = ls_change_po_elikz.
*       ELIKZ changed in order
    ELSEIF ls_goitem-xorditem = abap_true.
      ls_change_ord_elikz-pps_aufnr  = ls_goitem-pps_aufnr.
      ls_change_ord_elikz-pps_posnr  = ls_goitem-pps_posnr.
      ls_change_ord_elikz-migo_elikz = ls_goitem-migo_elikz.
      CALL METHOD change_elikz_later
        EXPORTING
          is_change_ord_elikz = ls_change_ord_elikz.
    ENDIF.
  ENDIF.
*     KZEAR changed in reservation
  IF ls_goitem-kzear <> is_old_goitem-kzear.
    ls_change_res_kzear-rsnum = ls_goitem-rsnum.
    ls_change_res_kzear-rspos = ls_goitem-rspos.
    ls_change_res_kzear-rsart = ls_goitem-rsart.            "411472
    ls_change_res_kzear-kzear = ls_goitem-kzear.
    CALL METHOD change_elikz_later
      EXPORTING
        is_change_res_kzear = ls_change_res_kzear.
  ENDIF.
*     MENGE changed in case of product units
  IF NOT ls_goitem-xparallel IS INITIAL AND s_action-migo_mode <> 'GT'.
    IF NOT (
       is_old_goitem-charg IS INITIAL         AND
       is_old_goitem-menge EQ ls_goitem-menge AND
       is_old_goitem-erfmg EQ ls_goitem-erfmg AND
       is_old_goitem-erfme EQ ls_goitem-erfme ).
*         During entry of second line item of same batch:
*         do not overwrite conversion factor of material master
*         if the user has not changed any quantity
*         Reason: The batch cannot be entered before first unit
*         conversion w/ factor of material master. Quantity in base UOM
*         could not have been entered before
      CALL METHOD send_quantity_to_class
        EXPORTING
          is_goitem     = ls_goitem
        IMPORTING
          es_batch_dark = ls_batch_dark.
      MOVE-CORRESPONDING ls_batch_dark TO ls_goitem.
      ls_change_batch-charg = ls_goitem-charg.
      ls_change_batch-matnr = ls_goitem-matnr.
      ls_change_batch-werks = ls_goitem-werks.
      CALL METHOD change_quantity_later
        EXPORTING
          is_change_batch = ls_change_batch.
    ENDIF.
  ENDIF.
  IF ls_goitem-xco_order  = abap_true AND
     ls_goitem-parent IS NOT INITIAL AND
     ls_goitem-xlbtype IS INITIAL.
    CLEAR ls_goitem-sernp.
  ENDIF.
*- sets batch master data from DB / buffer                       "624076
*- updates batch buffers with content on screen
  IF NOT ls_goitem-xchpf IS INITIAL.
    MOVE-CORRESPONDING ls_goitem TO ls_displ_mseg.          "702056
    CALL METHOD batch_data_update
      EXPORTING
        is_old_goitem = is_old_goitem
      CHANGING
        cs_goitem     = ls_goitem.
    IF s_action-display = abap_true.                        "702056
      MOVE-CORRESPONDING ls_displ_mseg TO ls_goitem.        "702056
    ENDIF.                                                  "702056
  ENDIF.
  IF NOT ls_goitem-umxchpf IS INITIAL.
    CALL METHOD batch_data_transfer_update
      EXPORTING
        is_old_goitem = is_old_goitem
      CHANGING
        cs_goitem     = ls_goitem.
  ENDIF.
*____________end of change routines ____________________________________

* Field selection for this line
  CALL METHOD screen_modify_line( ls_goitem ).
* Delete fields which are not longer needed for this movement type.
* A field is deleted if is it relevant for MvT-dependent field
* selection and in the current state INVISIBLE.
* Fields which are DISPLAY are already checked for being filled
* by the screenmodification. INPUT/REQUIRED are of course
* not to be cleared.
  LOOP AT cl_mmim_migo_move_fields=>t_all_cust_fields INTO l_fieldname.
*   Check if some fields are necessary independant of field selection.
*   This is e.g. the case for LIFNR in case of special stock in case
*   of MIGO_MODE <> 'GT' as in those mode the vendor input field is
*   LIFNR and not MAT_LIFNR. Therefore the content needs to be
*   unchanged even if not visible in movement type dependant field
*   selection. As no fields are relevant at the moment for transfer
*   movements, the check is done outside method
*   screen_modify_field_relevant. Maybe this has to be changed as soon
*   as fields might be relevant as well for transfer process.
    CHECK screen_modify_field_relevant( i_fieldname = l_fieldname
                                        is_goitem   = ls_goitem )
                       = abap_true OR s_action-migo_mode = 'GT'.
*   If the field has not been found, delete the content if the
*   field is INVISIBLE.
    CONCATENATE 'GOITEM-' l_fieldname INTO l_fs_name.
    CALL METHOD lcl_migo_screenmodification=>get
      EXPORTING
        i_field          = l_fs_name
        i_global_counter = ls_goitem-global_counter
      RECEIVING
        r_status         = l_status.

*/Earmarked Funds Document
    IF cl_psm_core_switch_check=>psm_fm_gi_ef_core_not_rev( ) IS NOT INITIAL.
      IF l_fs_name = 'GOITEM-FIPOS'     OR
         l_fs_name = 'GOITEM-FISTL'     OR
         l_fs_name = 'GOITEM-FKBER'     OR
         l_fs_name = 'GOITEM-MEASURE'   OR
         l_fs_name = 'GOITEM-GRANT_NBR' OR
         l_fs_name = 'GOITEM-GEBER'     OR
         l_fs_name = 'GOITEM-BUDGET_PD'.
        l_status = lcl_migo_screenmodification=>c_visible.
      ENDIF.
    ENDIF.
*\

    CHECK l_status = lcl_migo_screenmodification=>c_invisible.
    CONCATENATE 'LS_GOITEM-' l_fieldname INTO l_fieldname.
    ASSIGN (l_fieldname) TO <f>.
    CLEAR <f>.
  ENDLOOP.

* When in copy-mode, ablad will not be taken from the document,   ERP 10
* if the field is on display only.
* Other fields whose field selection does not depend on the movement
* type such as matnr, lgort etc. will be copied even if the fields are
* on display only (for a list of fields see ls_mseg_copy).
* In copy mode, the fields whose field selection does depend on the
* movement type should either be on input or invisible (i.e. be deleted
* above). In case of exceptions, i.e. fields are on display only: have a
* look at screen_modify_line, too.
* Should more extensive checks become necessary, they could be
* implemented in line_modify, calling line_check with all fields
* first to get the fieldselection for the new line, deleting the
* respective fields from ls_old_goitem afterwards, and finally calling
* line_check again with the remaining fields. Effects of the dublicate
* call to WM  would have to be checked then (see wm_data_prepare below).
  IF s_action-copy = abap_true AND NOT ls_goitem-ablad IS INITIAL.

    l_fs_name = 'GOITEM-ABLAD'.

    CALL METHOD lcl_migo_screenmodification=>get
      EXPORTING
        i_field          = l_fs_name
        i_global_counter = ls_goitem-global_counter
      RECEIVING
        r_status         = l_status.

    IF l_status <> lcl_migo_screenmodification=>c_input.
      CLEAR ls_goitem-ablad.
    ENDIF.
  ENDIF.

* Sending/receiving fields (UM-fields):________________________________
* a) Fill fields, if it makes sense.
* b) Field selection for UM-fields.
*    Attention: Fieldselection for UM-fields should never be done in
*               SCREEN_MODIFY_LINE!
  IF s_action-migo_mode = 'GT' AND s_action-display = abap_false AND
     s_action-cancel = abap_false.
*   (For mixed reservations: GR-/GI- and Transfer-Reservation)
    IF ls_goitem-xtransfer_mvt = x.
      CALL METHOD line_check_transfer
        EXPORTING
          is_old_goitem      = is_old_goitem
          is_unit_conversion = ls_unit_conversion
        CHANGING
          cs_goitem          = ls_goitem.
      IF ls_goitem-shkzg = 'H'.
        CALL METHOD wm_data_prepare
          CHANGING
            cs_goitem = ls_goitem.
      ENDIF.
    ENDIF.
  ENDIF.
  CALL METHOD screen_modify_transfer_fields
    EXPORTING
      is_goitem = ls_goitem.
* Display (transfer posting): Show WM-Data if LGNUM or LGNUM is filled
  IF s_action-display = abap_true AND
     ( NOT ls_goitem-lgnum   IS INITIAL OR
       NOT ls_goitem-umlgnum IS INITIAL ).
    ls_goitem-wm_relevant = abap_true.
  ENDIF.

* Determination whether the PARTNERS-tabstrip is visible.
* It is visible if at least one field in it is not invisible.
  CLEAR lt_fields.
  APPEND 'GOITEM-VENDORNAME'  TO lt_fields.
  APPEND 'GOITEM-LIFNR'       TO lt_fields.
  APPEND 'GOITEM-RESWKNAME'   TO lt_fields.
  APPEND 'GOITEM-RESWK'       TO lt_fields.
  APPEND 'GOITEM-CUSTNAME'    TO lt_fields.
  APPEND 'GOITEM-KUNNR'       TO lt_fields.
  APPEND 'GOITEM-RECVENDNAME' TO lt_fields.
  APPEND 'GOITEM-EMLIF'       TO lt_fields.
  APPEND 'GOITEM-SUPVENDNAME' TO lt_fields.
  APPEND 'GOITEM-LLIEF'       TO lt_fields.
  ls_goitem-xpartners = abap_false.
  LOOP AT lt_fields INTO l_fieldname.
    CALL METHOD lcl_migo_screenmodification=>get
      EXPORTING
        i_field          = l_fieldname
        i_global_counter = ls_goitem-global_counter
      RECEIVING
        r_status         = l_status.
    IF l_status <> lcl_migo_screenmodification=>c_invisible.
      ls_goitem-xpartners = abap_true.
      EXIT.
    ENDIF.
  ENDLOOP.
* send new goitem back to caller
  cs_goitem = ls_goitem.
ENDMETHOD.                    "line_check

************************************************************************
* Check a requested line after global counter has been set.
* LS_GOITEM is necessary. Please do not delete (otherwise the
* data in CS_GOITEM will be destroyed).
* Caution!! Only processed in creation mode!!!!! This is important for
* foreign trade and official number
************************************************************************
METHOD line_check_with_global_counter.
  DATA: ls_goitem  TYPE goitem,
        ls_wmdata      TYPE wms_migo,  "WM pallets
        ls_wm_defaults TYPE wms_migo_sugg, "WM pallets
        l_cert_active TYPE qm00-qkz,   "QM certificate
        ls_qcert_migo TYPE qcert_migo, "QM certificate
        l_werks       TYPE goitem-werks, "Check WM active
        l_lgort       TYPE goitem-lgort, "Check WM active
        l_country_active TYPE flag,      "check AR active     "n1342621
        l_xblnr_old   TYPE mkpf-xblnr.   "save old XBLNR      "n1350637

  CHECK s_action-create = abap_true.
  ls_goitem = cs_goitem.


*------------------foreign trade---------------------------------------*
* Check if foreign trade is active for item and copy - if necessary -
* the data from PO in foreign trade memory. Set header data from the
* first item
  IF ( is_old_goitem-matnr    <> ls_goitem-matnr   ) OR
     ( is_old_goitem-werks    <> ls_goitem-werks   ) OR
     ( is_old_goitem-lifnr    <> ls_goitem-lifnr   ) OR
     ( is_old_goitem-llief <> ls_goitem-llief ).
* Refresh old ftrade data if relevant data has changed
    IF is_old_goitem-import = abap_true.
      CALL METHOD ftrade_item_refresh
        EXPORTING
          i_exnum          = ps_gohead-exnum
          i_global_counter = ls_goitem-global_counter
          i_home_country   = ls_goitem-land1.
    ENDIF.
* Now determine if relevant and copy data from PO
    CALL METHOD ftrade_determine_item
      EXPORTING
        is_goitem = ls_goitem
      IMPORTING
        e_process = ls_goitem-import.
  ENDIF.

*-----------official number--------------------------------------------*
* Default the official number in header from the first item data.
* We assume the first item is the right one...
* In case country is Argentinia then the official number needs    "n1342621
* to be determined always                                         "n1342621
* Check wheter Argentinia is active                               "n1342621
  CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'                   "n1342621
    EXPORTING                                               "n1342621
      bukrs                      = ls_goitem-bukrs_for_stock "n1342621
      component                  = 'AR'                     "n1342621
    EXCEPTIONS                                              "n1342621
      component_not_active       = 1                        "n1342621
      OTHERS                     = 2 .                      "n1342621
  IF sy-subrc = 0.                                          "n1342621
    l_country_active = 'X'.                                 "n1342621
  ENDIF.                                                    "n1342621
* IF ls_goitem-global_counter = '000001' AND ps_gohead-xblnr IS INITIAL.
  CLEAR l_xblnr_old.                                        "n1350637
  IF ls_goitem-global_counter = '000001'                    "n1342621
    AND ( ps_gohead-xblnr IS INITIAL OR l_country_active = 'X' ). "n1342621

    l_xblnr_old = ps_gohead-xblnr.                          "n1350637

    CALL METHOD off_number_default
      EXPORTING
        is_goitem = ls_goitem
      RECEIVING
        r_xblnr   = ps_gohead-xblnr.
*     in case xblnr comes back as initial, take old input         "n1350637
    IF ps_gohead-xblnr IS INITIAL AND l_country_active = 'X'. "n1350637
      ps_gohead-xblnr = l_xblnr_old.                        "n1350637
    ENDIF.                                                  "n1350637
  ENDIF.
*----------warehouse management----------------------------------------*
* An item has WM active if LGNUM is set.
* In creation mode, we send the item data to wm if active. Wm has
* an internal table with global_counter and checks whether the changed
* data is important for them. If a previously relevant item is not
* relevant anymore, it has to be deleted in wm memory.
* In display mode, we do not need to check anything here. We only
* transfer the data to WM in PBO of WM detail.
* Ties empties (XVGTYPE=C) are never relevant.
*----------------------------------------------------------------------*
* Even the tab strip WM is visible in all cases when in the RECEIVING
* storage location WM is active (LGNUM exists), the palletization
* data can be entered.
* But the palletization data will ONLY be displayed (and stored), when
* it is customized for WM-movement types (OLML)! If not, the
* palletization will always be displayed as empty!
*----------------------------------------------------------------------*
  IF s_action-display = abap_false AND ls_goitem-xvgtype <> c.
    IF NOT ( s_action-migo_mode = 'GT' AND cs_goitem-shkzg = 'H' ).
ENHANCEMENT-SECTION     LMIGOKL4_MILL_01 SPOTS ES_SAPLMIGO.
      CALL METHOD wm_data_prepare
        CHANGING
          cs_goitem = ls_goitem.
END-ENHANCEMENT-SECTION.
    ENDIF.
  ENDIF.
* QM certificate. Only in creation mode and only if certificate type
* is filled from PO. Creation already checked above
  IF NOT ls_goitem-zgtyp IS INITIAL.
*   Check is relevant for certificate subscreen
    CALL FUNCTION 'QBCK_MIGO_CERT_REL_CHECK'
      EXPORTING
        i_tq05_zgtyp  = ls_goitem-zgtyp
        i_wemng       = ls_goitem-wemng
        i_xblnr       = ps_gohead-xblnr
      IMPORTING
        e_cert_active = l_cert_active
      EXCEPTIONS
        OTHERS        = 1.
    IF sy-subrc <> 0.
      l_cert_active = abap_false.
    ENDIF.
*   Field goitem-xqm_cert indicates that the subscreen will be set to
*   confirm certificate in PO tab strip
    ls_goitem-xqm_cert = l_cert_active.
*   Send data to QMfor certificate subscreen
    IF ls_goitem-xqm_cert = abap_true.
      ls_qcert_migo-global_counter = ls_goitem-global_counter.
      ls_qcert_migo-zgtyp          = ls_goitem-zgtyp.
      CALL FUNCTION 'QBCK_MIGO_LINE_TO_QM'
        EXPORTING
          i_qcert_migo = ls_qcert_migo.
* After line change, QM certificate not relevant anymore => delete
    ELSEIF is_old_goitem-xqm_cert = abap_true.
      CALL FUNCTION 'QBCK_MIGO_LINE_DELETE'
        EXPORTING
          i_global_counter = ls_goitem-global_counter.
    ENDIF.
  ENDIF.
* GR slip quantity WEANZ (only in creation mode)           note 333860
* a manual quantity has priority over default qty from material master
* (MARA-WEANZ). GOITEM-WEANZX means a manual quantity has been entered
  IF is_old_goitem-weanz <> ls_goitem-weanz.
    ls_goitem-weanzx = x.
  ENDIF.
  IF ls_goitem-weanzx IS INITIAL.
    CALL METHOD number_slips_propose
      EXPORTING
        i_erfmg = ls_goitem-erfmg
        i_wesch = ls_goitem-wesch
      IMPORTING
        e_weanz = ls_goitem-weanz.
  ENDIF.

ENHANCEMENT-POINT ES_LMIGOKL1_OIO SPOTS ES_SAPLMIGO.
* Send data back to line_modify
  cs_goitem = ls_goitem.
ENDMETHOD.                    "line_check_with_global_counter