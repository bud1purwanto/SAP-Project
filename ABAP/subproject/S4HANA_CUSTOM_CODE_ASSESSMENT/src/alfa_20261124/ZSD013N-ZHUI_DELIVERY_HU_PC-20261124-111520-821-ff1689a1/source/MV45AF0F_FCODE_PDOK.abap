*---------------------------------------------------------------------*
*       FORM FCODE_PDOK                                               *
*---------------------------------------------------------------------*
*       Aufruf des Dialogbausteins zur Nachrichtenbearbeitung auf     *
*       Positionsebene                                                *
*---------------------------------------------------------------------*
FORM FCODE_PDOK USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  DATA: BILDTEXT LIKE DV70A-BTEXT.
  DATA: DA_UPDAT.
  DATA: LS_TVAP LIKE TVAP.
  DATA: LS_VBAP LIKE VBAP.
  DATA: DA_POSNR LIKE VBAP-POSNR.

  DA_POSNR = VBAP-POSNR.                          " save vbap-posnr
* Objektkey aufbauen
  MOVE  VBAK-VBELN TO XOBJKY_POS.
  WRITE VBAP-POSNR TO XOBJKY_POS+10.
* Bildtext für Dialogbaustein aufbauen
  BILDTEXT    = RV45A-TXT_VBELN.
  BILDTEXT+21 = VBAK-VBELN.
  WRITE TEXT-063 TO BILDTEXT+40(20).
  WRITE VBAP-POSNR TO BILDTEXT+61(06).
* Nachrichtenfindung durchführen
  IF T185F-TRTYP NE 'A'.
* Kommunikationsblock Kopf neu aufbauen
    READ TABLE XVBKD INDEX 1.
    NA_VBKD = XVBKD.
    LS_VBAP = VBAP.
    LS_TVAP = TVAP.
    PERFORM XVBUK_UEBERSICHT_VORBEREITEN(SAPFV45K).
    CALL FUNCTION 'COMMUNICATION_AREA_KOMKBV1'
         EXPORTING
              MSG_VBAK  = VBAK
              MSG_VBKD  = NA_VBKD
              MSG_VBUK  = VBUK
              MSG_TRTYP = T180-TRTYP
         TABLES
              TAB_VBPA  = XVBPA
              TAB_VBAP  = XVBAP
              TAB_PART  = PART.
* Kommunikationsblock Position aufbauen
    VBAP = LS_VBAP.
    TVAP = LS_TVAP.
    PERFORM XVBUP_LESEN(SAPFV45P) USING VBAK-VBELN VBAP-POSNR.
    PERFORM XVBKD_LESEN(SAPFV45K) USING VBAP-POSNR.
    VBUP = XVBUP.
    CALL FUNCTION 'COMMUNICATION_AREA_KOMPBV1'
         EXPORTING
              MSG_VBAP = VBAP
              MSG_VBKD = VBKD
              MSG_VBUP = VBUP
* EHS environment
              MSG_VBAK = VBAK
         TABLES
              TAB_VBPA = XVBPA
              TAB_PART = PART.
    IF T185F-TRTYP = CHARV.
      LOOP AT XVBAP WHERE POSNR = DA_POSNR.  " looking for correct xvbap
        EXIT.
      ENDLOOP.
      IF XVBAP-UPDKZ = CHARU.
* Kommunikationsblock alt aufbauen
        PERFORM YVBAP_LESEN(SAPFV45P) USING DA_POSNR SY-TABIX.
        VBAP = YVBAP.
        PERFORM YVBKD_LESEN(SAPFV45K) USING VBAP-POSNR SY-TABIX ' '.
        IF SY-SUBRC = 0.
          VBKD = YVBKD.
        ELSE.
          VBKD-POSNR = 0.
          PERFORM YVBKD_LESEN(SAPFV45K) USING VBKD-POSNR SY-TABIX ' '.
          IF SY-SUBRC = 0.
            VBKD = YVBKD.
          ELSE.
            READ TABLE XVBKD INDEX 1.
            VBKD = XVBKD.
          ENDIF.
        ENDIF.
        YVBUP-MANDT = VBAK-MANDT.
        YVBUP-VBELN = VBAK-VBELN.
        YVBUP-POSNR = VBAP-POSNR.
        READ TABLE YVBUP.
        IF SY-SUBRC = 0.
          VBUP = YVBUP.
        ENDIF.
      ENDIF.
    ENDIF.
    CALL FUNCTION 'COMMUNICATION_AREA_KOMPBV1'
         EXPORTING
              MSG_OLD  = 'X'
              MSG_VBAP = VBAP
              MSG_VBKD = VBKD
              MSG_VBUP = VBUP
         TABLES
              TAB_VBPA = XVBPA
              TAB_PART = PART.
* Nachrichtenfindung durchführen
    CALL FUNCTION 'MESSAGING'
         EXPORTING
              APPLIKATION = TVAK-KAPPL
              MSG_OBJKY   = XOBJKY_POS
              SCHEMA      = TVAP-KALSM
              PI_ITEM     = CHARX
              PI_OBJTYPE  = BUSINESSOBJEKT_POS
         TABLES
              MSG_PART    = PART.
  ENDIF.
* Dialogbaustein zur Nachrichtenbearbeitung aufrufen.
  T185F = H185F.
  T185  = H185.
  T185V = H185V.
  CALL FUNCTION 'RV_MESSAGES_MAINTENANCE'
       EXPORTING
            MIN_T185     = T185
            MIN_T185F    = T185F
            MIN_T185V    = T185V
            MIN_OBJKY    = XOBJKY_POS
            MIN_KAPPL    = TVAK-KAPPL
            MIN_KALSM    = TVAP-KALSM
            MIN_BTEXT    = BILDTEXT
            MIN_CUA_TEXT = CUA_TEXT
            PI_OBJTYPE   = BUSINESSOBJEKT_POS
       IMPORTING
            MEX_FCODE    = FCODE
            MEX_T185F    = T185F
            MEX_T185V    = T185V
            MEX_UPDAT    = DA_UPDAT
       TABLES
            MTB_PART     = PART.
  IF DA_UPDAT NE SPACE.
    R185D-DATALOSS = CHARX.
  ENDIF.
  H185F = T185F.
  H185V = T185V.

ENDFORM.