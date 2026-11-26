***INCLUDE MV50AF0F_FCODE_KDOK .
*---------------------------------------------------------------------*
*       FORM FCODE_KDOK                                               *
*---------------------------------------------------------------------*
*       Aufruf des Dialogbausteins zur Nachrichtenbearbeitung         *
*---------------------------------------------------------------------*
FORM FCODE_KDOK USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  DATA: DA_UPDAT.
  DATA: XXTRTYP         LIKE T185F-TRTYP,
        DA_SUBRC        LIKE SY-SUBRC,
        LV_OBJTYPE      LIKE NAST-OBJTYPE,
        LV_OBJTYPE_ITEM LIKE NAST-OBJTYPE.

* Objektkey aufbauen
  XOBJKY = LIKP-VBELN.

* Bildtext für Dialogbaustein aufbauen
  BILDTEXT    = RV50A-TXT_VBELN.
  BILDTEXT+21 = XOBJKY.
* Ermitteln des Businessobjekts aus dem Vertriebsbelegtyp
  CALL FUNCTION 'SD_OBJECT_TYPE_DETERMINE'
       EXPORTING
            I_DOCUMENT_TYPE        = LIKP-VBTYP
       IMPORTING
            E_BUSINESS_OBJECT      = LV_OBJTYPE
            E_BUSINESS_OBJECT_ITEM = LV_OBJTYPE_ITEM
       EXCEPTIONS
            OTHERS                 = 0.

  IF T180-TRTYP NE 'A'.                                     "HP_375616
*   Status aktualisieren
    PERFORM XVBUK_PFLEGEN IN PROGRAM SAPFV50K.
    VBUK = XVBUK.
*   Füllt aktuelle Workarea KOMKBV2
    IF LIKP-VBTYP CA VBTYP_LIEF.
      CALL FUNCTION 'COMMUNICATION_AREA_KOMKBV2'
           EXPORTING
                MSG_LIKP  = LIKP
                MSG_OLD   = ' '
                MSG_RV50A = RV50A
                MSG_VBUK  = VBUK
                MSG_TRTYP = T180-TRTYP
           TABLES
                TAB_PART  = PART
                TAB_LIPS  = XLIPS
                TAB_VBPA  = XVBPA.
    ENDIF.
    IF LIKP-VBTYP CA VBTYP_LIAV.
      CALL FUNCTION 'COMMUNICATION_AREA_KOMKBE1'
           EXPORTING
                MSG_LIKP  = LIKP
                MSG_OLD   = ' '
                MSG_RV50A = RV50A
                MSG_VBUK  = VBUK
                MSG_TRTYP = T180-TRTYP
           TABLES
                TAB_PART  = PART
                TAB_LIPS  = XLIPS
                TAB_VBPA  = XVBPA.
    ENDIF.
    IF LIKP-VBTYP CA VBTYP_GRWE.
      CALL FUNCTION 'COMMUNICATION_AREA_KOMKBM1'
           EXPORTING
                MSG_LIKP  = LIKP
                MSG_OLD   = ' '
                MSG_RV50A = RV50A
                MSG_VBUK  = VBUK
                MSG_TRTYP = T180-TRTYP
           TABLES
                TAB_PART  = PART
                TAB_LIPS  = XLIPS
                TAB_VBPA  = XVBPA.
    ENDIF.
    CALL FUNCTION 'MESSAGING'
         EXPORTING
              APPLIKATION = TVLK-KAPPL
              MSG_OBJKY   = XOBJKY
              SCHEMA      = TVLK-KALSM
              PI_OBJTYPE  = LV_OBJTYPE
         TABLES
              MSG_PART    = PART.
  ENDIF.

* Berechtigungsprüfungen, falls nicht gegeben nur anzeigen
  XXTRTYP = T185F-TRTYP.
  IF NOT likp-vstel IS INITIAL.                               "n_1377162
    DATA: DA_ACTVT LIKE TACT-ACTVT.                          "v_n_810689
    DA_ACTVT = '04'.
    PERFORM BERECHTIGUNG_PRUEFEN USING DA_ACTVT DA_SUBRC.    "^_n_810689
    IF DA_SUBRC NE 0.
      if da_actvt = actvt_04.                                "v_n_810689
        perform lieferung_entsperren using likp-vbeln.
        message e087 with likp-vstel.
      endif.                                                 "^_n_810689
      T185F-TRTYP = 'A'.
    ENDIF.
  ENDIF.                                                      "n_1377162
  T185F = H185F.
  T185  = H185.
  T185V = H185V.

  CALL FUNCTION 'RV_MESSAGES_MAINTENANCE'
       EXPORTING
            MIN_T185     = T185
            MIN_T185F    = T185F
            MIN_T185V    = T185V
            MIN_OBJKY    = XOBJKY
            MIN_KAPPL    = TVLK-KAPPL
            MIN_KALSM    = TVLK-KALSM
            MIN_BTEXT    = BILDTEXT
            MIN_CUA_TEXT = TVLKT-VTEXT
            PI_OBJTYPE   = LV_OBJTYPE
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
  PERFORM TRANSFORM_FCODE CHANGING T185F-FCODE.     "46A BEY
  H185F = T185F.
  H185V = T185V.
* wiederherstellen TRTYP, der ggf. wegen Berechtigung auf Anzeigen saß
  T185F-TRTYP = XXTRTYP.
  PERFORM TRANSFORM_FCODE CHANGING FCODE.   "46A BEY

ENDFORM.