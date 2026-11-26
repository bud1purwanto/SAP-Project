*---------------------------------------------------------------------*
*       FORM FCODE_IREG                                               *
*---------------------------------------------------------------------*
*       Anzeige Regulierer                                            *
*---------------------------------------------------------------------*
FORM FCODE_IREG.

  DATA: DA_AUSWAHL(80) VALUE '110130320'.

  PERFORM PARTNER_ANZEIGEN USING 'RG'
                                 DA_AUSWAHL.

ENDFORM.