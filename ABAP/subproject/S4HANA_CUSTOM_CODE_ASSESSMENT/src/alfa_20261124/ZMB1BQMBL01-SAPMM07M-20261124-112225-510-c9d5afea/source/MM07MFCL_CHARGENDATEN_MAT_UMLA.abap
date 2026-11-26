*eject
*----------------------------------------------------------------------*
*       Form  CHARGENDATEN_MAT_UMLAGERUNG
*----------------------------------------------------------------------*
*       1) Das abgebende Material ist bereits gelesen
*       2) Die empfangende Charge ist neu
*       3) Das Material ist chargenpflichtig
*----------------------------------------------------------------------*
FORM chargendaten_mat_umlagerung USING loc_ummat
                                       loc_umwrk
                                       loc_umcha.

  CHECK NOT mbefu-xchpf IS INITIAL.

ENHANCEMENT-POINT CHARGENDATEN_MAT_UMLAGERUNG_01 SPOTS ES_SAPMM07M STATIC.
* Originalchargen lesen
  IF kzdch EQ charge_auf_werk.
    CHECK NOT xmtcor-rmcha IS INITIAL.
    xmcha_key-matnr = loc_ummat.
    xmcha_key-werks = loc_umwrk.
    xmcha_key-charg = loc_umcha.
    READ TABLE xmcha WITH KEY xmcha_key BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING xmcha TO omcha.
    ELSE.
      IF vm07m-xchpf IS INITIAL.
        CLEAR omcha.
      ELSE.
        CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
          EXPORTING
            matnr            = mseg-matnr
            charg            = mseg-charg
            werks            = mseg-werks
            read_from_buffer = x
            read_from_db     = x
          IMPORTING
            batch_buffer     = omcha
          EXCEPTIONS
            no_material      = 1
            no_batch         = 2
            no_plant         = 3
            lock_on_batch    = 4
            OTHERS           = 5.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        CLEAR omcha-bwtar.

*------ Kennzeichen daß akt. Charge aus Referenzcharge kopiert ***
        dm07m-xrefc = 'X'.
      ENDIF.
    ENDIF.
    CLEAR xmbcfc003.
    MOVE-CORRESPONDING omcha TO xmbcfc003.
  ELSE.
    CHECK NOT xmtcor-rmch1 IS INITIAL.
    xmch1_key-matnr = loc_ummat.
    xmch1_key-charg = loc_umcha.
    READ TABLE xmch1 WITH KEY xmch1_key BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING xmch1 TO omch1.
    ELSE.
      IF vm07m-xchpf IS INITIAL.
        CLEAR omch1.
      ELSE.
        CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
          EXPORTING
            matnr            = mseg-matnr
            charg            = mseg-charg
            read_from_buffer = x
            read_from_db     = x
          IMPORTING
             mch1_buffer     = omch1
          EXCEPTIONS
            no_material      = 1
            no_batch         = 2
            no_plant         = 3
            lock_on_batch    = 4
            OTHERS           = 5.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

*------ Kennzeichen daß akt. Charge aus Referenzcharge kopiert ***
        dm07m-xrefc = 'X'.
      ENDIF.
    ENDIF.
    CLEAR xmbcfc003.
    MOVE-CORRESPONDING omch1 TO xmbcfc003.
  ENDIF.

*------ Set last goods receipt date based on posting date
  xmbcfc003-lwedt = mkpf-budat.

ENHANCEMENT-POINT CHARGENDATEN_MAT_UMLAGERUNG_05 SPOTS ES_SAPMM07M STATIC.

ENHANCEMENT-POINT CHARGENDATEN_MAT_UMLAGERUNG_04 SPOTS ES_SAPMM07M.
* Aufruf das Customer Function Call
  CALL CUSTOMER-FUNCTION '003'
     EXPORTING
          i_matnr = loc_ummat
          i_charg = loc_umcha
          i_mseg  = mseg
          i_vm07m = vm07m
          i_dm07m = dm07m
          i_mkpf  = mkpf
     CHANGING
          batch_master_data = xmbcfc003.

* Setzen der relevanten Daten für die Bestandsführung
  mbefu-lifch = xmbcfc003-lifnr.
  mbefu-licha = xmbcfc003-licha.
  mbefu-lwedt = xmbcfc003-lwedt.
  mbefu-vfdat = xmbcfc003-vfdat.
  mbefu-hsdat = xmbcfc003-hsdat.
  mbefu-qndat = xmbcfc003-qndat.
  mbefu-verab = xmbcfc003-verab.
  IF dm07m-hsdat_input IS INITIAL.
    dm07m-hsdat_input = xmbcfc003-hsdat.
  ENDIF.
  IF dm07m-vfdat_input IS INITIAL.
    dm07m-vfdat_input = xmbcfc003-vfdat.
  ENDIF.

* Anpassung des Zustandes aus QM
  IF dm07m-qm_umzst EQ '0'.
    mbefu-zustd = x.
  ELSEIF dm07m-qm_umzst EQ '1'.
    mbefu-zustd = space.
  ENDIF.

* Übertragen der Originaldaten in die Sperrtabelle
  DATA: loc_mcha LIKE mcha.
  DATA: loc_mch1 LIKE mch1.
  DATA: loc_xrc  LIKE sy-subrc.
  loc_mcha-mandt = loc_mch1-mandt = sy-mandt.
  loc_mcha-matnr = loc_mch1-matnr = loc_ummat.
  loc_mcha-charg = loc_mch1-charg = loc_umcha.
  loc_mcha-werks = loc_umwrk.
  IF kzdch EQ charge_auf_werk.
    MOVE-CORRESPONDING xmbcfc003 TO loc_mcha.
ENHANCEMENT-POINT CHARGENDATEN_MAT_UMLAGERUNG_02 SPOTS ES_SAPMM07M.
    loc_mcha-zustd = mbefu-zustd.
    loc_mcha-bwtar = mbefu-bwtar.
    IF dm07m-xrefc IS INITIAL.
      loc_mcha-cuobj_bm = omcha-cuobj_bm.
    ENDIF.
    CALL FUNCTION 'MB_FILL_MCHA_ENQUEUE_TABLE'
      EXPORTING
        mbefu = mbefu
        rmcha = x
        xdbup = x
        kzdch = kzdch
        lmcha = loc_mcha
      IMPORTING
        xrc   = loc_xrc
      TABLES
        xmcha = xmcha.

*-- Falls Charge bereits in Sperrtabelle, muss Puffer angepasst werden.
*   Anpassung der Sperrtabelle geschieht in Sperrtabellen-Update
    IF loc_xrc IS INITIAL.
      CALL FUNCTION 'VB_BATCH_WRITE_BUFFER'
        CHANGING
          new_batch_buffer_mcha = loc_mcha
        EXCEPTIONS
          OTHERS                = 4.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

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
    loc_mch1-zustd = mbefu-zustd.
    IF dm07m-xrefc IS INITIAL.
      loc_mch1-cuobj_bm = omch1-cuobj_bm.
    ENDIF.
ENHANCEMENT-POINT CHARGENDATEN_MAT_UMLAGERUNG_03 SPOTS ES_SAPMM07M.
    CALL FUNCTION 'MB_FILL_MCH1_ENQUEUE_TABLE'
      EXPORTING
        mbefu = mbefu
        rmch1 = x
        xdbup = x
        kzdch = kzdch
        lmch1 = loc_mch1
      IMPORTING
        xrc   = loc_xrc
      TABLES
        xmch1 = xmch1.

*-- Falls Charge bereits in Sperrtabelle, muss Puffer angepasst werden.
*   Anpassung der Sperrtabelle geschieht in Sperrtabellen-Update
    IF loc_xrc IS INITIAL.
      CALL FUNCTION 'VB_BATCH_WRITE_BUFFER'
        CHANGING
          new_batch_buffer_mch1 = loc_mch1
        EXCEPTIONS
          OTHERS                = 4.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "CHARGENDATEN_MAT_UMLAGERUNG