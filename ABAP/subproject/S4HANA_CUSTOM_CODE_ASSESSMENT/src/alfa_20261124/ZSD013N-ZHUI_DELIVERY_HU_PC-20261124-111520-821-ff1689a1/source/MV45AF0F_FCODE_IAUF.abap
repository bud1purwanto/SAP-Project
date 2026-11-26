*---------------------------------------------------------------------*
*       FORM FCODE_IAUF                                               *
*---------------------------------------------------------------------*
*       Anzeige Auftraggeber                                          *
*---------------------------------------------------------------------*
FORM FCODE_IAUF.

  DATA: DA_AUSWAHL(80) VALUE '110310'.

  PERFORM PARTNER_ANZEIGEN USING 'AG'
                                 DA_AUSWAHL.

ENDFORM.