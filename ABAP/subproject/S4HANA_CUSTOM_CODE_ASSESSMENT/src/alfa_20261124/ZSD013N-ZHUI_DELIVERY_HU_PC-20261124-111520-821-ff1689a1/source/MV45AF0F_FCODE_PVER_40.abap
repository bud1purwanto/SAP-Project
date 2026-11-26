*---------------------------------------------------------------------*
*       FORM FCODE_PVER_40                                            *
*---------------------------------------------------------------------*
*       Bearbeitung der Vertragsdaten auf Positionsebene.             *
*---------------------------------------------------------------------*
FORM FCODE_PVER_40 USING H185F STRUCTURE T185F H185  STRUCTURE T185
                                            H185V STRUCTURE T185V.

  DATA: DA_VBELN       LIKE VEDA-VBELN.
  DATA: DA_VPOSN       LIKE VEDA-VPOSN.
  DATA: DA_TITEL(20)   TYPE C VALUE ''.
  DATA: DA_DATALOSS    LIKE R185D-DATALOSS.
  DATA: DA_FEHLER(1)   TYPE C.

  T185 = H185.
  T185F = H185F.
  T185V = H185V.

* Sicherstellen, daß Bildgruppenwechsel erkannt werden (TAXI)
  PERFORM CUA_SETZEN.
  PERFORM TAXI_INITIALIZE_CARRIERSCREEN.

* Fehlerprotokoll ?
  CLEAR DA_FEHLER.
  IF FEHLER = 'X'.
    DA_FEHLER = CHARX.
    T185V-PANEL = 'PVER'.
  ENDIF.

  PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).

  MOVE VBAK-VBELN TO DA_VBELN.
  MOVE VBAP-POSNR TO DA_VPOSN.
  MOVE POSNR_LOW TO VEDA_POSNR_LOW.

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
            I_T185F             = T185F
            I_T185              = T185
            I_T185V             = T185V
            I_TITEL             = DA_TITEL
            I_PROFILE           = TVAK-VPROF
            I_FEHGR             = TVAP-FEHGR
            I_DIALOG_INCOMPLETE = CHARX
            I_R185D             = R185D
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
            E_VEDA              = VEDA
       TABLES
            T_XVBUV             = XVBUV
            T_HVBUV             = HVBUV
       CHANGING
            C_TAXI_TABSTRIP     = TAXI_TABSTRIP_ITEM.

  CALL FUNCTION 'TAXI_CONVERT_FCODE'
       EXPORTING
            FCODE_IN        = T185F-FCODE
       IMPORTING
            FCODE_OUT       = T185F-FCODE
       EXCEPTIONS
            FCODE_NOT_FOUND = 1
            OTHERS          = 2.

  IF DA_DATALOSS NE SPACE.
    R185D-DATALOSS = CHARX.
    PERFORM VBAP_FUELLEN(SAPFV45P).
    PERFORM VBAP_BEARBEITEN(SAPFV45P).
*   Status bei Vertragsdatenänderung neu ermitteln
    VBAP_ENDE_BEARBEITUNG = CHARX.
    PERFORM VBAP_BEARBEITEN_ENDE(SAPFV45P).

*   Aktualisieren Fakturierungsplan
    MOVE VEDA TO XVEDA.
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
    PERFORM FPLAN_AKTUALISIEREN USING VBAP-POSNR VBAP-POSNR SPACE.
  ENDIF.

  H185  = T185.
  H185F = T185F.
  FCODE = T185F-FCODE.

ENDFORM.