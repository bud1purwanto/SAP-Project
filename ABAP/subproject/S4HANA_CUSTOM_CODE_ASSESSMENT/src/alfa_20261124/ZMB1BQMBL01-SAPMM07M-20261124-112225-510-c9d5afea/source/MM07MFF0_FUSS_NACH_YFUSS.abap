*eject
*---------------------------------------------------------------------*
*       FORM FUSS_NACH_YFUSS                                          *
*---------------------------------------------------------------------*
*       Die interne Tabelle YFUSS wird aus den FUSS-Daten gefüllt.    *
*       Sollte bei einer der Positionen ein Fehler auftreten, wird    *
*       nur die interne Tabelle YFUSS zurückgesetzt.                  *
*---------------------------------------------------------------------*
FORM fuss_nach_yfuss.

  yfuss = fuss.
  APPEND yfuss.
  CLEAR fuss.

ENDFORM.