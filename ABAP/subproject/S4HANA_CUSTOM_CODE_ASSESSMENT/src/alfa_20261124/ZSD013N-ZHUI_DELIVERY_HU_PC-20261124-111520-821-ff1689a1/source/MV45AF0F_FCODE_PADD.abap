*eject
*&---------------------------------------------------------------------*
*&      Form  FCODE_PADD
*&---------------------------------------------------------------------*
FORM FCODE_PADD USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

* Die folgenden Aufrufe sind nötig für den direkten Aufruf. Sie werden
* normalerweise im PBO ausgeführt. Es wird der Bildgruppenwechsel
* (falls erfolgt) festgestellt, die Reiterleiste aufgebaut, der FCode
* gespeichert, der zu diesem Bild geführt hat und der aktive Reiter
* nach vorne geholt.
  PERFORM CUA_SETZEN.
  PERFORM TAXI_INITIALIZE_CARRIERSCREEN.

  PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).

* Parameter für Trägerdynpro belegen.
  IF FEHLER = CHARX.
    TAXI_GUI_STATUS = 'FS_EXT'.
  ELSE.
    TAXI_GUI_STATUS = T185V-STATUS.
  ENDIF.
  TAXI_GUI_PROGRAM             = T185V-AGIDV.
  TAXI_GUI_TITLE               = T185V-CTITEL.
  TAXI_PROGRAM                 = T185V-CPROG.
  TAXI_HEADER_SUBSCREEN        = T185V-DYBS1.
  TAXI_BODY_SUBSCREEN          = T185V-DYBS2.
* Tabstrip-Kontrollstruktur für Tabstrip der Positionsbilder
  TAXI_TABSTRIP                = TAXI_TABSTRIP_ITEM.
* Wegen Rollbereichswechsel bei Call Dialog müssen zunächst die
* Felder des HeaderSubscreens zur späteren Rückübernahme in
* ABAP-Memory geschrieben werden.
  PERFORM TAXI_SET_ITEM_HEADER.

* evt. Kopfzeilen füllen
  IF XVBUP-POSNR NE XVBAP-POSNR.
    PERFORM XVBUP_LESEN(SAPFV45P) USING XVBAP-VBELN
                                        XVBAP-POSNR.
  ENDIF.

  CALL FUNCTION 'WTAD_ADDIS_IN_SO_DIALOG'
       EXPORTING
            FI_VBAK                  = VBAK
            FI_XVBAP                 = XVBAP
            FI_VBUK                  = VBUK
            FI_XVBUP                 = XVBUP
            FI_XVBKD                 = XVBKD
            T185_I                   = T185
            T185F_I                  = T185F
            T185V_I                  = T185V
*           FPTYP_I                  = ' '
            TAXI_TABSTRIP_CAPTIONS_I = TAXI_TABSTRIP_CAPTIONS
*           taxi_tabstrip_i          = taxi_tabstrip
            TAXI_PROGRAM_I           = TAXI_PROGRAM
            TAXI_HEADER_SUBSCREEN_I  = TAXI_HEADER_SUBSCREEN
            TAXI_GUI_PROGRAM_I       = TAXI_GUI_PROGRAM
            TAXI_GUI_STATUS_I        = TAXI_GUI_STATUS
            TAXI_GUI_TITLE_I         = TAXI_GUI_TITLE
       IMPORTING
            T185_E                   = T185
            T185F_E                  = T185F
       TABLES
            FIT_XVBEP                = XVBEP
       CHANGING
            TAXI_TABSTRIP_C          = TAXI_TABSTRIP_ITEM.


  CALL FUNCTION 'WTAD_ADDIS_IN_SO_POSNR_CHECK'
       EXPORTING
            FI_VBAK     = VBAK
            FI_POSNR    = XVBAP-POSNR
       CHANGING
            FE_ADDI_CHK = VBAPD-ADDIT_EXIST.

  PERFORM XVBAP_AENDERN(SAPFV45P).

  CALL FUNCTION 'TAXI_CONVERT_FCODE'
       EXPORTING
            FCODE_IN        = T185F-FCODE
       IMPORTING
            FCODE_OUT       = T185F-FCODE
       EXCEPTIONS
            FCODE_NOT_FOUND = 1
            OTHERS          = 2.

  H185  = T185.
  H185F = T185F.
  H185V = T185V.
  FCODE = T185F-FCODE.

ENDFORM.                               " FCODE_PADD