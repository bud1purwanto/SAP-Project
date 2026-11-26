***INCLUDE MV50AF0F_FCODE_KKOM .
*---------------------------------------------------------------------*
*       FORM FCODE_KKOM                                               *
*---------------------------------------------------------------------*
*       Aufruf des Dialogbausteins zur Nachrichtenbearbeitung         *
*       für die Kommilisten im Anzeigemodus                           *
*---------------------------------------------------------------------*
FORM FCODE_KKOM USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  DATA: DA_UPDAT.
  DATA: XXTRTYP LIKE T185F-TRTYP,
        XXPANEL LIKE T185-PANEL,
        DA_SUBRC LIKE SY-SUBRC,
        LV_OBJTYPE      LIKE NAST-OBJTYPE,
        LV_OBJTYPE_ITEM LIKE NAST-OBJTYPE.

* Bildtext für Dialogbaustein aufbauen
  BILDTEXT    = RV50A-TXT_VBELN.
  BILDTEXT+21 = XOBJKY.
  T185F = H185F.
  T185  = H185.
  T185V = H185V.
  XXTRTYP = T185F-TRTYP.
  XXPANEL = T185-PANEL.
  T185F-TRTYP = 'A'.
  T185-PANEL = 'NUEB'.
  XOBJKY_TO = XOBJKY.
* Ermitteln des Businessobjekts aus dem Vertriebsbelegtyp
  CALL FUNCTION 'SD_OBJECT_TYPE_DETERMINE'
       EXPORTING
            I_DOCUMENT_TYPE        = LIKP-VBTYP
       IMPORTING
            E_BUSINESS_OBJECT      = LV_OBJTYPE
            E_BUSINESS_OBJECT_ITEM = LV_OBJTYPE_ITEM
       EXCEPTIONS
            OTHERS                 = 0.

  CALL FUNCTION 'RV_MESSAGES_MAINTENANCE'
       EXPORTING
            MIN_T185     = T185
            MIN_T185F    = T185F
            MIN_T185V    = T185V
            MIN_OBJKY    = XOBJKY
            MIN_KAPPL    = 'V4'
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
  H185F = T185F.
  H185V = T185V.
* wiederherstellen TRTYP, PANEL
  T185F-TRTYP = XXTRTYP.
  T185-PANEL  = XXPANEL.

ENDFORM.