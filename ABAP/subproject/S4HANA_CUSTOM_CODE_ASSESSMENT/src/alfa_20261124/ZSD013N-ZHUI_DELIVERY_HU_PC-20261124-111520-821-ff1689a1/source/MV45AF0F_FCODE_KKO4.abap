*&---------------------------------------------------------------------*
*&      Form  FCODE_KKO4
*&---------------------------------------------------------------------*
*       Kopie von FCODE_KKON mit TAXI-Navigation
*----------------------------------------------------------------------*
FORM FCODE_KKO4 USING H185F STRUCTURE T185F H185  STRUCTURE T185
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

  PERFORM PREISFINDUNG_GESAMT USING CHARA.

  PERFORM PREISFINDUNG_VORBEREITEN(SAPFV45P) USING 'K'.

* Bildtext für Dialogbaustein aufbauen
  DATA: BILDTEXT(40) TYPE C.
*  bildtext    = tvakt-bezei.
* Der ausführliche Belegbezeichner wird in CUA_SETZEN gesetzt und in
* rv02p-title gespeichert.

  BILDTEXT = RV02P-TITLE.
  CONDENSE BILDTEXT.

  TAXI_PROGRAM                 = T185V-CPROG.
  TAXI_HEADER_SUBSCREEN        = T185V-DYBS1.
  TAXI_GUI_PROGRAM             = T185V-AGIDV.
  TAXI_GUI_STATUS              = T185V-STATUS.
  TAXI_GUI_TITLE               = T185V-CTITEL.
* Wegen Rollbereichswechsel bei Call Dialog müssen zunächst die
* Felder des HeaderSubscreens zur späteren Rückübernahme in
* ABAP-Memory geschrieben werden.
  PERFORM TAXI_SET_DOCUMENT_HEADER.

  CALL FUNCTION 'PRICING_DIALOG_TABSTRIPS'
       EXPORTING
            COMM_HEAD_I = TKOMK
            COMM_ITEM_I = TKOMP
            COMM_TEXT   = BILDTEXT
            T185_I      = T185
            T185F_I     = T185F
            T185V_I     = T185V
            TAXI_TABSTRIP_CAPTIONS_I = TAXI_TABSTRIP_CAPTIONS
            TAXI_PROGRAM_I           = TAXI_PROGRAM
            TAXI_HEADER_SUBSCREEN_I  = TAXI_HEADER_SUBSCREEN
            TAXI_GUI_PROGRAM_I       = TAXI_GUI_PROGRAM
            TAXI_GUI_STATUS_I        = TAXI_GUI_STATUS
            TAXI_GUI_TITLE_I         = TAXI_GUI_TITLE
       IMPORTING
            COMM_HEAD_E = TKOMK
            COMM_ITEM_E = TKOMP
            T185_E      = T185
            T185F_E     = T185F
            CALCULATION_TYPE = GLOBAL_PRICING_TYPE
       TABLES
            TKOMV       = XKOMV
            SVBAP       = UVBAP
       CHANGING
            TAXI_TABSTRIP_C = TAXI_TABSTRIP_HEAD.

  CALL FUNCTION 'TAXI_CONVERT_FCODE'
     EXPORTING
          FCODE_IN        = T185F-FCODE
     IMPORTING
          FCODE_OUT       = T185F-FCODE
     EXCEPTIONS
          FCODE_NOT_FOUND = 1
          OTHERS          = 2.


  IF TKOMP-FXMSG NE SPACE.
    R185D-DATALOSS = CHARX.
    KONV_GEAENDERT = CHARX.
  ENDIF.

  IF NOT GLOBAL_PRICING_TYPE IS INITIAL.
    PERFORM PREISFINDUNG_GESAMT USING GLOBAL_PRICING_TYPE.
  ENDIF.
  IF GLOBAL_PRICING_TYPE NE CHARE.
    PERFORM PREISFINDUNG_GESAMT USING CHARE.
  ENDIF.

  MODIFY TKOMK INDEX TKOMP-IX_KOMK.

  H185  = T185.
  H185F = T185F.
  H185V = T185V.
  FCODE = T185F-FCODE.

ENDFORM.