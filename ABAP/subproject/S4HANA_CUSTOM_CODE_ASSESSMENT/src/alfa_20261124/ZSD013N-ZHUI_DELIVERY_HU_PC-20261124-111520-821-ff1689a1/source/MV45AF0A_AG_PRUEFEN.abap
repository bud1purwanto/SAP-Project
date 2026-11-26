*eject
*----------------------------------------------------------------------*
*          FORM AG_PRUEFEN                                             *
*----------------------------------------------------------------------*
* Die festen Partnerrollen des Belegkopfes: Auftraggeber,              *
* Warenempfänger und Regulierer werden geprüft.                        *
* Input: KUAGV, KUWEV, KURGV.                                          *
*----------------------------------------------------------------------*
FORM AG_PRUEFEN USING US_DIALOG
                        CHANGING VALUE(CH_SUBRC).
  LOCAL: VBAK.

  CH_SUBRC = 0.

* Auftraggeber
  IF NOT KUAGV-KUNNR IS INITIAL.
    VTCOMAG-KUNNR = KUAGV-KUNNR.
    VTCOMAG-VKORG = VBAK-VKORG.
    VTCOMAG-VTWEG = VBAK-VTWEG.
    VTCOMAG-SPART = VBAK-SPART.
    CALL FUNCTION 'VIEW_KUAG2'
         EXPORTING
              COMWA  = VTCOMAG
         IMPORTING
              AGWA   = KUAGV
         EXCEPTIONS
              OTHERS = 1.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
*   Hinweis 1558868
    IF KUAGV-KUNNR NE VBAK-KUNNR AND  "AG-Änderung
       KUAGV-WAERK NE VBAK-WAERK AND  "Abweichende Währung
       VBUK-RRSTA CA 'BC'.            "RevRec-Buchungen vorhanden
       MESSAGE ID 'V2' TYPE 'E' NUMBER 462.
    ENDIF.
    PERFORM KUAGV-TXTPA_ERMITTELN.
* Auftraggeber erlaubt ?
    PERFORM TPAER_SELECT USING TVAK-PARGR
                               'AG'
                               SPACE
                               SY-SUBRC.
    IF SY-SUBRC NE 0.
* Kein Auftraggeber erlaubt
      IF US_DIALOG NE SPACE.
        MESSAGE E375.
      ELSE.
        MESSAGE I375.
        CH_SUBRC = 375.
        EXIT.
      ENDIF.
    ENDIF.
* Echter Auftraggeber ?
    IF NOT KUAGV-KUNNR = VBAK-KUNNR AND
       NOT VBAK-KUNNR IS INITIAL AND
       NOT KUAGV-DEAR5 IS INITIAL.
      MESSAGE W829.
    ENDIF.
* Auftraggeber für Aufträge gesperrt ?
    PERFORM TVASP_SELECT USING KUAGV-KUNNR
                               KUAGV-AUFSD
                               VBAK-AUART
                               US_DIALOG
                               CH_SUBRC.
    CHECK CH_SUBRC = 0.
* Kalkulationsschema vorhanden ?
    PERFORM T683V_SELECT(SAPMV45A) USING TVAK-KALVG
                                         KUAGV-KALKS
                                         US_DIALOG
                                         CH_SUBRC.
    CHECK CH_SUBRC = 0.
    IF NOT KUAGV-KUNNR = VBAK-KUNNR AND
       NOT VBAK-KUNNR IS INITIAL.
      MOVE-CORRESPONDING KUAGV TO VBAK.
      PERFORM VBAP_MATNR_PRUEFEN_ALLE(SAPFV45P) USING US_DIALOG
                                                      CHANGING CH_SUBRC.
      IF NOT CH_SUBRC IS INITIAL AND
         US_DIALOG IS INITIAL.
        EXIT.
      ENDIF.


    ENDIF.
  ENDIF.
  IF KUAGV-KUNNR IS INITIAL OR
     KUAGV-KUNNR = '?'.
* Ist der Auftraggeber Pflicht ?
    IF FCODE NE FCODE_KOPIEREN.
      PERFORM TPAER_SELECT USING TVAK-PARGR
                                 'AG'
                                 SPACE
                                 SY-SUBRC.
      IF SY-SUBRC EQ 0 AND
         TPAER-PAPFL EQ CHARX.
* Auftraggeber ist Pflicht
        IF US_DIALOG NE SPACE.
          MESSAGE E368.
        ELSE.
          MESSAGE I368.
          CH_SUBRC = 368.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.