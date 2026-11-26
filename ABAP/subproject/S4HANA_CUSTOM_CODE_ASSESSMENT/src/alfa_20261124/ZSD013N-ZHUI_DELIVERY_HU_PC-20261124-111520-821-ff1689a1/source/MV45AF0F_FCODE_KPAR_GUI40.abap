*&---------------------------------------------------------------------*
*&      Form  FCODE_KPAR_GUI40
*&---------------------------------------------------------------------*
*       Übergang zum Kopfpartnerbild via Dialogbaustein
*       Aufruf für GUI40 (Tabstrips)
*----------------------------------------------------------------------*
FORM FCODE_KPAR_GUI40 USING H185F STRUCTURE T185F
                            H185  STRUCTURE T185
                            H185V STRUCTURE T185V.

  DATA: CAM_MEMORY_ID TYPE I.

  DATA: MV45A_DATALOSS LIKE R185D-DATALOSS.
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

  MV45A_DATALOSS = R185D-DATALOSS.
  CLEAR PRF_WE.
  CLEAR R185D-DATALOSS.
  CLEAR: RV02P-WEUPD, RV02P-RGUPD, RV02P-SBUPD.
  MOVE VBAK-VBELN TO RV02P-VBELN.
  CLEAR              RV02P-POSNR.
  MOVE 'A'        TO RV02P-VBOBJ.
  MOVE VBAK-VKORG TO RV02P-VKORG.
  MOVE VBAK-VTWEG TO RV02P-VTWEG.
  MOVE VBAK-SPART TO RV02P-SPART.
  MOVE TVAK-AUART TO RV02P-AUART.
  MOVE TVAK-VBTYP TO RV02P-VBTYP.
  MOVE TVAK-KLIMP TO RV02P-KLIMP.
  MOVE VBAK-KKBER TO RV02P-KKBER.
  MOVE RV45A-TXT_VBELN TO RV02P-VTEXT.
  MOVE TVAK-PARGR TO RV02P-PARGR.
  MOVE KUAGV-KUNNR TO RV02P-KUNAG.

ENHANCEMENT-POINT FCODE_KPAR_GUI40_10 SPOTS ES_SAPMV45A.
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
* Tabstrip-Kontrollstruktur für Tabstrip der Kopfbilder
  TAXI_TABSTRIP           = TAXI_TABSTRIP_HEAD.

* Folgeort umsetzen für neuen Ort in der Partnerverarbeitung
  T185-PANEL  = 'KPA4'.   "Tabstripvariante zum Panel KPAR
  T185F-FCODE = 'ENT1'.   "Fcode wird von Partner selbst verarbeitet

* Wegen Rollbereichswechsel bei Call Dialog müssen zunächst die
* Felder des HeaderSubscreens zur späteren Rückübernahme in
* ABAP-Memory geschrieben werden.
  PERFORM TAXI_SET_DOCUMENT_HEADER.

  CALL FUNCTION 'SD_CAM_ADDRESS_PUSH'
       IMPORTING
            FEF_MEMORY_ID = cam_memory_id.

  if fcode(1) ne 'W'.
    CALL DIALOG 'RV_BELEG_PARTNER_40'
         EXPORTING
              T185F
              T185
              T185V
              RV02P
              XVBPA
              YVBPA
              KUWEV
              XVBUV
              XVBADR
              YVBADR
              FEHLER
              XVBPAKEY
              KUAGV
              R185D
              TAXI_TABSTRIP_CAPTIONS
              TAXI_TABSTRIP
              TAXI_PROGRAM
              TAXI_HEADER_SUBSCREEN
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
              XVBADR
              YVBADR
              RV02P
              KUAGV-NAME1
              TAXI_TABSTRIP.

  ELSE.
    CALL DIALOG 'RV_BELEG_PARTNER_DETAIL'
         EXPORTING
              T185F
              T185
              T185V
              RV02P
              XVBPA
              YVBPA
              KUWEV
              XVBUV
              XVBADR
              YVBADR
              FEHLER
              XVBPAKEY
              KUAGV
              R185D
              CAM_MEMORY_ID
         IMPORTING
              T185F
              T185
              FCODE
              R185D
              XVBPA
              YVBPA
              XVBUV
              XVBADR
              YVBADR
              RV02P
              KUAGV-NAME1.
  ENDIF.

  CALL FUNCTION 'SD_CAM_ADDRESS_POP'.

  TAXI_TABSTRIP_HEAD       = TAXI_TABSTRIP.

  PERFORM VBAK_PARTNER_AENDERN(SAPFV45K) USING SPACE.

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

  H185 = T185.
  H185F = T185F.
  H185V = T185V.

ENDFORM.                    " FCODE_KPAR_GUI40