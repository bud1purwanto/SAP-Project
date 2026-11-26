*---------------------------------------------------------------------*
*       FORM CALL_DIALOG_EXPORT                                       *
*---------------------------------------------------------------------*
*       Bei Auftragsbearbeitung mit Call-Dialog werden Daten          *
*       für den anderen Rollbereich ins Memory exportiert.            *
*---------------------------------------------------------------------*
FORM CALL_DIALOG_EXPORT.

* Tabelle für Objektnummern der Positionen
  DATA: DA_OBJNR LIKE IONRB OCCURS 20 WITH HEADER LINE.

* Tabelle DA_OBJNR mit Objektnummern aus XVBAP versorgen
  LOOP AT XVBAP WHERE NOT OBJNR IS INITIAL.
    DA_OBJNR-OBJNR = XVBAP-OBJNR.
    APPEND DA_OBJNR.
  ENDLOOP.

* Tabellen werden jetzt übergeben, also ist ein Neuaufbau nicht nötig
*  loop at xkomv.
*    xkomv-ix_komt1 = 0.
*    modify xkomv.
*  endloop.

  CALL FUNCTION 'RV_REQUIREMENT_EXPORT'
       EXCEPTIONS
            OTHERS = 1.

* Übergabe der wichtigen Preisfindungstabellen
  CALL FUNCTION 'PRICING_EXPORT_TO_MEMORY'.

* Nur exportieren, wenn tatsächlich eine Objektnummer existiert
  IF NOT VBAK-OBJNR IS INITIAL.
    CALL FUNCTION 'STATUS_BUFFER_EXPORT_TO_MEMORY'
         EXPORTING
              I_MEMORY_ID = 'BSVA_VBK'.
  ENDIF.

* Nur exportieren, wenn mindestens eine Position eine Objektnummer hat
  DESCRIBE TABLE DA_OBJNR LINES SY-TABIX.
  IF SY-TABIX > 0.
    CALL FUNCTION 'STATUS_BUFFER_EXPORT_TO_MEMORY'
         EXPORTING
              I_MEMORY_ID = 'BSVA_VBP'.
  ENDIF.

  CALL FUNCTION 'ME_REQUISITION_EXP_EXT'
       EXCEPTIONS
            OTHERS = 1.

  CALL FUNCTION 'SD_VEDA_EXPORT_TO_MEMORY'
       EXCEPTIONS
            OTHERS = 1.

  CALL FUNCTION 'K_SRULE_EXPORT_IMPORT'
       EXPORTING
            I_MODE     = 'EX'
       EXCEPTIONS
            WRONG_MODE = 1.

* ZAV Memory
  CALL FUNCTION 'SD_CAM_ADDRESS_PUSH'
       IMPORTING
            FEF_MEMORY_ID = cam_memory_id.

  CALL FUNCTION 'ATP_EXTERNAL_DELTA_EXPORT'
       EXCEPTIONS
            ERROR_MESSAGE = 1.
  IF  SY-SUBRC EQ 1
  AND SUPPRESS_AV_DIALOG EQ SPACE
  AND SY-BATCH EQ SPACE.
    MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  PERFORM KORRELATION_LFGKO_EXPORT IN PROGRAM SAPFV45V.

ENDFORM.