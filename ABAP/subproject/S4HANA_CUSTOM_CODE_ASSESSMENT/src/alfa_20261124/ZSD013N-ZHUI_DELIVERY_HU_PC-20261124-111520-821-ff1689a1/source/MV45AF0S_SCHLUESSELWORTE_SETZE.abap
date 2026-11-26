*---------------------------------------------------------------------*
*       FORM SCHLUESSELWORTE_SETZEN                                   *
*---------------------------------------------------------------------*
*       Dynamisches setzen bestimmter Schlüsselwörter gemass          *
*       titel für Dialogpopup: "Auftragsbearb. beenden, wollen Sie    *
*                                                       wirklich ?"   *
*       Auftragsart                                                   *
*---------------------------------------------------------------------*
FORM SCHLUESSELWORTE_SETZEN USING US_TRVOG.

  RV45A-TXT_ANGDT = TEXT-034.
  RV45A-TXT_BNDDT = TEXT-035.
  CASE US_TRVOG.
    WHEN CHAR0.
*                                      "Auftrag
      R185D-TITEL     = TEXT-010.
      RV45A-TXT_AUART = TEXT-011.
      RV45A-TXT_VBELN = TEXT-012.
    WHEN CHAR1.
*                                      "Anfrage
      R185D-TITEL     = TEXT-020.
      RV45A-TXT_AUART = TEXT-021.
      RV45A-TXT_VBELN = TEXT-022.
      RV45A-TXT_ANGDT = TEXT-024.
      RV45A-TXT_BNDDT = TEXT-025.
    WHEN CHAR2.
*                                      "Angebot
      R185D-TITEL     = TEXT-030.
      RV45A-TXT_AUART = TEXT-031.
      RV45A-TXT_VBELN = TEXT-032.
    WHEN CHAR3.
*                                      "Lieferplan
      R185D-TITEL     = TEXT-040.
      RV45A-TXT_AUART = TEXT-041.
      RV45A-TXT_VBELN = TEXT-042.
    WHEN CHAR4.
*                                      "Kontrakt
      R185D-TITEL     = TEXT-050.
      RV45A-TXT_AUART = TEXT-051.
      RV45A-TXT_VBELN = TEXT-052.
    WHEN CHAR5.
*                                      "Sortimente
      R185D-TITEL     = TEXT-060.
      RV45A-TXT_AUART = TEXT-061.
      RV45A-TXT_VBELN = TEXT-062.
    WHEN CHARB.
*                                      "Bedarfsplanerfassu
      R185D-TITEL     = TEXT-070.
      RV45A-TXT_AUART = TEXT-071.
      RV45A-TXT_VBELN = TEXT-072.
    WHEN OTHERS.
      RV45A-TXT_AUART = TEXT-008.
      RV45A-TXT_VBELN = TEXT-009.
  ENDCASE.
  IF NOT TVAKT-BEZEI IS INITIAL AND
     SY-DYNGR NE 'ANFO'.
    RV45A-TXT_VBELN = TVAKT-BEZEI.
  ENDIF.

ENDFORM.