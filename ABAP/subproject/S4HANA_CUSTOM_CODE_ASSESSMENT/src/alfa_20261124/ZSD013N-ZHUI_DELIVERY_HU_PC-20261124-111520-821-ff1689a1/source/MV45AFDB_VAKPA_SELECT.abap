*&---------------------------------------------------------------------*
*&      Form  VAKPA_SELECT
*&---------------------------------------------------------------------*
*       Lesen von vorangegangenen Verkaufsbelegen zu einem Auftrag-   *
*       geber. Vorangegangene Verkaufsbelege können Angebote oder     *
*       Kontrakte sein. Wird ein solcher Verkaufsbeleg gefunden und   *
*       ist er noch nicht vollständig bearbeitet, wird ein Schalter   *
*       gesetzt und die Verarbeitung verlassen.
*---------------------------------------------------------------------*
FORM VAKPA_SELECT USING US_KUNDE
                        US_PARVW
                        US_VKORG
                        US_TRVOG
                        US_VTWEG
                        US_SPART
                        US_KUNNR
                        CH_HEADER_EXIST.

  SELECT * FROM VAKPA_REF WHERE KUNDE = US_KUNDE AND
                                PARVW = US_PARVW AND
                                VKORG = US_VKORG AND
                                VTWEG = US_VTWEG AND
                                SPART = US_SPART AND
                                TRVOG = US_TRVOG AND
                                KUNNR = US_KUNNR AND
                                VBTYP NE VBTYP_GRUKO AND
                              ( GBSTK = ' ' OR
                                GBSTK = 'A' OR
                                GBSTK = 'B' ).

* Gültigkeitszeitraum prüfen
    CHECK ( VAKPA_REF-DATAB <= VBAK-VDATU AND
            VAKPA_REF-DATBI >= VBAK-VDATU ) OR
            VBAK-VDATU IS INITIAL.

*   Liste füllen
    IF SY-SUBRC EQ 0.
      CH_HEADER_EXIST = CHARX.
      HNW_VBAK-VBELN = VAKPA_REF-VBELN.
      HNW_VBAK-DATAB = VAKPA_REF-DATAB.
      HNW_VBAK-DATBI = VAKPA_REF-DATBI.
      HNW_VBAK-TRVOG = VAKPA_REF-TRVOG.
      HNW_VBAK-AUART = VAKPA_REF-AUART.
      APPEND HNW_VBAK.
    ENDIF.
  ENDSELECT.

ENDFORM.