*&---------------------------------------------------------------------*
*&      Form  FCODE_PPAR_GUI40
*&---------------------------------------------------------------------*
*       Übergang zum Positionspartnerbild via Dialogbaustein
*       Aufruf für GUI40 (Tabstrips)
*----------------------------------------------------------------------*
FORM FCODE_PPAR_GUI40 USING H185F STRUCTURE T185F
                            H185  STRUCTURE T185
                            H185V STRUCTURE T185V.

  DATA: CAM_MEMORY_ID TYPE I.

  DATA: MV45A_DATALOSS LIKE R185D-DATALOSS.
  DATA: RV02P_VBEP_ERLAUBT(1) TYPE C.
  DATA: TRANSLATED_FCODE    LIKE TAXI_PARAMS-FCODE.

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

  CLEAR: RV02P-WEUPD, RV02P-RGUPD, RV02P-SBUPD.     "P30K073015/30E

* Falls Einteilungen nicht erlaubt, betroffene FCodes/Reiter wegblenden
  IF TVAK-VBTYP CA VBTYP_OHNE_EINT_MIT_G OR
     TVAP-ETERL = ' '.
    RV02P_VBEP_ERLAUBT = ' '.              "Einteilungen nicht erlaubt
  ELSE.
    RV02P_VBEP_ERLAUBT = 'X'.              "Einteilungen erlaubt
  ENDIF.

  MV45A_DATALOSS = R185D-DATALOSS.
  CLEAR R185D-DATALOSS.

  MOVE VBAK-VBELN  TO RV02P-VBELN.         "Belegnummer
  MOVE XVBAP-POSNR TO RV02P-POSNR.         "Positionsnummer / Kopf = 0
  MOVE 'A'         TO RV02P-VBOBJ.         "Belegtyp: Auftrag
  MOVE VBAK-VKORG  TO RV02P-VKORG.         "Verkaufsorganisation
  MOVE VBAK-VTWEG  TO RV02P-VTWEG.         "Vertriebsweg
  MOVE XVBAP-SPART  TO RV02P-SPART.        "Sparte
  MOVE TVAP-PARGR  TO RV02P-PARGR.         "Partnerschema
  MOVE KUAGV-KUNNR TO RV02P-KUNAG.         "Kundennummer
  MOVE TVAKT-BEZEI TO RV02P-VBARTBEZ.
  MOVE TVAK-KLIMP TO RV02P-KLIMP.
* MOVE T001-KKBER TO RV02P-KKBER.
  MOVE VBAK-KKBER TO RV02P-KKBER.
  MOVE RV45A-TXT_VBELN TO RV02P-VTEXT.
  RV02P-AUART = VBAK-AUART.

ENHANCEMENT-POINT FCODE_PPAR_GUI40_10 SPOTS ES_SAPMV45A.
* Bei Product Selection dürfen die Partner auf der Position nicht
* geändert werden (Problem Abgleich HPOS - UPOS)
  IF XVBAP-PROSA NE SPACE OR
     XVBAP-UEPVW CA NATURALRABATT.
    CLEAR RV02P-PARGR.
  ENDIF.

* Parameter für Trägerdynpro belegen.
  IF FEHLER = 'X'.
     TAXI_GUI_STATUS      = 'FS_EXT'.      "Unvollständigskeitstatus
  ELSE.
     TAXI_GUI_STATUS      = T185V-STATUS.  "Normaler Status
  ENDIF.
  TAXI_GUI_PROGRAM        = T185V-AGIDV.   "Pool für Title/Status
  TAXI_GUI_TITLE          = T185V-CTITEL.
  TAXI_PROGRAM            = T185V-CPROG.   "Pool für Headersubscreen
  TAXI_HEADER_SUBSCREEN   = T185V-DYBS1.   "Dynpro für Headersubscreen
  TAXI_BODY_SUBSCREEN     = T185V-DYBS2.   "Dynpro für Bodysubscreen
* Tabstrip-Kontrollstruktur für Tabstrip der Positionsbilder
  TAXI_TABSTRIP           = TAXI_TABSTRIP_ITEM.

* Folgeort umsetzen für neuen Ort in der Partnerverarbeitung
  T185-PANEL  = 'PPA4'.   "Tabstripvariante zum Panel PPAR
  T185F-FCODE = 'ENT1'.   "Fcode wird von Partner selbst verarbeitet

* Wegen Rollbereichswechsel bei Call Dialog müssen zunächst die
* Felder des HeaderSubscreens zur späteren Rückübernahme in
* ABAP-Memory geschrieben werden.
  PERFORM TAXI_SET_ITEM_HEADER.

  CALL FUNCTION 'SD_CAM_ADDRESS_PUSH'
       IMPORTING
            FEF_MEMORY_ID = cam_memory_id.

  CALL DIALOG 'RV_BELEG_PARTNER_40'
       EXPORTING
            T185F
            T185
            T185V
            RV02P
            XVBPA
            YVBPA
            R185D
            KUWEV
            FCODE
            XVBUV
            XVBADR
            YVBADR
            FEHLER
            XVBPAKEY                   "11.05.95
            KUAGV
            RV02P_VBEP_ERLAUBT
            TAXI_TABSTRIP_CAPTIONS
            TAXI_TABSTRIP
            TAXI_PROGRAM
            TAXI_HEADER_SUBSCREEN
            TAXI_BODY_SUBSCREEN
            TAXI_GUI_PROGRAM
            TAXI_GUI_STATUS
            TAXI_GUI_TITLE
            CAM_MEMORY_ID
       IMPORTING
            T185F
            T185
            FCODE
            R185D
            XVBPA
            YVBPA
            XVBUV
            RV02P
            XVBADR
            YVBADR
            KUAGV-NAME1
            TAXI_TABSTRIP.

  CALL FUNCTION 'SD_CAM_ADDRESS_POP'.

  TAXI_TABSTRIP_ITEM       = TAXI_TABSTRIP.

  PERFORM VBAP_PARTNER_AENDERN(SAPFV45P) USING R185D-DATALOSS.
  IF RV02P-SBUPD NE SPACE.
    PERFORM SB_PRUEFEN_POSITION(SAPFV45V) USING XVBAP-VBELN
                                                XVBAP-POSNR.
    RV02P-SBUPD = SPACE.
  ENDIF.
*------- Außenhandel: Partnerdaten 'retten'
  CALL FUNCTION 'FT_SLS_PARTNER_ADDR_MEM_FILL'
       TABLES
           I_T_VBPAVB_PARTNER_NEW = XVBPA
           I_T_VBPAVB_PARTNER_OLD = YVBPA
           I_T_SADRVB_ADDRESS_NEW = XVBADR
           I_T_SADRVB_ADDRESS_OLD = YVBADR.

  IF MV45A_DATALOSS NE SPACE AND R185D-DATALOSS EQ SPACE.
    R185D-DATALOSS = MV45A_DATALOSS.
  ENDIF.

* Falls ermittelter Funktionscode Reiterfunktionscode, dann
* in semantischen Funktionscode übersetzen
  CALL FUNCTION 'TAXI_CONVERT_FCODE'
       EXPORTING
            FCODE_IN        = FCODE
       IMPORTING
            FCODE_OUT       = TRANSLATED_FCODE
       EXCEPTIONS
            FCODE_NOT_FOUND = 1
            OTHERS          = 2.

  IF SY-SUBRC = 0.
     T185F-FCODE = TRANSLATED_FCODE.
     FCODE       = TRANSLATED_FCODE.
  ELSE.
     T185F-FCODE = FCODE.
  ENDIF.

  H185  = T185.
  H185F = T185F.
  H185V = T185V.

ENDFORM.                    " FCODE_PPAR_GUI40