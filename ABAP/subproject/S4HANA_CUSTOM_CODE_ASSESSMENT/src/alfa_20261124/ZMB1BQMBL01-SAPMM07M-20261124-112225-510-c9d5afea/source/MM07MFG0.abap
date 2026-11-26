*---------------------------------------------------------------------*
*       FORM GRUND_PRUEFEN                                            *
*---------------------------------------------------------------------*
*       Die Tabellen T157D und T157E werden gelesen. Voraussetzung    *
*       ist, daß in der Tabelle T156 das Kennzeichen KZGRU ungleich   *
*       '-' ist und in dem Feld MSEG-GRUND etwas eingegeben wurde.    *
*---------------------------------------------------------------------*
FORM GRUND_PRUEFEN.
  CLEAR DM07M-GRTXT.
  IF T158-TRTYP = H.
    IF NOT XMBWL IS INITIAL.
      IF DM07M-KZGRU = '+' AND MSEG-GRUND IS INITIAL.
        MESSAGE E325 WITH MSEG-BWART.
      ENDIF.
* For reversal postings via BAPI_GOODMVT_CANCEL clear the      "n1673355
* reason for movement copied from the original document        "n1673355
* if the field is normally suppressed.                         "n1673355
      IF NOT XBAPI IS INITIAL AND NOT XCANC IS INITIAL         "n1673355
        AND DM07M-KZGRU = '-' AND NOT MSEG-GRUND IS INITIAL.   "n1673355
         CLEAR MSEG-GRUND.                                     "n1673355
      ENDIF.                                                   "n1673355
     CHECK NOT MSEG-GRUND IS INITIAL.
    ENDIF.
    SELECT SINGLE * FROM T157D WHERE BWART = MSEG-BWART
                               AND   GRUND = MSEG-GRUND.
    IF NOT SY-SUBRC IS INITIAL.
      SET CURSOR FIELD 'MSEG-GRUND'.
      PERFORM WRONG_INPUT(SAPFM07M) USING 'MSEG' 'GRUND' MSEG-GRUND E.
    ENDIF.
  ENDIF.
  SELECT SINGLE * FROM T157E WHERE SPRAS = SY-LANGU
                             AND   BWART = MSEG-BWART
                             AND   GRUND = MSEG-GRUND.
  IF SY-SUBRC IS INITIAL.
    DM07M-GRTXT = T157E-GRTXT.
  ELSE.
    CLEAR DM07M-GRTXT.
    IF T158-TRTYP = H.
      MESSAGE W001 WITH '157E' SY-LANGU MSEG-BWART MSEG-GRUND.
    ENDIF.
  ENDIF.
ENDFORM.
*eject
*&---------------------------------------------------------------------*
*&      Form  GET_FIELD
*&---------------------------------------------------------------------*
*       Feldbezeichner (mittel) aus DDIC holen
*----------------------------------------------------------------------*
FORM GET_FIELD USING    P_TAB   LIKE DCOBJDEF-NAME
                        P_FIELD LIKE DFIES-FIELDNAME
                        P_TEXT  LIKE DFIES-SCRTEXT_M.
    DATA: DFIES LIKE DFIES OCCURS 0 WITH HEADER LINE.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
         EXPORTING
              TABNAME   = P_TAB
              FIELDNAME = P_FIELD
              LANGU     = SY-LANGU
         TABLES
              DFIES_TAB = DFIES
         EXCEPTIONS
              OTHERS    = 1.

    IF SY-SUBRC <> 0.
      CLEAR P_TEXT.
    ENDIF.
    READ TABLE DFIES INDEX 1.
    P_TEXT = DFIES-SCRTEXT_M.

ENDFORM.                    " GET_FIELD