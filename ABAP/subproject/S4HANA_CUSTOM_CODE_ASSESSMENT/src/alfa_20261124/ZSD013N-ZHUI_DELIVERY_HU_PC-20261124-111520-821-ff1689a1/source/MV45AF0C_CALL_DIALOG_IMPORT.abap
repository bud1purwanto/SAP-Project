*---------------------------------------------------------------------*
*       FORM CALL_DIALOG_IMPORT                                       *
*---------------------------------------------------------------------*
*       Bei Auftragsbearbeitung mit Call-Dialog werden Daten          *
*       für den anderen Rollbereich aus dem Memory importiert         *
*---------------------------------------------------------------------*
FORM CALL_DIALOG_IMPORT.

* Tabelle für Objektnummern der Positionen
  DATA: DA_OBJNR LIKE IONRB OCCURS 20 WITH HEADER LINE.

* Tabelle DA_OBJNR mit Objektnummern aus XVBAP versorgen
  LOOP AT XVBAP WHERE NOT OBJNR IS INITIAL.
    DA_OBJNR-OBJNR = XVBAP-OBJNR.
    APPEND DA_OBJNR.
  ENDLOOP.

* Informationen werden übergeben, also nicht neu ermitteln
*  loop at xkomv.
*    xkomv-ix_komt1 = 0.
*    modify xkomv.
*  endloop.

  CALL FUNCTION 'RV_REQUIREMENT_IMPORT'
       EXCEPTIONS
            OTHERS = 1.

* Zurückgeben der Preisfindungsinformationen
  CALL FUNCTION 'PRICING_IMPORT_FROM_MEMORY'
     EXCEPTIONS
          IMPORT_ERROR = 1.

* Nur exportieren, wenn tatsächlich eine Objektnummer existiert
  IF NOT VBAK-OBJNR IS INITIAL.
    CALL FUNCTION 'STATUS_BUFFER_IMPORT_FROM_MEMO'
         EXPORTING
              I_MEMORY_ID = 'BSVA_VBK'
              I_OBJNR     = VBAK-OBJNR.
  ENDIF.

* Nur exportieren, wenn mindestens eine Position eine Objektnummer hat
  DESCRIBE TABLE DA_OBJNR LINES SY-TABIX.
  IF SY-TABIX > 0.
    CALL FUNCTION 'STATUS_BUFFER_IMPORT_FROM_MEMO'
         EXPORTING
              I_MEMORY_ID = 'BSVA_VBP'
         TABLES
              T_OBJNR     = DA_OBJNR.
  ENDIF.

  CALL FUNCTION 'ME_REQUISITION_IMP_EXT'
       EXCEPTIONS
            OTHERS = 1.

  CALL FUNCTION 'SD_VEDA_IMPORT_FROM_MEMORY'
       EXCEPTIONS
            OTHERS = 1.

  CALL FUNCTION 'K_SRULE_EXPORT_IMPORT'
       EXPORTING
            I_MODE     = 'IM'
       EXCEPTIONS
            WRONG_MODE = 1.

* ZAV Memory
  CALL FUNCTION 'SD_CAM_ADDRESS_POP'.

  CALL FUNCTION 'ATP_EXTERNAL_DELTA_IMPORT'
       EXCEPTIONS
            ERROR_MESSAGE = 1.
  IF  SY-SUBRC EQ 1
  AND SUPPRESS_AV_DIALOG EQ SPACE
  AND SY-BATCH EQ SPACE.
    MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  PERFORM KORRELATION_LFGKO_IMPORT IN PROGRAM SAPFV45V.

ENDFORM.