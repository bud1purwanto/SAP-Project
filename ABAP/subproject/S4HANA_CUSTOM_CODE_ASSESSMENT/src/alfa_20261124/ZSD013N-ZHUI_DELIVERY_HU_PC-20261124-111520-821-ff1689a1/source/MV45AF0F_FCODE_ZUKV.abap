*eject
*---------------------------------------------------------------------*
*       FORM FCODE_ZUKV                                               *
*---------------------------------------------------------------------*
*       Anzeige Kreditversicherung externe Daten                      *
*---------------------------------------------------------------------*
FORM FCODE_ZUKV    USING US_T185F
                         US_T185
                         US_T185V.

  DATA: DA_KEINE_POSITION_MARKIERT(1). "Flag

* Falls keine Position markiert wurde und kein Cursor darauf steht,
* wird von den neuen Bilder (Table Control Subscreen) ein 'D' als
* Default-Markierung zurückgegeben. Hier kennzeichnet es den Wunsch,
* den Belegfluß des Gesamtbelegs anzuzeigen.

  LOOP AT IVBAP WHERE SELKZ EQ CHARD.
    DA_KEINE_POSITION_MARKIERT = CHARX.
    IVBAP-SELKZ = ' '.
    MODIFY IVBAP.
  ENDLOOP.

  PERFORM XVBAP_BEREITSTELLEN(SAPFV45P) USING SY-SUBRC.
  IF SY-SUBRC = 4 AND DA_KEINE_POSITION_MARKIERT IS INITIAL.
    PERFORM XVBAP_MARKIEREN(SAPFV45P).
    PERFORM XVBAP_BEREITSTELLEN(SAPFV45P) USING SY-SUBRC.
  ENDIF.
  IF SY-SUBRC = 0 AND DA_KEINE_POSITION_MARKIERT IS INITIAL.
    VBAP = XVBAP.
    PERFORM IVBAP-SELKZ_RESET(SAPFV45P) USING VBAP-POSNR.

    PERFORM FCODE_ZUKV_POSITION USING US_T185F
                                      US_T185
                                      US_T185V.
  ELSE.
    PERFORM FCODE_ZUKV_KOPF USING US_T185F
                                  US_T185
                                  US_T185V.
  ENDIF.

ENDFORM.