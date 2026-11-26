*----------------------------------------------------------------------*
*   INCLUDE MV45AF0W_WK_XWSOP_LESEN                                    *
*----------------------------------------------------------------------*
FORM WK_XWSOP_LESEN.

  STATICS: DA_SKOPF LIKE VBAP-SKOPF.

* Übergabetabelle für Materialien aus Sortiment
  DATA: BEGIN OF DA_WSOP_READ OCCURS 20.
          INCLUDE STRUCTURE WSOP.
  DATA: END OF DA_WSOP_READ.
* Übergabestruktur zur Definition des auszulesenden Sortiments
  DATA: BEGIN OF DA_WSOP_INPUT.
          INCLUDE STRUCTURE WSOP.
  DATA: END OF DA_WSOP_INPUT.

  IF VBAP-SKOPF IS INITIAL.
    CLEAR XWSOP.
    REFRESH XWSOP.
    EXIT.
  ENDIF.

* Nur, wenn der Inhalt von XWSOP nicht noch stimmt --> Tuning
  IF DA_SKOPF NE VBAP-SKOPF.
    REFRESH XWSOP.
    CLEAR XWSOP.

    DA_WSOP_INPUT-MANDT = SY-MANDT.
    DA_WSOP_INPUT-SKOPF = VBAP-SKOPF.

* Sortiment auslesen
    CALL FUNCTION 'WSOP_READ_WSOP'
         EXPORTING
              WSOP          = DA_WSOP_INPUT
              DATUM         = SY-DATLO
              ALL_POS       = CHARX
         TABLES
              WSOP_INPUT    = DA_WSOP_READ
         EXCEPTIONS
              NO_REC_FOUND  = 1
              NO_REC_ACTIVE = 1.

    REFRESH MATKEY.
    CLEAR MATERIAL_VORSTEP_GELAUFEN.
    LOOP AT DA_WSOP_READ.
      MATKEY-MATNR = DA_WSOP_READ-SPOSI.
      APPEND MATKEY.
    ENDLOOP.

* XWSOP versorgen
    LOOP AT DA_WSOP_READ.

* Prüfung auf Existenz des Materials im Vertiebsbereich und Lesen
* des Artikelkurztextes
      PERFORM MAAPV_SELECT(SAPFV45P) USING DA_WSOP_READ-SPOSI
                                     VBAK-VKORG
                                     VBAK-VTWEG
                                     SPACE
                                     SY-SUBRC.
* Nur übernehmen, wenn Material für Vertriebsbereich vorgesehen ist
* und lesen Materialstamm erfolgreich war.
      IF SY-SUBRC = 0 AND
         NOT MAAPV-MATNR IS INITIAL.
        MOVE-CORRESPONDING DA_WSOP_READ TO XWSOP.
        XWSOP-ARKTX = MAAPV-ARKTX.
        APPEND XWSOP.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.