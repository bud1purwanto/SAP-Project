*----------------------------------------------------------------------*
*   INCLUDE LMIGOKB1 Batch maintain                                    *
*----------------------------------------------------------------------*

************************************************************************
* Maintain batch, if MIGO_OK_CLASS is pressed
************************************************************************
METHOD batch_maintain.
  DATA: ls_mcha_buffer     TYPE mcha,
        lv_kzdch           TYPE kzdch,
        lv_klart           TYPE klassenart,
        lv_kzcla           TYPE kzcla,
        lv_xkcfc           TYPE xkcfc,
        ls_rc_mcha_buffer  TYPE sy-subrc,
        ls_rc_mcha_db      TYPE sy-subrc,
        ls_batch_db        TYPE mcha,
        ls_bncom           TYPE bncom,
        ls_goitem          TYPE goitem,
        ls_classification  TYPE ty_s_classification,
        ls_ref_batch       TYPE ty_s_ref_batch,
        ls_change_batch    TYPE ty_s_change_batch,
        lv_subrc_loop      TYPE sysubrc,
        l_kzwsm            TYPE kzwso.

* get the current line
  CALL METHOD line_get
    EXPORTING
      i_line    = i_line
    IMPORTING
      es_goitem = ls_goitem.

* Use data from GOITEM to fill LS_CLASSIFICATION
  CALL METHOD batch_class_structure_fill
    EXPORTING
      is_goitem         = ls_goitem
    IMPORTING
      es_classification = ls_classification
      es_ref_batch      = ls_ref_batch.
*_______________________________________________________________________
* From now on do not use LS_GOITEM-fields to classify a batch! Always
* use LS_CLASSIFICATION. Otherwise a classification for UMCHA would not
* work correct.
*_______________________________________________________________________

* Only if MB_CREATE_GOODS_MOVEMENT / MB_SIMULATE is called, we call
* the real creation modules.
* Otherwise, we call MSC3N and jump directly to the classification
* screen.
  IF s_action-display = abap_true OR s_action-cancel = abap_true.
    CALL METHOD oref_environment->batch_show
      EXPORTING
        i_matnr          = ls_classification-matnr
        i_werks          = ls_classification-werks
        i_lgort          = ls_classification-lgort
        i_charg          = ls_classification-charg
        i_classification = abap_true.
    EXIT.
  ENDIF.


* fill communication area
  MOVE-CORRESPONDING ls_classification TO ls_bncom.
  MOVE-CORRESPONDING ps_gohead         TO ls_bncom.

ENHANCEMENT-POINT batch_maintain_01 SPOTS es_saplmigo.
* when material is prod./prop. UoM change of
*  classification is not allowed in general
  IF s_action-migo_mode = 'GT' AND ls_goitem-shkzg = h.
    l_kzwsm               = ls_goitem-umkzwsm.
  ELSE.
    l_kzwsm               = ls_goitem-kzwsm.
  ENDIF.
ENHANCEMENT-POINT BATCH_MAINTAIN_04 SPOTS ES_SAPLMIGO.

  IF NOT l_kzwsm IS INITIAL.
* send message in case of same batch is entered in
* same document before
    CALL FUNCTION 'VB_BATCH_DEFINITION'
      IMPORTING
        kzdch = lv_kzdch.
    IF lv_kzdch = 0.
      lv_klart = '022'.
      LOOP AT pt_goitem TRANSPORTING NO FIELDS
        WHERE
          matnr          = ls_classification-matnr AND
          werks          = ls_classification-werks AND
          charg          = ls_classification-charg AND
          zeile         <> ls_goitem-zeile AND
          erfmg          > 0.
        EXIT.
      ENDLOOP. "at pt_goitem transporting into ls_ptgoitem
      lv_subrc_loop = sy-subrc.
    ELSE.
      lv_klart = '023'.
      LOOP AT pt_goitem TRANSPORTING NO FIELDS
        WHERE
          matnr          = ls_classification-matnr AND
          charg          = ls_classification-charg AND
          zeile         <> ls_goitem-zeile AND
          erfmg          > 0.
        EXIT.
      ENDLOOP. "at pt_goitem transporting into ls_ptgoitem
      lv_subrc_loop = sy-subrc.
    ENDIF.

    IF     lv_subrc_loop           IS INITIAL AND
       NOT ls_classification-charg IS INITIAL.
      MESSAGE i004(xu) WITH ls_goitem-charg ls_goitem-matnr.
      EXIT.
    ENDIF. "sy-subrc loop pt_goitem

* show classification in display mode when
*  batch is not new and lwedt is set
* read batch data, if entered or filled from PO
    IF NOT ls_classification-charg IS INITIAL.
      CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
        EXPORTING
          matnr            = ls_classification-matnr
          charg            = ls_classification-charg
          werks            = ls_classification-werks
          lgort            = ls_classification-lgort
          read_from_buffer = x
          read_from_db     = x
          lock_batch       = s
        IMPORTING
          batch_buffer     = ls_mcha_buffer
          batch_db         = ls_batch_db
          rc_batch_buffer  = ls_rc_mcha_buffer
          rc_batch_db      = ls_rc_mcha_db.
    ELSE.
      ls_rc_mcha_buffer = 8.
      ls_rc_mcha_db     = 8.
    ENDIF.

    IF NOT ls_batch_db-lwedt IS INITIAL.
      IF lv_kzdch = 0.
        CALL METHOD oref_environment->batch_show
          EXPORTING
            i_matnr          = ls_classification-matnr      "RZ1078643
            i_werks          = ls_classification-werks      "RZ1078643
            i_lgort          = space
            i_charg          = ls_classification-charg      "RZ1078643
            i_classification = abap_true.
        EXIT.
      ELSE. "lv_kzdch = 0
        CALL METHOD oref_environment->batch_show
          EXPORTING
            i_matnr          = ls_classification-matnr      "RZ1078643
            i_werks          = space
            i_lgort          = space
            i_charg          = ls_classification-charg      "RZ1078643
            i_classification = abap_true.
        EXIT.
      ENDIF. "lv_kzdch = 0
    ENDIF. "NOT ls_batch_db-lwedt IS INITIAL
  ELSE. " NOT l_kzwsm IS INITIAL.
*   read batch data, if entered or filled from PO
    IF NOT ls_classification-charg IS INITIAL.              "1482059
      CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
        EXPORTING
          matnr            = ls_classification-matnr        "RZ1078643
          charg            = ls_classification-charg        "RZ1078643
          werks            = ls_classification-werks        "RZ1078643
          lgort            = ls_classification-lgort        "RZ1078643
          read_from_buffer = x
          read_from_db     = x
          lock_batch       = s
        IMPORTING
          batch_buffer     = ls_mcha_buffer
          rc_batch_buffer  = ls_rc_mcha_buffer
          rc_batch_db      = ls_rc_mcha_db.
    ELSE.
      ls_rc_mcha_buffer = 8.
      ls_rc_mcha_db     = 8.
    ENDIF.
  ENDIF. " NOT l_kzwsm IS INITIAL.

* set basis data
  ls_mcha_buffer-mandt = sy-mandt.
  ls_mcha_buffer-matnr = ls_classification-matnr.
  ls_mcha_buffer-werks = ls_classification-werks.
  ls_mcha_buffer-charg = ls_classification-charg.

* set batch data entered in MIGO
  IF NOT ls_classification-hsdat IS INITIAL.
    ls_mcha_buffer-hsdat = ls_classification-hsdat.
  ENDIF.
  IF NOT ls_classification-vfdat IS INITIAL.
    ls_mcha_buffer-vfdat = ls_classification-vfdat.
  ENDIF.
  IF NOT ls_rc_mcha_db IS INITIAL.
    IF NOT ls_classification-vendorbatch_from_refdoc IS INITIAL.
      ls_mcha_buffer-licha = ls_classification-vendorbatch_from_refdoc.
    ELSE.
      ls_mcha_buffer-licha = ls_classification-licha.
    ENDIF.
    IF NOT ls_classification-lifnr IS INITIAL
       AND NOT ls_classification-xpoitem IS INITIAL.
      ls_mcha_buffer-lifnr = ls_classification-lifnr.
    ENDIF.
    IF NOT ls_classification-bwtar IS INITIAL.
      ls_mcha_buffer-bwtar = ls_classification-bwtar.
    ENDIF.
  ELSE.
    IF ls_mcha_buffer-licha IS INITIAL.
      IF NOT ls_classification-vendorbatch_from_refdoc IS INITIAL.
        ls_mcha_buffer-licha = ls_classification-vendorbatch_from_refdoc.
      ELSE.
        ls_mcha_buffer-licha = ls_classification-licha.
      ENDIF.
    ENDIF.
    IF ls_mcha_buffer-lifnr IS INITIAL.
      ls_mcha_buffer-lifnr = ls_classification-lifnr.
    ENDIF.
    IF ls_mcha_buffer-bwtar IS INITIAL.
      ls_mcha_buffer-bwtar = ls_classification-bwtar.
    ENDIF.
  ENDIF.

* take date of last goods receipt - not in case of cancellation
  IF ls_mcha_buffer-lwedt IS INITIAL.
    IF s_action-cancel IS INITIAL.
      ls_mcha_buffer-lwedt = ps_gohead-budat.
    ENDIF.
  ELSEIF ls_classification-kzbew EQ b OR ls_classification-kzbew EQ f.
    ls_mcha_buffer-lwedt = ps_gohead-budat.
  ENDIF.

* set next check date, if initial until now
  IF ls_mcha_buffer-qndat IS INITIAL
    AND NOT ls_classification-prfrq IS INITIAL.
    ls_mcha_buffer-qndat = ls_mcha_buffer-lwedt +
                           ls_classification-prfrq.
  ENDIF.

* change batch
  IF ls_rc_mcha_buffer IS INITIAL.
ENHANCEMENT-SECTION     BATCH_MAINTAIN_02 SPOTS ES_SAPLMIGO.
    CALL FUNCTION 'VB_CHANGE_BATCH'
      EXPORTING
        ymcha                   = ls_mcha_buffer
        bypass_lock             = x
        x_bncom                 = ls_bncom
        kzcla                   = '3'
        xkcfc                   = ls_classification-xkcfc
        set_old_batch           = space
        buffer_refresh          = space
        no_change_document      = x
        no_cfc_calls            = space
      IMPORTING
        ymcha                   = ls_mcha_buffer
      EXCEPTIONS
        no_material             = 1
        no_batch                = 2
        no_plant                = 3
        material_not_found      = 4
        plant_not_found         = 5
        lock_on_material        = 6
        lock_on_plant           = 7
        lock_on_batch           = 8
        lock_system_error       = 9
        no_authority            = 10
        batch_not_exist         = 11
        no_class                = 12
        error_in_classification = 13
        OTHERS                  = 14.
END-ENHANCEMENT-SECTION.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE s NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* create batch
  ELSE.
* get batch definition level
    CALL FUNCTION 'VB_BATCH_DEFINITION'
      IMPORTING
        kzdch = lv_kzdch.
    IF lv_kzdch = 0.
      lv_klart = '022'.
    ELSE.
      lv_klart = '023'.
    ENDIF.

*   do not create a batch if this is forbidden for the movement type
    IF ls_goitem-chneu CA 'DEF' AND ls_goitem-charg IS INITIAL.
      MESSAGE e029(lb) WITH ls_goitem-bwart.
    ELSEIF ls_goitem-chneu = 'G'.
      MESSAGE e042(m7) WITH ls_classification-matnr
                            ls_classification-werks
                            ls_classification-lgort
                            ls_classification-charg.
    ENDIF.

*   check whether class can be assigned to batch
    CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
      EXPORTING
        material           = ls_classification-matnr
        plant              = ls_classification-werks
        classtype          = lv_klart
      EXCEPTIONS
        no_class_found     = 1
        no_classtype_found = 2
        OTHERS             = 99.
    IF sy-subrc IS INITIAL.
      lv_kzcla = '3'.
      lv_xkcfc = ls_classification-xkcfc.
    ELSE.
*!    For batch & of material & &, no class could be determined
      MESSAGE s207(m7)
              WITH ls_classification-charg
                   ls_classification-matnr
                   ls_classification-werks.
    ENDIF.

ENHANCEMENT-SECTION     BATCH_MAINTAIN_03 SPOTS ES_SAPLMIGO.
    CALL METHOD batch_create
      EXPORTING
        is_mcha      = ls_mcha_buffer
        i_new_lgort  = ls_classification-lgort
        is_bncom     = ls_bncom
        is_ref_batch = ls_ref_batch
        i_kzcla      = lv_kzcla
        i_xkcfc      = lv_xkcfc
      IMPORTING
        es_mcha      = ls_mcha_buffer.
END-ENHANCEMENT-SECTION.
  ENDIF.
*_______________________________________________________________________
* The work is done: We can use GOITEM again!
*_______________________________________________________________________

* Take batch data
  IF s_action-migo_mode = 'GT' AND ls_goitem-shkzg = h.
    ls_goitem-umcha = ls_mcha_buffer-charg.
    CALL METHOD batch_data_transfer_get
      EXPORTING
        is_mcha_buffer = ls_mcha_buffer
      CHANGING
        cs_goitem      = ls_goitem.
  ELSE.
    ls_goitem-charg = ls_mcha_buffer-charg.
    CALL METHOD batch_data_get
      EXPORTING
        is_mcha_buffer = ls_mcha_buffer
      CHANGING
        cs_goitem      = ls_goitem.
  ENDIF.
* Modify the data in goitem
  CALL METHOD line_modify
    EXPORTING
      i_line            = i_line
      i_authority_check = abap_false
    CHANGING
      cs_goitem         = ls_goitem.

* An update of the classification may have changed the conversion
* factor
  IF s_action-migo_mode = 'GT' AND ls_goitem-shkzg = h.
    ls_change_batch-charg = ls_goitem-umcha.
    ls_change_batch-matnr = ls_goitem-ummat.
    ls_change_batch-werks = ls_goitem-umwrk.
    l_kzwsm               = ls_goitem-umkzwsm.
  ELSE.
    ls_change_batch-charg = ls_goitem-charg.
    ls_change_batch-matnr = ls_goitem-matnr.
    ls_change_batch-werks = ls_goitem-werks.
    l_kzwsm               = ls_goitem-kzwsm.
  ENDIF.
  IF NOT l_kzwsm IS INITIAL AND
     NOT ( s_action-display = abap_true OR
           s_action-cancel = abap_true ).
    CALL METHOD change_quantity_later
      EXPORTING
        is_change_batch = ls_change_batch.
  ENDIF.

ENDMETHOD.                    "batch_maintain

************************************************************************
* Maintain batch, if MIGO_OK_CLASS is pressed
************************************************************************
METHOD batch_data_get.

  DATA: ls_change_batch TYPE ty_s_change_batch.

* Move buffer data into corresponding field, if it's initial.   "359659
  DEFINE def_move.                                          "359659
    if &1 is initial.                                       "359659
      &1 = &2.                                              "359659
    endif.                                                  "359659
  END-OF-DEFINITION.                                        "359659
  def_move cs_goitem-licha  is_mcha_buffer-licha.           "359659
  def_move cs_goitem-bwtar  is_mcha_buffer-bwtar.           "359659
  def_move cs_goitem-hsdat  is_mcha_buffer-hsdat.           "359659
  def_move cs_goitem-vfdat  is_mcha_buffer-vfdat.           "359659
  def_move cs_goitem-zustd  is_mcha_buffer-zustd.           "359659
*  IF cs_goitem-xpoitem = space.                            "519360
*    def_move cs_goitem-lifnr is_mcha_buffer-lifnr.         "519360
*  ENDIF.                                                   "519360

* in case of product units we have to fill change table
  IF cs_goitem-xparallel = abap_true.
    ls_change_batch-charg = cs_goitem-charg.
    ls_change_batch-matnr = cs_goitem-matnr.
    ls_change_batch-werks = cs_goitem-werks.
    CALL METHOD change_quantity_later
      EXPORTING
        is_change_batch = ls_change_batch.
  ENDIF.
ENDMETHOD.                             " BATCH_DATA_GET

************************************************************************
* Fill GOITEM batch-UM-fields form MCHA
************************************************************************
METHOD batch_data_transfer_get.

  DATA: ls_change_batch TYPE ty_s_change_batch.

* Move buffer data into corresponding field, if it's initial.
  DEFINE def_move.
    if &1 is initial.
      &1 = &2.
    endif.
  END-OF-DEFINITION.
  def_move cs_goitem-umbar   is_mcha_buffer-bwtar.
  def_move cs_goitem-umhsdat is_mcha_buffer-hsdat.
  def_move cs_goitem-umvfdat is_mcha_buffer-vfdat.
  def_move cs_goitem-umzst   is_mcha_buffer-zustd.
* -> In this case the field IS_MCHA_BUFFER-LIFNR is useless.

* In case of product units we have to fill change table
  IF cs_goitem-umxparallel = abap_true.
    ls_change_batch-charg = cs_goitem-umcha.
    ls_change_batch-matnr = cs_goitem-ummat.
    ls_change_batch-werks = cs_goitem-umwrk.
    CALL METHOD change_quantity_later
      EXPORTING
        is_change_batch = ls_change_batch.
  ENDIF.
ENDMETHOD.                    "batch_data_transfer_get

************************************************************************
* Update batch buffers from MIGO goitem line                     "624076
************************************************************************
METHOD batch_data_update.

  DATA:
    ls_mch1                TYPE mch1,
    ls_mcha                TYPE mcha,
    ls_mcha_db             TYPE mcha,
    ls_bncom               TYPE bncom,
    ls_batch_key           TYPE ty_s_change_batch,
    ls_gohead              TYPE gohead,
    ls_batch_data_old      TYPE ty_s_batch_relevant_data,
    ls_batch_data_act      TYPE ty_s_batch_relevant_data,
    ls_batch_data_new      TYPE ty_s_batch_relevant_data,
    lv_rc_t160m            TYPE sysubrc,
    lv_rc_buf              TYPE sysubrc,
    lv_rc_db               TYPE sysubrc,
    ls_ref_batch_dummy     TYPE ty_s_ref_batch,
    lv_lock_mode           TYPE enqmode,                        "1421689
    lv_hold_lifnr          TYPE mch1-lifnr.                     "1421689

*- transfer posting, receiving batch
  IF s_action-migo_mode EQ 'GT' AND
     cs_goitem-shkzg    EQ h.
    EXIT.
  ENDIF.
  CHECK NOT cs_goitem-xchpf IS INITIAL.
* only item with material number (maybe deleted manually)   "1246512
  CHECK NOT cs_goitem-matnr IS INITIAL.                     "1246512

  IF cl_ops_switch_check=>lo_mm_sd_sfws_dm_sc( ) EQ abap_true.
    IF cs_goitem-licha IS INITIAL AND
       cs_goitem-ebeln IS NOT INITIAL.
      SELECT COUNT( * )
        FROM mch_pur_temp
        WHERE ebeln EQ cs_goitem-ebeln
          AND ebelp EQ cs_goitem-ebelp.
      IF sy-dbcnt EQ 1.
        SELECT SINGLE licha
          FROM mch_pur_temp
          INTO cs_goitem-licha
          WHERE ebeln EQ cs_goitem-ebeln
            AND ebelp EQ cs_goitem-ebelp.
      ENDIF.
    ENDIF.
  ENDIF.

  IF cs_goitem-charg IS INITIAL.                            "N_740340
* only internal batch numbering allowed => create batch
    IF cs_goitem-chneu EQ 'C'.
* check whether it is allowed to post GR to same batch
      CALL FUNCTION 'MB_CHECK_T160M'
        EXPORTING
          i_arbgb = 'M7'
          i_msgnr = '668'
        IMPORTING
          rc      = lv_rc_t160m.
      CASE lv_rc_t160m.
* it's not allowed to post to same batch => create new batch
        WHEN 2.
          lv_rc_buf = 8.
        WHEN OTHERS.
          EXIT.
      ENDCASE.
* external batch numbering allowed, no batch number entered
* => do nothing here
    ELSE.
      EXIT.
    ENDIF.
* batch number entered
  ELSE.

*- fill key fields of batch
    MOVE-CORRESPONDING cs_goitem
      TO ls_batch_key.
    IF s_action-display = x.
      CLEAR lv_lock_mode.
    ELSE.
      lv_lock_mode = s.
    ENDIF.
    CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
      EXPORTING
        matnr            = ls_batch_key-matnr
        charg            = ls_batch_key-charg
        werks            = ls_batch_key-werks
        read_from_buffer = x
        read_from_db     = x
        lock_batch       = lv_lock_mode
      IMPORTING
        batch_buffer     = ls_mcha
        rc_batch_buffer  = lv_rc_buf
        batch_db         = ls_mcha_db
        rc_batch_db      = lv_rc_db
      EXCEPTIONS
        no_material      = 1
        no_batch         = 2
        no_plant         = 3
        lock_on_batch    = 4
        OTHERS           = 99.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE s NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

*- update relevant fields - buffer values
    MOVE-CORRESPONDING ls_mcha
      TO ls_batch_data_old.

*- update relevant fields - actual screen values
    MOVE-CORRESPONDING cs_goitem
      TO ls_batch_data_act.
  ENDIF.

*- batch already exists on DB or in buffer
*  in case of split valuation, the buffer must have a valuation"1482816
*  type, otherwise send the popup (new batch) to select it     "1482816
  IF ( lv_rc_buf IS INITIAL AND ls_mcha-bwtar IS NOT INITIAL   "1482816
       AND cs_goitem-bwtty IS NOT INITIAL ) OR                 "1482816
     ( lv_rc_buf IS INITIAL AND cs_goitem-bwtty IS INITIAL ).  "1482816
*- batch is on DB
*- filled DB-fields must not be initialized
    IF lv_rc_db IS INITIAL.
* clear buffer ls_mcha-licha in case vendor batch was          "1300381
* already took over once with enter but later overwritten      "1300381
* with blank                                                   "1300381
     IF is_old_goitem-licha <> space.                          "1300381
      IF is_old_goitem-licha <> cs_goitem-licha AND            "1300381
         cs_goitem-licha <> ls_mcha-licha.                     "1300381
       CLEAR: ls_mcha-licha.                                   "1300381
      ENDIF.                                                   "1300381
     ENDIF.                                                    "1300381
* clear cs_goitem-licha if the value in the vendor batch was not "731729
* changed in the screen, or if it is not equal to either         "731729
* database or the buffer value.                                  "731729
      IF cs_goitem-licha NE ls_mcha_db-licha AND            "731729
            cs_goitem-licha NE ls_mcha-licha AND            "731729
            cs_goitem-licha EQ is_old_goitem-licha.         "731729
        CLEAR cs_goitem-licha.                              "731729
      ENDIF.                                                "731729
* clear additionally cs_goitem-hsdat and cs_goitem-vfdat in case "730006
* batch number was changed on the screen                         "730006
      IF is_old_goitem-charg <> space.                      "730006
        IF is_old_goitem-charg <> cs_goitem-charg.          "730006
          CLEAR: cs_goitem-hsdat, cs_goitem-vfdat.          "730006
        ENDIF.                                              "730006
      ENDIF.                                                "730006
* movement type changed and new movement type not MHD-relevant   "926924
* -> reset dates with values from DB data                        "926924
      IF cs_goitem-kzmhd NE is_old_goitem-kzmhd AND         "926924
         cs_goitem-kzmhd IS INITIAL.                        "926924
        cs_goitem-hsdat = ls_mcha_db-hsdat.                 "926924
        cs_goitem-vfdat = ls_mcha_db-vfdat.                 "926924
      ENDIF.                                                "926924
* a stock- or batch determination will be processed several    "1051886
* times. If the first chosen batch will be replaced by another "1051886
* one, the old specific batch data have to be cleared          "1051886
        IF is_old_goitem-charg IS INITIAL AND                  "1360573
           goitem-xdetermination = 'X'.                        "1360573
          IF ( ( ls_mcha_db-lwedt <> ls_mcha_db-hsdat ) OR  "1051886
             ( ls_mcha-hsdat <> ls_mcha-lwedt ) )       AND "1051886
             cs_goitem-global_counter >= 2.                 "1051886
            CLEAR: cs_goitem-vfdat, cs_goitem-hsdat, cs_goitem-licha. "1056422
          ELSEIF ( cs_goitem-charg = ls_mcha_db-charg ) AND "1051886
                 ( cs_goitem-charg = ls_mcha-charg )    AND "1051886
                 cs_goitem-global_counter >= 2.             "1051886
            CLEAR: cs_goitem-hsdat, cs_goitem-vfdat, cs_goitem-licha. "1056422
          ENDIF.                                            "1051886
        ENDIF.                                              "1051886
* clear hsdat & vfdat if the user initializes it and it is not on DB"1409147
      IF cs_goitem-hsdat IS INITIAL AND ls_mcha_db-hsdat IS INITIAL "1409147
         AND NOT ls_mcha-hsdat IS INITIAL.                          "1409147
            clear ls_mcha-hsdat.                                    "1409147
      ENDIF.                                                        "1409147
      IF cs_goitem-vfdat IS INITIAL AND ls_mcha_db-vfdat IS INITIAL "1409147
         AND NOT ls_mcha-vfdat IS INITIAL.                          "1409147
            clear ls_mcha-vfdat.                                    "1409147
      ENDIF.                                                        "1409147
* cs_goitem-vfdat and cs_goitem-hsdat should get the right  "1321177
* values after changing the material, in case the batch is  "1321177
* identical however hsdat and vfdat are different           "1321177
       IF is_old_goitem-charg = cs_goitem-charg  AND        "1321177
          is_old_goitem-matnr <> cs_goitem-matnr.           "1321177
        IF is_old_goitem-vfdat <> ls_mcha-vfdat or          "1321177
           is_old_goitem-hsdat <> ls_mcha-hsdat.            "1321177
            cs_goitem-hsdat = ls_mcha-hsdat.                "1321177
            cs_goitem-vfdat = ls_mcha-vfdat.                "1321177
        ENDIF.                                              "1321177
       ENDIF.                                               "1321177

*- if screen fields are empty
*- 1.) if still empty fill from DB data
      CALL METHOD batch_data_get
        EXPORTING
          is_mcha_buffer = ls_mcha_db
        CHANGING
          cs_goitem      = cs_goitem.
*- 2.) fill them from buffer data
      CALL METHOD batch_data_get
        EXPORTING
          is_mcha_buffer = ls_mcha
        CHANGING
          cs_goitem      = cs_goitem.
*- update relevant fields - new screen values
      MOVE-CORRESPONDING cs_goitem
        TO ls_batch_data_new.

*- batch is only in buffer, not yet on DB
    ELSE.
*- screen fields are leading => take over stupidly
      IF is_old_goitem-charg EQ cs_goitem-charg AND
         is_old_goitem-matnr EQ cs_goitem-matnr AND
       ( is_old_goitem-werks EQ cs_goitem-werks OR
         lcl_migo_globals=>batch_level NE '0' ).
        ls_batch_data_new = ls_batch_data_act.

*- line is called newly
*- => empty screen fields are filled with buffer values
*-    filled screen fields are written to buffer
      ELSE.
        CALL METHOD batch_data_get
          EXPORTING
            is_mcha_buffer = ls_mcha
          CHANGING
            cs_goitem      = cs_goitem.
        MOVE-CORRESPONDING cs_goitem
          TO ls_batch_data_new.

      ENDIF.
    ENDIF.

*- update batch buffer
    IF ls_batch_data_new NE ls_batch_data_old.
*- batches defined on plant level
      IF lcl_migo_globals=>batch_level EQ '0'.
        MOVE-CORRESPONDING ls_batch_data_new
          TO ls_mcha.
        CALL FUNCTION 'VB_BATCH_WRITE_BUFFER'
          CHANGING
            new_batch_buffer_mcha = ls_mcha
          EXCEPTIONS
            no_material           = 1
            no_batch              = 2
            no_plant              = 3
            no_storage            = 4
            OTHERS                = 99.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
*- batches defined on material or client level
      ELSE.
        MOVE-CORRESPONDING ls_mcha
          TO ls_mch1.
        MOVE-CORRESPONDING ls_batch_data_new
          TO ls_mch1.
        CALL FUNCTION 'VB_BATCH_WRITE_BUFFER'
          CHANGING
            new_batch_buffer_mch1 = ls_mch1
          EXCEPTIONS
            no_material           = 1
            no_batch              = 2
            no_plant              = 3
            no_storage            = 4
            OTHERS                = 99.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
*- update all lines refering to same batch
      CALL METHOD change_batch_later
        EXPORTING
          is_batch_key = ls_batch_key.
    ENDIF.

*- batch is neither in buffer nor on DB => create it
  ELSE.
*- batch creation not allowed manually, generally
    IF    cs_goitem-chneu CA 'CG' AND
      NOT cs_goitem-charg IS INITIAL.
      MESSAGE s042(m7) WITH cs_goitem-matnr
                            cs_goitem-werks
                            cs_goitem-lgort
                            cs_goitem-charg.
      EXIT.
    ENDIF.
*- fill communication area
    CALL METHOD header_get
      IMPORTING
        e_gohead = ls_gohead.
    MOVE-CORRESPONDING ls_gohead
      TO ls_bncom.
    MOVE-CORRESPONDING cs_goitem
      TO ls_bncom.
*- store lifnr that it will not be overwritten                  "1421689
    lv_hold_lifnr = cs_goitem-lifnr.                            "1421689
*- fill batch data
    MOVE-CORRESPONDING cs_goitem
      TO ls_mcha.
    CALL METHOD batch_create
      EXPORTING
        is_mcha      = ls_mcha
        i_new_lgort  = space
        is_bncom     = ls_bncom
        is_ref_batch = ls_ref_batch_dummy
        i_kzcla      = space
        i_xkcfc      = space
      IMPORTING
        es_mcha      = ls_mcha.
    MOVE-CORRESPONDING ls_mcha
      TO cs_goitem.
*- restore lifnr in case of GR for PO as it could be changed    "1421689
*  in EXIT_SAPLV01Z_013 which is not allowed (M7360)            "1421689
    IF s_control-action = 'A01' AND s_control-refdoc = 'R01'.   "1421689
      cs_goitem-lifnr = lv_hold_lifnr.                          "1421689
    ENDIF.                                                      "1421689
  ENDIF.

ENDMETHOD.                             " batch_data_update

************************************************************************
* Update batch buffers from MIGO goitem line for stock transfers "624076
************************************************************************
METHOD batch_data_transfer_update.

  DATA:
    ls_mch1                 TYPE mch1,
    ls_mcha                 TYPE mcha,
    ls_mcha_db              TYPE mcha,
    ls_bncom                TYPE bncom,
    ls_batch_key            TYPE ty_s_change_batch,
    lv_kzcla                TYPE kzcla,
    ls_classification       TYPE ty_s_classification,
    ls_ref_batch            TYPE ty_s_ref_batch,
    ls_gohead               TYPE gohead,
    ls_batch_data_old       TYPE ty_s_batch_relevant_data,
    ls_batch_trans_data_act TYPE ty_s_batch_relevant_trans_data,
    ls_batch_trans_data_new TYPE ty_s_batch_relevant_trans_data,
    ls_batch_data_new       TYPE ty_s_batch_relevant_data,
    lv_rc_buf               TYPE sysubrc,
    lv_rc_db                TYPE sysubrc,
    lv_batch_in_other_item  TYPE xfeld,
    cs_displ_mseg           TYPE mseg,                      "H702056
    lt_migo_fields          TYPE tyt_migo_move_fields,      "1266848
    ls_migo_fields          TYPE tys_migo_move_fields.      "1266848

*- transfer posting, receiving batch
  CHECK s_action-migo_mode EQ 'GT'
    AND cs_goitem-shkzg    EQ h.
  CHECK NOT cs_goitem-umxchpf IS INITIAL.
  IF s_action-cancel = abap_true OR s_action-display = abap_true.
    CHECK NOT cs_goitem-ummat   IS INITIAL.                 "663173
    CHECK NOT cs_goitem-umwrk   IS INITIAL.                 "663173
  ENDIF.                                                    "663173

* Fill cs_goitem-umcha in case Charg number was changed     "1266848
* on the screen and field umcha is not editable             "1266848
* Check Customizing like in include LMIGOKU3 line 179       "1266848
  IF cs_goitem-umcha <> cs_goitem-charg                     "1266848
    AND is_old_goitem-charg <> cs_goitem-charg              "1266848
    AND s_action-display IS INITIAL.                        "1340843
    CALL METHOD cl_mmim_migo_move_fields=>get_fields        "1266848
      EXPORTING                                             "1266848
        i_bwart   = cs_goitem-bwart                         "1266848
      IMPORTING                                             "1266848
        et_fields = lt_migo_fields.                         "1266848
                                                            "1266848
    READ TABLE lt_migo_fields INTO ls_migo_fields           "1266848
        WITH KEY fieldname = 'UMCHA'.                       "1266848
    IF sy-subrc <> 0 OR ( ls_migo_fields-entry <> '+'       "1266848
                          AND cs_goitem-umcha IS INITIAL ) . "1266848
      cs_goitem-umcha = cs_goitem-charg.                    "1266848
      CLEAR: cs_goitem-umhsdat,                             "1266848
             cs_goitem-umvfdat.                             "1266848
    ENDIF.                                                  "1266848
  ENDIF.                                                    "1266848
                                                            "1266848
  IF cs_goitem-umcha IS INITIAL.                            "1266848
    CLEAR: cs_goitem-umhsdat,                               "1266848
           cs_goitem-umvfdat.                               "1266848
  ENDIF.                                                    "1266848

  CHECK NOT cs_goitem-umcha   IS INITIAL.
  CHECK NOT cs_goitem-ummat   IS INITIAL.                   "1261032

* Use data from GOITEM to fill LS_CLASSIFICATION
  CALL METHOD batch_class_structure_fill
    EXPORTING
      is_goitem         = cs_goitem
    IMPORTING
      es_classification = ls_classification
      es_ref_batch      = ls_ref_batch.

*- fill key fields of batch
  MOVE cs_goitem-ummat
    TO ls_batch_key-matnr.
  MOVE cs_goitem-umcha
    TO ls_batch_key-charg.
  MOVE cs_goitem-umwrk
    TO ls_batch_key-werks.

  CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
    EXPORTING
      matnr            = ls_batch_key-matnr
      charg            = ls_batch_key-charg
      werks            = ls_batch_key-werks
      read_from_buffer = x
      read_from_db     = x
    IMPORTING
      batch_buffer     = ls_mcha
      rc_batch_buffer  = lv_rc_buf
      batch_db         = ls_mcha_db
      rc_batch_db      = lv_rc_db
    EXCEPTIONS
      no_material      = 1
      no_batch         = 2
      no_plant         = 3
      lock_on_batch    = 4
      OTHERS           = 99.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*- update relevant fields - buffer values
  MOVE-CORRESPONDING ls_mcha
    TO ls_batch_data_old.

*- update relevant fields - actual screen values
  MOVE-CORRESPONDING cs_goitem
    TO ls_batch_trans_data_act.

*- batch already exists on DB or in buffer
  IF lv_rc_buf IS INITIAL.

*- batch is on DB
*- filled DB-fields must not be initialized
    IF lv_rc_db IS INITIAL.
      MOVE-CORRESPONDING cs_goitem TO cs_displ_mseg.        "702056

* clear additionally cs_goitem-umhsdat and cs_goitem-umvfdat"1260078
* in case batch number was changed on the screen            "1260078
      IF is_old_goitem-umcha <> space.                      "1260078
        IF is_old_goitem-umcha <> cs_goitem-umcha.          "1260078
          CLEAR: cs_goitem-umhsdat,                         "1260078
                 cs_goitem-umvfdat.                         "1260078
        ENDIF.                                              "1260078
      ENDIF.                                                "1260078

*- if screen fields are empty
*- 1.) fill them from buffer data
*- transfer posting, receiving batch
      CALL METHOD batch_data_transfer_get
        EXPORTING
          is_mcha_buffer = ls_mcha
        CHANGING
          cs_goitem      = cs_goitem.
*- 2.) if still empty fill from DB data
      CALL METHOD batch_data_transfer_get
        EXPORTING
          is_mcha_buffer = ls_mcha_db
        CHANGING
          cs_goitem      = cs_goitem.
* cs_goitem-vfdat and cs_goitem-hsdat should get the right  "861750
* values after changing the batch number                    "861750
* if only field VFDAT is defined in the batch masta data    "915679
* this should also be considered                            "915679
      IF is_old_goitem-charg =  space AND ( NOT             "915679
         is_old_goitem-hsdat IS INITIAL OR NOT              "915679
         is_old_goitem-vfdat IS INITIAL ).                  "915679
        IF is_old_goitem-vfdat <> ls_mcha-vfdat OR          "861750
           is_old_goitem-hsdat <> ls_mcha-hsdat.            "861750
          cs_goitem-hsdat = ls_mcha-hsdat.                  "861750
          cs_goitem-vfdat = ls_mcha-vfdat.                  "861750
        ENDIF.                                              "861750
      ENDIF.                                                "861750
      if s_action-display = abap_true.                      "702056
        MOVE-CORRESPONDING cs_displ_mseg TO cs_goitem.      "702056
      ENDIF.                                                "702056

*- update relevant fields - new screen values
      MOVE-CORRESPONDING cs_goitem
        TO ls_batch_trans_data_new.

*- receiving batch is only in buffer, not yet on DB
    ELSE.
      IF lcl_migo_globals=>batch_level EQ '0'.
        LOOP AT pt_goitem
          TRANSPORTING NO FIELDS
          WHERE global_counter NE cs_goitem-global_counter
            AND ummat          EQ cs_goitem-ummat
            AND umcha          EQ cs_goitem-umcha
            AND umwrk          EQ cs_goitem-umwrk.
          lv_batch_in_other_item = abap_true.
          EXIT.
        ENDLOOP.
      ELSE.
        LOOP AT pt_goitem
          TRANSPORTING NO FIELDS
          WHERE global_counter NE cs_goitem-global_counter
            AND ummat          EQ cs_goitem-ummat
            AND umcha          EQ cs_goitem-umcha.
          lv_batch_in_other_item = abap_true.
          EXIT.
        ENDLOOP.
      ENDIF.
*- the issueing batch has been changed => receiving batch is
*- reset in buffer and created newly
      IF lv_batch_in_other_item NE abap_true       AND
        ( is_old_goitem-matnr   NE cs_goitem-matnr OR
          is_old_goitem-charg   NE cs_goitem-charg OR
        ( is_old_goitem-werks   NE cs_goitem-werks AND
          lcl_migo_globals=>batch_level EQ '0' ) ).
        CALL FUNCTION 'VB_RESET_BATCH'
          EXPORTING
            dmcha  = ls_mcha
          EXCEPTIONS
            OTHERS = 0.
*- fill communication area
        CALL METHOD header_get
          IMPORTING
            e_gohead = ls_gohead.
        MOVE-CORRESPONDING ls_gohead
          TO ls_bncom.
        MOVE-CORRESPONDING cs_goitem
          TO ls_bncom.
*- fill batch data
        CLEAR ls_mcha.
        MOVE-CORRESPONDING ls_batch_key
          TO ls_mcha.
*- determine whether classification should be called
        IF NOT cs_goitem-kzcla IS INITIAL.
          lv_kzcla = '1'.
        ENDIF.
        CALL METHOD batch_create
          EXPORTING
            is_mcha      = ls_mcha
            i_new_lgort  = space
            is_bncom     = ls_bncom
            is_ref_batch = ls_ref_batch
            i_kzcla      = lv_kzcla
            i_xkcfc      = space
          IMPORTING
            es_mcha      = ls_mcha.
*- set screen fields for receiving batch
        MOVE-CORRESPONDING ls_mcha
          TO ls_batch_data_new.
        ls_batch_trans_data_new = ls_batch_data_new.
        MOVE-CORRESPONDING ls_batch_trans_data_new
          TO cs_goitem.
      ELSE.
*- screen fields are leading => take over stupidly
        IF is_old_goitem-umcha EQ cs_goitem-umcha AND
           is_old_goitem-ummat EQ cs_goitem-ummat AND
         ( is_old_goitem-umwrk EQ cs_goitem-umwrk OR
           lcl_migo_globals=>batch_level NE '0' ).
          ls_batch_trans_data_new = ls_batch_trans_data_act.
*- changed valuation type for new batch in buffer -> update     "1141939
          IF ls_mcha-charg EQ cs_goitem-umcha               "1141939
           AND NOT ls_mcha-bwtar EQ cs_goitem-umbar.        "1141939
            MOVE cs_goitem-umbar TO ls_mcha-bwtar.          "1141939
*- if batch_level NE '0' then batches on client or mat level    "1432563
*- therefore we have to call the FM for MCH1 not MCHA           "1432563
*- lcl_migo_globals=>batch_level                                "1432563
*- 0 Batch unique at plant level                                "1432563
*- 1 Batch unique at material level                             "1432563
*- 2 Batch unique at client level                               "1432563
          MOVE-CORRESPONDING ls_mcha TO ls_mch1.                "1432563
          CALL FUNCTION 'VB_BATCH_WRITE_BUFFER'                 "1141939
            CHANGING                                            "1141939
*             new_batch_buffer_mcha = ls_mcha                   "1432563
              new_batch_buffer_mch1 = ls_mch1                   "1432563
              EXCEPTIONS                                    "1141939
                no_material           = 1                   "1141939
                no_batch              = 2                   "1141939
                no_plant              = 3                   "1141939
                no_storage            = 4                   "1141939
                OTHERS                = 99.                 "1141939
            IF sy-subrc <> 0.                               "1141939
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno "1141939
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4. "1141939
            ENDIF.                                          "1141939
          ENDIF.                                            "1141939
*- line is called newly
*- => empty screen fields are filled with buffer values
*-    filled screen fields are written to buffer
        ELSE.
          CALL METHOD batch_data_transfer_get
            EXPORTING
              is_mcha_buffer = ls_mcha
            CHANGING
              cs_goitem      = cs_goitem.
        ENDIF.
      ENDIF.
    ENDIF.

*- shift UM*-fields to 'normal' fields
    ls_batch_data_new = ls_batch_trans_data_new.

*- update batch buffer
    IF ls_batch_data_new NE ls_batch_data_old.
*- batches defined on plant level
      IF lcl_migo_globals=>batch_level EQ '0'.
        MOVE-CORRESPONDING ls_batch_data_new
          TO ls_mcha.
        CALL FUNCTION 'VB_BATCH_WRITE_BUFFER'
          CHANGING
            new_batch_buffer_mcha = ls_mcha
          EXCEPTIONS
            no_material           = 1
            no_batch              = 2
            no_plant              = 3
            no_storage            = 4
            OTHERS                = 99.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
*- batches defined on material or client level
      ELSE.
        MOVE-CORRESPONDING ls_mcha
          TO ls_mch1.
        MOVE-CORRESPONDING ls_batch_data_new
          TO ls_mch1.
        CALL FUNCTION 'VB_BATCH_WRITE_BUFFER'
          CHANGING
            new_batch_buffer_mch1 = ls_mch1
          EXCEPTIONS
            no_material           = 1
            no_batch              = 2
            no_plant              = 3
            no_storage            = 4
            OTHERS                = 99.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
*- update all lines refering to same batch
      CALL METHOD change_batch_later
        EXPORTING
          is_batch_key = ls_batch_key.
    ENDIF.

*- batch is neither in buffer nor on DB => create it
  ELSE.
*- batch creation not allowed manually, generally
    IF cs_goitem-chneu CA 'CG'.
      MESSAGE s042(m7) WITH cs_goitem-ummat                 "N1230633
                            cs_goitem-umwrk                 "N1230633
                            cs_goitem-umlgo                 "N1230633
                            cs_goitem-umcha.                "N1230633
      EXIT.
    ENDIF.
*- fill communication area
    CALL METHOD header_get
      IMPORTING
        e_gohead = ls_gohead.
    MOVE-CORRESPONDING ls_gohead
      TO ls_bncom.
    MOVE-CORRESPONDING cs_goitem
      TO ls_bncom.
*- fill batch data
    MOVE-CORRESPONDING ls_batch_key
      TO ls_mcha.
    MOVE-CORRESPONDING cs_goitem
      TO ls_batch_trans_data_new.
    ls_batch_data_new = ls_batch_trans_data_new.
    MOVE-CORRESPONDING ls_batch_data_new
      TO ls_mcha.
    MOVE cs_goitem-umbar TO ls_mcha-bwtar.                  "937018
*- determine whether classification should be called
    IF NOT cs_goitem-kzcla IS INITIAL.
      lv_kzcla = '1'.
    ENDIF.
    CALL METHOD batch_create
      EXPORTING
        is_mcha      = ls_mcha
        i_new_lgort  = space
        is_bncom     = ls_bncom
        is_ref_batch = ls_ref_batch
        i_kzcla      = lv_kzcla
        i_xkcfc      = space
      IMPORTING
        es_mcha      = ls_mcha.
    MOVE-CORRESPONDING ls_mcha
      TO ls_batch_data_new.
    ls_batch_trans_data_new = ls_batch_data_new.
    MOVE-CORRESPONDING ls_batch_trans_data_new
      TO cs_goitem.
  ENDIF.

ENDMETHOD.                             " batch_data_transfer_update

************************************************************************
*                              <LG>
* reads the empties bom to the corresponding full product and returns a
* table with just the needed bom fields
*
* input:
*     is_goitem_full_product : actual full product
*
* export:
*     et_slcomp : the empties bom of the actual full product
************************************************************************
METHOD bom_empties_read.

  DATA: ls_slcomp TYPE ty_s_slcomp,    "just the necessary bom fields
        ls_slcomp_complete TYPE stpob,
        lt_slcomp_complete TYPE STANDARD TABLE OF stpob.

  CLEAR: et_slcomp.

  CALL FUNCTION 'MGW0_PACKAGING_COMPONENTS'
    EXPORTING
      mgw0_article    = is_goitem_full_product-matnr
      mgw0_unit       = is_goitem_full_product-erfme
    TABLES
      mgw0_components = lt_slcomp_complete
    EXCEPTIONS
      not_found       = 01.

  IF sy-subrc <> 0.
    RAISE not_found.
  ELSE.
* move bom into output structure
    LOOP AT lt_slcomp_complete INTO ls_slcomp_complete.
      MOVE-CORRESPONDING ls_slcomp_complete      TO ls_slcomp.
      MOVE is_goitem_full_product-global_counter
                                  TO ls_slcomp-global_counter.
      APPEND ls_slcomp TO et_slcomp.
    ENDLOOP.
  ENDIF.

ENDMETHOD.                    "
************************************************************************
*   Batch_Maintain_Dark                                                *
************************************************************************
METHOD batch_maintain_dark.
*   create batch if not already in buffer

  DATA: ls_goitem         TYPE goitem,
        ls_classification TYPE ty_s_classification,
        ls_mcha_buffer    TYPE mcha,
        ls_rc_mcha_buffer TYPE sy-subrc,
        ls_rc_mcha_db     TYPE sy-subrc,
        lv_klart          TYPE klassenart,                  "455890
        lv_kzdch          TYPE kzdch,                       "455890
        ls_bncom          TYPE bncom,
        ls_ref_batch      TYPE ty_s_ref_batch.


* Use data from GOITEM to fill LS_CLASSIFICATION
  CALL METHOD batch_class_structure_fill
    EXPORTING
      is_goitem         = is_goitem
    IMPORTING
      es_classification = ls_classification
      es_ref_batch      = ls_ref_batch.

* do not create a batch if this is forbidden for the movement type
  IF is_goitem-chneu CA 'DEF' AND ls_classification-charg IS INITIAL.
    MESSAGE s029(lb) WITH is_goitem-bwart.
    EXIT.
  ELSEIF is_goitem-chneu = 'G'.
    MESSAGE s042(m7) WITH ls_classification-matnr
                          ls_classification-werks
                          ls_classification-lgort
                          ls_classification-charg.
    EXIT.
  ENDIF.

* read batch data, if entered or filled from PO
  IF NOT ls_classification-charg IS INITIAL.                "455890
    CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
      EXPORTING
        matnr            = ls_classification-matnr
        charg            = ls_classification-charg
        werks            = ls_classification-werks
        lgort            = ls_classification-lgort
        read_from_buffer = x
        read_from_db     = x
        lock_batch       = s
      IMPORTING
        batch_buffer     = ls_mcha_buffer
        rc_batch_buffer  = ls_rc_mcha_buffer
        rc_batch_db      = ls_rc_mcha_db.
  ELSE.                                                     "455890
    ls_rc_mcha_buffer = 8.                                  "455890
    ls_rc_mcha_db     = 8.                                  "455890
  ENDIF.                                                    "455890

* Only create a batch if not in buffer
  IF ls_rc_mcha_buffer IS INITIAL.
    es_batch_dark-charg = ls_classification-charg.
    EXIT.
  ENDIF.

* fill communication area
  MOVE-CORRESPONDING ls_classification TO ls_bncom.
  MOVE-CORRESPONDING ps_gohead TO ls_bncom.

* set basis data
  ls_mcha_buffer-mandt = sy-mandt.
  ls_mcha_buffer-matnr = ls_classification-matnr.
  ls_mcha_buffer-werks = ls_classification-werks.
  ls_mcha_buffer-charg = ls_classification-charg.

* set batch data entered in MIGO
  IF NOT ls_classification-hsdat IS INITIAL.
    ls_mcha_buffer-hsdat = ls_classification-hsdat.
  ENDIF.
  IF NOT ls_classification-vfdat IS INITIAL.
    ls_mcha_buffer-vfdat = ls_classification-vfdat.
  ENDIF.
  IF NOT ls_rc_mcha_db IS INITIAL.
    IF NOT ls_classification-vendorbatch_from_refdoc IS INITIAL.
      ls_mcha_buffer-licha = ls_classification-vendorbatch_from_refdoc.
    ELSE.
      ls_mcha_buffer-licha = ls_classification-licha.
    ENDIF.
    IF NOT ls_classification-lifnr IS INITIAL
       AND NOT is_goitem-xpoitem IS INITIAL.
      ls_mcha_buffer-lifnr = ls_classification-lifnr.
    ENDIF.
    IF NOT ls_classification-bwtar IS INITIAL.
      ls_mcha_buffer-bwtar = ls_classification-bwtar.
    ENDIF.
  ENDIF.

* take date of last goods receipt - not in case of cancellation
  IF ls_mcha_buffer-lwedt IS INITIAL.
    IF s_action-cancel IS INITIAL.
      ls_mcha_buffer-lwedt = ps_gohead-budat.
    ENDIF.
  ELSEIF ls_classification-kzbew EQ b OR ls_classification-kzbew EQ f.
    ls_mcha_buffer-lwedt = ps_gohead-budat.
  ENDIF.

* set next check date, if initial until now
  IF ls_mcha_buffer-qndat IS INITIAL
    AND NOT ls_classification-prfrq IS INITIAL.
    ls_mcha_buffer-qndat = ls_mcha_buffer-lwedt +
    ls_classification-prfrq.
  ENDIF.

* get batch definition level                           "Begin 455890
  CALL FUNCTION 'VB_BATCH_DEFINITION'
    IMPORTING
      kzdch = lv_kzdch.
  IF lv_kzdch = 0.
    lv_klart = '022'.
  ELSE.
    lv_klart = '023'.
  ENDIF.

* check whether class can be assigned to batch
  CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
    EXPORTING
      material           = ls_classification-matnr
      plant              = ls_classification-werks
      classtype          = lv_klart
    EXCEPTIONS
      no_class_found     = 1
      no_classtype_found = 2
      OTHERS             = 99.
  CHECK sy-subrc IS INITIAL.                                "End 455890

* Create batch without dialog
ENHANCEMENT-SECTION     BATCH_MAINTAIN_DARK_01 SPOTS ES_SAPLMIGO.
  CALL METHOD batch_create
    EXPORTING
      is_mcha      = ls_mcha_buffer
      i_new_lgort  = ls_classification-lgort
      is_bncom     = ls_bncom
      is_ref_batch = ls_ref_batch
      i_kzcla      = '1'
      i_xkcfc      = ls_classification-xkcfc
    IMPORTING
      es_mcha      = ls_mcha_buffer.
END-ENHANCEMENT-SECTION.
  CHECK sy-subrc EQ 0.

* take batch data                                        "455890

  IF s_action-migo_mode = 'GT' AND ls_goitem-shkzg = h.
    CALL METHOD batch_data_transfer_get
      EXPORTING
        is_mcha_buffer = ls_mcha_buffer
      CHANGING
        cs_goitem      = ls_goitem.

    MOVE-CORRESPONDING ls_goitem TO es_batch_dark.
    es_batch_dark-umcha = ls_mcha_buffer-charg.

  ELSE.
    CALL METHOD batch_data_get
      EXPORTING
        is_mcha_buffer = ls_mcha_buffer
      CHANGING
        cs_goitem      = ls_goitem.

    MOVE-CORRESPONDING ls_goitem TO es_batch_dark.
    es_batch_dark-charg = ls_mcha_buffer-charg.

  ENDIF.


ENDMETHOD.                    "
************************************************************************
*   Batch_Classif_Status_Get                                           *
************************************************************************
*METHOD batch_classif_status_get.
**   check whether batch classification may be changed
*
*  DATA: l_date_last_gr  TYPE mcha-lwedt.
*
** Change of classification not allowed for materials
** with product units of measure
*  CLEAR e_display_only.
*  CALL METHOD check_batch_posted
*           EXPORTING
*                 i_matnr = i_matnr
*                 i_werks = i_werks
*                 i_charg = i_charg
*           IMPORTING
*                 e_date_last_gr = l_date_last_gr.
*
*  IF NOT l_date_last_gr IS INITIAL.
*    e_display_only = abap_true.
*    EXIT.
*  ENDIF.
** Stefan - woher habt Ihr das im Dm07m gelesen?
** Change of classification not allowed
** if batch has valued active ingredients
** and there is already a "Bewertungssatz"
**  IF NOT DM07M-XBEWM IS INITIAL AND DM07M-RMBEW IS INITIAL.
**    e_display_only = abap_true.
**    EXIT.
**  ENDIF.
*
*ENDMETHOD.

************************************************************************
* Method BATCH_CLASS_STRUCTURE_FILL
************************************************************************
METHOD batch_class_structure_fill.
  IF s_action-migo_mode = 'GT' AND is_goitem-shkzg = h.
*   Perform classification with UM-fields
    es_classification-charg = is_goitem-umcha.
    es_classification-bwtar = is_goitem-umbar.
    es_classification-hsdat = is_goitem-umhsdat.
    es_classification-vfdat = is_goitem-umvfdat.
    es_classification-prfrq = is_goitem-umprfrq.
    es_classification-xkcfc = is_goitem-xkcfc.              "from T156
*   - XPOITEM (in case of 'GT', this field is always initial)
*   - VENDORBATCH_FROM_REFDOC  (dito)
*   BNCOM-fields:
*   - LIFNR (in case of 'GT', this field is always initial )
*   - LICHA (in case of 'GT', this field is always initial )
*   - EKORG (in case of 'GT', this field is always initial )
*   - AUART (not in structure GOITEM)
*   - AUTYP (not in structure GOITEM)
    es_classification-lgnum = is_goitem-umlgnum.
    es_classification-bwlvs = is_goitem-bwlvs.
* begin of note 595722
*   Material document posted with mvt. 311 and batch
    IF ( s_action-display = abap_true OR s_action-cancel = abap_true )
      AND is_goitem-ummat = space AND is_goitem-matnr <> space
      AND is_goitem-umwrk = space AND is_goitem-werks <> space.
      es_classification-matnr = is_goitem-matnr.
      es_classification-werks = is_goitem-werks.
*   begin of note 991065
*   Material document posted with mvt. 301 and batch
    ELSEIF ( s_action-display = abap_true OR s_action-cancel = abap_true )
      AND is_goitem-ummat = space AND is_goitem-matnr <> space
      AND is_goitem-umwrk <> space AND is_goitem-werks <> space.
      es_classification-matnr = is_goitem-matnr.
      es_classification-werks = is_goitem-umwrk.
*   end of note 991065
    ELSE.
      es_classification-matnr = is_goitem-ummat.
      es_classification-werks = is_goitem-umwrk.
    ENDIF.
* end of note 595722
    es_classification-lgort = is_goitem-umlgo.
*   - WAGRP (not in structure GOITEM)
    es_classification-matkl = is_goitem-ummatkl.
*   - MTART (not in structure GOITEM)
    es_classification-shkzg = s.            " -> Always receiving side
    es_classification-bwtty = is_goitem-umbwtty.
    es_classification-bwart = is_goitem-bwart.
    es_classification-sobkz = is_goitem-umsok.
    es_classification-ummat = is_goitem-matnr.
    es_classification-umwrk = is_goitem-werks.
    es_classification-umcha = is_goitem-charg.
    es_classification-umlgo = is_goitem-lgort.
    es_classification-umsok = is_goitem-sobkz.
*   - PMATN (not in structure GOITEM)
*   - PWERK (not in structure GOITEM)
*   - KDAUF (accounting field -> not relevant for UM-fields)
*   - KDPOS (accounting field -> not relevant for UM-fields)
*   - KDEIN (accounting field -> not relevant for UM-fields)
*   - EBELN (in case of 'GT', this field is always initial )
*   - EBELP (in case of 'GT', this field is always initial )
*   - BSTYP (in case of 'GT', this field is always initial )
*   - BSART (not in structure GOITEM)
*   - AUFNR (in case of 'GT', this field is always initial )
*   - POSNR (in case of 'GT', this field is always initial )
*   - KZBEW (in case of 'GT', this field is always initial )
    es_classification-kzcla = is_goitem-kzcla.              "from T156
*   - PRWRK  (not in structure GOITEM)
*   - KDUMMY (not in structure GOITEM)
*___________________________________________________________________
*   Fill reference fields
    es_ref_batch-ref_matnr = is_goitem-matnr.
    es_ref_batch-ref_charg = is_goitem-charg.
    es_ref_batch-ref_werks = is_goitem-werks.
  ELSE.
*   Perform classification standard fields
    MOVE-CORRESPONDING is_goitem TO es_classification.
    MOVE is_goitem-pps_aufnr TO es_classification-aufnr.    "666302
    MOVE is_goitem-pps_posnr TO es_classification-posnr.    "666302
    MOVE is_goitem-vbeln     TO es_classification-lfbel.
    MOVE is_goitem-posnr     TO es_classification-lfpos.
    IF s_action-migo_mode = 'GT'.
*     Fill reference fields
      es_ref_batch-ref_matnr = is_goitem-ummat.
      es_ref_batch-ref_charg = is_goitem-umcha.
      es_ref_batch-ref_werks = is_goitem-umwrk.
    ENDIF.
  ENDIF.
ENDMETHOD.                    "BATCH_CLASS_STRUCTURE_FILL

************************************************************************
* Method BATCH_CREATE
************************************************************************
METHOD batch_create.

  CALL FUNCTION 'VB_CREATE_BATCH'
    EXPORTING
      ymcha                        = is_mcha
      new_lgort                    = i_new_lgort
      x_bncom                      = is_bncom
      ref_matnr                    = is_ref_batch-ref_matnr
      ref_charg                    = is_ref_batch-ref_charg
      ref_werks                    = is_ref_batch-ref_werks
      kzcla                        = i_kzcla
      xkcfc                        = i_xkcfc
      no_change_of_bwtar           = 'X'
    IMPORTING
      ymcha                        = es_mcha
    EXCEPTIONS
      no_material                  = 1
      no_batch                     = 2
      no_plant                     = 3
      material_not_found           = 4
      plant_not_found              = 5
      stoloc_not_found             = 6
      lock_on_material             = 7
      lock_on_plant                = 8
      lock_on_batch                = 9
      lock_system_error            = 10
      no_authority                 = 11
      batch_exist                  = 12
      stoloc_exist                 = 13
      illegal_batch_number         = 14
      no_batch_handling            = 15
      no_valuation_area            = 16
      valuation_type_not_found     = 17
      no_valuation_found           = 18
      error_automatic_batch_number = 19
      cancelled                    = 20
      wrong_status                 = 21
      interval_not_found           = 22
      number_range_not_extern      = 23
      object_not_found             = 24
      error_check_batch_number     = 25
      no_external_number           = 26
      no_customer_number           = 27
      no_class                     = 28
      error_in_classification      = 29
      inconsistency_in_key         = 30
      OTHERS                       = 99.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE s NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMETHOD.                    "batch_create