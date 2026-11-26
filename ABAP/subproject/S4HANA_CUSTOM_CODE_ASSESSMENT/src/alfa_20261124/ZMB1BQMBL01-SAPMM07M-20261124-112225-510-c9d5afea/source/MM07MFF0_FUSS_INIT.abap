*eject
*---------------------------------------------------------------------*
*       FORM FUSS_INIT                                                *
*---------------------------------------------------------------------*
*       Initialisieren der internen Tabelle FUSS                      *
*---------------------------------------------------------------------*
FORM fuss_init.
  REFRESH: fuss, var_fuss.
  CLEAR fuss.
  CLEAR f_zeile.
ENDFORM.