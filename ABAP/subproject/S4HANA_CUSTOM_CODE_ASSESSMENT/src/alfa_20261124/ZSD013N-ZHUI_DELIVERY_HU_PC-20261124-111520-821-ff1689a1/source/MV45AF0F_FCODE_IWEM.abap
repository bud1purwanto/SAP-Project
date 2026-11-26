*---------------------------------------------------------------------*
*       FORM FCODE_IWEM                                               *
*---------------------------------------------------------------------*
*       Anzeige Warenempfänger                                        *
*---------------------------------------------------------------------*
FORM FCODE_IWEM.

  DATA: DA_AUSWAHL(80) VALUE '110120315330340'.

  PERFORM PARTNER_ANZEIGEN USING 'WE'
                                 DA_AUSWAHL.

ENDFORM.