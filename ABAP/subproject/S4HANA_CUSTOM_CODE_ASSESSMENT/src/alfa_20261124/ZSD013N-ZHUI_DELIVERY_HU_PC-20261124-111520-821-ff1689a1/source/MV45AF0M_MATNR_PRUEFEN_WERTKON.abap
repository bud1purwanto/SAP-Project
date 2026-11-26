*&---------------------------------------------------------------------*
*&      Form  MATNR_PRUEFEN_WERTKONTRAKT
*&---------------------------------------------------------------------*
*       Prüft, ob ein Material im gegebenen Sortiment existiert oder
*       einer gegebenen Produkthierarchie angehört
*       Sortiment in RV45A-SKOPF, Produkthierarchie in RV45A-PRODH
*----------------------------------------------------------------------*
FORM MATNR_PRUEFEN_WERTKONTRAKT USING    US_ERROR
                                CHANGING US_SUBRC.

* Übergabetabelle für Materialien aus Sortiment
  DATA: BEGIN OF DA_WSOP_READ OCCURS 1.
          INCLUDE STRUCTURE WSOP.
  DATA: END OF DA_WSOP_READ.
* Übergabestruktur zur Definition des auszulesenden Sortiments
  DATA: BEGIN OF DA_WSOP_INPUT.
          INCLUDE STRUCTURE WSOP.
  DATA: END OF DA_WSOP_INPUT.
  DATA: DA_TVAK LIKE TVAK.

* Bei Löschen des Materials nach Fehler nicht weiterlaufen
  CHECK NOT VBAP-MATNR IS INITIAL.

  CLEAR US_SUBRC.

* Prüfung auf Existenz des Materials im Vertiebsbereich und Lesen
* des Artikelkurztextes
  PERFORM MAAPV_SELECT(SAPFV45P) USING VBAP-MATNR
                                       VBAK-VKORG
                                       VBAK-VTWEG
                                       US_ERROR
                                       SY-SUBRC.

* Nur akzeptieren, wenn Material für Vertriebsbereich vorgesehen ist
  IF SY-SUBRC = 0.
    PERFORM VBAP_FUELLEN_MAAPV(SAPFV45P).
* Hat Sparte aus Kopf Vorrang?
    VBAP-SPART = VBAK-SPART.
    SELECT SINGLE * FROM TVAK INTO DA_TVAK WHERE AUART = TVCPA-AUARN.
    IF DA_TVAK-SPAPO NE SPACE AND
       MAAPV-SPART NE SPACE.
      VBAP-SPART = MAAPV-SPART.
    ENDIF.
* Artikelkurztext wird nicht mehr in VBAP_FUELLEN_MAAPV gefüllt
    VBAP-ARKTX = MAAPV-ARKTX.
* Wenn keine Sparte gefunden wird, Sparte aus Wertkontraktposition
    IF VBAP-SPART IS INITIAL.
      VBAP-SPART = RV45A-SPART.
    ENDIF.

    PERFORM VBAP_UMRECHNUNGSFAKTOREN(SAPFV45P) USING SY-SUBRC.
    IF TVAP-ETERL = SPACE.             " Zielmengeneinheit
      IF SY-SUBRC = 2 OR
         SY-SUBRC = 3.
        IF NOT US_ERROR IS INITIAL.
          MESSAGE E742 WITH VBAP-MATNR VBAP-ZIEME.
        ENDIF.
      ENDIF.
    ELSE.                              " Verkaufsmengeneinheit
      IF SY-SUBRC = 1 OR
         SY-SUBRC = 2.
        IF NOT US_ERROR IS INITIAL.
          MESSAGE E742 WITH VBAP-MATNR VBAP-VRKME.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

* Ist ein Sortiment oder eine Produkthierarchie vorhanden?
  CHECK: ( NOT RV45A-SKOPF IS INITIAL OR
           NOT RV45A-PRODH IS INITIAL ),
         US_SUBRC = 0.

  US_SUBRC = '-1'.                 "Kennzeichen: Negativ = ohne Prüfung

* 1. Schritt: prüfen auf Sortiment
  IF NOT RV45A-SKOPF IS INITIAL.

    DA_WSOP_INPUT-MANDT = SY-MANDT.
    DA_WSOP_INPUT-SKOPF = RV45A-SKOPF.
    DA_WSOP_INPUT-SPOSI = VBAP-MATNR.

* Sortiment auslesen
    CALL FUNCTION 'WSOP_READ_WSOP'
         EXPORTING
              DATUM         = SY-DATLO
              WSOP          = DA_WSOP_INPUT
         TABLES
              WSOP_INPUT    = DA_WSOP_READ
         EXCEPTIONS
              NO_REC_FOUND  = 1
              NO_REC_ACTIVE = 1.

    US_SUBRC = SY-SUBRC.

  ENDIF.

* 2. Schritt: Prüfen auf Produkthierarchie
* Nur wenn im Sortiment nichts gefunden wurde
  IF NOT RV45A-PRODH IS INITIAL AND
     US_SUBRC NE 0.

    PERFORM MATNR_PRUEFEN_PRODH USING RV45A-PRODH
                                      VBAP-PRODH
                                      SY-SUBRC.
*   Keine Übereinstimmung bei Produkthierarchie
    IF SY-SUBRC > 0.
      IF US_SUBRC EQ -1.               "Ohne vorgegebenes Sortiment
        US_SUBRC = 2.
      ELSE.
        US_SUBRC = 3.
      ENDIF.
    ELSE.
      US_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

  IF NOT US_ERROR IS INITIAL.
    CASE US_SUBRC.
      WHEN 1.
        MESSAGE E655 WITH VBAP-MATNR RV45A-SKOPF.
      WHEN 2.
        MESSAGE E656 WITH VBAP-MATNR RV45A-PRODH.
      WHEN 3.
        MESSAGE E657 WITH VBAP-MATNR RV45A-SKOPF RV45A-PRODH.
    ENDCASE.
  ENDIF.

ENDFORM.                               " MATNR_PRUEFEN_WERTKONTRAKT