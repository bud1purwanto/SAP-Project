*---------------------------------------------------------------------*
*       FORM FCODE_IREM                                               *
*---------------------------------------------------------------------*
*       Anzeige Rechnungsempfänger Kopf                               *
*---------------------------------------------------------------------*
FORM FCODE_IREM.

  DATA: DA_AUSWAHL(80) VALUE '110'.

  PERFORM PARTNER_ANZEIGEN USING 'RE'
                                 DA_AUSWAHL.

ENDFORM.