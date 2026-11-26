*---------------------------------------------------------------------*
*       FORM VBELN_UEBERNEHMEN                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM VBELN_UEBERNEHMEN.

DATA: DA_SERIAL_COMMIT TYPE C.

  CHECK NOT VBAK-VBELN IS INITIAL.

  LOOP AT XVBAP.
    XVBAP-VBELN = VBAK-VBELN.
    IF XVBAP-VBELV IS INITIAL AND
       NOT XVBAP-POSNV IS INITIAL.
       XVBAP-VBELV = VBAK-VBELN.
    ENDIF.
    MODIFY XVBAP.
  ENDLOOP.

  LOOP AT XVBEP.
    XVBEP-VBELN = VBAK-VBELN.
    MODIFY XVBEP.
  ENDLOOP.

  LOOP AT XVBSN.
    XVBSN-VBELN = VBAK-VBELN.
    MODIFY XVBSN.
  ENDLOOP.

  LOOP AT XVBFA WHERE VBELN IS INITIAL.
    XVBFA-VBELN = VBAK-VBELN.
    MODIFY XVBFA.
  ENDLOOP.
  SORT XVBFA BY MANDT VBELV POSNV VBELN POSNN VBTYP_N.

  VBKD-VBELN = VBAK-VBELN.
  LOOP AT XVBKD.
    XVBKD-VBELN = VBAK-VBELN.
    MODIFY XVBKD.
  ENDLOOP.

  LOOP AT XVBPA.
    XVBPA-VBELN = VBAK-VBELN.
    MODIFY XVBPA.
  ENDLOOP.

  LOOP AT XVBUK.
    IF XVBUK-VBELN IS INITIAL.
      XVBUK-VBELN = VBAK-VBELN.
      MODIFY XVBUK.
    ENDIF.
  ENDLOOP.

  SORT XVBUK BY MANDT
                VBELN.

  LOOP AT XVBUP.
    IF XVBUP-VBELN IS INITIAL.
      XVBUP-VBELN = VBAK-VBELN.
      MODIFY XVBUP.
    ENDIF.
  ENDLOOP.

  SORT XVBUP BY MANDT
                VBELN
                POSNR.

  LOOP AT XVBUV.
    XVBUV-VBELN = VBAK-VBELN.
    MODIFY XVBUV.
  ENDLOOP.

* Texte
  CALL FUNCTION 'SD_EXTERNAL_NUMBER'
       EXPORTING
            FI_VBELN = VBAK-VBELN
       TABLES
            XTHEAD   = XTHEAD.

* Korrektur der Bedarfssätze
  CALL FUNCTION 'RV_REQUIREMENT_CORRECT'
       EXPORTING
            BELEGNUMMER = VBAK-VBELN
       TABLES
            AVBBD       = AVBBD.
* Dokumentenzuordnung
  PERFORM DOKUMENTE_UMBENENNEN.
* Lieferabrufe
  CALL FUNCTION 'SD_XVBLB_RENAME'
       EXPORTING
            DOCUMENT_NUMBER = VBAK-VBELN.

* Vertragsdaten
  MOVE VBAK-VBELN TO VEDA-VBELN.
  CALL FUNCTION 'SD_XVEDA_RENUMBER'
       EXPORTING
            I_DOCUMENT_NUMBER = VEDA-VBELN.

* Vertragsnummer an Preisvereinbarung Konditionssätze geben
  IF NOT TVAK-VTERL IS INITIAL.
    CALL FUNCTION 'RV_CONDITION_FIELD_CHANGE'
         EXPORTING
              NAME_OF_FIELD       = 'VBELN'
              NEW_VALUE           = VBAK-VBELN
              OLD_VALUE           = '$TEMP'
              NO_NEW_CONTEXT      = 'X'
         EXCEPTIONS
              OLD_VALUE_NOT_FOUND = 01
              UNKNOWN_FIELD       = 02.
  ENDIF.

DATA: DA_VBELN LIKE VBAK-VBELN.

* Gegebenenfalls mit Belegnummer '$' arbeiten
  IF *VBAK-VBELN IS INITIAL.
    DA_VBELN = CHAR$.
  ELSE.
    DA_VBELN = *VBAK-VBELN.
  ENDIF.

* Serialnummern aktualisieren
* 2 Aufrufe für Serialnummern --> ohne Einteilungen und mit Einteilungen
  CALL FUNCTION 'SERIALPROFILE_CHECK'
       EXPORTING
            OPERATION = VRGNG_SDR3
            DOC_OLD   = DA_VBELN
            DOC_NEW   = VBAK-VBELN
       IMPORTING
            SERIAL_COMMIT = DA_SERIAL_COMMIT.

  IF NOT DA_SERIAL_COMMIT IS INITIAL.
    SERIAL_DATALOSS = DA_SERIAL_COMMIT.
  ENDIF.

  CALL FUNCTION 'IWOL_WV_SWITCH_NUMBER'
       EXPORTING
            OLD_SDAUFNR    = *VBAK-VBELN
            NEW_SDAUFNR    = VBAK-VBELN
       EXCEPTIONS
            NO_OBJECT_LIST = 1.

* Exportkontrolldaten aktualisieren: korrekte VBELN einfuegen
  IF NOT ( TVAK-EXCOK = SPACE ).

    CALL FUNCTION 'RV_EXPORT_XVBEX_RENAME'
         EXPORTING
              DOCUMENT_NUMBER = VBAK-VBELN
         TABLES
              I_XVBEX         = XVBEX.

  ENDIF.

* Advanced Returns - create and update Customer RMA to buffer
  FIELD-SYMBOLS <lfs_xvbap> TYPE VBAPVB.
  IF gr_msr_sales IS BOUND.
    gr_msr_sales->exchange_document_number( iv_vbeln = vbak-vbeln ).
    LOOP AT XVBAP ASSIGNING <lfs_xvbap>.
      gr_msr_sales->create_customer_rma(
        EXPORTING
          is_xvbap          = <lfs_xvbap>
          is_vbak           = vbak ).
   ENDLOOP.
  ENDIF.

* LOGIC
  perform beleg_rename_logic.

ENDFORM.