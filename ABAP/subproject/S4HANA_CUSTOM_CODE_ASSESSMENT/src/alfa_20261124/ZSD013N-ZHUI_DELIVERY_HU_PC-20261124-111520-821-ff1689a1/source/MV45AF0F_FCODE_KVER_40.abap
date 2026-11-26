*---------------------------------------------------------------------*
*       FORM FCODE_KVER_40                                            *
*---------------------------------------------------------------------*
*       Bearbeitung der Vertragsdaten auf Kopfebene.                  *
*---------------------------------------------------------------------*
FORM FCODE_KVER_40 USING H185F STRUCTURE T185F H185  STRUCTURE T185
                                            H185V STRUCTURE T185V.
*
  DATA: DA_VBELN      LIKE VEDA-VBELN.
  DATA: DA_VPOSN      LIKE VEDA-VPOSN.
  DATA: DA_TITEL(20)  TYPE C.
  DATA: DA_DATALOSS   LIKE R185D-DATALOSS.
  DATA: DA_DIALOG(1)  TYPE C VALUE 'X'.
  DATA: DA_FEHLER(1)  TYPE C.

  T185 = H185.
  T185F = H185F.
  T185V = H185V.

* Sicherstellen, daß Bildgruppenwechsel erkannt werden (TAXI)
  PERFORM CUA_SETZEN.
  PERFORM TAXI_INITIALIZE_CARRIERSCREEN.

* Fehlerprotokoll.
  CLEAR DA_FEHLER.
  IF FEHLER = 'X'.
    DA_FEHLER = CHARX.
  ENDIF.

  PERFORM VBAK_BEARBEITEN_VORBEREITEN(SAPFV45K).

  DA_VBELN = VBAK-VBELN.
  DA_VPOSN = POSNR_LOW.
  CONDENSE DA_TITEL.

  TAXI_PROGRAM          = T185V-CPROG.
  TAXI_HEADER_SUBSCREEN = T185V-DYBS1.
  TAXI_GUI_PROGRAM      = T185V-AGIDV.
  TAXI_GUI_STATUS       = T185V-STATUS.
  TAXI_GUI_TITLE        = T185V-CTITEL.
  TAXI_GUI_TITLE_PARAM  = RV02P-TITLE.
  CONDENSE TAXI_GUI_TITLE_PARAM.

  CALL FUNCTION 'SD_VEDA_DIALOG'
       EXPORTING
            I_DOCUMENT_NUMBER   = DA_VBELN
            I_FEHLERFELD        = FEHLERFELD
            I_FEHLERPROTOKOLL   = DA_FEHLER
            I_POSITION_NUMBER   = DA_VPOSN
            I_POSNR_LOW         = VEDA_POSNR_LOW
            I_FEHGR             = TVAK-FEHGR
            I_DIALOG_INCOMPLETE = CHARX
            I_T185F             = T185F
            I_T185              = T185
            I_T185V             = T185V
            I_TITEL             = DA_TITEL
            I_PROFILE           = TVAK-VPROF
            I_R185D             = R185D
            I_VBAK              = VBAK
            I_TVAK              = TVAK
            I_TAXI_TABSTRIP_CAPTIONS = TAXI_TABSTRIP_CAPTIONS
            I_TAXI_PROGRAM           = TAXI_PROGRAM
            I_TAXI_HEADER_SUBSCREEN  = TAXI_HEADER_SUBSCREEN
            I_TAXI_GUI_PROGRAM       = TAXI_GUI_PROGRAM
            I_TAXI_GUI_STATUS        = TAXI_GUI_STATUS
            I_TAXI_GUI_TITLE         = TAXI_GUI_TITLE
            I_TAXI_GUI_TITLE_PARAM   = TAXI_GUI_TITLE_PARAM

       IMPORTING
            E_DATALOSS          = DA_DATALOSS
            E_T185              = T185
            E_T185F             = T185F
       TABLES
            T_XVBUV             = XVBUV
            T_HVBUV             = HVBUV
       CHANGING
            C_TAXI_TABSTRIP     = TAXI_TABSTRIP_HEAD.

IF SY-SUBRC <> 0.
  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

  CALL FUNCTION 'TAXI_CONVERT_FCODE'
       EXPORTING
            FCODE_IN        = T185F-FCODE
       IMPORTING
            FCODE_OUT       = T185F-FCODE
       EXCEPTIONS
            FCODE_NOT_FOUND = 1
            OTHERS          = 2.

  IF NOT DA_DATALOSS IS INITIAL.
    R185D-DATALOSS = CHARX.
    PERFORM VBAK_UPDATE_FROM_VEDA(SAPFV45K).
*   Unvollständigkeit aktualisieren
    PERFORM VEDA_CHECK_ITEM_COMPLETENESS.
*   Kopffakturierungsplan aktualisieren
    PERFORM FPLAN_KOPF_AKTUALISIEREN_CALL USING SPACE.
*   Fakturierungsplan aktualisieren
    PERFORM FPLAN_AKTUALISIEREN USING POSNR_FIRST POSNR_HIGH SPACE.
  ENDIF.
  H185  = T185.
  H185F = T185F.
  FCODE = T185F-FCODE.

ENDFORM.