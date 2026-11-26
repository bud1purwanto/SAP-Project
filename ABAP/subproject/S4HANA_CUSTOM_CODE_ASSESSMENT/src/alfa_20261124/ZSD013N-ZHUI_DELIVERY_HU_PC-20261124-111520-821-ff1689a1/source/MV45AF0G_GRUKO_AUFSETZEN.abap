*&---------------------------------------------------------------------*
*&      Form  GRUKO_AUFSETZEN
*&---------------------------------------------------------------------*
*       Auf den aktuellen Gruppenkontrakt referenzierte Belege
*       lesen um diese im Tablecontrol anzuzeigen
*----------------------------------------------------------------------*
FORM GRUKO_AUFSETZEN.

  LOCAL: VBAK.
  DATA: DA_VBELN LIKE VBAK-VBELN.

  DESCRIBE TABLE GRUKO LINES SY-TFILL.
  CHECK: SY-TFILL EQ 0.

  DA_VBELN = VBAK-VBELN.

* GRUKO aus Belegfluß füllen
  LOOP AT XVBFA.
    GRUKO-VBELN = XVBFA-VBELN.
    SELECT SINGLE * FROM VBAK WHERE VBELN = GRUKO-VBELN.
    IF SY-SUBRC EQ 0 AND
       NOT VBAK-VBELN_GRP IS INITIAL AND  " Referenz im UK eingetragen
       VBAK-VBELN_GRP EQ DA_VBELN.        " Referenz passt zu akt. GK
      MOVE-CORRESPONDING VBAK TO GRUKO.
      APPEND GRUKO.
    ELSE.
      " When a subcontract in XVBFA does not exist in VBAK
      " let it be looked for in archive. If not found, nothing happens.
      IF cl_ops_switch_check=>sd_sfws_sc4( ) EQ abap_true AND
         data_read_from_archive EQ abap_true.
        DATA: LT_VBAK LIKE VBAK OCCURS 0 WITH HEADER LINE,
              L_BORIDENT LIKE BORIDENT.
        FIELD-SYMBOLS: <LS_VBAK> LIKE LINE OF LT_VBAK,
                       <LS_GRUKO> LIKE LINE OF GRUKO.
        L_BORIDENT-OBJKEY = XVBFA-VBELN.
        CALL FUNCTION 'ASH_SD_VBAK_READ'
          EXPORTING
           I_BORIDENT                   = L_BORIDENT
          TABLES
           ET_VBAK                      = LT_VBAK
          EXCEPTIONS
           NOT_IN_INFOSTRUCTURE         = 1
           NOT_IN_ARCHIVE               = 2
           NO_INSTRUCTURE_DEFINED       = 3
           OTHERS                       = 4.
        " found in archive.
        IF SY-SUBRC EQ 0.
          LOOP AT LT_VBAK ASSIGNING <LS_VBAK> WHERE VBELN_GRP EQ DA_VBELN.
            APPEND INITIAL LINE TO GRUKO ASSIGNING <LS_GRUKO>.
            MOVE-CORRESPONDING <LS_VBAK> TO <LS_GRUKO>.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " GRUKO_AUFSETZEN