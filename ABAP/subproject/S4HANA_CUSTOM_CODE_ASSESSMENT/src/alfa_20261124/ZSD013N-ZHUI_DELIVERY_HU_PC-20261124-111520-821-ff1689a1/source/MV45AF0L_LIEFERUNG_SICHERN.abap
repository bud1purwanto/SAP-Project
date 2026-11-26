*---------------------------------------------------------------------*
*       FORM LIEFERUNG_SICHERN                                        *
*---------------------------------------------------------------------*
*       Nach der Nummernvergabe für den Auftrag wird die Sofort-      *
*       lieferung gesichert. Dabei wird die Nummer des Auftrags       *
*       an die Lieferung übergeben                                    *
*---------------------------------------------------------------------*
FORM LIEFERUNG_SICHERN CHANGING CH_VBELN
                                CH_SUBRC.
  FIELD-SYMBOLS: <FS>.
  DATA: TEXT(30).


ENHANCEMENT-SECTION     LIEFERUNG_SICHERN_01 SPOTS ES_SAPMV45A.
  CALL FUNCTION 'RV_DELIVERY_CREATE_SINGLE_POST'
       EXPORTING
            LVBAK_VBELN_NEW             = VBAK-VBELN
            LVBAK_VBELN_OLD             = *VBAK-VBELN
            LVBAK_VBTYP                 = VBAK-VBTYP
            IF_DO_FINAL_CHECK           = SPACE                "n_788275
       EXCEPTIONS
            NO_DELIVERY_CREATED         = 1
            MULTIPLE_DELIVERIES_CREATED = 2.
END-ENHANCEMENT-SECTION.

  IF SY-SUBRC = 0.
    TEXT = '(SAPLV50S)XLIKP-VBELN'.
    ASSIGN (TEXT) TO <FS>.
    CH_VBELN = <FS>.
  ENDIF.
  CH_SUBRC = SY-SUBRC.
ENDFORM.