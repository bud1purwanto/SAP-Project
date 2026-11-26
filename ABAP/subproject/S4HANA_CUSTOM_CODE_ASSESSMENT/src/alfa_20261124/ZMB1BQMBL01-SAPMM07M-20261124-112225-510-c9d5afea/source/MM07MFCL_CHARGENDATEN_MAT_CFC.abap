*eject
*----------------------------------------------------------------------*
*       Form  CHARGENDATEN_MAT_CFC
*----------------------------------------------------------------------*
*       1) Die Charge ist neu
*       3) Das Material ist chargenpflichtig
*----------------------------------------------------------------------*
FORM chargendaten_mat_cfc.

  DATA:
    ls_mcha             LIKE mcha,
    lv_subrc            LIKE sy-subrc,
    loc_mcha            LIKE mcha,
    loc_mch1            LIKE mch1.

  CHECK NOT mbefu-xchpf IS INITIAL.
  CLEAR xmbcfc003.
  IF kzdch EQ charge_auf_werk.
    CHECK NOT xmtcor-rmcha IS INITIAL.
    CLEAR omcha.
    omcha-mandt = sy-mandt.
    xmcha_key-matnr = mseg-matnr.
    xmcha_key-werks = mseg-werks.
    xmcha_key-charg = mseg-charg.
    READ TABLE xmcha WITH KEY xmcha_key BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      PERFORM charge_sperrtab USING vm07m-lifch
                                    vm07m-licha
                                    vm07m-lwedt
                                    mseg-vfdat
                                    mseg-hsdat
                                    vm07m-qndat
                           CHANGING xmcha-lifnr
                                    xmcha-licha
                                    xmcha-lwedt
                                    xmcha-vfdat
                                    xmcha-hsdat
                                    xmcha-qndat.
      IF mseg-sobkz = 'K' AND mseg-kzbew IS INITIAL AND      "1695572
         vm07m-lifch IS NOT INITIAL AND                      "1695572
         vm07m-lifch <> xmcha-lifnr.                         "1695572
        xmcha-lifnr = vm07m-lifch.                           "1695572
        MODIFY xmcha index sy-tabix.                         "1695572
      ENDIF.                                                 "1695572
      MOVE-CORRESPONDING xmcha TO omcha.
      MOVE-CORRESPONDING omcha TO xmbcfc003.
    ELSE.
      CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
        EXPORTING
          matnr            = mseg-matnr
          charg            = mseg-charg
          werks            = mseg-werks
          read_from_buffer = x
        IMPORTING
          batch_buffer     = ls_mcha
          rc_batch_buffer  = lv_subrc.
      IF lv_subrc IS INITIAL.
        MOVE-CORRESPONDING ls_mcha TO omcha.
      ENDIF.
      IF mseg-umcha IS INITIAL.
        MOVE-CORRESPONDING mseg  TO omcha.
        MOVE-CORRESPONDING vm07m TO omcha.
        MOVE-CORRESPONDING dm07m TO omcha.
        MOVE vm07m-lifch         TO omcha-lifnr.
      ELSE.
        IF mseg-ummat IS INITIAL.
          mseg-ummat = mseg-matnr.
        ENDIF.
        IF mseg-umwrk IS INITIAL.
          mseg-umwrk = mseg-werks.
        ENDIF.
        PERFORM charge_original_mcha USING mseg-ummat
                                           mseg-umwrk
                                           mseg-umcha.
        IF sy-subrc IS INITIAL.
          CLEAR omcha-bwtar.
*-------- Kennzeichen daß akt. Charge aus Referenzcharge kopiert wurde
          dm07m-xrefc = 'X'.
        ELSE.
          MOVE-CORRESPONDING mseg  TO omcha.
          MOVE-CORRESPONDING vm07m TO omcha.
          MOVE-CORRESPONDING dm07m TO omcha.
          MOVE vm07m-lifch         TO omcha-lifnr.
        ENDIF.
      ENDIF.
      MOVE-CORRESPONDING omcha TO xmbcfc003.
    ENDIF.
  ELSE.
    CHECK NOT xmtcor-rmch1 IS INITIAL.
    CLEAR omch1.
    omch1-mandt = sy-mandt.
    xmch1_key-matnr = mseg-matnr.
    xmch1_key-charg = mseg-charg.
    READ TABLE xmch1 WITH KEY xmch1_key BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      PERFORM charge_sperrtab USING vm07m-lifch
                                    vm07m-licha
                                    vm07m-lwedt
                                    mseg-vfdat
                                    mseg-hsdat
                                    vm07m-qndat
                           CHANGING xmch1-lifnr
                                    xmch1-licha
                                    xmch1-lwedt
                                    xmch1-vfdat
                                    xmch1-hsdat
                                    xmch1-qndat.
      IF mseg-sobkz = 'K' AND mseg-kzbew IS INITIAL AND      "1695572
         vm07m-lifch IS NOT INITIAL AND                      "1695572
         vm07m-lifch <> xmch1-lifnr.                         "1695572
        xmch1-lifnr = vm07m-lifch.                           "1695572
        MODIFY xmch1 index sy-tabix.                         "1695572
      ENDIF.                                                 "1695572
      MOVE-CORRESPONDING xmch1 TO omch1.
      MOVE-CORRESPONDING omch1 TO xmbcfc003.
    ELSE.
      CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
        EXPORTING
          matnr            = mseg-matnr
          charg            = mseg-charg
          read_from_buffer = x
        IMPORTING
          batch_buffer     = ls_mcha
          rc_batch_buffer  = lv_subrc.
      IF lv_subrc IS INITIAL.
        MOVE-CORRESPONDING ls_mcha TO omch1.
      ENDIF.
      IF mseg-umcha IS INITIAL.
        MOVE-CORRESPONDING mseg  TO omch1.
        MOVE-CORRESPONDING vm07m TO omch1.
        MOVE-CORRESPONDING dm07m TO omch1.
        MOVE vm07m-lifch         TO omch1-lifnr.
      ELSE.
        IF mseg-ummat IS INITIAL.
          mseg-ummat = mseg-matnr.
        ENDIF.
        PERFORM charge_original_mch1 USING mseg-ummat
                                           mseg-umcha.
        IF NOT sy-subrc IS INITIAL.
          MOVE-CORRESPONDING mseg  TO omch1.
          MOVE-CORRESPONDING vm07m TO omch1.
          MOVE-CORRESPONDING dm07m TO omch1.
          MOVE vm07m-lifch         TO omch1-lifnr.
        ELSE.
*-------- Kennzeichen daß akt. Charge aus Referenzcharge kopiert wurde
          dm07m-xrefc = 'X'.
        ENDIF.
      ENDIF.
      MOVE-CORRESPONDING omch1 TO xmbcfc003.
    ENDIF.
  ENDIF.

* Chargenzustandsschlüssel aus VB_BATCH_DEFAULT_STATUS
  xmbcfc003-zusch = mbefu-zusch.

* Aufruf das Customer Function Call
ENHANCEMENT-POINT chargendaten_mat_cfc_04 SPOTS es_sapmm07m STATIC.
ENHANCEMENT-POINT chargendaten_mat_cfc_03 SPOTS es_sapmm07m.
  CALL CUSTOMER-FUNCTION '003'
     EXPORTING
          i_matnr = mseg-matnr
          i_charg = mseg-charg
          i_werks = mseg-werks
          i_mseg  = mseg
          i_vm07m = vm07m
          i_dm07m = dm07m
          i_mkpf  = mkpf
     CHANGING
          batch_master_data = xmbcfc003.
  MOVE xmbcfc003-lifnr TO vm07m-lifch.
  MOVE xmbcfc003-licha TO vm07m-licha.
  MOVE xmbcfc003-lwedt TO vm07m-lwedt.
  MOVE xmbcfc003-vfdat TO mseg-vfdat.
  MOVE xmbcfc003-hsdat TO mseg-hsdat.
  MOVE xmbcfc003-qndat TO vm07m-qndat.
  IF dm07m-hsdat_input IS INITIAL.
    dm07m-hsdat_input = xmbcfc003-hsdat.
  ENDIF.
  IF dm07m-vfdat_input IS INITIAL.
    dm07m-vfdat_input = xmbcfc003-vfdat.
  ENDIF.

* Anpassung des Zustandes aus QM
  IF dm07m-qm_zustd EQ '0'.
    mbefu-zustd = x.
  ELSEIF dm07m-qm_umzst EQ '1'.
    mbefu-zustd = space.

* Chargenzustand wurde zuvor bei Neuanlage der Charge bestimmt
  ELSE.
    CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
      EXPORTING
        matnr            = mseg-matnr
        charg            = mseg-charg
        werks            = mseg-werks
        read_from_buffer = x
      IMPORTING
        batch_buffer     = ls_mcha
        rc_batch_buffer  = lv_subrc.
    IF lv_subrc IS INITIAL.
      mbefu-zustd = ls_mcha-zustd.
    ENDIF.
  ENDIF.

* Übertragen der Stammdaten in die Sperrtabelle
  loc_mcha-mandt = loc_mch1-mandt = sy-mandt.
  loc_mcha-matnr = loc_mch1-matnr = mseg-matnr.
  loc_mcha-charg = loc_mch1-charg = mseg-charg.
  loc_mcha-werks = mseg-werks.
  IF kzdch EQ charge_auf_werk.
    MOVE-CORRESPONDING xmbcfc003 TO loc_mcha.
    loc_mcha-batch_type = vm07m-batch_type.
ENHANCEMENT-POINT chargendaten_mat_cfc_01 SPOTS es_sapmm07m.
    loc_mcha-zustd = mbefu-zustd.
    loc_mcha-bwtar = mbefu-bwtar.
    IF dm07m-xrefc IS INITIAL.
      loc_mcha-cuobj_bm = omcha-cuobj_bm.
    ENDIF.
    CALL FUNCTION 'VB_BATCH_WRITE_BUFFER'
      EXPORTING
        mcha_new              = x
      CHANGING
        new_batch_buffer_mcha = loc_mcha
      EXCEPTIONS
        OTHERS                = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    CALL FUNCTION 'MB_FILL_MCHA_ENQUEUE_TABLE'
      EXPORTING
        mbefu = mbefu
        rmcha = x
        xdbup = x
        kzdch = kzdch
        lmcha = loc_mcha
      TABLES
        xmcha = xmcha.

*-- Charge auf MCH1-Segment immer notwendig
    CALL FUNCTION 'MB_FILL_MCH1_ENQUEUE_TABLE'
      EXPORTING
        mbefu = mbefu
        rmch1 = x
        xdbup = x
        kzdch = kzdch
      TABLES
        xmch1 = xmch1.

  ELSE.
    MOVE-CORRESPONDING xmbcfc003 TO loc_mch1.
    loc_mch1-batch_type = vm07m-batch_type.
ENHANCEMENT-POINT chargendaten_mat_cfc_02 SPOTS es_sapmm07m.
    loc_mch1-zustd = mbefu-zustd.
    IF dm07m-xrefc IS INITIAL.
      loc_mch1-cuobj_bm = omch1-cuobj_bm.
    ENDIF.
    CALL FUNCTION 'VB_BATCH_WRITE_BUFFER'
      EXPORTING
        mch1_new              = x
      CHANGING
        new_batch_buffer_mch1 = loc_mch1
      EXCEPTIONS
        OTHERS                = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    CALL FUNCTION 'MB_FILL_MCH1_ENQUEUE_TABLE'
      EXPORTING
        mbefu = mbefu
        rmch1 = x
        xdbup = x
        kzdch = kzdch
        lmch1 = loc_mch1
      TABLES
        xmch1 = xmch1.

  ENDIF.

*-- batch derivation
  PERFORM batch_derivation(sapfm07m)
    TABLES   xmcha
             xmch1
    USING    mseg-matnr
             mseg-werks
             mseg-charg
             xmbwl
             kzdch
             mseg
             vm07m
             dm07m
             mkpf
   CHANGING  mbefu-zustd                   "1659494
             mbefu-zusch.                  "1659494

ENDFORM.                    "chargendaten_mat_cfc