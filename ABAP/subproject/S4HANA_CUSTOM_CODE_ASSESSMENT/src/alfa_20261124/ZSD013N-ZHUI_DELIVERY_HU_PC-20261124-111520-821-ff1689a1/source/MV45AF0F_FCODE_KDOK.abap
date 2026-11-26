*---------------------------------------------------------------------*
*       FORM FCODE_KDOK                                               *
*---------------------------------------------------------------------*
*       Aufruf des Dialogbausteins zur Nachrichtenbearbeitung         *
*---------------------------------------------------------------------*
FORM FCODE_KDOK USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  DATA: BILDTEXT LIKE DV70A-BTEXT.
  DATA: DA_UPDAT.

* Bildtext für Dialogbaustein aufbauen
  BILDTEXT    = RV45A-TXT_VBELN.
  BILDTEXT+21 = VBAK-VBELN.
* Nachrichtenfindung durchführen
  DATA: BEGIN OF VBKD_KEY,
          MANDT LIKE VBKD-MANDT,
          VBELN LIKE VBKD-VBELN,
          POSNR LIKE VBKD-POSNR,
        END   OF VBKD_KEY.

* Get data of objectkey for output
  MOVE VBAK-VBELN TO XOBJKY.

  IF T185F-TRTYP NE 'A'.
    VBKD_KEY-MANDT = SY-MANDT.
    VBKD_KEY-VBELN = VBAK-VBELN.
    VBKD_KEY-POSNR = 0.
    READ TABLE XVBKD WITH KEY VBKD_KEY.
    NA_VBKD = XVBKD.
* Kopfstatus ermitteln
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

    CALL FUNCTION 'MESSAGING'
         EXPORTING
              APPLIKATION = TVAK-KAPPL
              MSG_OBJKY   = XOBJKY
              SCHEMA      = TVAK-KALSM
              PI_OBJTYPE  = BUSINESSOBJEKT
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
            MIN_OBJKY    = XOBJKY
            MIN_KAPPL    = TVAK-KAPPL
            MIN_KALSM    = TVAK-KALSM
            MIN_BTEXT    = BILDTEXT
            MIN_CUA_TEXT = CUA_TEXT
            PI_OBJTYPE   = BUSINESSOBJEKT
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